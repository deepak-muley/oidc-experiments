# Dex - OIDC Provider

Dex is an OpenID Connect (OIDC) identity provider that acts as a bridge between LDAP and OIDC.

## Configuration

This directory contains the Dex deployment configuration:

- `dex-config.yaml` - ConfigMap with Dex configuration, including:
  - ForumSys LDAP connector
  - Static OIDC client (`cli`)
  - Kubernetes storage backend

- `dex.yaml` - Deployment and Service for Dex

## Architecture

Dex connects to ForumSys public LDAP server and provides OIDC tokens for authentication.

**Issuer URL:** `http://dex.auth.svc.cluster.local:5556`

## ForumSys LDAP

The configuration uses ForumSys public LDAP test server:
- **Host:** `ldap.forumsys.com:389`
- **Base DN:** `dc=example,dc=com`
- **Bind DN:** `uid=read-only-admin,dc=example,dc=com`

### Test Users

- `einstein` / `password`
- `newton` / `password`
- `galieleo` / `password`
- `tesla` / `password`
- `riemann` / `password`

## References

- [Dex GitHub](https://github.com/dexidp/dex)
- [ForumSys LDAP Test Server](https://www.forumsys.com/tutorials/integration-how-to/ldap/online-ldap-test-server/)

