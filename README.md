# axi_to_apb_bridge

This project implements an AXI to APB Bridge to enable seamless communication between AXI and APB protocols. The bridge buffers AXI transactions and converts them into APB transactions, ensuring proper synchronization between the two clock domains.

# Contents
* Introduction
* Design
* Architecture
* AXI to APB Bridge Flow
* Synchronization Mechanism
* Testbench
* Simulation
* Outputs
* Future Enhancements
* Conclusion

# Introduction

The AXI to APB Bridge is designed to facilitate communication between an AXI bus and an APB bus. The AXI interface operates at a higher frequency (100MHz), whereas the APB interface runs at a lower frequency (50MHz). The bridge buffers transactions between the two domains using a FIFO structure, ensuring seamless data transfer despite clock domain differences.

# Design

The bridge is designed with the following characteristics:

* AXI Interface: Operates at 100MHz, supporting burst transfers with a 64-bit data bus and a 32-bit address bus.
  
* APB Interface: Operates at 50MHz, with a 32-bit data bus and a 32-bit address bus.
  
* Clock Domain Crossing: Synchronization between AXI and APB domains using Gray code conversion and FIFO buffering.
  
* FIFO Depth: Configurable FIFO buffer to handle data transfer efficiently. The FIFO depth is determined based on system requirements and latency considerations. In this design, the FIFO depth is 64 entries, and each entry stores 32-bit data.
  
* Synchronization Mechanism: Uses binary to Gray and Gray to binary conversion before transferring over synchronizers to ensure safe data exchange.

    | Feature | AXI Protocol| APB Protocol |
    |----------|----------|----------|
    | Clock Speed   | 100MHz  | 50MHz   |
    | Data Bus Width   | 64-bit   | 32-bit   |
    | Address Bus  | 32-bit   | 32-bit  |
    | Transfer Type  | Burst  | Single   |
    | Handshaking   | Complex  | Simple   |
    | Performance   | High-speed   | Low-power   |
    | Read/Write Ops | Concurrent   | Sequential   |


# Architecture

The bridge consists of the following key modules:

* AXI Interface Module: Captures incoming AXI write transactions and stores them in a FIFO buffer.

* FIFO Module: A dual-clock FIFO buffer that temporarily holds data and addresses until they can be processed by the APB interface.

* Binary to Gray & Gray to Binary Converter Modules: Convert binary pointers to Gray code before synchronization and convert them back to binary after synchronization.

* APB Interface Module: Reads from the FIFO and issues corresponding transactions to the APB bus.

* Synchronizer Modules: Used to safely transfer write and read pointers across clock domains.

* Full and Empty Logic: Ensures proper flow control by managing FIFO status flags.

![Untitled drawing](https://github.com/user-attachments/assets/1f3c47eb-5ad0-4601-b298-19ae02c042f7)

# AXI to APB Bridge Flow

1. AXI Write Transaction:
   * When an AXI write transaction is received, the bridge extracts the address and data.
   * The address and lower 32 bits of data are stored in the FIFO buffer.
   * The axi_wready signal is asserted when the FIFO has space available.
2. FIFO Management:
   * The FIFO buffer temporarily holds the transactions before they are processed by the APB interface.
   * Gray-coded pointers are used for synchronization between AXI and APB clock domains.
3. APB Read Transaction:
   * When the APB interface is ready (apb_ready signal is high), data is read from the FIFO and written to the APB bus.
   * The apb_wvalid signal is asserted during the transfer.
  
# Synchronization Mechanism

![Untitled drawing1](https://github.com/user-attachments/assets/66719499-f13f-48c9-b141-23569f136f2c)

Since AXI and APB operate in different clock domains, pointer synchronization is required:

* Binary to Gray Code Conversion: Before synchronization, the write and read pointers are converted to Gray code to reduce metastability issues.
  
* Write Pointer Synchronizer: Ensures the write pointer from the AXI domain is correctly interpreted in the APB domain.
  
* Read Pointer Synchronizer: Ensures the read pointer from the APB domain is correctly interpreted in the AXI domain.
  
* Gray to Binary Code Conversion: After synchronization, the pointers are converted back to binary for proper FIFO operation.

# Full & Empty Logic

![Untitled drawing2](https://github.com/user-attachments/assets/a704a6b4-f3b4-4fa4-92b3-d804e857b8de)


* FIFO Full Condition: The FIFO is full when the write pointer reaches the read pointer plus the FIFO depth.

* FIFO Empty Condition: The FIFO is empty when the read pointer matches the synchronized write pointer.

# Testbench

A SystemVerilog and Verilog testbench has been provided to verify the functionality of the AXI to APB Bridge. The testbench includes:

* Clock and Reset Generation

* AXI Write Transactions

* FIFO Data Verification

* APB Write Transactions

* Assertions for Functional Coverage

