# UART & DC Motor Control System with ASIC Implementation

## 1. Project Overview
This repository contains a Verilog-based UART communication system integrated with a PWM DC Motor controller. 
Designed from the ground up, the system handles asynchronous serial communication (Baud rate: 9600, 16x oversampling) to receive commands via a Bluetooth module, mapping them to specific motor actions (Forward, Reverse, PWM speed control). 
Furthermore, the project encompasses a complete ASIC design flow using Cadence tools (Genus & Innovus), extending from RTL synthesis to Place & Route (P&R) and Post-Layout Gate-Level Simulation (GLS).

## 2. Key Features
* **Custom UART Transceiver:** Independent Rx/Tx modules utilizing an 11-bit frame (Start, 8-bit Data, Parity, Stop) with a robust finite state machine (FSM).
* **PWM Motor Controller:** Converts decoded UART bytes into directional logic and variable PWM duty cycles for L9110S motor drivers.
* **ASIC Physical Design:** Validated timing closure and physical implementation using standard cell libraries.

## 3. Critical Troubleshooting Log (Deep Dive)

### Issue 1: Simulation vs. Synthesis Mismatch in FSM State Transitions
* **Symptom:** In functional simulation, the FSM transitioned correctly. However, during FPGA hardware testing (verified via ILA), `state` advanced prematurely when `bit_index` reached 1 instead of 2.
* **Root Cause:** The `always @(*)` combinational logic for `next_state` lacked exhaustive `else` conditions. While the simulator processed this with zero-time delay, the synthesis tool generated unintended latches to "remember" the previous state. This physical latch introduced propagation delays and glitches, causing a race condition during the setup time of the state flip-flop.
* **Resolution:** Implemented completely defined combinational logic by adding explicit `else` statements for all conditions, ensuring pure combinational synthesis without latches.

### Issue 2: Duty Cycle Overwrite in Sequential Logic
* **Symptom:** The PWM duty cycle remained at 0 despite receiving speed increment/decrement commands (0x83, 0x84).
* **Root Cause:** Multiple non-blocking assignments (`<=`) targeted the `duty_cycle` register within the same clock cycle. The default `else { duty_cycle <= duty_cycle; }` at the end of the block continuously overwrote the newly updated values from the command decoder.
* **Resolution:** Restructured the sequential block into a strict priority hierarchy, guaranteeing that `duty_cycle` is assigned exactly once per clock cycle.

## 4. Future Architecture Upgrade
* **AMBA AXI4-Lite Integration:** Transitioning from a standalone MCU-FPGA interface to an SoC architecture. The UART and Motor controller modules will be packaged as AXI4-Lite slave peripherals, allowing direct memory-mapped control from the Zynq Processing System (ARM Cortex-A9).

-------

[프로젝트] Custom UART & DC Motor 제어 시스템 및 ASIC 설계 파이프라인 구축

1. 프로젝트 개요
개발 환경: Verilog HDL, Xilinx Vivado, Cadence (Genus, Innovus, Xcelium)
핵심 내용: Bluetooth 모듈을 통한 무선 명령(Baud rate 9600)을 수신하는 UART IP를 직접 설계하고, 이를 기반으로 DC 모터의 방향 및 PWM 속도를 제어하는 하드웨어 가속기 구현. 순수 RTL 설계를 넘어 ASIC Physical Design (합성, P&R, Post-GLS)까지 Full-flow 검증 완료.

2. 핵심 엔지니어링 역량 (Troubleshooting)
① 시뮬레이션과 실제 하드웨어(Synthesis)의 동작 불일치 원인 규명
* 현상: 기능 시뮬레이션에서는 정상 동작하던 FSM이 실제 FPGA 하드웨어(ILA 관찰)에서는 조건이 충족되지 않은 상태에서 다음 State로 넘어가는 현상 발생.
* 원인 분석: always @(*) 구문 내 불완전한 조건문(missing else)으로 인해 합성 툴이 의도치 않은 '래치(Latch)'를 생성함. 시뮬레이터는 Zero-time delay로 동작하여 문제를 숨겼으나, 실제 물리 회로에서는 래치로 인한 전파 지연(Propagation delay)과 글리치(Glitch)가 발생해 Race Condition을 유발함.
* 해결: 조합 논리(Combinational logic)의 모든 분기에 명확한 상태 지시(else 구문)를 추가하여 래치 생성을 원천 차단하고 안정적인 FSM 구축.

② 레지스터 덮어쓰기(Overwrite) 설계 결함 수정
* 현상: PWM 듀티 사이클 증감 명령(0x83, 0x84)을 수신해도 모터 속도가 변하지 않음.
* 원인 및 해결: 단일 Clock Cycle 내에서 동일한 레지스터(duty_cycle)에 대해 다중 Non-blocking 할당이 중첩되어 마지막 값이 덮어씌워지는 구조적 결함 파악. 할당 우선순위 구조를 단일화하여 1 Clock 당 1회의 업데이트만 발생하도록 RTL 아키텍처 재설계.

3. ASIC Flow 및 타이밍 검증 (Timing Closure)
* Synthesis (Genus): 설계 제약 조건(SDC)을 바탕으로 Gate-level Netlist 추출 및 Pre-layout STA 진행.

* Place & Route (Innovus): Floorplanning, Power Plan(Ring/Stripe), CTS(Clock Tree Synthesis), Routing 수행.

* Sign-off 검증: Parasitic RC 값이 반영된 SDF를 생성하여 Post-layout Gate-Level Simulation(GLS)을 수행, 실제 배선 지연이 포함된 상태에서의 타이밍 제약(Setup/Hold)을 최종 검증함.

4. 향후 아키텍처 고도화 (Scalability)
단독 제어(Standalone) 구조를 확장하여, 개발한 모듈을 AMBA AXI4-Lite Slave IP로 패키징. Zynq PS(ARM 코어)의 Memory-mapped 제어를 받는 완벽한 SoC 통합 시스템으로 업그레이드 예정.

* Board: ARM-Nucleo-F429ZI-board (STM32F429ZI)

