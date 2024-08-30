
# Loudspeaker to Go

A virtual 5-channel loudspeaker setup designed for dynamic binaural synthesis during room traversal, simulating a realistic auditory experience.

## Project Overview

This media project focuses on developing a mobile, virtual loudspeaker setup for the playback of multi-channel audio content using dynamic binaural synthesis. The system aims to reproduce a 5-channel surround speaker setup over headphones, overcoming the limitations of traditional headphone listening by incorporating head and body tracking to maintain a consistent virtual sound environment.

## Key Features

- **5-Channel Virtual Loudspeaker System:** Simulates a surround sound environment over headphones.
- **Dynamic Binaural Synthesis:** Real-time adaptation to user head and body movements.
- **Virtual Room Acoustics:** Simulates different environments with customizable room settings.
- **User Interface:** Allows control over audio playback, room settings, and visualization of user orientation in the virtual space.

## Motivation and Introduction

Traditional headphone listening often leads to in-head localization, which limits the immersive experience. This project addresses these limitations by developing a system that allows users to experience virtual surround sound as if they were in the same room as the speakers, even while on the move.

## System Architecture and Design

The system is built on the pyBinSim tool, which handles real-time binaural synthesis. It consists of a portable setup involving sensors placed on a backpack and headphones to track the user's head and body movements. The system adjusts the audio output dynamically based on these movements, creating an immersive audio experience.

### Components

- **PyBinSim Processor:** Handles the core audio processing and binaural rendering.
- **PyBinSim Controller:** Manages user inputs, sensor data, and communication with the processor.
- **User Interface:** Developed using Tkinter, the UI allows users to interact with the system, control audio playback, change virtual environments, and visualize head movements.

## Experimental Setup and Validation

The system was tested in a controlled environment with multiple stages, each evaluating different aspects of the system's performance, including sound localization, stability, and user experience. The results were positive, with participants reporting a high level of immersion and sound quality.

### Test Stages

1. **Room Change Detection and Loudness Check:** Assessed the ability to detect changes in virtual room acoustics.
2. **Head Tracking:** Evaluated the stability and localization of sound sources as users moved their heads.
3. **Head and Body Tracking:** Tested the system's response to combined head and body movements, ensuring the sound environment adapted accurately.

## Installation

### Requirements

- **Hardware:** HP VR Backpack PC, Bridgehead Head Tracker, Intel RealSense T265 sensor.
- **Software:** Python 3.9, pyBinSim library, Tkinter for UI development.

### Setup Instructions

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/your-repo/Loudspeakers_2_GO.git
   cd Loudspeakers_2_GO
   ```

2. **Install Dependencies:**
   ```bash
   conda create --name binsim python=3.9 numpy
   conda activate binsim
   pip install pybinsim
   pip install customtkinter
   ```

3. **Run the System:**
   ```bash
   python main.py
   ```

## Folder Structure

```plaintext
Loudspeakers_2_GO/
├── 01 SDM IR RecTool/
├── 02 SDM BRIR QuantizedDOA/
├── 03 BinSim fixPos/
│   ├── UI for pyBinSim.py
│   ├── pyBinSimSetting SourcesListenerDefs.txt
│   └── pyBinSimSettings isoperare.txt
└── data/
    ├── HPIRs/
    ├── HRIRs/
    ├── RIRs/
    ├── SDMRenderedBRIRs/
    └── Signals/
```

## Usage

The system is designed to be portable and user-friendly. Users can control the system via the provided UI, which includes buttons for starting head tracking, adjusting audio playback, changing virtual rooms, and visualizing head movements.

### Basic Operations

- **Start Head Tracking:** Click the "Start Head Tracking" button to begin dynamic binaural rendering.
- **Change Room:** Select the desired virtual room from the UI to experience different acoustic environments.
- **Adjust Volume:** Use the slider to control the playback volume.
- **Reset Tracking:** Use the reset buttons to re-center the head or body orientation.

## Future Improvements

- **Latency Reduction:** Further optimization to reduce system latency.
- **Improved Sensors:** Integration of higher accuracy and lower latency sensors.
- **Wireless Operation:** Development of a wireless version of the system.
- **Enhanced Visualization:** Adding more visual feedback to assist with localization and user interaction.

## Contribution

Contributions to this project are welcome. Please follow the standard process of forking the repository, making changes, and submitting a pull request.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Acknowledgments

- **Supervisors:** Dr.-Ing. Stephan Werner, Dr.-Ing. Florian Klein
- **Contributors:** Pranav Sharma, Syed Muhammad Ahmed
- **Institution:** Technische Universität Ilmenau
