import serial
import time
import struct
import numpy as np

# Configure UART connection
serial_port = 'COM4'  # Replace with the correct port
baud_rate = 9600

# Open the serial port
ser = serial.Serial(serial_port, baudrate=baud_rate, timeout=1)

def ieee_rep(number,precision=8):
    packed = struct.pack('>f', number)

    # Unpack the 4 bytes into a 32-bit integer using 'I' (unsigned int)
    unpacked = struct.unpack('>I', packed)[0]

    # Get the sign (1 bit), exponent (8 bits), and mantissa (23 bits)
    sign = (unpacked >> 31) & 0x1
    exponent = (unpacked >> 23) & 0xFF
    mantissa = unpacked & 0x7FFFFF
    reduced_mantissa = ((mantissa >> (23-precision))) << (23-precision)

    reduced_representation = (sign << 31) | (exponent << 23) | reduced_mantissa

    packed_reduced = struct.pack('>I', reduced_representation)
    reduced_number = struct.unpack('>f', packed_reduced)[0]

    binary_representation = f"{reduced_representation:032b}"
    return binary_representation

def ieee_to_fraction(binary_string):
    # Ensure the binary string is 32 bits long
    if len(binary_string) != 32:
        raise ValueError("Binary string must be 32 bits long.")

    # Extract the sign, exponent, and mantissa
    sign = int(binary_string[0], 2)  # First bit
    exponent_bits = binary_string[1:9]  # Next 8 bits
    mantissa_bits = binary_string[9:]  # Last 23 bits

    # Convert exponent from binary to decimal
    exponent = int(exponent_bits, 2) - 127  # Subtract bias of 127

    # Convert mantissa from binary to decimal
    mantissa_value = 1.0  # Start with implicit leading 1
    for i in range(23):
        mantissa_value += int(mantissa_bits[i]) * (2 ** -(i + 1))

    # Calculate the floating-point value
    fraction_value = ((-1) ** sign) * mantissa_value * (2 ** exponent)

    # Format the output to 4 decimal places
    formatted_fraction = format(fraction_value, ".4f")

    return formatted_fraction
# Helper function to send 32-bit data
def send_32bit_data(value):
    """Sends a 32-bit integer over UART."""
    data_bytes = value.to_bytes(4, byteorder='big')  # Convert to 4 bytes (MSB first)
    ser.write(data_bytes)
    print(f"Sent: 0x{value:08X}")

# Helper function to read 32-bit data
def read_32bit_data():
    """Reads a 32-bit integer from UART."""
    data_bytes = ser.read(4)  # Read 4 bytes from UART
    if len(data_bytes) == 4:
        received_value = int.from_bytes(data_bytes, byteorder='big')  # Convert bytes to int
        print(f"Received: 0x{received_value:08X}")
        return received_value
    else:
        print("Error: Incomplete data received!")
        return None

# Main function to test the communication
if __name__ == "__main__":
    try:
        if ser.is_open:
            print(f"Connected to {serial_port} at {baud_rate} baud.")

            # Example input value
            inp = ieee_rep(float(input("Enter input: ")))  # Replace with desired 32-bit input valu
            input_value= int(inp,2)

            # Send input value to FPGA
            send_32bit_data(input_value)

            # Wait for FPGA to process the data
            time.sleep(5)  # Adjust this based on FPGA processing time

            # Read the processed output
            result = read_32bit_data()

            res=ieee_to_fraction(str(result))
            if result is not None:
                print(f"Processed output from FPGA: ",res)

        else:
            print("Failed to open the serial port.")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        ser.close()