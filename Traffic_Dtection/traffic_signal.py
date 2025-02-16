import cv2
import numpy as np
from ultralytics import YOLO

# Load YOLOv8 model
model = YOLO("yolov8n.pt")

# Load the traffic video
cap = cv2.VideoCapture("traffic1.mp4")

if not cap.isOpened():
    print("❌ Error: Cannot open video!")
    exit()

print("✅ Video loaded successfully!")

# Function to check if a vehicle is inside a detected lane
def is_in_lane(x_center, y_center, lanes):
    for lane in lanes:
        x1, _, x2, _ = lane
        if x1 <= x_center <= x2:
            return True
    return False

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        print("🔄 Restarting video...")
        cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
        continue

    # Convert to grayscale and detect edges
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray, 50, 150)

    # Detect lanes using Hough Transform
    lines = cv2.HoughLinesP(edges, 1, np.pi / 180, 120, minLineLength=250, maxLineGap=60)

    lanes = []
    if lines is not None:
        for line in lines:
            x1, y1, x2, y2 = line[0]
            angle = np.arctan2(y2 - y1, x2 - x1) * 180 / np.pi
            if 85 < abs(angle) < 95:  # Keep only vertical lanes
                lanes.append((x1, y1, x2, y2))

    # Filter similar lanes to avoid duplicates
    filtered_lanes = []
    for new_lane in lanes:
        x1_new, _, x2_new, _ = new_lane
        add_lane = True
        for existing in filtered_lanes:
            x1_old, _, x2_old, _ = existing
            if abs(x1_new - x1_old) < 80:
                add_lane = False
                break
        if add_lane:
            filtered_lanes.append(new_lane)

    # Debug: Print detected lane count
    print(f"🛣️  Lanes Detected: {len(filtered_lanes)}")

    # Count vehicles per lane
    lane_counts = {i: 0 for i in range(len(filtered_lanes))}

    # Run YOLO detection
    results = model(frame)

    for box in results[0].boxes:
        cls_id = int(box.cls)  # Object class ID
        if cls_id in [2, 3, 5, 7]:  # Count only cars, buses, trucks
            x1, y1, x2, y2 = map(int, box.xyxy[0])
            x_center, y_center = (x1 + x2) // 2, (y1 + y2) // 2

            # Check which lane the vehicle belongs to
            for i, lane in enumerate(filtered_lanes):
                if is_in_lane(x_center, y_center, [lane]):
                    lane_counts[i] += 1

    # Set traffic signals based on vehicle count
    signal_status = {}
    for lane_idx, count in lane_counts.items():
        signal_status[lane_idx] = "GREEN" if count > 5 else "RED"

    # Debug: Print lane vehicle counts & signal status
    for lane_idx, count in lane_counts.items():
        print(f"🚗 Lane {lane_idx + 1}: {count} vehicles → Signal: {signal_status[lane_idx]}")

    # Draw detected lanes
    for lane in filtered_lanes:
        x1, y1, x2, y2 = lane
        cv2.line(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)

    # Display lane signals
    for i, (lane_idx, status) in enumerate(signal_status.items()):
        cv2.putText(frame, f"Lane {lane_idx + 1}: {status}", (50, 50 + (i * 40)), 
                    cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0) if status == "GREEN" else (0, 0, 255), 2)

    # Show video with lane detection & signals
    cv2.imshow("Traffic Signal Control", frame)

    # Press 'q' to exit
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
