Install: (Stand 10.03.2022)

open anaconda prompt

conda create --name binsim python=3.9 numpy

activate binsim

pip install git+https://avt10.rz.tu-ilmenau.de/git/ehuebner/pybinsim.git@ConvolverMultisourceMat

pip install pyrealsense2
pip install scipy
pip install python-osc