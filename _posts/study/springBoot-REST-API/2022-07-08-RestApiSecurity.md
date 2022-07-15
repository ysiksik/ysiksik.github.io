---
layout: post
bigtitle: 'Spring Boot 기반 REST API 개발'
subtitle: REST API 보안 적용
date: '2022-07-08 00:00:00 +0900'
categories:
    - study
    - springBoot-REST-API
tags: RestAPI
comments: true
---

# REST API 보안 적용

# REST API 보안 적용
* toc
{:toc}


## 스프링 Security

+ 스프링 Security 란?
  + 스프링 Security는 스프링 기반의 어플리케이션 보안(인증과 권한)을 담당하는 프레임워크이다.
  + 보안관련 용어
    + 접근 주체(Principal) : 보호된 대상에 접근하는 user
    + 인증(Authenticate) : 현재 user가 누구인지 확인, 애플리케이션의 작업을 수행할 수 있는 주체임을 증명한다.
    + 인가(Authorize) : 현재 user가 어떤 서비스, 페이지에 접근할 수 있는 권한이 있는지 검사
  + 스프링 시큐리티가 제공하는 기능
    + 웹 시큐리티 (Filter 기반 시큐리티)
    + 메소도 시큐리티
    + 두가지 방법 모두 Security Interceptor을 사용한다.
      + 리소스에 접근을 허용할 것이냐 말 것 이냐를 결정하는 로직이 들어 있다.
+ 스프링 Security : 인증관련 Architecture
<div class="language-mermaid">
graph LR;
    Http_Request--1-->AuthenticationFilter;
    AuthenticationFilter--2-->UsernamePasswordAuthenticationToken;
    AuthenticationFilter--3--> AuthenticationManager_interface;
    AuthenticationManager_interface--4-->AuthenticationProvider;
    ProviderManager--implements-->AuthenticationManager_interface;    
    AuthenticationProvider--5-->UserDetailsService;
    UserDetailsService--6-->UserDetails_interface;
    User--implements-->UserDetails_interface;
    UserDetailsService--7-->AuthenticationProvider;
    AuthenticationProvider--8-->AuthenticationManager_interface;
    AuthenticationManager_interface--9-->AuthenticationFilter;
    AuthenticationFilter--10--> SecurityContextHolder_SecurityContext_Authentication;
</div>

1. 사용자가 Form을 통해 로그인 정보를 입혁하고 인증 요청을 보낸다.
2. UsernamePasswordAuthenticationFilter가 사용자가 보낸 아이디와 패스워드를 인터셉트한다.
HttpServletRequest에서 꺼내온 사용자 아이디와 패스워드를 진짜 인증을 담당할 AuthenticationManager 인터페이스(구현체 - ProviderManager)에게 인증용 객체(UsernamePasswordAuthenticationToken)로 만들어줘서 위임한다.
3. AuthenticationFilter에게 인증용 객체(UsernamePasswordAuthenticationFilter)을 전달받는다.
4. 실제 인증일 할 AuthenticaionProvider에게 Authentication객체(UsernamePasswordAuthenticationFilter)을 다시 전달한다.
5. DB에서 사용자 인증 정보를 가져올 UserDetailsService 객체에게 사용자 아이디를 넘겨주고 DB에서 인증에 사용할 사용자 정보(사용자 아이디, 암호화된 패스워드, 권한 등)를 UserDetails라는 객체로 전달 받는다.
6. AuthenticationProvider는 UserDetails 객체를 전달 받은 이후 실제 사용자의 입력정보와 UserDetails 객체를 가지고 인증을 시도한다.
7. 7,8,9,10 인증이 완료되면 사용자 정보를 가진 Authentication 객체를 SecurityContextHolder에 담은 이후 AuthenticationSuccessHandler를 실행한다.(실패시 AuthenticationFailureHandler를 실행한다.)

