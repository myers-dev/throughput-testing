#!/bin/bash

storage_account_name="ttresult"
table_name="stats"

rg=`terraform output resource_group_name | tr -d '"'`
location=`terraform output location | tr -d '"'`

echo "Cleaning up storage account $storage_account_name at $rg / $location"


az storage account delete  \
  --name $storage_account_name \
  --resource-group $rg \
  --yes

az storage account create  \
  --name $storage_account_name \
  --resource-group $rg \
  --location $location \
  --sku Standard_GRS \
  --kind StorageV2

az storage table create --name $table_name \
                        --account-name $storage_account_name 
