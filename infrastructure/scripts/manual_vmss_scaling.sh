#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 number"
    exit 1
fi

number=$1

echo "Started VMSS scale at `date`"

az vmss scale --new-capacity $number --name `terraform output servers | tr -d '"'` --resource-group `terraform output resource_group_name | tr -d '"'` --no-wait

az vmss scale --new-capacity $number --name `terraform output clients | tr -d '"'` --resource-group `terraform output resource_group_name | tr -d '"'` --no-wait
