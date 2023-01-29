THIS IS THE BEST EXAMPLE I HAVE SO FAR (I THINK)

tf apply
aws eks --region ap-southeast-2 update-kubeconfig --name eks-serverless
kubectl apply -f 2048-game.yaml

kubectl apply -f logger-server.yaml && kubectl -n orchestration expose deploy logger-server

kubectl -n orchestration port-forward svc/logger-server 8080:80
kubectl -n orchestration logs deploy/logger-server -f
curl localhost:8080
kubectl get configmap aws-logging -n aws-observability -o yaml


# Have to do this to get CoreDNS to run on Fargate
# Can I add it as an add on afterwards?, and run a patch?

# Could try this
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon

$ kubectl patch deployment coredns \
    -n kube-system \
    --type json \
    -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
$ kubectl rollout restart -n kube-system deployment coredns

https://docs.amazonaws.cn/en_us/eks/latest/userguide/fargate-getting-started.html


# Had to add this to the IAM role of the fargate profile:
module.eks.module.fargate_profile["orchestration-fargate-profile"].aws_iam_role.this[0]
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:*",
                "logs:*"
            ],
            "Resource": "*"
        }
    ]
}

https://aws.amazon.com/blogs/containers/fluent-bit-for-amazon-eks-on-aws-fargate-is-here/