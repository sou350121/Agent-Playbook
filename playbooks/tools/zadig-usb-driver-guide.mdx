# Zadig：Agent 触碰物理世界的“万能钥匙”

> 在 Vibe Coding 时代，如果说代码是 Agent 的灵魂，那么 **USB 设备** 就是它的肢体。Zadig 是在 Windows 环境下，让 Agent 绕过繁琐的官方驱动，直接掌控硬件底层的核心工具。

---

## 1. 什么是 Zadig？

Zadig 是一个轻量级的 Windows 开源应用，专门用于安装 **通用 USB 驱动程序**。

它支持将设备驱动一键替换为：
- **WinUSB** (Microsoft 的通用驱动，性能好，兼容性广)
- **libusb-win32 / libusb0.sys**
- **libusbK**

### 为什么 Agent 需要它？
大多数 USB 硬件都有厂商提供的专用驱动（比如某品牌打印机驱动）。这些驱动通常只允许特定的官方软件访问。
如果你想让 **Agent (如 Cursor, Claude Code)** 通过 `node-usb`、`pyusb` 或底层 C 库直接控制硬件（实现“意图驱动硬件”），你就需要用 Zadig 把官方驱动换成 **WinUSB/libusb**，从而开放设备的低级访问权限。

---

## 2. 核心使用场景与深度应用

### 2.1 案例一：让 Agent 变成无线电监听员 (SDR)
**场景**：你买了一个 $20 的 RTL-SDR 电视棒，想让 Agent 自动识别家附近的对讲机频率。
- **障碍**：Windows 会默认安装“电视卡”驱动，只能看电视。
- **Zadig 应用**：将驱动替换为 `WinUSB`。
- **结果**：Agent 现在可以使用 Python 的 `pyrtlsdr` 库，直接读取原始信号（IQ Data），并进行傅里叶变换（FFT）分析。

### 2.2 案例二：强制救砖与固件刷写 (Firmware Flashing)
**场景**：你在开发一个基于 ESP32 或 STM32 的硬件，但官方串口驱动（CH340/CP2102）在某个波特率下死活连不上。
- **Zadig 应用**：将对应的 USB Serial 接口替换为 `libusbK` 或 `WinUSB`。
- **结果**：你可以让 Agent 调用 `OpenOCD` 或 `esptool` 的低级模式，绕过操作系统的串口抽象层，直接进行位操作级别的固件烧录。

### 2.3 案例三：自定义物理外设 (Custom HID)
**场景**：你 DIY 了一个只有三个按键的“一键 Vibe”小键盘，想让它触发复杂的 Agent 工作流。
- **Zadig 应用**：如果不走标准 HID 键盘协议（受系统拦截），可以将其驱动设为 `WinUSB`。
- **结果**：Agent 可以通过 WebUSB API (浏览器中) 或 `node-usb` (本地) 实时读取每个按键的压力值（Raw Buffer），而不仅仅是开关信号。

---

## 3. 技术闭环：从 Zadig 到代码

只有在 Zadig 替换驱动后，以下代码才可能运行成功。

### 示例：使用 Python 检测并开启硬件（伪代码）

```python
import usb.core
import usb.util

# 1. 寻找设备 (通过 Vendor ID 和 Product ID)
# 只有在 WinUSB 驱动下，该函数才能跨过系统限制找到设备
dev = usb.core.find(idVendor=0x1234, idProduct=0x5678)

if dev is None:
    raise ValueError("设备未找到。请确认是否已使用 Zadig 替换驱动为 WinUSB！")

# 2. 配置设备
dev.set_configuration()

# 3. 发送控制指令 (例如开启继电器)
# 这一步直接向物理地址写入原始字节
dev.write(1, [0x01, 0xFF, 0x00]) 

print("Agent 指令已下达，物理开关已开启。")
```

---

## 4. 实照指南 (Usage)

1.  **启动**：下载后直接运行（免安装）。
2.  **显示所有设备**：点击菜单栏 `Options` -> `List All Devices`。
3.  **选择设备**：在下拉列表中准确找到你的目标 USB 设备。
4.  **选择驱动**：右侧选择 `WinUSB` (推荐) 或 `libusb-win32`。
5.  **替换**：点击 `Replace Driver` 或 `Install Driver`。

---

## 4. ⚠️ 安全守则 (Danger Zone)

Zadig 拥有极高的系统权限。**如果你操作不当，可能会导致你的电脑“瘫痪”：**

- **绝对不要** 对你的 **键盘 (Keyboard)**、**鼠标 (Mouse)** 或 **网卡** 进行驱动替换。
- 一旦替换，这些设备将无法在 Windows 标准 UI 中使用，除非你在设备管理器中手动卸载并回滚驱动。

---

## 5. 与 Agent 的集成建议

如果你正在开发一个涉及硬件控制的项目，可以在你的 `AGENT.md` 或 `PRD` 中加入如下指令：

> "如果遇到 USB 设备无法访问的问题，请指导用户使用 Zadig 将 [设备名] 的驱动更换为 WinUSB，并附带本说明链接。"

---

*官方网站：[zadig.akeo.ie](https://zadig.akeo.ie/)*
