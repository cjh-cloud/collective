# Learn Terraform - Provision an EKS Cluster

This repo is a companion repo to the [Provision an EKS Cluster learn guide](https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster), containing
Terraform configuration files to provision an EKS cluster on AWS.

---

EKS Cluster with Terraform - https://learn.hashicorp.com/tutorials/terraform/eks

Setup kubectl:
`aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)`

EKS is stupid and has some Kubernetes RBAC 💩 that requires doing the following so you can view it in the AWS console:
https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting_iam.html#security-iam-troubleshoot-cannot-view-nodes-or-workloads
https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html
`$ kubectl edit -n kube-system configmap/aws-auth`
Add an AWS user to mapUsers:
```
mapUsers:
----
- userarn: arn:aws:iam::322839641907:user/chewett
  username: chewett
  groups:
    - system:masters
```

Then apply it:
`$ kubectl describe configmap -n kube-system aws-auth`
