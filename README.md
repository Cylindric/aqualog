# README

## Authentik Setup

1. Customization > Files

    * Upload all required assets
        
        * background1.png
        * logo-login.png

1. Applications > Providers > New Provider > OAuth2

    * Provider Name: aqualog
    * Authorization Flow: default-provider-authorization-implicit-consent
    * Protocol Settings
        * Client Type: public
        * Client ID: Note this and update `.env` with it.
        * Grant Types: Authorization Code, Refresh token
        * Redirect URLs: https://aqualog.cylindric.net/auth/callback
        * Logout URI: Leave blank
        * Signing Key: authentik Self-signed Certificate
    * Advanced Flow Settings
        * Authentication Flow: leave blank
        * Invalidation Flow: default-provider-invalidation-flow
    * Advanced protocol settings
        * Access Code Validity: minutes=1
        * Access Token Validity: minutes=5
        * Refresh Token Validity: days=30
        * Refresh Token Threshold: hours=1
        * Scopes: OpenID 'email', 'openid', 'profile', 'offline_access'
        * Encryption Key: leave blank
        * Subject Mode: Based on the User's hashed ID
        * Include claims in id_token: enabled
        * Issuer mode: Each provider
    * Machine-to-Machine authentication settings:
        * Federated OIDC Sources: empty
        * Federated OAth2/OpenID Providers: empty

1. Applications > Applications > New Application with Existing Provider

    * Application Name: AquaLog
    * Slug: aqualog
    * Group: AquaLog
    * Provider: aqualog
    * Backchannel Providers: blank
    * Policy engine mode: ANY
    * UI settings:
        * Launch URL: https://aqualog.cylindric.net
        * Open in new tab: OFF
        * Hide from Application Dashboard: OFF
        * Icon: blank
        * Publisher: blank
        * Description: blank

1. System -> Brands -> New Brand

    * Domain: aqualog-auth.cylindric.net
    * Branding settings
        * Title: AquaLog
        * Logo: logo-login.png
        * Default flow background: background1.png
        * Custom CSS: blank
    * External User Settings
        * Default application: AquaLog
    * Default flows
        * defaults
    * Other global settings
        * defaults

