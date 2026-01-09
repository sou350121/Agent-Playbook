# Wujihandpy 完整入门教程

## 第一步：了解项目

**Wujihandpy** 是无尽科技（Wuji Technology）开发的一个 Python 手势识别和控制库，主要功能：
- 🖐️ 实时手部检测和追踪
- 👆 手势识别（捏合、点击、拖拽等）
- 🖱️ 通过手势控制计算机鼠标和键盘
- 📹 支持摄像头输入
- 🎯 高精度低延迟

## 第二步：安装准备

### 1. 硬件要求
- ✅ 摄像头（内置或外接 USB 摄像头）
- ✅ 至少 4GB RAM
- ✅ 支持 Python 3.8+ 的系统

### 2. 软件要求
- Python 3.8 或更高版本
- pip 包管理器

### 3. 安装 wujihandpy

```bash
# 克隆项目
git clone https://github.com/wuji-technology/wujihandpy.git
cd wujihandpy

# 安装依赖
pip install -r requirements.txt

# 安装 wujihandpy
pip install -e .
```

或者直接从 PyPI 安装（如果已发布）：
```bash
pip install wujihandpy
```

### 4. 验证安装

```bash
python -c "import wujihandpy; print('Wujihandpy 安装成功!')"
```

## 第三步：运行第一个示例

### 基础手势检测示例

创建文件 `my_first_gesture.py`：

```python
from wujihandpy import HandDetector
import cv2

def main():
    # 初始化手部检测器
    detector = HandDetector(
        max_hands=2,              # 最多检测2只手
        detection_con=0.7,        # 检测置信度阈值
        tracking_con=0.5          # 追踪置信度阈值
    )

    # 打开摄像头
    cap = cv2.VideoCapture(0)

    while True:
        success, img = cap.read()
        if not success:
            break

        # 检测手部
        img = detector.find_hands(img)
        lm_list = detector.find_position(img)

        # 如果检测到手部关键点
        if lm_list:
            print(f"检测到手部! 食指指尖坐标: {lm_list[8]}")

        # 显示图像
        cv2.imshow("Hand Tracking", img)

        # 按 'q' 退出
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
```

运行：
```bash
python my_first_gesture.py
```

## 第四步：核心功能详解

### 1. 手部关键点检测

```python
from wujihandpy import HandDetector

detector = HandDetector()
# ... 获取图像后 ...
landmarks = detector.find_position(img)

# 21 个手部关键点：
# 0: 手腕
# 4: 拇指尖
# 8: 食指尖
# 12: 中指尖
# 16: 无名指尖
# 20: 小指尖
```

### 2. 手势识别

```python
from wujihandpy import GestureRecognizer

recognizer = GestureRecognizer()
gesture = recognizer.recognize_gesture(landmarks)

# 支持的手势：
# - "open_palm": 张开手掌
# - "fist": 握拳
# - "pointing": 指向
# - "pinch": 捏合（拇指+食指）
# - "victory": V字手势
# - "thumbs_up": 点赞
```

### 3. 虚拟鼠标控制

```python
from wujihandpy import VirtualMouse

mouse = VirtualMouse()

# 使用食指位置移动鼠标
if landmarks:
    index_finger_tip = landmarks[8]
    mouse.move(index_finger_tip[1], index_finger_tip[2])

# 检测捏合手势进行点击
if recognizer.recognize_gesture(landmarks) == "pinch":
    mouse.click()
```

### 4. 手势控制计算机

创建文件 `gesture_control.py`：

```python
from wujihandpy import HandDetector, GestureRecognizer, VirtualMouse
import cv2

def main():
    detector = HandDetector(max_hands=1)
    recognizer = GestureRecognizer()
    mouse = VirtualMouse()

    cap = cv2.VideoCapture(0)
    screen_width, screen_height = 1920, 1080  # 调整为你的屏幕分辨率

    while True:
        success, img = cap.read()
        if not success:
            break

        img = detector.find_hands(img)
        lm_list = detector.find_position(img, draw=False)

        if lm_list:
            # 获取食指指尖位置
            x, y = lm_list[8][1], lm_list[8][2]

            # 转换到屏幕坐标
            screen_x = int(x * screen_width / img.shape[1])
            screen_y = int(y * screen_height / img.shape[0])

            # 移动鼠标
            mouse.move(screen_x, screen_y)

            # 检测手势
            gesture = recognizer.recognize_gesture(lm_list)

            if gesture == "pinch":
                mouse.click()
                cv2.putText(img, "Click!", (50, 50),
                          cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
            elif gesture == "fist":
                # 握拳可以执行其他操作
                pass

        cv2.imshow("Gesture Control", img)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
```

