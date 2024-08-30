from pythonosc import udp_client
from pythonosc.dispatcher import Dispatcher
from pythonosc import osc_server
import math as m
import numpy as np
import time
import os
import tkinter as tk
import sys
import traceback
from multiprocessing import Process
import threading
import math
import customtkinter as ctk
import msvcrt
import pyrealsense2 as rs


#Intitiating variables

stop_loop = False
chk = False
pause_conv = False
loop = True
use_headphone_filter = False
floudness= 1
pitch = 0
yaw = 0
roll = 0
pitch_current = 0
yaw_current = 0
roll_current = 0
x_current = 0
y_current = 0
z_current = 0
pitch_offset = 0
yaw_offset = 0 
roll_offset = 0
x_offset = 0
y_offset = 0
z_offset = 0
xPos_emu = 0
yPos_emu = 0
ds_on = 0
last_pose=[0,0,0]
last_position=[0,0,0]
i_now = 0
update = 1
yaw_sensor = 0
pitch_sensor = 0
roll_sensor = 0
center_x = 150
center_y = 150
radius = 100
arrow = None
yaw_out_rs = 0
pitch_out_rs = 0
roll_out_rs = 0
yaw_rs = 0
pitch_rs=0
roll_rs=0
roll_offset_rs=0
yaw_offset_rs=0
pitch_offset_rs=0
one_time_update = 1
body_orientation = False



#Path for the files

path = 'C:/Users/Media_Project/BRIR_synthese_SDM_fixPos_BinSim_example/data/Signals/'

filter_database_path = 'C:/Users/Media_Project/BRIR_synthese_SDM_fixPos_BinSim_example/data/SDMRenderedBRIRs/'

files = [f for f in os.listdir(path) if f.endswith('.wav')]
numfiles = len(files)
played_file = 0

#sorting room files

room_files = [f for f in os.listdir(filter_database_path) if f.endswith('.mat')]
num_room_files = len(room_files)
selected_room_file = 0
print("The number of rooms are : " , num_room_files , '\n\n')



# pyBinSim_Controller acts as the remotecontrol UI for PyBinSim
def pyBinSim_Controller():

    try:

        with open("C:/Users/Media_Project/BRIR_synthese_SDM_fixPos_BinSim_example/03_BinSim_fixPos/pyBinSimSetting_SourcesListenerDefs.txt", "r") as tf:
            values = tf.read().split(',')

        count = 0
        numChan = int(values[0])
        count += 1

        print(numChan)

        # Initializing values 
        sourceOrientation = np.array([[0]*3]*numChan)
        sourcePosition = np.array([[0]*3]*numChan)
        listenerPosition = np.array([0]*3)
        values_yaw = np.array([0]*3)
        values_pitch = np.array([0] * 3)
        for idxC in range(0, numChan):
            for idxP in range(0, 3):
                sourcePosition[idxC][idxP] = int(values[count])
                count = count + 1
        for idxC in range(0, numChan):
            for idxP in range(0, 3):
                sourceOrientation[idxC][idxP] = int(values[count])
                count = count + 1
        for idxP in range(0, 3):
            listenerPosition[idxP] = int(values[count])
            count = count + 1
        for idxP in range(0, 3):
            values_yaw[idxP] = int(values[count])
            count = count + 1
        for idxP in range(0, 3):
            values_pitch[idxP] = int(values[count])
            count = count + 1

        sourceOrientation = sourceOrientation.tolist()
        sourcePosition = sourcePosition.tolist()
        listenerPosition = listenerPosition.tolist()
        values_yaw = values_yaw.tolist()
        values_pitch = values_pitch.tolist()

        print(sourcePosition , '\n')
        print(sourceOrientation, '\n')
        print(listenerPosition, '\n')
        print(values_yaw, '\n')
        print(values_pitch, '\n')

        availableAngles_yaw = range(values_yaw[0], values_yaw[1], values_yaw[2])  # Angle range and step size
        availableAngles_pitch = range(values_pitch[0], values_pitch[1], values_pitch[2])  # Angle range and step size
        availableAngles_roll = range(-180, 180, 5)

        availablePositions = range(0, 1, 1)  # Position range and step size




        # Create OSC client
        ip = "127.0.0.1"
        ports = [10000, 10001, 10002, 10003]

        port_listening = 9010

        reset_message = udp_client.SimpleUDPClient(ip, port_listening)
        oscClient_ds = udp_client.SimpleUDPClient(ip, ports[0])
        oscClient_early = udp_client.SimpleUDPClient(ip, ports[1])
        oscClient_late = udp_client.SimpleUDPClient(ip, ports[2])
        oscClient_misc = udp_client.SimpleUDPClient(ip, ports[3])


