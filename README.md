# EKS-Lab

Experimentation with AWS EKS using the [Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/2.0.0)


## Setup

### Create cluster & workers

```
terraform init
terraform plan
terraform apply
```

### Install Helm server

```
kubectl apply -f ~/environment/rbac.yaml
helm init --service-account tiller
```

### Dashboard

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
# Enable permission
kubectl apply -f eks-admin-service-account.yaml
kubectl proxy
xdg-open http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
```
