# ARM-FPGA Integrated Control System: UART & DC Motor PWM Control

## 1. Project Overview
This repository contains a heterogeneous system integration project utilizing an **ARM Cortex-M MCU (STM32F429ZI)** and an **FPGA (Zynq-7000)**. 
Designed from the ground up, the system enables wireless DC motor control. The ARM board acts as the control plane, transmitting command data via Bluetooth. The FPGA's Programmable Logic (PL) acts as a hardware accelerator, utilizing a custom-designed asynchronous UART transceiver (Baud rate: 9600, 16x oversampling) to receive these commands and map them to specific motor actions (Forward, Reverse, PWM speed control).
Furthermore, the project encompasses a complete ASIC design flow using Cadence tools (Genus & Innovus), extending from RTL synthesis to Place & Route (P&R) and Post-Layout Gate-Level Simulation (GLS).

* **Hardware Boards:** Zynq-7000 FPGA Board, ARM-Nucleo-F429ZI-board (STM32F429ZI)
* **EDA Tools:** Xilinx Vivado, Cadence (Genus, Innovus, Xcelium)

## 2. System Architecture
* **Command Source (ARM/STM32):** Processes user input and generates control signals (numeric data), formatted for UART transmission.
* **Wireless Bridge (Bluetooth):** Facilitates asynchronous wireless data transmission between the MCU and the FPGA.
* **Hardware Accelerator (FPGA PL):**
  * **Custom UART Transceiver:** Independent Rx/Tx modules utilizing an 11-bit frame (Start, 8-bit Data, Parity, Stop) with a robust finite state machine (FSM).
  * **PWM Motor Controller:** Converts decoded UART bytes into directional logic and variable PWM duty cycles for L9110S motor drivers.

## 3. Critical Troubleshooting Log (Deep Dive)

### Issue 1: Metastability in Heterogeneous Interfacing
* **Symptom:** Occasional erratic motor behavior when receiving commands from the external ARM board, despite clean functional simulation results.
* **Root Cause:** The system involves asynchronous communication between two completely independent clock domains (STM32 clock vs. FPGA PCLK). The incoming UART signal from the Bluetooth module was not synchronized with the FPGA's internal clock, leading to Metastability at the first flip-flop stage of the UART Rx module.
* **Resolution:** Implemented a **2-stage Flip-Flop Synchronizer** at the `rx` input signal to ensure stable signal transitions and prevent meta-stable states from propagating into the FSM logic.

### Issue 2: Simulation vs. Synthesis Mismatch in FSM State Transitions
* **Symptom:** In functional simulation, the FSM transitioned correctly. However, during FPGA hardware testing (verified via ILA), `state` advanced prematurely when `bit_index` reached 1 instead of 2.
* **Root Cause:** The `always @(*)` combinational logic for `next_state` lacked exhaustive `else` conditions. While the simulator processed this with zero-time delay, the synthesis tool generated unintended latches to "remember" the previous state. This physical latch introduced propagation delays and glitches, causing a race condition during the setup time of the state flip-flop.
* **Resolution:** Implemented completely defined combinational logic by adding explicit `else` statements for all conditions, ensuring pure combinational synthesis without latches.

### Issue 3: Duty Cycle Overwrite in Sequential Logic
* **Symptom:** The PWM duty cycle remained at 0 despite receiving speed increment/decrement commands (0x83, 0x84).
* **Root Cause:** Multiple non-blocking assignments (`<=`) targeted the `duty_cycle` register within the same clock cycle. The default `else { duty_cycle <= duty_cycle; }` at the end of the block continuously overwrote the newly updated values from the command decoder.
* **Resolution:** Restructured the sequential block into a strict priority hierarchy, guaranteeing that `duty_cycle` is assigned exactly once per clock cycle.

## 4. Future Architecture Upgrade
* **AMBA AXI4-Lite Integration:** Transitioning from a standalone MCU-FPGA interface to an SoC architecture. The UART and Motor controller modules will be packaged as AXI4-Lite slave peripherals, allowing direct memory-mapped control from the Zynq Processing System (ARM Cortex-A9).

-------

