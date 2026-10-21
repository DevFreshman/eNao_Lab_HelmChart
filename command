minikube start --cpus=4 --memory=8192
helm install authservice . -f values-authservice.yaml
helm install userservice . -f values-userservice.yaml
helm install labservice . -f values-labservice.yaml
helm install gwservice . -f values-gwservice.yaml

helm uninstall authservice
helm uninstall userservice
helm uninstall labservice
helm uninstall gwservice

kubectl create namespace monitoring

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring -f values-monitoring.yaml

kubectl get pods -n monitoring
kubectl get svc -n monitoring
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
minikube service gwservice-lab --url

minikube addons enable metrics-server

helm upgrade authservice . -f values-authservice.yaml
helm upgrade userservice . -f values-userservice.yaml
helm upgrade labservice . -f values-labservice.yaml
helm upgrade gwservice . -f values-gwservice.yaml


kubectl apply -f monitoring/namespace.yaml

kubectl apply -f "G:\Java App\eNaoLab\helm\servicemonitor-authservice.yaml"
kubectl apply -f "G:\Java App\eNaoLab\helm\servicemonitor-userservice.yaml"
kubectl apply -f "G:\Java App\eNaoLab\helm\servicemonitor-labservice.yaml"
kubectl apply -f "G:\Java App\eNaoLab\helm\servicemonitor-gwservice.yaml"

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
kubectl get pods -n monitoring
kubectl get secret prometheus-grafana -n monitoring -o jsonpath="{.data.admin-password}" | %{ [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

 helm upgrade prometheus prometheus-community/kube-prometheus-stack `
  --namespace monitoring `
  --set grafana.enabled=true `
  --reuse-values


http://my-jaeger.monitoring.svc.cluster.local:16686
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo update
helm search repo jaegertracing
kubectl port-forward svc/my-jaeger 16686:16686 -n monitoring

helm install my-jaeger jaegertracing/jaeger --namespace monitoring --set provisionDataStore.cassandra=false --set allInOne.enabled=true --set storage.type=memory --set agent.enabled=false --set collector.enabled=false --set query.enabled=false

kubectl get pod authservice-lab-7686645c67-sqzxq -o jsonpath='{.spec.containers[*].resources}'
kubectl exec -it authservice-lab-86466fbd4c-2zx2l -- cat /sys/fs/cgroup/cpu.max
kubectl exec -it authservice-lab-7686645c67-sqzxq -- cat /sys/fs/cgroup/cpu.stat