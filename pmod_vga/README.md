# PMOD VGA Demo for PYNQ Z1

这是一个使用 Digilent Pmod VGA 的演示项目，可以在 PYNQ Z1 开发板上显示多种图案。

## 硬件连接

### Pmod VGA 引脚分配
Pmod VGA 使用两个 Pmod 连接器（12 个引脚）：

**连接器 A (JA) - 红色和蓝色通道：**
- JA1-JA4: Red[0:3] (4位红色)
- JA7-JA10: Blue[0:3] (4位蓝色)

**连接器 B (JB) - 绿色通道和同步信号：**
- JB1-JB4: Green[0:3] (4位绿色)
- JB7: HSync (水平同步)
- JB8: VSync (垂直同步)

### XDC 约束文件说明

#### 时钟约束
```xdc
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports CLK_125MHZ_FPGA]
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports CLK_125MHZ_FPGA]
```
- **H16**: 物理引脚位置，连接到 125 MHz 系统时钟
- **LVCMOS33**: 3.3V CMOS 逻辑电平标准
- **period 8.00**: 时钟周期 8 ns (1/125MHz = 8ns)
- **waveform {0 4}**: 时钟波形，0ns 上升沿，4ns 下降沿（50% 占空比）

#### 按钮映射
4 个板载按钮映射到引脚 D19, D20, L20, L19，用于切换 VGA 显示图案。

#### LED 映射
4 个板载 LED 映射到引脚 R14, P14, N16, M14，显示当前按钮状态。

#### Pmod Header JA - VGA 红色和蓝色通道
**红色通道 (4位):**
- vga_r[0-3] → Y18, Y19, Y16, Y17

**蓝色通道 (4位):**
- vga_b[0-3] → U18, U19, W18, W19

#### Pmod Header JB - VGA 绿色通道和同步信号
**绿色通道 (4位):**
- vga_g[0-3] → W14, Y14, T11, T10

**同步信号:**
- **vga_hs** (水平同步) → V16
- **vga_vs** (垂直同步) → W16

**总结**: Pmod VGA 使用 2 个 Pmod 连接器（JA 和 JB），提供 12位颜色（每通道4位 RGB）和 2 个同步信号（HSync 和 VSync），所有信号使用 LVCMOS33 (3.3V) 标准。

## VGA 时序

- 分辨率：640x480 @ 59.5Hz
- 标准时序：640x480 @ 60Hz (需要 25.175 MHz 像素时钟)
- 实际时钟：25 MHz (125 MHz / 5)
- 颜色深度：12位 (每个通道 4 位)
- 同步极性：负极性 (active low)

**注意**：使用 25 MHz 而非标准的 25.175 MHz，实际刷新率约为 59.5 Hz。
刷新率 = 25 MHz / (800 × 525) ≈ 59.5 Hz

## 演示图案

使用板上的按钮来切换不同的显示图案：

1. **BUTTONS[1:0] = 00**: 彩色条纹
   - 白色、黄色、青色、绿色、洋红、红色、蓝色、黑色

2. **BUTTONS[1:0] = 01**: 渐变图案
   - 水平和垂直渐变混合

3. **BUTTONS[1:0] = 10**: 棋盘格
   - 黑白相间的棋盘格图案

4. **BUTTONS[1:0] = 11**: 网格图案
   - 白色网格线，上半部分红色，下半部分绿色

## LED 指示

- LEDS[3:0]: 显示按钮状态（直接镜像 BUTTONS[3:0]）

## 编译和下载

### 仿真测试
```bash
make test
```

这将运行 Icarus Verilog 仿真并生成波形文件 `testbench.fst`。

### 综合和实现
```bash
make build
```

这将使用 Vivado 进行综合、实现，并生成比特流文件 `z1top.bit`。

### 下载到 FPGA
在 Vivado Hardware Manager 中打开硬件连接，然后下载生成的 `z1top.bit` 文件。

或者使用命令行：
```bash
make program
```

## 故障排除

### 显示器无图像
1. 检查 Pmod VGA 连接是否正确
2. 确认显示器支持 640x480@60Hz
3. 检查 VGA 线缆连接

### 图像闪烁或不稳定
1. 检查时钟分频是否正确
2. 确认约束文件中的时钟定义正确
3. 可能需要调整时序约束

### 颜色不正确
1. 检查 RGB 引脚分配
2. 确认 Pmod 连接器位置正确

## 技术细节

- **时钟管理**: 使用简单的计数器从 125 MHz 生成 ~25 MHz 像素时钟
- **时序生成**: 标准 VGA 640x480@60Hz 时序
- **同步信号**: 负极性 (active low)
- **消隐期间**: RGB 输出为 0

## 扩展想法

- 添加更多图案
- 实现动画效果
- 添加文字显示
- 连接按钮进行交互式绘图
- 添加帧缓冲支持


主要规格：

分辨率：640x480（最通用的 VGA 分辨率）
像素时钟：25 MHz (125 MHz ÷ 5)
刷新率：约 59.5 Hz（非常接近 60 Hz）
时序参数：
H_TOTAL: 800 (640 + 16 + 96 + 48)
V_TOTAL: 525 (480 + 10 + 2 + 33)
同步极性：负极性（active low）
这是最标准、兼容性最好的 VGA 分辨率，几乎所有显示器都支持。25 MHz 与标准的 25.175 MHz 非常接近（误差小于 1%），刷新率 59.5 Hz 也非常接近标准的 60 Hz。

## references

- https://digilent.com/reference/pmod/pmodvga/start
- https://digilent.com/reference/pmod/pmodvga/reference-manual