[프로젝트] Custom UART & DC Motor 제어 시스템 및 ASIC 설계 파이프라인 구축

1. 프로젝트 개요
개발 환경: Verilog HDL, Xilinx Vivado, Cadence (Genus, Innovus, Xcelium)
타겟 보드: Zynq-7000 FPGA, ARM-Nucleo-F429ZI-board (STM32F429ZI)
핵심 내용: ARM Cortex-M(STM32)과 FPGA를 결합한 이종 시스템(Heterogeneous System) 통합 설계. STM32에서 전송한 무선 제어 명령을 수신하기 위해 FPGA(PL) 내부에 UART IP를 직접 설계하고, 이를 기반으로 DC 모터의 방향 및 PWM 속도를 제어하는 하드웨어 가속기를 구현함. 순수 RTL 설계를 넘어 ASIC Physical Design (합성, P&R, Post-GLS)까지 Full-flow 검증 완료.

2. 핵심 엔지니어링 역량 (Troubleshooting)
① 이종 플랫폼 간 비동기 통신 시 발생하는 Metastability 해결
현상: 기능 시뮬레이션에서는 완벽히 동작하던 코드가 실제 ARM 보드와 블루투스로 통신할 때 간헐적인 오작동(모터 제어 튐 현상) 발생.
원인 및 해결: STM32와 FPGA가 서로 다른 독립적인 클럭 도메인을 사용함에 따라, 외부에서 비동기적으로 인가되는 UART 수신 신호가 FPGA 내부 플립플롭의 Setup/Hold 타임을 위반하여 Metastability(메타스테이블) 상태를 유발함. 이를 방지하기 위해 UART Rx 입력단에 **2-stage Flip-Flop 동기화 회로(Synchronizer)**를 설계하여 외부 신호를 FPGA 클럭 도메인으로 안전하게 동기화함.
② 시뮬레이션과 실제 하드웨어(Synthesis)의 동작 불일치 원인 규명
현상: FSM이 실제 FPGA 하드웨어(ILA 관찰)에서는 조건이 충족되지 않은 상태에서 다음 State로 넘어가는 현상 발생.
원인 및 해결: always @(*) 구문 내 불완전한 조건문(missing else)으로 인해 합성 툴이 의도치 않은 '래치(Latch)'를 생성함. 시뮬레이터는 Zero-time delay로 동작하여 문제를 숨겼으나, 실제 물리 회로에서는 래치로 인한 전파 지연과 글리치가 발생함. 모든 분기에 명확한 상태 지시(else)를 추가하여 래치 생성을 원천 차단.
③ 레지스터 덮어쓰기(Overwrite) 설계 결함 수정
원인 및 해결: 단일 Clock Cycle 내에서 동일한 레지스터(duty_cycle)에 대해 다중 Non-blocking 할당이 중첩되어 마지막 값이 덮어씌워지는 구조적 결함 파악. 할당 우선순위 구조를 단일화하여 1 Clock 당 1회의 업데이트만 발생하도록 RTL 아키텍처 재설계.

3. ASIC Flow 및 타이밍 검증 (Timing Closure)
Synthesis (Genus): 설계 제약 조건(SDC)을 바탕으로 Gate-level Netlist 추출 및 Pre-layout STA 진행.
Place & Route (Innovus): Floorplanning, Power Plan(Ring/Stripe), CTS(Clock Tree Synthesis), Routing 수행.
Sign-off 검증: Parasitic RC 값이 반영된 SDF를 생성하여 Post-layout Gate-Level Simulation(GLS)을 수행, 실제 배선 지연이 포함된 상태에서의 타이밍 제약(Setup/Hold)을 최종 검증함.

4. 향후 아키텍처 고도화 (Scalability)
단독 제어(Standalone) 구조를 확장하여, 개발한 모듈을 AMBA AXI4-Lite Slave IP로 패키징. Zynq PS(ARM 코어)의 Memory-mapped 제어를 받는 완벽한 SoC 통합 시스템으로 업그레이드 예정.

* Board: Zynq-7000 & ARM-Nucleo-F429ZI-board (STM32F429ZI)

