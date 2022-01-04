from azure.servicebus import ServiceBusClient, ServiceBusMessage
import socket

CONNECTION_STR=''
QUEUE_NAME=''

def get_ip():
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

def send_single_message(sender):
    # create a Service Bus message
    message = ServiceBusMessage(get_ip())
    # send the message to the queue
    sender.send_messages(message)
    #print("Sent a single message")

# create a Service Bus client using the connection string
servicebus_client = ServiceBusClient.from_connection_string(conn_str=CONNECTION_STR, logging_enable=True)

with servicebus_client:
    # get a Queue Sender object to send messages to the queue
    sender = servicebus_client.get_queue_sender(queue_name=QUEUE_NAME)
    with sender:
        # send one message        
        send_single_message(sender)

#print("Done sending messages")
#print("-----------------------")