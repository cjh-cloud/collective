

Add ingress crds?
kubectl apply -k "github.com/kubernetes/ingress-nginx.git/deploy/static/provider/aws?ref=controller-v0.44.0"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.4.0/deploy/static/provider/cloud/deploy.yaml

kubectl annotate serviceaccount -n external-dns external-dns eks.amazonaws.com/role-arn=arn:aws:iam::322839641907:role/externaldns_route53

kustomize build . | kubectl apply -f -

kubectl delete ingress --all -A
kubectl delete namespace myapp ingress-nginx 
kustomize build . | kubectl delete -f -