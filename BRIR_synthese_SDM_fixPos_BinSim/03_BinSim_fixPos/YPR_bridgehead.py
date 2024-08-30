import tkinter as tk
from pythonosc.dispatcher import Dispatcher
from pythonosc.osc_server import BlockingOSCUDPServer
import threading

# Define global variables for yaw, pitch, and roll
yaw = 0
pitch = 0
roll = 0

def handle_data(address, *args):
    global yaw, pitch, roll
    yaw = args[0]
    pitch = args[1]
    roll = args[2]

dispatcher = Dispatcher()
dispatcher.map("/ypr", handle_data)

# Define a function to start the OSC server in a separate thread
def start_osc_server(stop_event):
    server = BlockingOSCUDPServer(("localhost", 8000), dispatcher)
    while not stop_event.is_set():
        server.handle_request()
    server.server_close()

# Create a stop event to signal the OSC server thread to stop running
stop_event = threading.Event()

# Start the OSC server thread
osc_thread = threading.Thread(target=start_osc_server, args=(stop_event,))
osc_thread.start()

# Create the Tkinter GUI
root = tk.Tk()
root.title("Yaw, Pitch, Roll")
root.geometry("300x150")

# Create the entry widgets for yaw, pitch, and roll
yaw_label = tk.Label(root, text="Yaw:")
yaw_label.place(x=50, y=20)
yaw_entry = tk.Entry(root, width=10, font=("Arial", 12))
yaw_entry.place(x=100, y=20)

pitch_label = tk.Label(root, text="Pitch:")
pitch_label.place(x=50, y=50)
pitch_entry = tk.Entry(root, width=10, font=("Arial", 12))
pitch_entry.place(x=100, y=50)

roll_label = tk.Label(root, text="Roll:")
roll_label.place(x=50, y=80)
roll_entry = tk.Entry(root, width=10, font=("Arial", 12))
roll_entry.place(x=100, y=80)

# Define a function to update the entry widget values
def update_entry_values():
    yaw_entry.delete(0, tk.END)
    yaw_entry.insert(0, f"{yaw:.2f}")
    pitch_entry.delete(0, tk.END)
    pitch_entry.insert(0, f"{pitch:.2f}")
    roll_entry.delete(0, tk.END)
    roll_entry.insert(0, f"{roll:.2f}")
    root.after(50, update_entry_values)  # Update the values every 50ms

# Start updating the entry widget values continuously
update_entry_values()

# Define a function to stop the OSC server and exit the program
def stop_program():
    stop_event.set()  # Set the stop event to signal the OSC server thread to stop running
    osc_thread.join()  # Wait for the OSC server thread to stop running
    root.destroy()  # Close the Tkinter window and exit the program

# Create a Quit button
quit_button = tk.Button(root, text="Quit", command=stop_program, bg="#FF0000", fg="white")
quit_button.place(x=220, y=115)

root.mainloop()