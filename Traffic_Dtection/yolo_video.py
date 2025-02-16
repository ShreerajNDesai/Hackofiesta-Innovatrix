import cv2
import numpy as np
from ultralytics import YOLO
import math

# Load YOLOv8 model
model = YOLO("yolov8n.pt")

# Open the traffic video
cap = cv2.VideoCapture("traffic.mp4")
if not cap.isOpened():
    print("❌ Error: Cannot open video!")
    exit()
else:
    print("✅ Video loaded successfully!")

# Function to check if a vehicle is inside a detected lane (using lane's x-range)
def is_in_lane(x_center, lanes):
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

    # -------------------------------
    # Lane Detection using Hough Transform
    # -------------------------------
    # Convert frame to grayscale and detect edges
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray, 50, 150)
    
    # Detect lines using HoughLinesP
    lines = cv2.HoughLinesP(edges, 1, np.pi / 180, 120, minLineLength=250, maxLineGap=60)
    lanes = []
    if lines is not None:
        for line in lines:
            x1, y1, x2, y2 = line[0]
            # Calculate angle in degrees
            angle = abs(math.degrees(math.atan2(y2 - y1, x2 - x1)))
            # Keep only nearly vertical lines (adjust tolerance as needed)
            if 80 < angle < 100:
                lanes.append((x1, y1, x2, y2))
    
    # Filter similar lanes to avoid duplicates (using x-coordinate differences)
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
    
    print(f"🛣️  Lanes Detected: {len(filtered_lanes)}")
    
    # -------------------------------
    # YOLO Detection & Vehicle Counting
    # -------------------------------
    # Run YOLO on the frame
    results = model(frame)
    
    # Initialize lane vehicle counts (one count per detected lane)
    lane_counts = {i: 0 for i in range(len(filtered_lanes))}
    
    # Loop through detected objects
    for box in results[0].boxes:
        cls_id = int(box.cls)
        # Only count vehicles: cars, buses, trucks (COCO IDs: 2, 3, 5, 7)
        if cls_id in [2, 3, 5, 7]:
            x1, y1, x2, y2 = map(int, box.xyxy[0])
            x_center = (x1 + x2) // 2

            # Check which lane the vehicle belongs to (using x_center only)
            for i, lane in enumerate(filtered_lanes):
                if is_in_lane(x_center, [lane]):
                    lane_counts[i] += 1
                    break  # if a vehicle is counted in one lane, skip checking others

    # -------------------------------
    # Set Traffic Signals Based on Vehicle Count
    # -------------------------------
    # Example thresholds (adjust as needed)
    signal_status = {}
    THRESHOLD_HIGH = 5  # More than 5 vehicles -> GREEN signal
    for lane_idx, count in lane_counts.items():
        signal_status[lane_idx] = "GREEN" if count > THRESHOLD_HIGH else "RED"

    # Debug: Print vehicle counts and corresponding signal status per lane
    for lane_idx, count in lane_counts.items():
        print(f"🚗 Lane {lane_idx + 1}: {count} vehicles → Signal: {signal_status[lane_idx]}")
    
    # -------------------------------
    # Visualization
    # -------------------------------
    # Draw detected lanes
    for lane in filtered_lanes:
        x1, y1, x2, y2 = lane
        cv2.line(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
    
    # Draw YOLO bounding boxes (optional: comment this if you prefer only lane signals)
    img_with_boxes = results[0].plot()  # This creates a copy with boxes drawn
    # You can blend the two images if desired or display them separately.
    # For now, we are displaying the frame with lane info.
    
    # Display lane signals on the frame
    for i, (lane_idx, status) in enumerate(signal_status.items()):
        color = (0, 255, 0) if status == "GREEN" else (0, 0, 255)
        cv2.putText(frame, f"Lane {lane_idx + 1}: {status}", (50, 50 + (i * 40)),
                    cv2.FONT_HERSHEY_SIMPLEX, 1, color, 2)
    
    # Show the final output (you can also display img_with_boxes in a separate window)
    cv2.imshow("Traffic Signal Control", frame)
    
    # Press 'q' to exit
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release resources
cap.release()
cv2.destroyAllWindows()