## 第五步：高级功能

### 1. 自定义手势识别

```python
from wujihandpy import GestureDetector

class MyGestureDetector(GestureDetector):
    def detect_custom_gesture(self, landmarks):
        """检测自定义手势"""
        # 检查是否是"OK"手势
        # 拇指和食指形成圆圈，其他手指伸直
        thumb_tip = landmarks[4]
        index_tip = landmarks[8]

        # 计算拇指和食指距离
        distance = ((thumb_tip[1] - index_tip[1])**2 +
                   (thumb_tip[2] - index_tip[2])**2)**0.5

        if distance < 30:  # 捏合
            # 检查其他手指是否伸直
            middle_up = landmarks[12][2] < landmarks[10][2]
            ring_up = landmarks[16][2] < landmarks[14][2]
            pinky_up = landmarks[20][2] < landmarks[18][2]

            if middle_up and ring_up and pinky_up:
                return "OK_sign"

        return None
```

### 2. 多手势组合控制

```python
class MultiGestureController:
    def __init__(self):
        self.gesture_history = []

    def process_gesture_sequence(self, gesture):
        """处理手势序列"""
        self.gesture_history.append(gesture)

        # 保留最近5个手势
        if len(self.gesture_history) > 5:
            self.gesture_history.pop(0)

        # 检测特定序列：张开 -> 握拳 -> 张开
        sequence = [g['gesture'] for g in self.gesture_history]

        if sequence == ['open_palm', 'fist', 'open_palm']:
            return "zoom_in"  # 执行放大操作

        return None
```

### 3. 平滑手势控制

```python
from collections import deque

class SmoothController:
    def __init__(self, window_size=5):
        self.position_buffer = deque(maxlen=window_size)

    def smooth_position(self, x, y):
        """平滑位置变化，减少抖动"""
        self.position_buffer.append((x, y))

        # 计算平均位置
        avg_x = sum(p[0] for p in self.position_buffer) / len(self.position_buffer)
        avg_y = sum(p[1] for p in self.position_buffer) / len(self.position_buffer)

        return int(avg_x), int(avg_y)
```

### 4. 添加可视化反馈

```python
def draw_gesture_info(img, gesture, confidence):
    """在画面上显示手势信息"""

    # 绘制状态框
    cv2.rectangle(img, (10, 10), (300, 100), (0, 255, 0), 2)

    # 显示手势名称
    cv2.putText(img, f"Gesture: {gesture}",
               (20, 40), cv2.FONT_HERSHEY_SIMPLEX,
               1, (0, 255, 0), 2)

    # 显示置信度
    cv2.putText(img, f"Confidence: {confidence:.2f}",
               (20, 80), cv2.FONT_HERSHEY_SIMPLEX,
               0.7, (0, 255, 0), 2)

    return img
```

## 第六步：实战项目

### 项目1：手势演示控制器

创建 `presentation_controller.py`：

```python
from wujihandpy import HandDetector, GestureRecognizer
import cv2
import pyautogui

class PresentationController:
    def __init__(self):
        self.detector = HandDetector(max_hands=1)
        self.recognizer = GestureRecognizer()
        self.current_action = None

    def run(self):
        cap = cv2.VideoCapture(0)

        while True:
            success, img = cap.read()
            if not success:
                break

            img = self.detector.find_hands(img)
            lm_list = self.detector.find_position(img)

            if lm_list:
                gesture = self.recognizer.recognize_gesture(lm_list)

                # 不同手势执行不同操作
                if gesture == "pointing" and self.current_action != "next":
                    pyautogui.press('right')  # 下一页
                    self.current_action = "next"
                    print("下一页")

                elif gesture == "victory" and self.current_action != "prev":
                    pyautogui.press('left')  # 上一页
                    self.current_action = "prev"
                    print("上一页")

                elif gesture == "fist" and self.current_action != "exit":
                    # 按住不放可以退出
                    self.current_action = "exit"

                elif gesture == "open_palm":
                    self.current_action = None

                # 显示当前手势
                cv2.putText(img, f"Gesture: {gesture}",
                          (10, 50), cv2.FONT_HERSHEY_SIMPLEX,
                          1, (0, 255, 0), 2)

            cv2.imshow("Presentation Control", img)

            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

        cap.release()
        cv2.destroyAllWindows()

if __name__ == "__main__":
    controller = PresentationController()
    controller.run()
```

### 项目2：手势绘图板

创建 `gesture_draw.py`：

