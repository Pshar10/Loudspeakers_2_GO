# First import the library
from pythonosc import osc_message_builder
from pythonosc import udp_client
import pyrealsense2 as rs
import math as m
import numpy as np
import msvcrt
import time



def start_tracker():
	# Declare RealSense pipeline, encapsulating the actual device and sensors
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
	pitch_offset_rs=0
	yaw_offset_rs=0
	roll_offset_rs=0

	reset_yaw =0

	try:
		while 1:

			time.sleep(0.1)
			# Wait for the next set of frames from the camera
			frames = pipe.wait_for_frames()
			pose = frames.get_pose_frame()
			data_rs = pose.get_pose_data()

			w = data_rs.rotation.w
			x = -data_rs.rotation.z
			y = data_rs.rotation.x
			z = -data_rs.rotation.y

			pitch_rs = -m.asin(2.0 * (x * z - w * y)) * 180.0 / m.pi
			yaw_rs = m.atan2(2.0 * (w * x + y * z), w * w - x * x - y * y + z * z) * 180.0 / m.pi
			roll_rs = m.atan2(2.0 * (w * z + x * y), w * w + x * x - y * y - z * z) * 180.0 / m.pi



			pitch_current_rs = (pitch_rs - pitch_offset_rs)
			yaw_current_rs   = (yaw_rs   - yaw_offset_rs)
			roll_current_rs  = (roll_rs  - roll_offset_rs)



			# yaw_adj = min(availableAngles_yaw, key=lambda x: abs(x - yaw_current_rs))



			print('yaw_real_sense : ', roll_current_rs)

			if msvcrt.kbhit():
				char = msvcrt.getch()
				#print(ord(char))
				# Key 'n' sets zero pos and pose
				if ord(char) == 110:
					pitch_offset_rs = pitch_rs
					yaw_offset_rs = yaw_rs
					roll_offset_rs = roll_rs

	except KeyboardInterrupt:
		pipe.stop()



if __name__ == "__main__":
	start_tracker()
