
from azure.servicebus import ServiceBusClient, ServiceBusMessage
from azure.cosmosdb.table.tableservice import TableService
from azure.cosmosdb.table.models import Entity

import iperf3
import datetime
import time
import socket
import os

#CONNECTION_STR=''
#QUEUE_NAME=''
#STORAGEACCOUNT = ''
#STORAGEACCOUNTKEY = ''

def get_sourceip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # doesn't even have to be reachable
        s.connect(('1.1.1.1', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

def get_serverip():
    # create a Service Bus client using the connection string
    servicebus_client = ServiceBusClient.from_connection_string(conn_str='CONNECTION_STR', logging_enable=True)

    with servicebus_client:
        msg = None
        while not msg:
            receiver = servicebus_client.get_queue_receiver(queue_name='QUEUE_NAME', max_wait_time=5)

            with receiver:
                for msg in receiver:
                    receiver.complete_message(msg)
                    return (str(msg))
                
def measure_throughput_old(ip):
    client = iperf3.Client()
    client.duration = 30
    client.server_hostname = ip
    #client.num_streams = 64
    client.port = 5201
    result = client.run()

    throughput = [ result.sent_Mbps, result.received_Mbps ]
    return(throughput)

def measure_throughput(ip):
    duration = 30
    o=os.popen(f"iperf3 -c {ip} -t {duration} -P64 -J | jq \".end.sum_sent.bits_per_second, .end.sum_received.bits_per_second\" ").read()

    return (o.split("\n")[:2])


source_ip = get_sourceip()
server_ip = get_serverip()

# ------------------------------

table_service = TableService(account_name='STORAGEACCOUNT', account_key='STORAGEACCOUNTKEY')

while True:
    if int(datetime.datetime.now().strftime("%S")) == 0:
        n = datetime.datetime.now().strftime("%m %d %Y %H %M %S")

        # --------------------------------

        entity = Entity()
        entity.PartitionKey = source_ip
        entity.RowKey = n
        throughput = measure_throughput(server_ip)
        entity.sent_throughput = throughput[0]
        entity.received_throughput = throughput[1]
        entity.server = server_ip
        #print("ready to insert",entity)
        table_service.insert_entity('stats', entity)
        #print("inserted",entity)