```python
from wujihandpy import HandDetector
import cv2
import numpy as np

class GestureDraw:
    def __init__(self):
        self.detector = HandDetector(max_hands=1)
        self.canvas = None
        self.prev_pos = None
        self.drawing = False
        self.color = (255, 0, 0)  # 蓝色
        self.brush_size = 5

    def run(self):
        cap = cv2.VideoCapture(0)

        while True:
            success, img = cap.read()
            if not success:
                break

            # 初始化画布
            if self.canvas is None:
                self.canvas = np.zeros_like(img)

            img = self.detector.find_hands(img)
            lm_list = self.detector.find_position(img)

            if lm_list:
                # 食指指尖位置
                x, y = lm_list[8][1], lm_list[8][2]

                # 检测是否捏合（画画模式）
                thumb_tip = lm_list[4]
                index_tip = lm_list[8]
                distance = ((thumb_tip[1] - index_tip[1])**2 +
                           (thumb_tip[2] - index_tip[2])**2)**0.5

                if distance < 30:  # 捏合状态
                    self.drawing = True
                    if self.prev_pos:
                        cv2.line(self.canvas, self.prev_pos, (x, y),
                                self.color, self.brush_size)
                    self.prev_pos = (x, y)
                else:
                    self.drawing = False
                    self.prev_pos = None

            # 合并摄像头画面和画布
            img = cv2.addWeighted(img, 0.7, self.canvas, 0.3, 0)

            # 显示模式
            mode = "Drawing" if self.drawing else "Moving"
            cv2.putText(img, f"Mode: {mode}",
                      (10, 50), cv2.FONT_HERSHEY_SIMPLEX,
                      1, (0, 255, 0), 2)

            cv2.imshow("Gesture Drawing", img)

            # 按 'c' 清除画布
            if cv2.waitKey(1) & 0xFF == ord('c'):
                self.canvas = np.zeros_like(img)
            # 按 'q' 退出
            elif cv2.waitKey(1) & 0xFF == ord('q'):
                break

        cap.release()
        cv2.destroyAllWindows()

if __name__ == "__main__":
    draw = GestureDraw()
    draw.run()
```

## 第七步：性能优化技巧

### 1. 提高帧率

```python
# 降低检测频率，每3帧检测一次
frame_count = 0
detection_every = 3

while True:
    success, img = cap.read()

    if frame_count % detection_every == 0:
        lm_list = detector.find_position(img)
        # 使用追踪技术更新位置
    else:
        # 简单的光流追踪
        pass

    frame_count += 1
```

### 2. 多线程处理

```python
import threading

class HandDetectorThread:
    def __init__(self):
        self.detector = HandDetector()
        self.latest_frame = None
        self.latest_result = None

    def process_frame(self, frame):
        while True:
            if self.latest_frame is not None:
                self.latest_result = self.detector.find_hands(self.latest_frame)

    def start(self, cap):
        thread = threading.Thread(target=self.process_frame, args=(cap,))
        thread.daemon = True
        thread.start()
```

### 3. GPU 加速

```python
# 如果有 NVIDIA GPU，可以启用 CUDA
detector = HandDetector(
    mode=False,
    max_hands=2,
    detection_con=0.7,
    tracking_con=0.5,
    model_complexity=1,  # 0, 1, 2 - 越高越精确但越慢
    enable_gpu=True      # 启用 GPU 加速
)
```

## 常见问题解决

### Q1: 摄像头打不开
```bash
# 检查摄像头设备
python -c "import cv2; print(cv2.VideoCapture(0).isOpened())"

# 尝试不同的摄像头索引
cap = cv2.VideoCapture(0)  # 或 1, 2, 3
```

### Q2: 手势识别不准确
```python
# 调整检测参数
detector = HandDetector(
    detection_con=0.5,  # 降低检测阈值
    tracking_con=0.7    # 提高追踪阈值
)

# 添加光照补偿
img = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
# ... 处理光照
```

### Q3: 延迟太高
```python
# 降低图像分辨率
img = cv2.resize(img, (640, 480))

# 减少检测的手的数量
detector = HandDetector(max_hands=1)
```

## 下一步学习

1. 📚 深入学习 MediaPipe 手部关键点算法
2. 🎯 实现更复杂的手势组合
3. 🎨 开发自己的手势应用
4. ⚡ 优化性能和准确性
5. 🌐 集成到实际产品中

## 参考资源

- [Wujihandpy GitHub](https://github.com/wuji-technology/wujihandpy)
- [MediaPipe 手部追踪文档](https://google.github.io/mediapipe/solutions/hands.html)
- [OpenCV 官方文档](https://docs.opencv.org/4.x/)

---

**恭喜！您已经掌握了 wujihandpy 的基本用法！** 🎉

现在可以开始创建自己的手势控制应用了！
