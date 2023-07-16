THIS IS THE BEST EXAMPLE I HAVE SO FAR (I THINK)

tf apply
aws eks --region ap-southeast-2 update-kubeconfig --name my-cluster
kubectl apply -f 2048-game.yaml


Grafana Dashboard
11159 for Node JS Dashboard


KEDA
https://www.youtube.com/watch?v=QWweMlerTZY

$ kubectl apply -f scaledobject.yaml
$ kubectl apply -f keda-sigv4.yaml

Had to add policy "AmazonPrometheusQueryAccess" to role "default-eks-node-group-2023071522532923550000000b" 
for ScaledObject to be able to hit prometheus
This link was useful: https://aws.amazon.com/blogs/mt/proactive-autoscaling-kubernetes-workloads-keda-metrics-ingested-into-aws-amp/


TODO
- [ ] autoscaling of nodes
- [ ] metrics for http requests
 