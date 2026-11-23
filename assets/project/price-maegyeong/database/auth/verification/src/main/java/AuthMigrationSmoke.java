import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.UUID;
import java.util.concurrent.CyclicBarrier;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import com.mysql.cj.jdbc.AbandonedConnectionCleanupThread;
import org.flywaydb.core.Flyway;

public final class AuthMigrationSmoke {
    private static final String NOW = "UTC_TIMESTAMP(6)";
    private static final String LATER = "UTC_TIMESTAMP(6) + INTERVAL 5 MINUTE";

    public static void main(String[] args) throws Exception {
        try {
            run();
        } finally {
            AbandonedConnectionCleanupThread.checkedShutdown();
        }
    }

    private static void run() throws Exception {
        var url = env("PM_AUTH_JDBC_URL");
        require(url.matches("jdbc:mysql://127\\.0\\.0\\.1:[0-9]{1,5}/pm_auth_smoke_[0-9a-f]{12}"),
                "Expected a loopback database named pm_auth_smoke_<12 lowercase hex characters>");

        try (var db = connect()) {
            require(count(db, "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE()") == 0,
                    "Refusing to write to a nonempty database");
            System.out.println("MySQL: " + db.getMetaData().getDatabaseProductVersion());
        }

        var migrations = Path.of(env("PM_AUTH_MIGRATIONS")).toAbsolutePath().normalize();
        var flyway = Flyway.configure()
                .dataSource(url, env("PM_AUTH_DB_USER"), System.getenv("PM_AUTH_DB_PASSWORD"))
                .locations("filesystem:" + migrations)
                .cleanDisabled(true)
                .load();
        require(flyway.migrate().migrationsExecuted == 1, "Expected exactly one migration");
        flyway.validate();
        require(flyway.migrate().migrationsExecuted == 0, "Second migrate must be a no-op");

        try (var db = connect()) {
            require(count(db, """
                    SELECT COUNT(*) FROM information_schema.tables
                    WHERE table_schema = DATABASE() AND table_name <> 'flyway_schema_history'
                    """) == 10, "Expected ten Auth tables");
            checkPhoneRace(db);
            checkSocialIdentityAndReauth(db);
            checkPhoneChallengeAndCallback(db);
        }
        flyway.validate();
        System.out.println("PASS: V1 migration, second migrate, validation, and Auth database constraints");
    }

    private static void checkPhoneRace(Connection observer) throws Exception {
        var barrier = new CyclicBarrier(2);
        var pool = Executors.newFixedThreadPool(2);
        try {
            var first = pool.submit(() -> tryBindPhone(barrier));
            var second = pool.submit(() -> tryBindPhone(barrier));
            require(first.get(20, TimeUnit.SECONDS) != second.get(20, TimeUnit.SECONDS),
                    "Exactly one signup transaction must commit");
        } finally {
            pool.shutdownNow();
        }
        require(count(observer, "SELECT COUNT(*) FROM members") == 1, "Losing signup left a member row");
        require(count(observer, "SELECT COUNT(*) FROM member_phone_bindings") == 1, "Duplicate phone binding");
        System.out.println("PASS: competing phone bindings allow one commit and one full rollback");
    }

    private static boolean tryBindPhone(CyclicBarrier barrier) throws Exception {
        try (var db = connect()) {
            db.setAutoCommit(false);
            var member = addMember(db);
            barrier.await(10, TimeUnit.SECONDS);
            try {
                change(db, "INSERT INTO member_phone_bindings VALUES (?, UNHEX(REPEAT('ab', 32)), " + NOW + ")", member);
                db.commit();
                return true;
            } catch (SQLException e) {
                db.rollback();
                if (e.getErrorCode() != 1062) throw e;
                return false;
            }
        }
    }

    private static void checkSocialIdentityAndReauth(Connection db) throws SQLException {
        var member = addMember(db);
        var other = addMember(db);
        var firstIdentity = id();
        var insert = "INSERT INTO social_identities VALUES (?, ?, ?, 'test-app', 'test-subject', " + NOW + ")";
        change(db, insert, firstIdentity, member, "KAKAO");
        expect(1062, () -> change(db, insert, id(), other, "KAKAO"));
        change(db, insert, id(), member, "GOOGLE");
        expect(1452, () -> change(db, insert, id(), id(), "NAVER"));

        var flow = addFlow(db);
        expect(3819, () -> change(db,
                "UPDATE auth_flows SET status = 'LINK_READY', target_member_id = ? WHERE id = ?", member, flow));
        change(db, "UPDATE auth_flows SET status = 'LINK_READY', target_member_id = ?, reauth_identity_id = ?,"
                + " reauthenticated_at = " + NOW + " WHERE id = ?", member, firstIdentity, flow);
        System.out.println("PASS: social identity uniqueness, member FK, required link reauth fields");
    }

