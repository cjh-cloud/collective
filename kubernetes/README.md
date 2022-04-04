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
