minikube start  
helm install clunky-serval ./mychart/  
helm uninstall clunky-serval  

$ cd mychart/charts  
$ helm create mysubchart  
Creating mysubchart...  
$rm -rf mysubchart/templates/*  
