# Azure Fierewall premium throughput testing

## Overview

The following topology used for the throughput testing. Classical hub-and-spoke topology with Azure Firewall Premium , deployed in the hub. 

![Topology](supplementals/img/Topology0.png)

During testing two VM sizes were used : DS4_v2 and DS5_v2 which, should provide 6 and 12Gbps of network perormance.

https://docs.microsoft.com/en-us/azure/virtual-machines/dv2-dsv2-series

## Verification

Verifying that internet connectivity is in-fact thought the firewall

```
az network firewall show --name AZFWP --resource-group AZFP --query ipConfigurations[].publicIpAddress[].id
[
  "/subscriptions/6fd2b24c-1ffa-43ca-abc1-8127c30dcb39/resourceGroups/AZFP/providers/Microsoft.Network/publicIPAddresses/AZFWPIP"
]

> az network public-ip show --id="/subscriptions/6fd2b24c-1ffa-43ca-abc1-8127c30dcb39/resourceGroups/AZFP/providers/Microsoft.Network/publicIPAddresses/AZFWPIP" --query=ipAddress
"20.84.235.151"

root@spoke1-vm:~# curl https://api.my-ip.io/ip
20.84.235.151

root@AZFPVNET-vm:~# curl https://api.my-ip.io/ip
20.84.235.151

root@spoke2-vm:~# curl https://api.my-ip.io/ip
20.84.235.151
```

## Speedtest - Azure Firewall Premium , AFWEnableAccelnet = False 

Basic test with Speedtest , configured as described at https://www.speedtest.net/apps/cli

```
sudo apt-get install curl
curl -s https://install.speedtest.net/app/cli/install.deb.sh | sudo bash
sudo apt-get install speedtest
```

### spoke1
```
   Speedtest by Ookla

     Server: IP Pathways, LLC - Urbandale, IA (id = 11902)
        ISP: Microsoft Corporation
    Latency:    24.12 ms   (0.23 ms jitter)
   Download:  8186.40 Mbps (data used: 9.9 GB )
     Upload:  3664.42 Mbps (data used: 3.3 GB )
Packet Loss:     0.0%
 Result URL: https://www.speedtest.net/result/c/13126a26-08e2-4ecb-99eb-2897d90c2743
```

### spoke2
```
   Speedtest by Ookla

     Server: IP Pathways, LLC - Urbandale, IA (id = 11902)
        ISP: Microsoft Corporation
    Latency:    20.94 ms   (0.13 ms jitter)
   Download:  7349.91 Mbps (data used: 11.5 GB )
     Upload:  3145.44 Mbps (data used: 5.1 GB )
Packet Loss:     0.0%
 Result URL: https://www.speedtest.net/result/c/3ee296b9-71ec-4e71-8f1c-4e0f5c0d1045
```
### hub
```
   Speedtest by Ookla

     Server: ICS Advanced Technologies - Ames, IA (id = 37733)
        ISP: Microsoft Corporation
    Latency:    23.65 ms   (0.25 ms jitter)
   Download:  5829.51 Mbps (data used: 9.9 GB )
     Upload:  3347.37 Mbps (data used: 3.3 GB )
Packet Loss:     0.0%
 Result URL: https://www.speedtest.net/result/c/da35660c-7ae1-4b81-aded-41aefc8370fe
```

## iperf3 spoke to spoke  - Azure Firewall Premium , AFWEnableAccelnet = False 

Install : sudo apt-get install iperf3 -y

### iperf3 spoke1 to spoke2

One Flow
```
azureadmin@spoke1-vm:~$ iperf3 -c 10.1.0.4
Connecting to host 10.1.0.4, port 5201
[  4] local 10.2.0.4 port 45070 connected to 10.1.0.4 port 5201
  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec  2.30 GBytes  1.98 Gbits/sec  385             sender
[  4]   0.00-10.00  sec  2.30 GBytes  1.97 Gbits/sec                  receiver
```

64 parallel flows (-P64):
```

[SUM]   0.00-10.00  sec  6.50 GBytes  5.58 Gbits/sec    6             sender
[SUM]   0.00-10.00  sec  6.44 GBytes  5.53 Gbits/sec                  receiver

```

### iperf3 spoke1 to hub (bypassing firewall)

```
azureadmin@spoke1-vm:~$ iperf3 -c 10.0.1.4
Connecting to host 10.0.1.4, port 5201
[  4] local 10.2.0.4 port 53928 connected to 10.0.1.4 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd   
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec  2.66 GBytes  2.29 Gbits/sec  187             sender
[  4]   0.00-10.00  sec  2.66 GBytes  2.28 Gbits/sec                  receiver

iperf Done.

-P64:

[SUM]   0.00-10.00  sec  6.51 GBytes  5.60 Gbits/sec    0             sender
[SUM]   0.00-10.00  sec  6.45 GBytes  5.54 Gbits/sec                  receiver

```

