# MediaPipe 手势识别完整教程

## 第一步：了解 MediaPipe Hands

**MediaPipe Hands** 是 Google 开发的高性能手部追踪解决方案：

- ✅ **21 个手部关键点**检测
- ✅ **实时追踪**，高精度低延迟
- ✅ **单手/双手**检测
- ✅ **跨平台**支持（Windows/Linux/Mac/Android/iOS）
- ✅ **免费开源**，MIT 许可证
- ✅ **CPU 运行**，无需 GPU

## 第二步：安装准备

### 1. 系统要求
- Python 3.8+
- 摄像头（内置或 USB）
- 至少 4GB RAM

### 2. 安装依赖

```bash
# 创建虚拟环境（推荐）
python -m venv venv

# 激活虚拟环境
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# 安装核心依赖
pip install opencv-python
pip install mediapipe
pip install numpy

# 安装额外依赖（某些功能需要）
pip install pyautogui  # 鼠标控制
pip install cvzone  # 简化的 Computer Vision 库
```

### 3. 验证安装

```bash
python -c "import cv2, mediapipe; print('✅ 安装成功!')"
python -c "import mediapipe; print('MediaPipe 版本:', mediapipe.__version__)"
```

## 第三步：理解 21 个手部关键点

MediaPipe 检测 21 个手部关键点：

```
手腕: 0
拇指: [1, 2, 3, 4]     -> 4 是指尖
食指: [5, 6, 7, 8]     -> 8 是指尖
中指: [9, 10, 11, 12]  -> 12 是指尖
无名指: [13, 14, 15, 16] -> 16 是指尖
小指: [17, 18, 19, 20] -> 20 是指尖
```

**最常用的关键点：**
- **0**: 手腕（基准点）
- **4, 8, 12, 16, 20**: 5 个手指尖
- **8**: 食指指尖（最常用）

## 第四步：运行第一个示例

### 示例 1：基础手部检测

创建 `example1_basic_detection.py`：

```python
import cv2
import mediapipe as mp

def main():
    print("🎯 MediaPipe 手部检测示例")
    print("=" * 50)

    # 初始化 MediaPipe Hands
    mp_hands = mp.solutions.hands
    hands = mp_hands.Hands(
        static_image_mode=False,    # 视频流模式
        max_num_hands=2,            # 最多检测2只手
        min_detection_confidence=0.7,  # 检测置信度阈值
        min_tracking_confidence=0.5    # 追踪置信度阈值
    )

    # 初始化绘图工具
    mp_draw = mp.solutions.drawing_utils
    mp_draw_styles = mp.solutions.drawing_styles

    # 打开摄像头
    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("❌ 错误: 无法打开摄像头!")
        return

    print("✅ 摄像头已启动! 开始检测手部...")
    print("提示: 按 'q' 退出")

    while True:
        success, img = cap.read()
        if not success:
            break

        # 转换颜色空间 BGR -> RGB
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        # 处理图像
        results = hands.process(img_rgb)

        # 如果检测到手部
        if results.multi_hand_landmarks:
            for hand_idx, hand_landmarks in enumerate(results.multi_hand_landmarks):
                print(f"✅ 检测到第 {hand_idx + 1} 只手")

                # 绘制手部关键点和连接线
                mp_draw.draw_landmarks(
                    img,
                    hand_landmarks,
                    mp_hands.HAND_CONNECTIONS,
                    mp_draw_styles.get_default_hand_landmarks_style(),
                    mp_draw_styles.get_default_hand_connections_style()
                )

                # 获取食指指尖坐标
                index_finger_tip = hand_landmarks.landmark[8]
                h, w, c = img.shape
                cx, cy = int(index_finger_tip.x * w), int(index_finger_tip.y * h)
                print(f"   食指指尖: X={cx}, Y={cy}")

                # 在食指尖位置画圆
                cv2.circle(img, (cx, cy), 10, (255, 0, 0), cv2.FILLED)

        # 显示图像
        cv2.imshow("Hand Tracking - Press Q to quit", img)

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
python example1_basic_detection.py
```

**预期效果：**
- ✅ 摄像头画面显示
- ✅ 手部骨架和关键点可视化
- ✅ 21 个关键点用不同颜色标记
- ✅ 食指指尖有蓝色圆点标记

## 第五步：手势识别原理

### 手指状态判断

判断手指是否伸直：

