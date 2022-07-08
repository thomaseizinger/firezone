# In this file, we load configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.

import Config

alias FzCommon.{CLI, FzInteger, FzString}

# external_url is important
external_url = System.get_env("EXTERNAL_URL", "http://localhost:4000")

# Enable Forwarded headers, e.g 'X-FORWARDED-HOST'
proxy_forwarded = FzString.to_boolean(System.get_env("PROXY_FORWARDED") || "false")

%{host: host, path: path, port: port, scheme: scheme} = URI.parse(external_url)

config :fz_http, FzHttpWeb.Endpoint,
  url: [host: host, scheme: scheme, port: port, path: path],
  check_origin: ["//127.0.0.1", "//localhost", "//#{host}"],
  proxy_forwarded: proxy_forwarded

# Formerly releases.exs - Only evaluated in production
if config_env() == :prod do
  # For releases, require that all these are set
  database_name = System.fetch_env!("DATABASE_NAME")
  database_user = System.fetch_env!("DATABASE_USER")
  database_host = System.fetch_env!("DATABASE_HOST")
  database_port = String.to_integer(System.fetch_env!("DATABASE_PORT"))
  database_pool = String.to_integer(System.fetch_env!("DATABASE_POOL"))
  database_ssl = FzString.to_boolean(System.fetch_env!("DATABASE_SSL"))
  database_ssl_opts = Jason.decode!(System.fetch_env!("DATABASE_SSL_OPTS"))
  database_parameters = Jason.decode!(System.fetch_env!("DATABASE_PARAMETERS"))
  phoenix_listen_address = System.fetch_env!("PHOENIX_LISTEN_ADDRESS")
  phoenix_port = String.to_integer(System.fetch_env!("PHOENIX_PORT"))
  admin_email = System.fetch_env!("ADMIN_EMAIL")
  default_admin_password = System.fetch_env!("DEFAULT_ADMIN_PASSWORD")
  wireguard_private_key_path = System.fetch_env!("WIREGUARD_PRIVATE_KEY_PATH")
  wireguard_interface_name = System.fetch_env!("WIREGUARD_INTERFACE_NAME")
  wireguard_port = String.to_integer(System.fetch_env!("WIREGUARD_PORT"))
  nft_path = System.fetch_env!("NFT_PATH")
  egress_interface = System.fetch_env!("EGRESS_INTERFACE")
  wireguard_dns = System.get_env("WIREGUARD_DNS")
  wireguard_allowed_ips = System.fetch_env!("WIREGUARD_ALLOWED_IPS")
  wireguard_persistent_keepalive = System.fetch_env!("WIREGUARD_PERSISTENT_KEEPALIVE")
  wireguard_ipv4_enabled = FzString.to_boolean(System.fetch_env!("WIREGUARD_IPV4_ENABLED"))
  wireguard_ipv4_masquerade = FzString.to_boolean(System.fetch_env!("WIREGUARD_IPV4_MASQUERADE"))
  wireguard_ipv6_masquerade = FzString.to_boolean(System.fetch_env!("WIREGUARD_IPV6_MASQUERADE"))
  wireguard_ipv4_network = System.fetch_env!("WIREGUARD_IPV4_NETWORK")
  wireguard_ipv4_address = System.fetch_env!("WIREGUARD_IPV4_ADDRESS")
  wireguard_ipv6_enabled = FzString.to_boolean(System.fetch_env!("WIREGUARD_IPV6_ENABLED"))
  wireguard_ipv6_network = System.fetch_env!("WIREGUARD_IPV6_NETWORK")
  wireguard_ipv6_address = System.fetch_env!("WIREGUARD_IPV6_ADDRESS")
  wireguard_mtu = System.fetch_env!("WIREGUARD_MTU")
  wireguard_endpoint = System.fetch_env!("WIREGUARD_ENDPOINT")
  telemetry_enabled = FzString.to_boolean(System.fetch_env!("TELEMETRY_ENABLED"))
  telemetry_id = System.fetch_env!("TELEMETRY_ID")
  guardian_secret_key = System.fetch_env!("GUARDIAN_SECRET_KEY")
  disable_vpn_on_oidc_error = FzString.to_boolean(System.fetch_env!("DISABLE_VPN_ON_OIDC_ERROR"))
  auto_create_oidc_users = FzString.to_boolean(System.fetch_env!("AUTO_CREATE_OIDC_USERS"))
  secure = FzString.to_boolean(System.get_env("DEV_SECURE", "true"))

  allow_unprivileged_device_management =
    FzString.to_boolean(System.fetch_env!("ALLOW_UNPRIVILEGED_DEVICE_MANAGEMENT"))

  # Outbound Email
  from_email = System.get_env("OUTBOUND_EMAIL_FROM")

  if from_email do
    provider = System.get_env("OUTBOUND_EMAIL_PROVIDER", "sendmail")

    config :fz_http,
           FzHttp.Mailer,
           [from_email: from_email] ++ FzHttp.Mailer.configs_for(provider)
  end

  # Local auth
  local_auth_enabled = FzString.to_boolean(System.fetch_env!("LOCAL_AUTH_ENABLED"))

  # Okta auth
  okta_auth_enabled = FzString.to_boolean(System.fetch_env!("OKTA_AUTH_ENABLED"))
  okta_client_id = System.get_env("OKTA_CLIENT_ID")
  okta_client_secret = System.get_env("OKTA_CLIENT_SECRET")
  okta_site = System.get_env("OKTA_SITE")

  # Google auth
  google_auth_enabled = FzString.to_boolean(System.fetch_env!("GOOGLE_AUTH_ENABLED"))
  google_client_id = System.get_env("GOOGLE_CLIENT_ID")
  google_client_secret = System.get_env("GOOGLE_CLIENT_SECRET")
  google_redirect_uri = System.get_env("GOOGLE_REDIRECT_URI")

  max_devices_per_user =
    System.fetch_env!("MAX_DEVICES_PER_USER")
    |> String.to_integer()
    |> FzInteger.clamp(0, 100)

  telemetry_module =
    if telemetry_enabled do
      FzCommon.Telemetry
    else
      FzCommon.MockTelemetry
    end

  connectivity_checks_enabled =
    FzString.to_boolean(System.fetch_env!("CONNECTIVITY_CHECKS_ENABLED")) &&
      System.get_env("CI") != "true"

  connectivity_checks_interval =
    System.fetch_env!("CONNECTIVITY_CHECKS_INTERVAL")
    |> String.to_integer()
    |> FzInteger.clamp(60, 86_400)

  # secrets
  encryption_key = System.fetch_env!("DATABASE_ENCRYPTION_KEY")
  secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
  live_view_signing_salt = System.fetch_env!("LIVE_VIEW_SIGNING_SALT")
  cookie_signing_salt = System.fetch_env!("COOKIE_SIGNING_SALT")
  cookie_encryption_salt = System.fetch_env!("COOKIE_ENCRYPTION_SALT")

  # Password is not needed if using bundled PostgreSQL, so use nil if it's not set.
  database_password = System.get_env("DATABASE_PASSWORD")

  # XXX: Using to_atom here because this is trusted input and to_existing_atom
  # won't work because we won't know the keys ahead of time.
  ssl_opts = Keyword.new(database_ssl_opts, fn {k, v} -> {String.to_atom(k), v} end)
  parameters = Keyword.new(database_parameters, fn {k, v} -> {String.to_atom(k), v} end)

  # Database configuration
  connect_opts = [
    database: database_name,
    username: database_user,
    hostname: database_host,
    port: database_port,
    pool_size: database_pool,
    ssl: database_ssl,
    ssl_opts: ssl_opts,
    parameters: parameters,
    queue_target: 500
  ]

  if database_password do
    config(:fz_http, FzHttp.Repo, connect_opts ++ [password: database_password])
  else
    config(:fz_http, FzHttp.Repo, connect_opts)
  end

  config :fz_http, FzHttp.Vault,
    ciphers: [
      default: {
        Cloak.Ciphers.AES.GCM,
        # In AES.GCM, it is important to specify 12-byte IV length for
        # interoperability with other encryption software. See this GitHub
        # issue for more details:
        # https://github.com/danielberkompas/cloak/issues/93
        #
        # In Cloak 2.0, this will be the default iv length for AES.GCM.
        tag: "AES.GCM.V1", key: Base.decode64!(encryption_key), iv_length: 12
      }
    ]

  listen_ip =
    phoenix_listen_address
    |> String.split(".")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()

  config :fz_http, FzHttpWeb.Endpoint,
    http: [ip: listen_ip, port: phoenix_port],
    server: true,
    secret_key_base: secret_key_base,
    live_view: [
      signing_salt: live_view_signing_salt
    ]

  config :fz_wall,
    wireguard_ipv4_masquerade: wireguard_ipv4_masquerade,
    wireguard_ipv6_masquerade: wireguard_ipv6_masquerade,
    nft_path: nft_path,
    egress_interface: egress_interface,
    wireguard_interface_name: wireguard_interface_name,
    cli: FzWall.CLI.Live

  config :fz_vpn,
    wireguard_private_key_path: wireguard_private_key_path,
    wireguard_interface_name: wireguard_interface_name,
    wireguard_port: wireguard_port

  # Guardian configuration
  config :fz_http, FzHttpWeb.Authentication,
    issuer: "fz_http",
    secret_key: guardian_secret_key

  config :fz_http,
    disable_vpn_on_oidc_error: disable_vpn_on_oidc_error,
    auto_create_oidc_users: auto_create_oidc_users,
    cookie_signing_salt: cookie_signing_salt,
    cookie_encryption_salt: cookie_encryption_salt,
    cookie_secure: secure,
    allow_unprivileged_device_management: allow_unprivileged_device_management,
    max_devices_per_user: max_devices_per_user,
    local_auth_enabled: local_auth_enabled,
    okta_auth_enabled: okta_auth_enabled,
    google_auth_enabled: google_auth_enabled,
    wireguard_dns: wireguard_dns,
    wireguard_allowed_ips: wireguard_allowed_ips,
    wireguard_persistent_keepalive: wireguard_persistent_keepalive,
    wireguard_ipv4_enabled: wireguard_ipv4_enabled,
    wireguard_ipv4_network: wireguard_ipv4_network,
    wireguard_ipv4_address: wireguard_ipv4_address,
    wireguard_ipv6_enabled: wireguard_ipv6_enabled,
    wireguard_ipv6_network: wireguard_ipv6_network,
    wireguard_ipv6_address: wireguard_ipv6_address,
    wireguard_mtu: wireguard_mtu,
    wireguard_endpoint: wireguard_endpoint,
    telemetry_module: telemetry_module,
    telemetry_id: telemetry_id,
    connectivity_checks_enabled: connectivity_checks_enabled,
    connectivity_checks_interval: connectivity_checks_interval,
    admin_email: admin_email,
    default_admin_password: default_admin_password

  # Configure strategies
  identity_strategy =
    {:identity,
     {Ueberauth.Strategy.Identity,
      [
        callback_methods: ["POST"],
        callback_url: "#{external_url}/auth/identity/callback",
        uid_field: :email
      ]}}

  okta_strategy = {:okta, {Ueberauth.Strategy.Okta, []}}
  google_strategy = {:google, {Ueberauth.Strategy.Google, []}}

  providers =
    [
      {local_auth_enabled, identity_strategy},
      {google_auth_enabled, google_strategy},
      {okta_auth_enabled, okta_strategy}
    ]
    |> Enum.filter(fn {key, _val} -> key end)
    |> Enum.map(fn {_key, val} -> val end)

  config :ueberauth, Ueberauth, providers: providers

  # Configure OAuth portion of enabled strategies
  if okta_auth_enabled do
    config :ueberauth, Ueberauth.Strategy.Okta.OAuth,
      client_id: okta_client_id,
      client_secret: okta_client_secret,
      site: okta_site
  end

  if google_auth_enabled do
    config :ueberauth, Ueberauth.Strategy.Google.OAuth,
      client_id: google_client_id,
      client_secret: google_client_secret,
      redirect_uri: google_redirect_uri
  end
end

# OIDC Auth
auth_oidc_env = System.get_env("AUTH_OIDC")

if config_env() != :test && auth_oidc_env do
  auth_oidc =
    Jason.decode!(auth_oidc_env)
    # Convert Map to something openid_connect expects, atomic keyed configs
    # eg. [provider: [client_id: "CLIENT_ID" ...]]
    |> Enum.map(fn {provider, settings} ->
      {
        String.to_atom(provider),
        [
          discovery_document_uri: settings["discovery_document_uri"],
          client_id: settings["client_id"],
          client_secret: settings["client_secret"],
          redirect_uri: "#{external_url}/auth/oidc/#{provider}/callback/",
          response_type: settings["response_type"],
          scope: settings["scope"],
          label: settings["label"]
        ]
      }
    end)

  config :fz_http, :openid_connect_providers, auth_oidc
end