#################################################### GET DATA FROM SENSOR ################################################################################
        def Head_tracker(address, *args):
            global yaw_sensor, pitch_sensor, roll_sensor
            yaw_sensor = args[0]
            pitch_sensor = args[1]
            roll_sensor = args[2]
            
            

        dispatcher = Dispatcher()
        dispatcher.map("/ypr", Head_tracker)

        # Define a function to start the OSC server in a separate thread
        def start_osc_server(stop_event):
            server =  osc_server.ThreadingOSCUDPServer(("localhost", 8000), dispatcher)
            while not stop_event.is_set():
                server.handle_request()
            server.server_close()

        # Create a stop event to signal the OSC server thread to stop running
        stop_event = threading.Event()

        # Start_Head_Tracking the OSC server thread
        osc_thread = threading.Thread(target=start_osc_server, args=(stop_event,))
        osc_thread.start()

######################################################################################################################################################
        

#################################################### GET DATA FROM Realsense ################################################################################
        def Body_tracker(stop_event):
            # Declare RealSense pipeline, encapsulating the actual device and sensors

            global roll_out_rs,yaw_offset_rs,pitch_offset_rs,roll_offset_rs,yaw_out_rs,pitch_out_rs,roll_rs,yaw_rs,pitch_rs

            pipe = rs.pipeline()

            # Build config object and request pose data_rs
            cfg = rs.config()
            cfg.enable_stream(rs.stream.pose)

            # Start streaming with requested config
            pipe.start(cfg)

            # Offsets for OSC values
            pitch_rs = 0
            yaw_rs = 0
            roll_rs = 0

            try:
                while not stop_event.is_set():

                    time.sleep(0.01) ####Change accordingly
                    

                    frames = pipe.wait_for_frames() 
                    pose = frames.get_pose_frame()
                    data_rs = pose.get_pose_data()

                    w = data_rs.rotation.w
                    x = -data_rs.rotation.z
                    y = data_rs.rotation.x
                    z = -data_rs.rotation.y

                    pitch_rs = -m.asin(2.0 * (x * z - w * y)) * 180.0 / m.pi
                    roll_rs = m.atan2(2.0 * (w * x + y * z), w * w - x * x - y * y + z * z) * 180.0 / m.pi
                    yaw_rs = m.atan2(2.0 * (w * z + x * y), w * w + x * x - y * y - z * z) * 180.0 / m.pi


                    pitch_current_rs = (pitch_rs - pitch_offset_rs)
                    yaw_current_rs   = (yaw_rs   - yaw_offset_rs)
                    roll_current_rs  = (roll_rs  - roll_offset_rs)
                    yaw_out_rs = yaw_current_rs



            except KeyboardInterrupt:
                pipe.stop()   




        stop_event_rs = threading.Event()
        rs_thread = threading.Thread(target=Body_tracker, args=(stop_event_rs,))
        rs_thread.start()


