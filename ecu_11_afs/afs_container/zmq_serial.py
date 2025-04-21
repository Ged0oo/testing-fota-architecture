import serial
import time
import zmq
import os

print("Starting ZMQ Serial Subscriber...")
# Read ZMQ publisher address from environment variable
ZMC_HOST = os.getenv("ZMC_HOST", "tcp://192.168.1.18:5555")

# Setup ZeroMQ subscriber
context = zmq.Context()
socket = context.socket(zmq.SUB)
socket.connect(ZMC_HOST)
socket.setsockopt_string(zmq.SUBSCRIBE, "")  # Subscribe to all messages
print(f"Connected to ZMQ publisher at {ZMC_HOST}")

# Open serial port
ser = serial.Serial('/dev/ttyUSB0', 9600, timeout=1)

def send_data():
    while True:
        try:
            message = socket.recv_string()  # Receive message from ZMQ
            data = message.strip().split()  # Expecting: "r 90" or "l 45"

            if len(data) != 2:
                print("Invalid format! Expected format: 'r 90'")
                continue

            char, angle = data[0].lower(), data[1]
 
            if char not in ['r', 'l']:
                print("Invalid direction! Use 'r' or 'l'.")
                continue

            if not angle.isdigit() or not (0 <= int(angle) <= 180):
                print("Invalid angle! Enter a number between 0 and 180.   =>   ", angle)
                continue

            # Send direction
            ser.write(char.encode())

            # Send angle
            ser.write(bytes([int(angle)]))

            print(f"Sent to Serial: {char} {angle}")

        except Exception as e:
            print(f"Error: {e}")

# Start processing data
send_data()
