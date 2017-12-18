# Key pair configurations
Provider-specific node configuration options

* `aws` - [aws keypairs](aws.md)
* `gke` - [gke keypairs](gke.md)


## Options
| Key Name       | Required     | Type   | Description|
| -------------- | ------------ | ------ | ---------- |
| name           | __Required__ | String | Keypair name |
| kind           | __Required__ | String | Keypair |
| publickeyFile  | Optional     | String | Path to public key material |
| privatekeyFile | Optional     | String | Path to private key |

```yaml
keyPairs:
 - &defaultKeyPair
    name: defaultKeyPair
    kind: keyPair
    publickeyFile: "$HOME/.ssh/id_rsa.pub"
    privatekeyFile: "$HOME/.ssh/id_rsa"
```
