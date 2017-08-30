# KubeAuth

Authorization stanza. This is under active development both in kraken-lib and in kubernetes as a whole.  As of Kubernetes 1.6 rbac will be required. 

## Options
### Root Options
| Key Name       | Required     | Type    | Description      |
| --------       | ------------ | ------  | ---------------- |
| authz          | __Required__ |         |                  |
| authn          | __Required__ | Object  |                  |

### Authz Options
| Key Name       | Required     | Type    | Description      |
| --------       | ------------ | ------  | ---------------- |
| rbac           |              |         |                  |

### Authn Options
| Key Name           | Required     | Type           | Description      |
| --------           | ------------ | ------         | ---------------- |
| basic              |              | Object Array   |                  |
| default_basic_user |              | String         |                  |
| oidc               |              |                |                  |

#### OIDC Options
| Key Name           | Required     | Type    | Description      |
| --------           | ------------ | ------  | ---------------- |
| issuer             |              |         |                  |
| service_name       | String       |         |                  |
| domain             |              |         |                  |
| clientId           |              |         |                  |
| clientSecret       |              |         |                  |



```yaml
kubeAuth:
 - &defaultKubeAuth
    authz: {}
    authn:
      basic:
        -
          password: "ChangeMe"
          user: "admin"
      default_basic_user: "admin"
```

For more information about kubeAuth and security, read the [docs](../security/README.md)
