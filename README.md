# **WiFi OFDM 802.11a Standard Receiver**

## **1. Introduction**

This project involves the **design and implementation** of a **WiFi OFDM 802.11a Standard Receiver**. The system was designed according to the IEEE 802.11a specifications and developed for both software simulation and hardware implementation. The objective was to build a fixed-point receiver capable of achieving the data rate specified by the standard, excluding the encoding and puncturing stages.

## **2. Project Structure**

### **2.1 Documentation Folder**
This folder contains the thesis and documentation of everything done in the project.

### **2.2 Hardware Implementation Folder**
The hardware implementation folder includes:
- **Fixed-point simulation of the OFDM receiver.**
  - A file with synchronization and the full receiver system.
  - A folder containing only the receiver chain.
  - `do` files for testing that write memory contents to compare against Python floating-point and fixed-point reference models.

### **2.3 Python Models Folder**
This folder contains the high-level code for the system:
- **Two versions of the model:**
  - **Floating point** (for full accuracy).
  - **Fixed point** (compared against floating point for accuracy).
- **Accuracy goal**: Achieving **45 dB** comparison between floating and fixed-point models.
- **Python scripts and project skeleton** for testing.
- **Jupyter notebooks** to visualize the BER (Bit Error Rate) curves of the system.

## **3. Project Specifications**

### **3.1 Synchronization and Packet Detection**
- Utilizes **CORDIC** and a **correlator** for synchronization and packet detection.

### **3.2 Receiver Details**
- A **4-QAM receiver** with an **FFT engine**.
- The FFT engine is implemented using an **SDF Radix-2 algorithm**.
- The design achieves the required data rate as per the **IEEE 802.11a standard** (without encoding and puncturing stages).

## **4. Testing and Verification**
- **Hardware simulation** uses fixed-point models with `do` files for memory testing.
- **Python models** simulate both floating and fixed-point implementations for comparison and validation.
- **BER curves** demonstrate the performance of the receiver with the desired 45 dB accuracy.