+ UserDetailsService 구현
  + loadUserByUsername 메소드를 오버라이딩 해야 한다.
    + 권한을 저장하기 위해서는 "사용자 권한" 이라는 문자열 값을 SimpleGrantedAuthority의 생성자 파라미터로 넣어 주면 권한 객체가 생성 된다.

    ~~~java
     public UserDetails loadUserByUsername (String username) throws UsernameNotFoundException {
              Account account = accountRepository.findByEmail(username).orElseThrow(() -> new UsernameNotFoundException(username));
              return new User(account.getEmail(), account.getPassword(), authorities(account.getRoles()));
          }
    private Collection<? extends GrantedAuthority> authorities (Set < AccountRole > roles) {
              return roles.stream().map(role -> new SimpleGrantedAuthority(role.name())).collect(Collectors.toSet());
          }
    ~~~
  
  + 이 메서드에서 DB에 있는 Username 값을 체크한다.

+ PasswordEncoder Bean 등록
  + 스프링 시큐리티에서 제공하는 PasswordEncoder는 사용자가 등록한 비밀번호를 단방향으로 변환하여 저장하는 용도로 사용된다.
  + PasswordEncoderFactories.createDelagatingPasswordEncoder()로 생성한 PasswordEncoder는 BCryptPasswordEncoder가 사용되며 앞에 {id}로 PasswordEncoder 유형이 정의된다.

  ~~~java
  @Configuration
  public class AppConfig {
      @Bean
      public PasswordEncoder passwordEncoder() {
          return PasswordEncoderFactories.createDelegatingPasswordEncoder();
      }
  }
  ~~~

+ Security Customizing
  + Spring MVC 웹 보안을 활성화 하기 위한 설정
    + @EnableWebSecurity 어노테이션은 웹 보안을 활성화 한다.
    + 이 주석을 @Configuration 클래스에 추가하여 모든 웹 보안 구성자에 스프링 보안 구성을 정의하도록 한다.
    + WebSebSecurityConfigurerAdapter를 확장한 Bean으로 설정 해야 한다.
  
    ~~~java
    @Configuration
    @EnableWebSecurity
    public class SecurityConfig extends WebSecurityConfigurerAdapter {
    }
    ~~~
  
    + .anonymous() : 익명 사용자 사용 활성화.
    + .formLogin() : Form 인증 방식 확성화, 스프링 시큐리티가 제공하는 기본 로그인 페이지
    + .authorizeRequests() : 요청에 인증 적용
    + .mvcMatchers(GET, "/api/**").permitAll() : /api 이하 모든 GET 요청에 인증은 필요 없음
    + .anyRequest().authenticated() : 그 밖의 모든 요청(POST)는 인증이 필요하다.

    ~~~java
    @Override protected void configure (HttpSecurity http) throws Exception {
      http.anonymous().and().formLogin().and().authorizeRequests().mvcMatchers(HttpMethod.GET, "/api/**").permitAll().anyRequest().authenticated();
    }
    ~~~

## OAuth 2.0