######################################################################################################################################################
        

          
            
        def adjust_volume(var):  # function to adjust volume
            loudness_label.config(text="Current Loudness: " + str(var))
            oscClient_misc.send_message("/pyBinSimLoudness", float(var))

        def Body_tracker_toggle(): # function to toggle body tracking

            global body_orientation
            body_orientation = not body_orientation
            if body_orientation:
                btn_body_orientation.config(text="Turn off Dynamic Pose Tracking")
            else:
                btn_body_orientation.config(text="Turn on Dynamic Pose Tracking")

            label_body.config(text=f"Body Dynamics is {'On' if body_orientation else 'Off'}")




        def Start_Head_Tracking(): # function to start/stop head tracking and begin application
            global stop_loop
            if sensor_frame["text"] == "Start Head Tracking":
                # Start the animation
                for i in range(3):
                    sensor_frame.config(background="#FF0000")
                    root.after(10, sensor_frame.config, {"background": "#BDFCBF"})
                    root.after(10, sensor_frame.config, {"background": "#FF5733"})
                # Update the button text and start the head tracking loop
                sensor_frame.config(text="Stop Head Tracking")
                label.config(text="Head Rotation Angle")
                stop_loop = False
                while sensor_frame and sensor_frame["text"] == "Stop Head Tracking" and not stop_loop:
                    update_data()
                    update_arrow(yaw_out) #yaw_sensor
                    root.update()
                    time.sleep(0.25)
            else:
                # Update the button text and stop the head tracking loop
                sensor_frame.config(text="Start Head Tracking")
                root.after(0, sensor_frame.config, {"background": "#BDFCBF"})
                label.config(text="Head Tracking Off")



        def Close(): # function to close application and binsim and then exit from terminal
            global stop_loop
            stop_loop = True
            oscClient_misc.send_message("/close", str("True"))
            stop_event.set()  # Set the stop event to signal the OSC server thread to stop running
            stop_event_rs.set()
            rs_thread.join()
            osc_thread.join()  # Wait for the OSC server thread to stop running
            root.quit()  # Quit the main window

        
        def set_travel_mode(mode):# function to enable travel mode, system will aautomaticall recenter iteself
            
            reset_message.send_message("/travel", mode)
            if mode == 0:
                status_var.set("Adaptive Sound Control : OFF")
            elif mode == 1:
                status_var.set("Adaptive Sound Control : Walking")
            elif mode == 2:
                status_var.set("Adaptive Sound Control : Travelling")

        reset_message.send_message("/travel", 0) # Initializing it as Off 


        def reset(): # function to reset the head orientation
            reset_message.send_message("/zero",0)
            update_data()
            update_arrow(0)

        def reset_offsets(): # function to reset the body tracker
            global yaw_offset_rs, pitch_rs, yaw_rs,roll_offset_rs
            roll_offset_rs = roll_rs
            yaw_offset_rs = yaw_rs
            pitch_offset_rs = pitch_rs

        def reset_both(): # function to reset both head and body tracker
            reset()
            reset_offsets()

        def pause_play_audio(): # function to toggle audio playback
            global chk
            chk = not chk
            if chk:
                btn_pause_play_audio.config(text="Play", background="#32CD32")
                oscClient_misc.send_message("/pyBinSimPauseAudioPlayback", "True")
            else:
                btn_pause_play_audio.config(text="Pause", background="#FFE4B5")
                oscClient_misc.send_message("/pyBinSimPauseAudioPlayback", "False")

