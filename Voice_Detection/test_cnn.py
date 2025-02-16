import torch
import torchvision.transforms as transforms
from PIL import Image
import numpy as np

# Load the trained model
class DistressCNN(torch.nn.Module):
    def __init__(self):
        super(DistressCNN, self).__init__()
        self.conv1 = torch.nn.Conv2d(3, 16, kernel_size=3, stride=1, padding=1)
        self.conv2 = torch.nn.Conv2d(16, 32, kernel_size=3, stride=1, padding=1)
        self.pool = torch.nn.MaxPool2d(2, 2)
        self.fc1 = torch.nn.Linear(32 * 16 * 16, 128)
        self.fc2 = torch.nn.Linear(128, 2)
        self.relu = torch.nn.ReLU()
        self.softmax = torch.nn.LogSoftmax(dim=1)

    def forward(self, x):
        x = self.pool(self.relu(self.conv1(x)))
        x = self.pool(self.relu(self.conv2(x)))
        x = x.view(x.size(0), -1)
        x = self.relu(self.fc1(x))
        x = self.softmax(self.fc2(x))
        return x

# Load model and set to evaluation mode
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model = DistressCNN().to(device)
model.load_state_dict(torch.load("distress_cnn.pth", map_location=device))
model.eval()

# Define image transformations
transform = transforms.Compose([
    transforms.Resize((64, 64)),
    transforms.ToTensor()
])

# Load and preprocess the spectrogram
image_path = r"D:\HACKOFIESTA\spectrograms\normal\normal_1.jpg"  # Change this to your test image
image = Image.open(image_path)
image = transform(image).unsqueeze(0).to(device)

# Make prediction
with torch.no_grad():
    output = model(image)
    predicted_class = torch.argmax(output).item()

# Interpret result
labels = ["Distress", "Normal"]
print(f"Predicted Class: {labels[predicted_class]}")