```python
def finger_is_up(landmarks, finger_tip_idx, finger_pip_idx):
    """判断手指是否伸直"""
    return landmarks.landmark[finger_tip_idx].y < landmarks.landmark[finger_pip_idx].y

# 判断每个手指
thumb_up = finger_is_up(hand_landmarks, 4, 2)
index_up = finger_is_up(hand_landmarks, 8, 6)
middle_up = finger_is_up(hand_landmarks, 12, 10)
ring_up = finger_is_up(hand_landmarks, 16, 14)
pinky_up = finger_is_up(hand_landmarks, 20, 18)

fingers_up = [thumb_up, index_up, middle_up, ring_up, pinky_up]
```

### 常见手势识别

#### 1. 握拳（Fist）
所有手指弯曲
```python
if sum(fingers_up) == 0:
    gesture = "✊ 握拳"
```

#### 2. 张开手掌（Open Palm）
所有手指伸直
```python
if sum(fingers_up) == 5:
    gesture = "✋ 张开手掌"
```

#### 3. 点赞（Thumbs Up）
只有拇指伸直
```python
if fingers_up == [True, False, False, False, False]:
    gesture = "👍 点赞"
```

#### 4. V字手势（Victory）
只有食指和中指伸直
```python
if fingers_up == [False, True, True, False, False]:
    gesture = "✌️ V字手势"
```

#### 5. 捏合（Pinch）
拇指和食指指尖距离很近
```python
thumb_tip = hand_landmarks.landmark[4]
index_tip = hand_landmarks.landmark[8]

distance = ((thumb_tip.x - index_tip.x)**2 + (thumb_tip.y - index_tip.y)**2)**0.5

if distance < 0.05:  # 阈值可调
    gesture = "👌 捏合"
```

## 第六步：高级功能

### 1. 平滑追踪（减少抖动）

```python
from collections import deque

class SmoothTracker:
    def __init__(self, window_size=5):
        self.buffer = deque(maxlen=window_size)

    def smooth(self, x, y):
        self.buffer.append((x, y))
        avg_x = sum(p[0] for p in self.buffer) / len(self.buffer)
        avg_y = sum(p[1] for p in self.buffer) / len(self.buffer)
        return int(avg_x), int(avg_y)

tracker = SmoothTracker(window_size=5)
```

### 2. 手势历史记录

```python
from collections import deque

gesture_history = deque(maxlen=10)

def process_gesture(gesture):
    gesture_history.append(gesture)

    # 检测特定序列
    if list(gesture_history) == ["open_palm", "fist", "open_palm"]:
        return "zoom_in"

    return gesture
```

### 3. 多手检测

```python
if results.multi_hand_landmarks:
    for idx, hand_landmarks in enumerate(results.multi_hand_landmarks):
        # 获取左右手信息
        handedness = results.multi_handedness[idx].classification[0].label
        print(f"第 {idx + 1} 只手: {handedness}")
```

### 4. 坐标转换

```python
# 图像坐标转换为屏幕坐标
def image_to_screen(img_x, img_y, img_w, img_h, screen_w, screen_h):
    screen_x = int(img_x / img_w * screen_w)
    screen_y = int(img_y / img_h * screen_h)
    return screen_x, screen_y
```

## 第七步：实战项目

### 项目 1：手势计数器

```python
import cv2
import mediapipe as mp
import time

def count_fingers(landmarks):
    """计算伸直的手指数量"""
    finger_tips = [8, 12, 16, 20]
    finger_pips = [6, 10, 14, 18]

    fingers_up = 0

    # 拇指特殊处理（比较 x 坐标）
    if landmarks.landmark[4].x < landmarks.landmark[3].x:
        fingers_up += 1

    # 其他四个手指
    for tip, pip in zip(finger_tips, finger_pips):
        if landmarks.landmark[tip].y < landmarks.landmark[pip].y:
            fingers_up += 1

    return fingers_up

def main():
    mp_hands = mp.solutions.hands
    hands = mp_hands.Hands(max_num_hands=2)
    mp_draw = mp.solutions.drawing_utils

    cap = cv2.VideoCapture(0)

    while True:
        success, img = cap.read()
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        results = hands.process(img_rgb)

        if results.multi_hand_landmarks:
            for hand_landmarks in results.multi_hand_landmarks:
                mp_draw.draw_landmarks(img, hand_landmarks, mp_hands.HAND_CONNECTIONS)

                # 计算伸直的手指数量
                count = count_fingers(hand_landmarks)

                # 显示数字
                cv2.putText(img, str(count), (100, 150),
                          cv2.FONT_HERSHEY_SIMPLEX, 5, (0, 255, 0), 5)

        cv2.imshow("Finger Counter", img)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
```