################ uncomment  for testing purpose for binaural audio #############################
        # def pause_play_convolution():
        #     global pause_conv
        #     if btn_pause_play_conv["text"] == "Pause Convolution":
        #         btn_pause_play_conv.config(text="Play Convolution", background="#32CD32")
        #         pause_conv = True
        #         oscClient_misc.send_message("/pyBinSimPauseConvolution", str(pause_conv))
        #     else:
        #         btn_pause_play_conv.config(text="Pause Convolution", background="#FFD700")
        #         pause_conv = False
        #         oscClient_misc.send_message("/pyBinSimPauseConvolution", str(pause_conv))


        def loop_toggle(): # function to toggle the loop of audio playback

            global loop
            loop = not loop
            if loop:
                btn_loop_toggle.config(text="Turn off loop")
            else:
                btn_loop_toggle.config(text="Turn on loop")
            oscClient_misc.send_message("/pyBinSimloopAudio", str(loop))

        def next_audio():# function to play next audio

            global played_file,chk
            global path
            global files
            global numfiles
            played_file += 1
            if played_file > numfiles-1:
                played_file = 0   
            oscClient_misc.send_message("/pyBinSimPauseAudioPlayback", "True")
            time.sleep(0.2)
            oscClient_misc.send_message("/pyBinSimFile", str(path+files[played_file]))
            time.sleep(0.2)
            if not chk:
                oscClient_misc.send_message("/pyBinSimPauseAudioPlayback", "False")
            else:
                 oscClient_misc.send_message("/pyBinSimPauseAudioPlayback", "True")
            print(path + files[played_file])

        def prev_audio():# function to previous audio
            
            global played_file
            global path
            global files
            global numfiles
            played_file -= 1
            if played_file < 0:
                    played_file = numfiles-1
            oscClient_misc.send_message("/pyBinSimPauseAudioPlayback", "True")
            time.sleep(0.2)
            oscClient_misc.send_message("/pyBinSimFile", str(path+files[played_file]))
            time.sleep(0.2)
            if not chk:
                oscClient_misc.send_message("/pyBinSimPauseAudioPlayback", "False")
            else:
                 oscClient_misc.send_message("/pyBinSimPauseAudioPlayback", "True")
            print(path + files[played_file])


        # def next_room(): # function to change to next room (Just an additional function, can be used as next room)

        #     global selected_room_file
        #     global num_room_files
        #     global room_files
        #     global filter_database_path

        #     selected_room_file += 1
        #     if selected_room_file > num_room_files-1:
        #         selected_room_file = 0

        #     oscClient_misc.send_message("/pyBinSimPauseAudioPlayback", "True")
        #     time.sleep(0.4)
        #     oscClient_misc.send_message("/newroom", str(filter_database_path+room_files[selected_room_file]))
        #     time.sleep(1.5)
        #     oscClient_misc.send_message("/pyBinSimPauseAudioPlayback", "False")
        #     print(filter_database_path+room_files[selected_room_file])
        #     current_room_label.config(text="Current Room: " + room_files[selected_room_file].replace("_5LS_M_binsim_struct.mat", "").replace("SDM_", ""), font=("Arial", 8,"bold"),fg="black") ##0000FF

        def select_room(selected_room_file): # function to select the room file given by user
                global one_time_update
                oscClient_misc.send_message("/pyBinSimPauseAudioPlayback", "True")
                time.sleep(0.4)
                oscClient_misc.send_message("/newroom", str(filter_database_path+room_files[selected_room_file]))
                one_time_update =1
                time.sleep(1.5)
                oscClient_misc.send_message("/pyBinSimPauseAudioPlayback", "False")
                print(filter_database_path+room_files[selected_room_file])
                current_room_label.config(text="Current Room: " + room_files[selected_room_file].replace("_5LS_M_binsim_struct.mat", "").replace("SDM_", ""), font=("Arial", 8,"bold"),fg="black") ##0000FF     

        def H1539():  # function to add to a button for this room
                  select_room(0)
        def H2505():  # function to add to a button for this room
                  select_room(1)
        def HL():  # function to add to a button for this room
                  select_room(2)
        def ML2_102():  # function to add to a button for this room
                  select_room(3)
        

        ####### can test reverb filter   ###########
        # def later_reverb_toggle():
        #     global one_time_update
        #     if one_time_update ==1:
        #         one_time_update =0
        #     elif one_time_update ==0:
        #          one_time_update =1
        #     else:
        #          pass
            



        def create_circle():# function to create a circle with angles for head tracking visvualization

            for angle in range(-180, 180, 20):
                x = center_x + radius * math.sin(math.radians(angle))
                y = center_y - radius * math.cos(math.radians(angle))
                canvas.create_oval(x-2, y-2, x+2, y+2, fill='white')
                canvas.create_text(x, y-10, text=str(angle), fill='white')

            # Create the arrow shape
            global arrow
            arrow = canvas.create_line(center_x, center_y, center_x, center_y - radius * 0.8, arrow=tk.LAST, fill='red')

            # Create the label for displaying the yaw_sensor value
            global yaw_label
            yaw_label = canvas.create_text(center_x, center_y, text='', fill='white', font=('Arial', 10, 'bold'))


        def update_arrow(yaw_out):# function to update the arrow of source position
            global arrow
            global yaw_label
            
            # Calculate the angle of the arrow in radians
            angle = math.radians(-yaw_out)

            # Calculate the position of the arrow tip
            x = center_x + radius * math.sin(angle)
            y = center_y - radius * math.cos(angle)

            # Update the arrow shape with the new coordinates
            canvas.coords(arrow, (center_x, center_y, x, y))

            yaw_current_arrow = min(availableAngles_yaw, key=lambda x: abs(x - yaw_out))

            # Update the yaw label with the new text and position
            canvas.itemconfigure(yaw_label, text=f'{-yaw_current_arrow:.1f}')
            canvas.coords(yaw_label, (center_x-12, center_y-6))

            # Update the canvas
            canvas.update()

        def update_data():# function to update the data for the pybinsim

            # pitch_current = (pitch - pitch_offset)
            # yaw_current   = (yaw   - yaw_offset)
            # roll_current  = (roll  - roll_offset)

            global body_orientation,yaw_out,one_time_update

            if body_orientation:

                yaw_current   = -(yaw_sensor + yaw_out_rs )
                pitch_current = (pitch_sensor - pitch_out_rs)
                roll_current  = (roll  - roll_out_rs)

                

            else:

                 
                yaw_current   = -(yaw_sensor )
                pitch_current = (pitch_sensor)
                roll_current  = (roll)
                 

            #Making range from -180 to 180

            if yaw_current >= 180:
                        yaw_current = yaw_current-360
            if pitch_current >= 180:
                        pitch_current = pitch_current-360
            if roll_current >= 180:
                        roll_current = roll_current-360

            if yaw_current <= -180:
                         yaw_current = yaw_current+360
            if pitch_current <= -180:
                         pitch_current = pitch_current+360
            if roll_current <= -180:
                         roll_current = roll_current+360


            # Choose nearest available data
            yaw_out = min(availableAngles_yaw, key=lambda x: abs(x - yaw_current))
            pitch_out = min(availableAngles_pitch,default=0, key=lambda x: abs(x - pitch_current))
            roll_out = min(availableAngles_roll, key=lambda x: abs(x - roll_current))



            
            for iChan in range(0, numChan):
                # send data to switch ds and early filter
                
                binSimParameters_ds = [iChan, yaw_out, pitch_out, 0, listenerPosition[0], listenerPosition[1], listenerPosition[2], sourceOrientation[iChan][0], sourceOrientation[iChan][1], sourceOrientation[iChan][2],  sourcePosition[iChan][0], sourcePosition[iChan][1] ,sourcePosition[iChan][2],0,0,0]
                binSimParameters_early = [iChan, yaw_out, pitch_out, 0, listenerPosition[0], listenerPosition[1], listenerPosition[2], sourceOrientation[iChan][0], sourceOrientation[iChan][1], sourceOrientation[iChan][2],  sourcePosition[iChan][0], sourcePosition[iChan][1] ,sourcePosition[iChan][2],0,0,0]

                # binSimParameters_ds = [iChan, 90, pitch_out, 0, listenerPosition[0], listenerPosition[1], listenerPosition[2], sourceOrientation[iChan][0], sourceOrientation[iChan][1], sourceOrientation[iChan][2],  sourcePosition[iChan][0], sourcePosition[iChan][1] ,sourcePosition[iChan][2],0,0,0]
                # binSimParameters_early = [iChan, 90, pitch_out, 0, listenerPosition[0], listenerPosition[1], listenerPosition[2], sourceOrientation[iChan][0], sourceOrientation[iChan][1], sourceOrientation[iChan][2],  sourcePosition[iChan][0], sourcePosition[iChan][1] ,sourcePosition[iChan][2],0,0,0]


                oscClient_ds.send_message("/pyBinSim_ds_Filter", binSimParameters_ds)
                oscClient_early.send_message("/pyBinSim_early_Filter", binSimParameters_early)
                
                print(binSimParameters_ds, "\n")

                if one_time_update == 1:
                # send data to switch late filter
                    # print(one_time_update)
                    binSimParameters_late = [iChan, 0, 0, 0, listenerPosition[0], listenerPosition[1], listenerPosition[2], sourceOrientation[iChan][0], sourceOrientation[iChan][1], sourceOrientation[iChan][2],  sourcePosition[iChan][0], sourcePosition[iChan][1] ,sourcePosition[iChan][2],0,0,0]
                    # print(binSimParameters_late)
                    oscClient_late.send_message("/pyBinSim_late_Filter", binSimParameters_late)
                    print("Reverb update: ", "\n",binSimParameters_late, "\n")

            one_time_update = 0
                #print(binSimParameters_late)

            




        root = ctk.CTk()
        root.configure(bg='#F5F5F5')
        root.title("Pybinsim Control")
        root.protocol("WM_DELETE_WINDOW", Close)

        # Defining a common frame

        frame = tk.Frame(root)
        frame.pack(fill="both", expand=True)


        # Start_Head_Tracking 

        sensor_frame = tk.Frame(frame)
        sensor_frame.pack(fill="both")
        sensor_frame = tk.Button(sensor_frame, text="Start Head Tracking", command=Start_Head_Tracking)
        sensor_frame['background'] = '#BDFCBF'
        sensor_frame.pack(side="right", fill="both", expand=True,padx=18, pady=18)

        #pause/play audio

        audio_toggle_frame = tk.Frame(frame)
        audio_toggle_frame.pack(fill="both")

        btn_pause_play_audio = tk.Button(audio_toggle_frame, text="Pause", command=pause_play_audio)
        btn_pause_play_audio['background'] = '#FFE4B5'
        btn_pause_play_audio.pack(side="top", fill="both", expand=True,padx=4, pady=4)

        # Reset button

        start_reset_frame = tk.Frame(frame)
        start_reset_frame.pack(fill="both")

        btn_Reset = tk.Button(start_reset_frame, text="  Reset Head Orientation", command=reset)
        btn_Reset['background'] = '#FFE4B5'
        btn_Reset.pack(fill="both", expand=True,padx=4, pady=4)