### nc spoke1 to spoke2
```
azureadmin@spoke1-vm:~$ dd if=/dev/zero bs=1M count=10240 | nc -n 10.1.0.4 1234510240+0 records in
10240+0 records out
10737418240 bytes (11 GB, 10 GiB) copied, 41.6609 s, 258 MB/s

azureadmin@spoke2-vm:~$ nc -l -n 12345 > /dev/null

```
## vxlan

Lets combine multiple flows by wrapping them under Vxlan encapsulation:

```
# spoke1
ip link add vxlan1 type vxlan id 1 remote 10.1.0.4 dstport 4789 dev eth0
ip link set vxlan1 up
ip addr add 10.77.0.1/30 dev vxlan1

# spoke2

ip link add vxlan1 type vxlan id 1 remote 10.2.0.4 dstport 4789 dev eth0
ip link set vxlan1 up
ip addr add 10.77.0.2/30 dev vxlan1
```

```
# D4_v2 with AN

root@spoke1-vm:~# iperf3 -P 64 -c 10.77.0.2
[SUM]   0.00-10.00  sec  2.89 GBytes  2.48 Gbits/sec  214             sender
[SUM]   0.00-10.00  sec  2.77 GBytes  2.38 Gbits/sec                  receiver

root@spoke1-vm:~# iperf3 -P 128 -c 10.77.0.2
[SUM]   0.00-10.00  sec  2.92 GBytes  2.51 Gbits/sec  1144             sender
[SUM]   0.00-10.00  sec  2.78 GBytes  2.39 Gbits/sec                  receiver
```

``` 
# D5_v2 with AN
[SUM]   0.00-10.00  sec  2.17 GBytes  1.87 Gbits/sec  500             sender
[SUM]   0.00-10.00  sec  2.03 GBytes  1.74 Gbits/sec                  receiver

[SUM]   0.00-10.00  sec  2.26 GBytes  1.94 Gbits/sec  1814             sender
[SUM]   0.00-10.00  sec  2.13 GBytes  1.83 Gbits/sec                  receiver
```

## Register AFWEnableAccelnet feature

```
Select-AzSubscription -Subscription ACAI_Network_Internal_1

Register-AzProviderFeature -Featurename AFWEnableAccelnet  -ProviderNamespace Microsoft.Network

PS C:\Users\ayerofyeyev> Get-AzProviderFeature -ProviderNamespace Microsoft.Network -FeatureName AFWEnableAccelnet

FeatureName       ProviderName      RegistrationState
-----------       ------------      -----------------
AFWEnableAccelnet Microsoft.Network Registered

```

Re-testing

```
# D5_v2 with AN

[SUM]   0.00-10.00  sec  2.17 GBytes  1.86 Gbits/sec  962             sender
[SUM]   0.00-10.00  sec  2.02 GBytes  1.74 Gbits/sec                  receiver

[SUM]   0.00-10.00  sec  2.17 GBytes  1.86 Gbits/sec  962             sender
[SUM]   0.00-10.00  sec  2.02 GBytes  1.74 Gbits/sec                  receiver

[SUM]   0.00-10.00  sec  2.17 GBytes  1.86 Gbits/sec  962             sender
[SUM]   0.00-10.00  sec  2.02 GBytes  1.74 Gbits/sec                  receiver

# D4_v2 with AN

[SUM]   0.00-10.00  sec  2.57 GBytes  2.21 Gbits/sec  718             sender
[SUM]   0.00-10.00  sec  2.45 GBytes  2.11 Gbits/sec                  receiver

[SUM]   0.00-10.00  sec  2.68 GBytes  2.31 Gbits/sec  3735             sender
[SUM]   0.00-10.00  sec  2.57 GBytes  2.21 Gbits/sec                  receiver


```

As a contrast throughput between hub and spoke directly

```
# spoke1
ip link add vxlan2 type vxlan id 2 remote 10.0.1.4 dstport 4789 dev eth0
ip link set vxlan2 up
ip addr add 10.78.0.1/30 dev vxlan2

# hub

ip link add vxlan2 type vxlan id 2 remote 10.2.0.4 dstport 4789 dev eth0
ip link set vxlan2 up
ip addr add 10.78.0.2/30 dev vxlan2

on DS4_v2 spoke to hub , bypassing firewall

[SUM]   0.00-10.00  sec  6.52 GBytes  5.60 Gbits/sec    0             sender
[SUM]   0.00-10.00  sec  6.44 GBytes  5.53 Gbits/sec                  receiver

DS5_v2 spoke1 to spoke2

[SUM]   0.00-10.00  sec  3.06 GBytes  2.63 Gbits/sec  1326             sender
[SUM]   0.00-10.00  sec  2.93 GBytes  2.51 Gbits/sec                  receiver

```
