-- MySQL 8.4 / InnoDB. Apply only to an empty auth-service schema.
-- All application timestamps are UTC. No cross-service foreign keys.

CREATE TABLE members (
    id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    status VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT chk_members_status CHECK (status IN ('ACTIVE', 'DISABLED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE social_identities (
    id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    member_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    provider VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    identity_scope VARBINARY(255) NOT NULL,
    subject VARBINARY(255) NOT NULL,
    linked_at DATETIME(6) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_social_identity (provider, identity_scope, subject),
    KEY ix_social_member (member_id),
    CONSTRAINT fk_social_member FOREIGN KEY (member_id) REFERENCES members (id),
    CONSTRAINT chk_social_identity CHECK (OCTET_LENGTH(identity_scope) > 0 AND OCTET_LENGTH(subject) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE member_phone_bindings (
    member_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    phone_fingerprint BINARY(32) NOT NULL,
    verified_at DATETIME(6) NOT NULL,
    PRIMARY KEY (member_id),
    UNIQUE KEY uq_phone_fingerprint (phone_fingerprint),
    CONSTRAINT fk_phone_binding_member FOREIGN KEY (member_id) REFERENCES members (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE auth_flows (
    id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    browser_digest BINARY(32) NOT NULL,
    provider VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    identity_scope VARBINARY(255) NOT NULL,
    subject VARBINARY(255) NOT NULL,
    status VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    phone_generation INT UNSIGNED NOT NULL DEFAULT 0,
    target_member_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    reauth_identity_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    reauthenticated_at DATETIME(6) NULL,
    created_at DATETIME(6) NOT NULL,
    expires_at DATETIME(6) NOT NULL,
    finished_at DATETIME(6) NULL,
    PRIMARY KEY (id),
    KEY ix_auth_flow_expiry (expires_at),
    CONSTRAINT fk_auth_flow_target FOREIGN KEY (target_member_id) REFERENCES members (id),
    CONSTRAINT fk_auth_flow_reauth_identity FOREIGN KEY (reauth_identity_id) REFERENCES social_identities (id),
    CONSTRAINT chk_auth_flow_status CHECK (status IN (
        'PHONE_REQUIRED', 'SIGNUP_READY', 'LINK_OFFERED', 'REAUTH_REQUIRED', 'LINK_READY', 'COMPLETED', 'CANCELLED'
    )),
    CONSTRAINT chk_auth_flow_finish CHECK (
        (status IN ('COMPLETED', 'CANCELLED') AND finished_at IS NOT NULL) OR
        (status NOT IN ('COMPLETED', 'CANCELLED') AND finished_at IS NULL)
    ),
    CONSTRAINT chk_auth_flow_reauth CHECK (
        (status <> 'LINK_READY' OR (
            target_member_id IS NOT NULL AND reauth_identity_id IS NOT NULL AND reauthenticated_at IS NOT NULL
        )) AND
        (status NOT IN ('LINK_OFFERED', 'REAUTH_REQUIRED') OR target_member_id IS NOT NULL)
    ),
    CONSTRAINT chk_auth_flow_lifetime CHECK (expires_at > created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE oauth_attempts (
    state_digest BINARY(32) NOT NULL,
    browser_digest BINARY(32) NOT NULL,
    flow_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    flow_phone_generation INT UNSIGNED NULL,
    provider VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    purpose VARCHAR(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    nonce_digest BINARY(32) NULL,
    pkce_verifier_envelope VARBINARY(512) NULL,
    created_at DATETIME(6) NOT NULL,
    expires_at DATETIME(6) NOT NULL,
    claimed_at DATETIME(6) NULL,
    PRIMARY KEY (state_digest),
    KEY ix_oauth_attempt_expiry (expires_at),
    CONSTRAINT fk_oauth_attempt_flow FOREIGN KEY (flow_id) REFERENCES auth_flows (id),
    CONSTRAINT chk_oauth_attempt_purpose CHECK (
        (purpose = 'LOGIN' AND flow_id IS NULL AND flow_phone_generation IS NULL) OR
        (purpose = 'LINK_REAUTH' AND flow_id IS NOT NULL AND
            flow_phone_generation IS NOT NULL AND flow_phone_generation > 0)
    ),
    CONSTRAINT chk_oauth_attempt_lifetime CHECK (expires_at > created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE phone_verification_challenges (
    id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    flow_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    generation INT UNSIGNED NOT NULL,
    phone_fingerprint BINARY(32) NOT NULL,
    phone_envelope VARBINARY(512) NULL,
    check_count SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    last_checked_at DATETIME(6) NULL,
    created_at DATETIME(6) NOT NULL,
    expires_at DATETIME(6) NOT NULL,
    verified_at DATETIME(6) NULL,
    consumed_at DATETIME(6) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_phone_challenge_generation (flow_id, generation),
    KEY ix_phone_challenge_expiry (expires_at),
    CONSTRAINT fk_phone_challenge_flow FOREIGN KEY (flow_id) REFERENCES auth_flows (id),
    CONSTRAINT chk_phone_challenge_generation CHECK (generation > 0),
    CONSTRAINT chk_phone_challenge_lifetime CHECK (expires_at > created_at),
    CONSTRAINT chk_phone_challenge_consumed CHECK (consumed_at IS NULL OR verified_at IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE member_agreement_acceptances (
    member_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    document_code VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    document_version VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    accepted_at DATETIME(6) NOT NULL,
    PRIMARY KEY (member_id, document_code, document_version),
    CONSTRAINT fk_agreement_member FOREIGN KEY (member_id) REFERENCES members (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE account_link_audits (
    id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    flow_ref CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    member_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    social_identity_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    outcome VARCHAR(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    reason_code VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    created_at DATETIME(6) NOT NULL,
    PRIMARY KEY (id),
    KEY ix_link_audit_flow (flow_ref, created_at),
    CONSTRAINT fk_link_audit_member FOREIGN KEY (member_id) REFERENCES members (id),
    CONSTRAINT fk_link_audit_social FOREIGN KEY (social_identity_id) REFERENCES social_identities (id),
    CONSTRAINT chk_link_audit_outcome CHECK (
        (outcome = 'LINKED' AND member_id IS NOT NULL AND social_identity_id IS NOT NULL) OR
        (outcome IN ('DECLINED', 'REJECTED') AND social_identity_id IS NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE auth_sessions (
    id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    member_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    created_at DATETIME(6) NOT NULL,
    expires_at DATETIME(6) NOT NULL,
    revoked_at DATETIME(6) NULL,
    PRIMARY KEY (id),
    KEY ix_auth_session_member (member_id, revoked_at),
    KEY ix_auth_session_expiry (expires_at),
    CONSTRAINT fk_auth_session_member FOREIGN KEY (member_id) REFERENCES members (id),
    CONSTRAINT chk_auth_session_lifetime CHECK (expires_at > created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE auth_refresh_tokens (
    token_digest BINARY(32) NOT NULL,
    session_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    issued_at DATETIME(6) NOT NULL,
    expires_at DATETIME(6) NOT NULL,
    rotated_at DATETIME(6) NULL,
    PRIMARY KEY (token_digest),
    KEY ix_refresh_token_session (session_id),
    KEY ix_refresh_token_expiry (expires_at),
    CONSTRAINT fk_refresh_token_session FOREIGN KEY (session_id) REFERENCES auth_sessions (id),
    CONSTRAINT chk_refresh_token_lifetime CHECK (expires_at > issued_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