######## can be used to check effects of late reverb ######################
        # reverb_toggle_frame = tk.Frame(frame)
        # reverb_toggle_frame.pack(fill="both")

        # reverb_toggle_button = tk.Button(reverb_toggle_frame, text="LR toggle", command=later_reverb_toggle)
        # reverb_toggle_button['background'] = '#FFE4B5'
        # reverb_toggle_button.pack(fill="both", expand=True,padx=4, pady=4)
###############################################################################

        reset_button = tk.Button(frame, text="Reset Body Orientation", command=reset_offsets)
        reset_button['background'] = '#FFE4B5'
        reset_button.pack(fill="both", expand=True,padx=4, pady=4)

        reset_button_both = tk.Button(frame, text="Reset All", command=reset_both)
        reset_button_both['background'] = '#FFE4B5'
        reset_button_both.pack(fill="both", expand=True,padx=4, pady=4)


        # Create the travel mode buttons
        btn_travel_off = tk.Button(frame, text="Turn Off Travel Mode", command=lambda: set_travel_mode(0))
        btn_travel_off['background'] = '#FFE4B5'
        btn_travel_off.pack(fill="both", expand=True, padx=4, pady=4)

        travel_mode_frame = tk.Frame(frame)
        travel_mode_frame.pack(fill="both")

        btn_travel_slow = tk.Button(travel_mode_frame, text="To GO (Slow Travel)", command=lambda: set_travel_mode(1))
        btn_travel_slow['background'] = '#FFE4B5'
        btn_travel_slow.pack(side="left", fill="both", expand=True, padx=4, pady=4)

        btn_travel_fast = tk.Button(travel_mode_frame, text="To GO (Fast Travel)", command=lambda: set_travel_mode(2))
        btn_travel_fast['background'] = '#FFE4B5'
        btn_travel_fast.pack(side="left", fill="both", expand=True, padx=4, pady=4)

        btn_body_orientation = tk.Button(frame, text="Turn on Dynamic Pose Tracking", command=Body_tracker_toggle)
        btn_body_orientation['background'] = '#FFE4B5'
        btn_body_orientation.pack(fill="both", expand=True,padx=4, pady=4)


        label_body = tk.Label(frame, text="Body Dynamics is Off")
        label_body.pack(fill="x", pady=4, anchor="center")


        # Create the travel mode status label
        status_var = tk.StringVar()
        status_label = tk.Label(frame, textvariable=status_var,font=("Arial", 8, "bold"),fg="black")
        status_label.pack(fill="both", expand=True, padx=4, pady=4)

        # Set the initial status text
        status_var.set("Adaptive Sound Control : OFF")

        # Increase and Decrease Loudness Slider

        frame_slider = tk.Frame(frame)
        frame_slider.pack(fill="both")
        slider_value = tk.DoubleVar(value=1)
        slider = tk.Scale(frame_slider, from_=0, to=15, resolution=1, orient="horizontal", variable=slider_value, command=lambda value: adjust_volume(value), troughcolor="#DDDDDD", sliderlength=30, sliderrelief="raised", highlightthickness=1, highlightcolor="#FFFFFF", bd=0)
        slider.pack(side="top", fill="both", expand=True,padx=6, pady=6)


        #ADD Text
        loudness_label = tk.Label(frame, text="Current Loudness: " + str(floudness), font=("Arial", 8, "bold"),fg="black")
        loudness_label.pack(fill="x", pady=4, anchor="center")

        # Audio Change buttons

        audio_frame = tk.Frame(frame)
        audio_frame.pack(fill="both")

        btn_prev_audio = tk.Button(audio_frame, text="Prev Audio", command=prev_audio)
        btn_prev_audio['background'] = '#ADD8E6'
        btn_prev_audio.pack(side="left", fill="both", expand=True,padx=4, pady=4)

        btn_next_audio = tk.Button(audio_frame, text="Next Audio", command=next_audio)
        btn_next_audio['background'] = '#ADD8E6'
        btn_next_audio.pack(side="right", fill="both", expand=True,padx=4, pady=4)

        # Pause/Play Convolution and Toggle Loop buttons
        conv_toggle_frame = tk.Frame(frame)
        conv_toggle_frame.pack(fill="both")

        # btn_pause_play_conv = tk.Button(conv_toggle_frame, text="Pause Convolution", command=pause_play_convolution)
        # btn_pause_play_conv['background'] = '#ADD8E6'
        # btn_pause_play_conv.pack(side="top", fill="both", expand=True,padx=4, pady=4)

        # Loop Toggle

        btn_loop_toggle = tk.Button(conv_toggle_frame, text="Turn off loop", command=loop_toggle)
        btn_loop_toggle['background'] = '#ADD8E6'
        btn_loop_toggle.pack(side="bottom", fill="both", expand=True, padx=4, pady=4)

        var = tk.StringVar()
        label = tk.Label(frame, textvariable=var,font=("Arial", 8, "bold"),fg="black")
        label.pack(fill="both", expand=True, padx=4, pady=4)

        # Set the initial status text
        var.set("Room Selection : ")

        left_rooms_frame = tk.Frame(frame)
        left_rooms_frame.pack(fill="both")

        H1539b_room = tk.Button(left_rooms_frame, text="H1539b", command=H1539,width=10)
        H1539b_room['background'] = '#FFA07A'
        H1539b_room.pack(side="left", fill="both", expand=True,padx=4, pady=4)

        H2505_room = tk.Button(left_rooms_frame, text="H2505", command=H2505,width=10)
        H2505_room['background'] = '#FFA07A'
        H2505_room.pack(side="right", fill="both", expand=True, padx=4, pady=4)

        # Rooms on the right
        right_rooms_frame = tk.Frame(frame)
        right_rooms_frame.pack(fill="both")


        HL_room = tk.Button(right_rooms_frame, text="HL", command=HL,width=10)
        HL_room['background'] = '#FFA07A'
        HL_room.pack(side="left", fill="both", expand=True,padx=4, pady=4)


        ML2_102_room = tk.Button(right_rooms_frame, text="ML2_102", command=ML2_102,width=10)
        ML2_102_room['background'] = '#FFA07A'
        ML2_102_room.pack(side="right", fill="both", expand=True,padx=4, pady=4)

