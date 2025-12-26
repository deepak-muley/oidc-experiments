# podinfo

podinfo is a simple microservice used as a demo application.

## Deployment

podinfo is deployed directly from the upstream repository:

```bash
kubectl -n podinfo apply -f https://raw.githubusercontent.com/stefanprodan/podinfo/master/kustomize/deployment.yaml
kubectl -n podinfo apply -f https://raw.githubusercontent.com/stefanprodan/podinfo/master/kustomize/service.yaml
```

## Service Details

- **Namespace:** `podinfo`
- **Service:** `podinfo.podinfo.svc.cluster.local:9898`
- **Port:** `9898`

## Architecture

podinfo is the protected backend service that:
- Receives requests from kube-oidc-proxy
- Returns JSON metadata about the pod
- Trusts kube-oidc-proxy for authentication

## References

- [podinfo GitHub](https://github.com/stefanprodan/podinfo)

