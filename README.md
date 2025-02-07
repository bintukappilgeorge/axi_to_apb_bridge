# axi_to_apb_bridge

This project implements an AXI to APB Bridge to enable seamless communication between AXI and APB protocols. The bridge buffers AXI transactions and converts them into APB transactions, ensuring proper synchronization between the two clock domains.

# Contents
* Introduction
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
  

