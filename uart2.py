import serial
import time
import struct

# Configure UART connection
serial_port = 'COM4'  # Replace with the correct port
baud_rate = 9600

# Open the serial port
ser = serial.Serial(serial_port, baudrate=baud_rate, timeout=5)

def ieee_rep(number, precision=8):
    """
    Converts a floating-point number to its IEEE 754 binary representation.
    """
    packed = struct.pack('>f', number)
    unpacked = struct.unpack('>I', packed)[0]

    sign = (unpacked >> 31) & 0x1
    exponent = (unpacked >> 23) & 0xFF
    mantissa = unpacked & 0x7FFFFF
    reduced_mantissa = ((mantissa >> (23 - precision))) << (23 - precision)

    reduced_representation = (sign << 31) | (exponent << 23) | reduced_mantissa
    packed_reduced = struct.pack('>I', reduced_representation)
    binary_representation = f"{reduced_representation:032b}"

    return binary_representation

def ieee_to_fraction(binary_string):
    """
    Converts a 32-bit IEEE 754 binary string to its floating-point representation.
    """
    if len(binary_string) != 32:
        raise ValueError("Binary string must be 32 bits long.")

    sign = int(binary_string[0], 2)
    exponent_bits = binary_string[1:9]
    mantissa_bits = binary_string[9:]

    exponent = int(exponent_bits, 2) - 127
    mantissa_value = 1.0
    for i in range(23):
        mantissa_value += int(mantissa_bits[i]) * (2 ** -(i + 1))

    fraction_value = ((-1) ** sign) * mantissa_value * (2 ** exponent)
    return format(fraction_value, ".4f")

def send_5_bytes(data, extra):
    """
    Sends 5 bytes: 4 bytes for 32-bit data and 1 byte for the second input.
    """
    if not (0 <= data <= 0xFFFFFFFF):
        raise ValueError("Data must be a 32-bit value (0-4294967295).")
    if not (0 <= extra <= 255):
        raise ValueError("Second input must be an 8-bit value (0-255).")

    data_bytes = data.to_bytes(4, byteorder='big')  # 32-bit data
    extra_byte = extra.to_bytes(1, byteorder='big')  # 8-bit input
    combined_bytes =data_bytes+extra_byte
    #reversed_bytes = combined_bytes[::-1]  # Reverse the byte order


    ser.write(combined_bytes)
    print(f"Sent: Data = 0x{data:08X}, Extra = 0x{extra:02X} (5 bytes total)")
    # Print the combined 40-bit data in hexadecimal
    print("Sent combined 40-bit data (hex):", combined_bytes.hex().upper())

    # Print the combined 40-bit data in binary
    combined_binary = ''.join(f"{byte:08b}" for byte in combined_bytes)
    print("Sent combined 40-bit data (binary):", combined_binary)
    
'''
def send_5_bytes(data, extra):
    """
    Sends 40-bit data (32-bit data + 8-bit extra) bit by bit.
    Data goes into [39:8], and extra goes into [7:0].
    """
    if not (0 <= data <= 0xFFFFFFFF):
        raise ValueError("Data must be a 32-bit value (0-4294967295).")
    if not (0 <= extra <= 255):
        raise ValueError("Second input must be an 8-bit value (0-255).")

    # Combine 32-bit data and 8-bit extra into a single 40-bit value
    full_data = (data << 8) | extra  # Data in [39:8], extra in [7:0]

    print(f"Original 40-bit data: 0x{full_data:010X}")

    # Loop through each bit from LSB to MSB of the full 40-bit value
    for i in range(40):
        # Extract the ith bit (LSB first)
        bit = (full_data >> i) & 1

        # Send the bit as a single byte (0 or 1)
        ser.write(bytes([bit]))
        print(f"Sent bit {i}: {bit}")

    print("All bits sent!")
'''
def read_4_bytes():
    """
    Receives 4 bytes of data (32 bits).
    """
    data_bytes = ser.read(4)  # Read only 4 bytes
    if len(data_bytes) == 4:
        received_data = int.from_bytes(data_bytes, byteorder='big')
        print(f"Received: Data = 0x{received_data:08X}")
        return received_data
    else:
        print("Error: Incomplete data received!")
        return None

# Main function to test the communication
if __name__ == "__main__":
    try:
        if ser.is_open:
            print(f"Connected to {serial_port} at {baud_rate} baud.")

            # Get user input
            user_input = float(input("Enter the number: "))
            inp = ieee_rep(user_input)  # Convert to IEEE 754 representation
            input_value = int(inp, 2)

            print("Enter 0 to implement tanh.")
            print("Enter 1 to implement sigmoid.")
            print("Enter 2 to implement elu.")
            print("Enter 3 to implement relu.")
            print("Enter 4 to implement leakyrelu.")
            second_input = int(input("Enter the input: "))

            # Send 5 bytes
            send_5_bytes(input_value, second_input)

            # Wait for FPGA to process the data
            time.sleep(2)  # Adjust based on processing time

            # Receive 4 bytes
            result = read_4_bytes()
            if result is not None:
                result_fraction = ieee_to_fraction(f"{result:032b}")
                #print(f"Processed output from FPGA: {result_fraction}")
            else:
                print("Failed to receive valid data from FPGA.")

        else:
            print("Failed to open the serial port.")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        ser.close()
