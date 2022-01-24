#!/bin/sh

export rg=`terraform output resource_group_name | tr -d '"'`
export subnet1=`terraform output subnet1_id | tr -d "\""`
export subnet2=`terraform output subnet2_id | tr -d "\""`


export vnet1_id=`terraform output vnet1_id | tr -d "\""`
export vnet2_id=`terraform output vnet2_id | tr -d "\""`


# -----------------------------------------

cd aks/docker

az acr create -g $rg -n acrcopernic --sku Standard --admin-enabled
az acr update -n acrcopernic --anonymous-pull-enabled

az acr login --name acrcopernic

docker build --network=host -t andrew/universalcs .

docker tag andrew/universalcs acrcopernic.azurecr.io/universalcs
docker push acrcopernic.azurecr.io/universalcs

az acr repository show -n acrcopernic  --image universalcs

# -----------------------------------------

az aks create --resource-group "${rg}" --name aks1 --node-count 3 --enable-addons monitoring \
--generate-ssh-keys --vnet-subnet-id "${subnet1}" --service-cidr 172.16.0.0/24 --dns-service-ip 172.16.0.10 \
--network-plugin azure --attach-acr acrcopernic --enable-cluster-autoscaler --min-count 1 --max-count 1000 --node-vm-size Standard_D4_v4

# az aks delete --name aks1 --resource-group "${rg}"

az aks get-credentials --name aks1 --resource-group $rg

kubectl config get-contexts
kubectl config use-context aks1

# -----------------------------------------

az aks create --resource-group "${rg}" --name aks2 --node-count 3 --enable-addons monitoring \
--generate-ssh-keys --vnet-subnet-id "${subnet2}" --service-cidr 172.16.0.0/24 --dns-service-ip 172.16.0.10 \
--network-plugin azure --attach-acr acrcopernic --enable-cluster-autoscaler --min-count 1 --max-count 1000 --node-vm-size Standard_D4_v4

# az aks delete --name aks2 --resource-group "${rg}"

az aks get-credentials --name aks2 --resource-group $rg
kubectl config get-contexts
kubectl config use-context aks2

# ------------------------------------------

# aks_managed_id=$(az aks show --name aks2 --resource-group $rg --query identity.principalId -o tsv)
# az role assignment create --assignee $aks_managed_id --role "Contributor" --scope $vnet2_id

# 
kubectl config use-context aks2

kubectl create deployment nginx --image=acrcopernic.azurecr.io/universalcs:latest --replicas=1 -- bash -c "nginx ; sleep infinity"

kubectl apply -f lb.yaml 

kubectl get svc -o wide

# ------

kubectl config use-context aks1

kubectl create deployment universalcs --image=acrcopernic.azurecr.io/universalcs:latest \
cas> --replicas=1 -- bash -c "while true; do echo GET http://10.1.0.5 | vegeta attack -duration=600s -insecure -rate=50 | vegeta report; done"

# 
kubectl config use-context aks2
kubectl scale deploy/nginx --replicas=1000

# 
kubectl config use-context aks1
kubectl scale deploy/universalcs --replicas=1000