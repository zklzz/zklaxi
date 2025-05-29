## Overview
基于 AXI 总线协议的 3x3 交叉矩阵模块，支持高性能片上互连，关键特性包括：
- **全功能 AXI4 支持**
- **高级传输控制**：
  - 突发传输类型：FIXED/INCR/WRAP
  - Outstanding 传输（读/写通道独立配置）
  - 读/写乱序完成（Out-of-order completion）
  - 数据交织（Interleaving）
  - SSPID（Single Slave per ID）处理
- **4K 边界处理**：
  - 自动事务拆分（主机视角为 1 个事务，从机视角为 2 个事务）
  - 符合 ARM 架构规范
- **动态配置**：
  - 通过 APB 总线实时配置访问权限
  - 
- **AXI2AHB Bridge**：
  - AXI 端支持乱序和交织
  - AHB 端支持 HBURST 类型（SINGLE/INCR/WRAP）
  - 自动处理 AHB 边界检测