+ OAuth란?
  + OAuth는 인증을 위한 오픈 스탠더드 프로토콜로, 사용자가 Facebook이나 트위터 같은 인터넷 서비스의 기능을 다른 애플리케이션(데스크톱, 웹, 모바일 등)에서도 사용할 수 있게 한 것이다.
  + 2010년 IETF (국제인터넷표준화기구) OAuth 워킹 그룹에 의해 IETF 표준 프로토콜로 발표된다.
  + OAuth 1.0 특징
    + API 인증 시, 써드파티 어플리케이션에게 사용자의 비번을 노출하지 않고 인증 할 수 있다.
    + 인증(Authentication)과 API 권한(Authorization) 부여를 동시에 할 수 있다.
  + 인증 토큰의 장점
    + 사용자의 아이디 / 패스워드를 몰라도 토큰을 통해 허가 받은 API에 접근 가능
    + 필요한 API에만 제한적으로 접근할 수 있도록 권한 제어 가능
    + 저장되어 있는 인증 토큰이 유출 되더라도 트위터의 관리자 화면에서 인증 토큰의 권한 취소 가능
    + 사용자가 트위터(Service Provider)의 패스워드를 변경해도 인증 토큰은 계속 유효함
  + [List of OAuth Provider](https://en.wikipedia.org/wiki/List_of_OAuth_providers)
+ OAuth 2.0의 개선사항
  + 일단 OAuth 2.0은 1.0과 호환되지 않으며 용어 부터 많은 것이 다르다. 모바일에서의 사용성 문제나 서명과 같은 개발이 복잡하고 기능과 규모의 확장성 등을 지원하기 위해 만들어진 표준이다. 표준이 매우 크고 복잡해서 
  이름도 "OAuth 인증 프레임워크(OAuth 2.0 Authorization Framework)"이다 [http://tools.ietf.org/wg/oauth/](http://tools.ietf.org/wg/oauth/) 에서 확인 가능
  + OAuth 2.0 용어들
    + Resource Owner : 사용자(User)
    + Resource Server : REST API 서버
    + Authorization Server : 인증서버 (API 서버와 같을 수도 있음.), Access Token 발행
    + Client : 써드파티 어플리케이션(서비스)
  + 더 많은 인증 방법을 지원
    + OAuth 2.0은 여러 인증 방식을 통해 웹 / 모바일 등 다양한 시나리오에 대응 가능
    + Access Token의 Life-time을 지정하여 만료 시간 설정 가능
+ OAuth 2.0의 다양한 인증 방식(Grant types)
  + Client는 기본적으로 Confidential Client 와 Public Client로 나누어진다.
    + Confidential Client는 웹 서버가 API를 호출하는 경우와 같이 client 증명서(client_secret)를 안전하게 보관할 수 있는 Client를 의미한다.
    + Public Client는 브라우저 기반 어플리케이션이나 모바일 어플리케이션 같이 client 증명서를 안전하게 보관할 수 없는 client를 의미하는데 이런 경우 redirect_uri를 통해서 client를 인증한다.
  1. Authorization Code Grant : used with server-side applications(서버 측 응용 프로그램과 함께 사용)
     + 웹 서버에서 API를 호출하는 등의 시나리오에서 Confidential Client가 사용하는 방식이다. 
     + 서버 사이드 코드가 필요한 인증 방식이며 인증 과정에서 client_secret이 필요하다.
  2. Implicit Grant : used with Moblie App or Web app(Moblie 앱 또는 웹 앱과 함께 사용)
     + Token과 scope에 대한 스펙 등은 다르지만 Oauth 1.0a과 가장 비슷한 인증방식이다. 
     + Public Client인 브라우저 기반의 어플리케이션(Javascript application)이나 모바일 어플리케이션에서 이 방식을 사용하면 된다. Client 증명서를 사용할 필요가 없으며 실제로 Oauth 2.0에서 많이 사용되는 방식이다.
  3. Password Credentials Grant : used with trusted application(신뢰할 수 있는 응용 프로그램과 함께 사용)
     + Client에 아이디/패스워드를 저장해 놓고 아이디/패스워드로 직접 access token을 받아오는 방식이다.
     + Client를 믿을 수 없을 때 사용하기에는 위험하므로 API 서비스의 공식 어플리케이션이나 믿을 수 있는 Client에 한해서만 사용하는 것을 추천한다.
  4. Client Credentials Grant : used with application api access(응용 프로그램 API 액세스와 함께 사용)
     + 어플리케이션이 Confidential Client일 때 id와 secret을 가지고 인증하는 방식이다.
     + 로그인 시에 API에 POST로 grant_type=client_credentials 라고 넘긴다.
+ 다양한 Token 지원
  + Access Token
    + OAuth 2.0은 기본적으로 Bearer 토큰, 즉 암호화 하지 않은 그냥 토큰을 주고받는 것으로 인증을 한다. 
    + 기본적으로 HTTPS를 사용하기 때문에 토큰을 안전하게 주고 받는 것은 HTTPS의 암호화에 의존한다.
    + 또한 복잡한 signature 등을 생성할 필요가 없기 때문에 curl이 API를 호출 할 때 간단하게 Header에 아래와 같이 한 줄을 같이 보내어 API를 테스트해 볼 수 있다
      + Authorization: Bearer
  + Refresh Token
    + 클라이언트가 같은 access token을 오래 사용하면 결국에 해킹에 노출될 위험이 높아진다. 그래서 OAuth 2.0에서는 refresh token 이라는 개념을 도입했다.
    + 인증 토큰(access token)의 만료기간을 가능한 짧게 하고 만료가 되면 refresh token으로 access token을 새로 갱신하는 방법이다.
+ Authorization Server
  + OAuth의 목표 : "인증 토큰을 발행하고, 발행된 인증 토큰을 사용하여 API를 호출하는 것"
  + 중요한 두가지 어노테이션 : @EnableAuthorizationServer 와 @EnableResourceServer
    + @EnableAuthorizationServer는 토큰을 발행하고, 발행된 토큰을 검증하는 역활
    + @EnableResourceServer는 발행된 토큰을 사용해 API를 호출할 때 권한을 검증하는 필터 같은 역할
  
    ~~~java
    @Configuration
    @EnableAuthorizationServer
    public class AuthServerConfig extends AuthorizationServerConfigurerAdapter {
    @Autowired
    PasswordEncoder passwordEncoder;
    
        // OAuth2 인증 서버 보안(Password) 정보를 설정
        @Override
        public void configure(AuthorizationServerSecurityConfigurer security)
                throws Exception {
            security.passwordEncoder(passwordEncoder);
        }
    }    
    ~~~
    + configure(ClientDetailsServiceConfigurer clients) 메서드 : API의 요청 클라이언트 정보
    + inMemory()는 클라이언트 정보를 메모리에 저장한다. 개발 환경에 적합하다.
    + withClient()는 client_id 값을 설정한다.
    + secret()은 client_secret 값을 설정한다.
    + authorizedGrantTypes()은 grant_type 값을 설정한다. 복수개 저장할 수 있다.
    + accessTokenValiditySeconds()은 access_token의 만료 시간을 설정한다.
    + refreshTokenValiditySeconds()은 refresh_token의 만료 시간을 설정한다.
  
    ~~~java
    @Override
    public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
      clients.inMemory().withClient("myApp")
       .authorizedGrantTypes("password", "refresh_token")
       .scopes("read", "write")
       .secret(this.passwordEncoder.encode("pass"))
       .accessTokenValiditySeconds(10 * 60)
       .refreshTokenValiditySeconds(6 * 10 * 60);
      }   
    ~~~

    + Grant Type : Password
      + Grant Type : 토큰 받아오는 방법
      + 서비스 오너가 만든 클라이언트에서 사용하는 Grant Type
      + [https://developer.okta.com/blog/2018/06/29/what-is-the-oauth2-password-grant](https://developer.okta.com/blog/2018/06/29/what-is-the-oauth2-password-grant)
  + Security Customizing
    + 클라이언트와 토큰 관리는 Spring Security OAuth 모듈이 담당하지만, 사용자 관리는 Spring Security의 몫이다.
  
    ~~~java
    @Configuration
    @EnableWebSecurity
    public class SecurityConfig extends WebSecurityConfigurerAdapter {
      @Autowired
      AccountService accountService;
      @Autowired
      PasswordEncoder passwordEncoder;
    }
    ~~~
    + TokenStore에 토큰을 저장한다.
      + org.springframework.security.oauth2.provider.store.InmemoryTokenStore는 Map, Queue 구조의 메모리를 사용하는 저장소 이다.
    + AuthenticationManager를 노출시키고 싶으면.
      + WebSecurityConfigurerAdapter.authenticationManagerBean() 메서드를 오버라이드 하고 Bean 으로 등룩 후에 사용 해야 한다.
      
    ~~~java
    @Bean
    public TokenStore tokenStore() {
      return new InMemoryTokenStore();
    }
    @Bean
    @Override
    public AuthenticationManager authenticationManagerBean() throws Exception {
      return super.authenticationManagerBean();
    }
    ~~~
    + AuthenticationManagerBuiler
      + AuthenticationManagerBuilder를 통해 인증 객체를 만들 수 있도록 제공하고 있다.
      
    ~~~java
    @Override 
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
     auth.userDetailsService(accountService).passwordEncoder(passwordEncoder); 
    }
    ~~~
    + configure(AuthorizationServerEndpointsConfigurer endpoints) 메서드 : 인증 서버 Endpoint 설정
    + 인증 정보를 알고 있는 AuthenticationManager를 설정하고, UserDetailsService와 TokenStore를 설정한다.

    ~~~java
    @Autowired AuthenticationManager authenticationManager;
    @Autowired 
    AccountService accountService;
    @Autowired 
    TokenStore tokenStore;
    
    @Override 
    public void configure(AuthorizationServerEndpointsConfigurer endpoints)throws Exception {
            endpoints.authenticationManager(authenticationManager)
                    .userDetailsService(accountService)
                    .tokenStore(tokenStore);
    }
    ~~~
    
  + Resource Server
    + @EnableResourceServer는 발행된 토큰을 사용해 API를 호출할 때 권한을 검증하는 필터 같은 역할
    
    ~~~java
    @Configuration
    @EnableResourceServer
    public class ResourceServerConfig extends ResourceServerConfigurerAdapter {
      @Override
      public void configure(ResourceServerSecurityConfigurer resources) throws Exception {
        resources.resourceId("event");
      }
    
      @Override
      public void configure(HttpSecurity http) throws Exception {
        http.anonymous()
        .and()
        .authorizeRequests()
          .mvcMatchers(HttpMethod.GET, "/api/**").permitAll()
          .anyRequest().authenticated()
          .and()
        .exceptionHandling()
          .accessDeniedHandler(new OAuth2AccessDeniedHandler());
      }
    }
    ~~~
  
  + 외부 설정
    + @ConfigurationProperties 어노테이션을 통한 외부 설정값 주입
      + @ConfigurationProperties 프로퍼티 파일의 값을 받은 클래스를 하나 생성하여 그클래스를 @Autowired 같은 어노테이션을 통해 자동 주입하는 방법이 type-safe 하며, 유지보수 측면에서 더 좋은 장점을 가진다.
      + Property 클래스를 작성하면 여러 프로퍼티 묶어서 읽어올 수 있다.
      + Property 클래스를 Bean으로 등록해서 다른 Bean에 주입할 수 있다.
      + application.properties 에 똑같은 key값을 가진 property가 많은 경우에 프로퍼티 클래스를 작성 할 수 있다. 
    + @ConfigurationProperties 어노테이션을 사용하려면 META 정보를 생성 해주는 spring-boot-configuration-processor 의존성 설치 해야한다.
  + @AuthenticationPrincipal
    + 로그인한 사용자의 정보를 아규먼트로 받을 수 있다.
    + @AuthenticationPrincipal 어노테이션을 사용하면 UserDetailsService에서 Return 한 객체를 아규먼트로 직접 받아 사용할 수 있다.
    + AccountAdapter에 저장된 Account를 가져오기 위해서 accountAdapter.getAccount()를 사용해도 되지만 SPEL(Spring Expression Language)을 사용하여 가져오 올 수 있다.
      + @AuthenticationPrincipal(expression = "account")
  + 새로운 @CurrentUser 어노테이션 정의하기
    + @Target - 어노테이션이 적용할 위치를 결정한다. ( java.lang.annotation.Target )
    + @Retention - 어떤 시점까지 어노테이션이 영향을 미치는지 결정한다. ( java.lang.annotation.Retention ) 
    + 현재 인증 정보가 anonymousUser 인 경우에는 null을 보내고 아니면 “account”를 꺼내준다.
      + @AuthenticationPrincipal(expression = "#this == 'anonymousUser' ? null : account")
  + @JsonSerialize
    + 커스텀 Serialize를 지정 할 때 사용한다.
    + @JsonSerialize 은 엔터티를 마샬링할 때 사용할 사용정 직렬화기를 나타냅니다.
      