############################ can be used as a simple button to change to next room #######################################
        # btn_next_room = tk.Button(next_room_frame, text="Change Room", command=next_room)
        # btn_next_room['background'] = '#FFA07A'
        # btn_next_room.pack(side="top", fill="both", expand=True,padx=4, pady=4)
###############################################################################################################

        # ADD TEXT

        current_room_label = tk.Label(frame, text="Current Room: " + room_files[selected_room_file].replace("_5LS_M_binsim_struct.mat", "").replace("SDM_", ""), font=("Arial", 8, "bold"),fg="black") #0000FF
        current_room_label.pack(fill="x", pady=6, anchor="center")


       # Create the canvas
        label = tk.Label(root, text="Head Tracking Off", bg='#F5F5F5', fg='black', font=('Helvetica', 10, 'italic', 'underline'))
        label.pack()
        canvas = tk.Canvas(root, width=300, height=300, bg='black')
        canvas.pack()

        create_circle()
        reset_message.send_message("/zero",0)

        root.mainloop()

    except Exception as e:
        exc_type, exc_value, exc_traceback = sys.exc_info()
        traceback.print_exception(exc_type, exc_value, exc_traceback)

###### the main core of pybinsim lies in pyBinSim processor
def pyBinSim_Processor ():

    import pybinsim
    import logging
    pybinsim.logger.setLevel(logging.DEBUG)    # defaults to INFO

    with pybinsim.BinSim('C:/Users/Media_Project/BRIR_synthese_SDM_fixPos_BinSim_example/03_BinSim_fixPos/pyBinSimSettings_isoperare.txt') as binsim:
        binsim.stream_start()

if __name__ == '__main__':

    process1 = Process(target=pyBinSim_Controller)
    process2 = Process(target=pyBinSim_Processor)

    process1.start()
    process2.start()

    process1.join()
    process2.join()