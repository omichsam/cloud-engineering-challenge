# Kubernetes Study Guide

## Kubernetes fundamentals

**What is Kubernetes?** Kubernetes is a platform that schedules and manages containerized workloads. **Why use it?** It provides declarative deployment, service discovery, scaling, self-healing, and rolling updates. **What is a cluster?** A control plane coordinates worker nodes; nodes run Pods. **What is a Pod?** The smallest deployable unit, normally one application container plus shared network/storage. **What is a Deployment?** A controller that maintains a desired number of Pod replicas through a ReplicaSet. **What is a Service?** A stable virtual IP and DNS name that load-balances to matching Pod labels.

**What are ConfigMaps and Secrets?** ConfigMaps hold non-sensitive configuration; Secrets hold sensitive values and should be backed by a production secret manager. **What is a volume/PVC?** A volume stores data beyond a container lifecycle; a PersistentVolumeClaim requests storage. **What is Ingress?** An HTTP routing resource requiring an Ingress controller. **What are readiness and liveness probes?** Readiness controls traffic; liveness restarts unhealthy containers. **How does self-healing work?** Controllers compare desired and actual state and recreate missing Pods. **How do you troubleshoot?** Start with `kubectl get`, then `describe`, `logs`, `events`, labels, endpoints, and resource status.

## Kubernetes Commands Practice

```bash
kubectl cluster-info; kubectl version; kubectl get nodes; kubectl describe node minikube
kubectl get namespaces; kubectl create namespace dev; kubectl delete namespace dev
kubectl get pods -A; kubectl get pods -o wide; kubectl describe pod <pod-name>; kubectl delete pod <pod-name>
kubectl logs <pod-name>; kubectl logs -f <pod-name>; kubectl exec -it <pod-name> -- sh
kubectl get deployments; kubectl describe deployment <name>; kubectl create deployment nginx --image=nginx
kubectl scale deployment nginx --replicas=3; kubectl delete deployment nginx; kubectl get replicasets
kubectl get svc; kubectl get endpoints; kubectl describe svc <service-name>
kubectl get configmaps; kubectl describe configmap <name>; kubectl get secrets; kubectl describe secret <name>
kubectl get pv; kubectl get pvc; kubectl describe pvc <name>; kubectl get ingress; kubectl describe ingress <name>
kubectl apply -f file.yaml; kubectl apply -f kubernetes/; kubectl delete -f file.yaml
kubectl get all; kubectl get all -A; kubectl get events --sort-by=.metadata.creationTimestamp
kubectl rollout status deployment/<name>; kubectl rollout history deployment/<name>; kubectl rollout undo deployment/<name>
kubectl port-forward svc/<service-name> 8080:80; kubectl top pods; kubectl top nodes; kubectl get hpa; kubectl describe hpa <name>
minikube start; minikube stop; minikube delete; minikube status; minikube ip; minikube dashboard; minikube service <service-name>
```

### Practice exercise
Create a namespace, deploy nginx, scale it to three replicas, inspect Pods/ReplicaSets/Service, view logs, port-forward it, delete a Pod and watch a replacement, then remove the Deployment and namespace.