### 项目 2：手势绘图板

```python
import cv2
import mediapipe as mp
import numpy as np

class DrawingBoard:
    def __init__(self):
        self.canvas = None
        self.prev_pos = None
        self.drawing = False
        self.color = (255, 0, 0)
        self.brush_size = 5

    def draw(self, img, hand_landmarks):
        if self.canvas is None:
            self.canvas = np.zeros_like(img)

        h, w, _ = img.shape
        index_tip = hand_landmarks.landmark[8]
        thumb_tip = hand_landmarks.landmark[4]

        x, y = int(index_tip.x * w), int(index_tip.y * h)

        # 检查捏合
        distance = ((index_tip.x - thumb_tip.x)**2 +
                   (index_tip.y - thumb_tip.y)**2)**0.5

        if distance < 0.05:  # 捏合状态
            self.drawing = True
            if self.prev_pos:
                cv2.line(self.canvas, self.prev_pos, (x, y),
                        self.color, self.brush_size)
            self.prev_pos = (x, y)
        else:
            self.drawing = False
            self.prev_pos = None

        # 合并图像
        img = cv2.addWeighted(img, 0.7, self.canvas, 0.3, 0)

        # 显示模式
        mode = "Drawing" if self.drawing else "Moving"
        cv2.putText(img, f"Mode: {mode}", (10, 50),
                   cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)

        return img

def main():
    mp_hands = mp.solutions.hands
    hands = mp_hands.Hands(max_num_hands=1)
    mp_draw = mp.solutions.drawing_utils

    cap = cv2.VideoCapture(0)
    board = DrawingBoard()

    while True:
        success, img = cap.read()
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        results = hands.process(img_rgb)

        if results.multi_hand_landmarks:
            for hand_landmarks in results.multi_hand_landmarks:
                mp_draw.draw_landmarks(img, hand_landmarks, mp_hands.HAND_CONNECTIONS)
                img = board.draw(img, hand_landmarks)

        cv2.imshow("Gesture Drawing", img)

        key = cv2.waitKey(1)
        if key & 0xFF == ord('q'):
            break
        elif key & 0xFF == ord('c'):  # 清除画布
            board.canvas = np.zeros_like(img)

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
```

## 性能优化技巧

### 1. 降低分辨率

```python
# 设置较低分辨率以提高性能
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
```

### 2. 调整检测频率

```python
frame_count = 0
detection_every = 3  # 每3帧检测一次

while True:
    success, img = cap.read()

    if frame_count % detection_every == 0:
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        results = hands.process(img_rgb)

    frame_count += 1
```

### 3. 减少检测的手数

```python
hands = mp_hands.Hands(
    max_num_hands=1,  # 只检测1只手
    min_detection_confidence=0.5,  # 降低阈值
    min_tracking_confidence=0.5
)
```

## 常见问题解决

### Q1: 检测不准确
```python
# 调整置信度阈值
hands = mp_hands.Hands(
    min_detection_confidence=0.5,  # 降低阈值
    min_tracking_confidence=0.5
)
```

### Q2: 延迟太高
```python
# 降低分辨率
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

# 减少检测的手数
hands = mp_hands.Hands(max_num_hands=1)
```

### Q3: 手指方向判断错误
```python
# 对于拇指，需要考虑手的左右方向
handedness = results.multi_handedness[0].classification[0].label

if handedness == "Left":
    # 左手的拇指判断逻辑
    thumb_up = landmarks.landmark[4].x < landmarks.landmark[3].x
else:
    # 右手的拇指判断逻辑
    thumb_up = landmarks.landmark[4].x > landmarks.landmark[3].x
```

## 下一步学习

1. 🎯 实现更复杂的手势组合
2. 🎨 创建自己的手势应用
3. ⚡ 优化性能和准确性
4. 🌐 集成到实际项目中
5. 🤖 结合机器学习进行自定义手势识别

## 参考资源

- [MediaPipe 官方文档](https://google.github.io/mediapipe/)
- [MediaPipe Hands 解决方案](https://google.github.io/mediapipe/solutions/hands.html)
- [OpenCV 官方文档](https://docs.opencv.org/4.x/)
- [GitHub 示例代码](https://github.com/google/mediapipe/tree/master/examples/python)

---

**恭喜！您已经掌握了 MediaPipe 手势识别的基础！** 🎉

现在可以开始创建自己的手势控制应用了！
