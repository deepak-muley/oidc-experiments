# Cluster Configuration

This directory contains the Kubernetes cluster configuration.

## kind Cluster

- **Config:** `kind.yaml`
- **Cluster Name:** `oidc-proxy-demo`

## Usage

Create the cluster:
```bash
kind create cluster --config kind.yaml
```

Delete the cluster:
```bash
kind delete cluster --name oidc-proxy-demo
```

## References

- [kind Documentation](https://kind.sigs.k8s.io/)

