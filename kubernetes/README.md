

Directories:
- learnk8s/ https://learnk8s.io/terraform-eks - useful tutorial
- learn-terraform-provision-eks-cluster/ - tf docs tutorial to create eks cluster
- learn-terraform-deploy-nginx-kubernetes/ - requires eks cluster created by above directory 

Useful links:
https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller - used in learnk8s/

Works for the learn-*/ dirs
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)

Works for the learnk8s/ dir (should make it like above)
aws eks --region ap-southeast-2 update-kubeconfig --name my-cluster

allow aws user access to EKS cluster
`$ kubectl edit configmap aws-auth -n kube-system`
mapUsers: |
    - userarn: arn:aws:iam::ACCOUNT_ID:user/USERNAME
      username: USERNAME
      groups:
        systems:masters

-----

kubectl describe services test-kubernetes
kubectl describe ingress test-kubernetes
kubectl port-forward terraform-example-dbfb6847f-fpjp4 8080:8080
kubectl get pods --output=wide 
kubectl get services 
kubectl describe replicasets 
kubectl get replicasets


---

apiVersion:
kind:
metadata:
spec:

replication controller spans multiple nodes, does that mean it is running on the master?
replication controller is old, replica set is the new hotness
kind is ReplicationController
kubectl create -f rc-definition.yml
kubectl get replicationcontroller
kubectl get replicaset

kubectl replace -f replicaset-definition.yml (with updated replicas)
kubectl scale --replicas=6 -f replicaset-def

what's the best practice for writing YAML files, e.g. what 'kind' to use? pod, replica set, deployment

namespaces
default, dev and prod namespaces, is this all within one cluster?
