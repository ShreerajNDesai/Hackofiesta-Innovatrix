from ultralytics import YOLO
import cv2  

# Load YOLOv8 model
model = YOLO("yolov8n.pt")

# Run inference on an image
results = model("download.jpg")

# Display the image with OpenCV
for result in results:
    img = result.plot()  # Draw bounding boxes on the image
    cv2.imshow("YOLOv8 Detection", img)  # Show image in a window
    cv2.waitKey(0)  # Wait for a key press to close
    cv2.destroyAllWindows()