    private static void checkPhoneChallengeAndCallback(Connection db) throws SQLException {
        var flow = addFlow(db);
        var challenge = id();
        var insert = "INSERT INTO phone_verification_challenges"
                + " (id, flow_id, generation, phone_fingerprint, created_at, expires_at)"
                + " VALUES (?, ?, 1, UNHEX(REPEAT('ab', 32)), " + NOW + ", " + LATER + ")";
        change(db, insert, challenge, flow);
        expect(1062, () -> change(db, insert, id(), flow));
        expect(3819, () -> change(db,
                "UPDATE phone_verification_challenges SET consumed_at = " + NOW + " WHERE id = ?", challenge));

        var linkAttempt = "INSERT INTO oauth_attempts (state_digest, browser_digest, provider, purpose, flow_id,"
                + " flow_phone_generation, created_at, expires_at) VALUES (UNHEX(REPEAT('12', 32)),"
                + " UNHEX(REPEAT('ef', 32)), 'KAKAO', 'LINK_REAUTH', ?, %s, " + NOW + ", " + LATER + ")";
        expect(3819, () -> change(db, linkAttempt.formatted("NULL"), flow));
        change(db, linkAttempt.formatted("1"), flow);

        change(db, "INSERT INTO oauth_attempts (state_digest, browser_digest, provider, purpose, created_at, expires_at)"
                + " VALUES (UNHEX(REPEAT('cd', 32)), UNHEX(REPEAT('ef', 32)), 'KAKAO', 'LOGIN', " + NOW + ", " + LATER + ")");
        var claim = "UPDATE oauth_attempts SET claimed_at = " + NOW
                + " WHERE state_digest = UNHEX(REPEAT('cd', 32)) AND claimed_at IS NULL";
        require(change(db, claim) == 1 && change(db, claim) == 0, "OAuth state claim must be one-shot");
        System.out.println("PASS: unique challenge generation, proof before consumption, version-bound reauth and one-shot claim");
    }

    private static String addMember(Connection db) throws SQLException {
        var id = id();
        change(db, "INSERT INTO members VALUES (?, 'ACTIVE', " + NOW + ", " + NOW + ")", id);
        return id;
    }

    private static String addFlow(Connection db) throws SQLException {
        var id = id();
        change(db, "INSERT INTO auth_flows"
                + " (id, browser_digest, provider, identity_scope, subject, status, created_at, expires_at)"
                + " VALUES (?, UNHEX(REPEAT('ef', 32)), 'KAKAO', 'test-app', 'pending-subject', 'PHONE_REQUIRED', "
                + NOW + ", " + LATER + ")", id);
        return id;
    }

    private static Connection connect() throws SQLException {
        return DriverManager.getConnection(env("PM_AUTH_JDBC_URL"), env("PM_AUTH_DB_USER"),
                System.getenv("PM_AUTH_DB_PASSWORD"));
    }

    private static int change(Connection db, String sql, String... args) throws SQLException {
        try (var statement = db.prepareStatement(sql)) {
            for (int i = 0; i < args.length; i++) statement.setString(i + 1, args[i]);
            return statement.executeUpdate();
        }
    }

    private static int count(Connection db, String sql) throws SQLException {
        try (var statement = db.createStatement(); var rows = statement.executeQuery(sql)) {
            require(rows.next(), "Missing count row");
            return rows.getInt(1);
        }
    }

    private static void expect(int errorCode, SqlAction action) throws SQLException {
        try {
            action.run();
        } catch (SQLException e) {
            if (e.getErrorCode() != errorCode) throw e;
            return;
        }
        throw new AssertionError("Expected MySQL error " + errorCode);
    }

    private static String env(String name) {
        var value = System.getenv(name);
        require(value != null && !value.isBlank(), "Missing " + name);
        return value;
    }

    private static String id() {
        return UUID.randomUUID().toString();
    }

    private static void require(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
    }

    @FunctionalInterface
    private interface SqlAction {
        void run() throws SQLException;
    }
}
