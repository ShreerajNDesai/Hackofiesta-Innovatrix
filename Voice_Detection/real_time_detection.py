import torch
import torchvision.transforms as transforms
import sounddevice as sd
import numpy as np
import librosa
import librosa.display
import matplotlib.pyplot as plt
import wavio
from PIL import Image

# Load trained model
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

# Load model
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model = DistressCNN().to(device)
model.load_state_dict(torch.load("distress_cnn.pth", map_location=device))
model.eval()

# Define image transformation
transform = transforms.Compose([
    transforms.Resize((64, 64)),
    transforms.ToTensor()
])

# Function to record live audio
def record_audio(duration=3, filename="live_audio.wav"):
    fs = 16000  # Sample rate
    print("\n🎤 Listening... Speak now!")
    audio = sd.rec(int(duration * fs), samplerate=fs, channels=1, dtype='int16')
    sd.wait()
    wavio.write(filename, audio, fs, sampwidth=2)
    print(f"📁 Audio saved: {filename}")

# Function to generate spectrogram
def save_spectrogram(audio_path, image_path):
    y, sr = librosa.load(audio_path, sr=16000)
    mel_spec = librosa.feature.melspectrogram(y=y, sr=sr, n_mels=128)
    mel_spec_db = librosa.power_to_db(mel_spec, ref=np.max)

    plt.figure(figsize=(5, 5))
    librosa.display.specshow(mel_spec_db, sr=sr, x_axis='time', y_axis='mel')
    plt.axis('off')
    plt.savefig(image_path, bbox_inches='tight', pad_inches=0)
    plt.close()
    print(f"📷 Spectrogram saved: {image_path}")

# Function to classify audio
def classify_audio():
    record_audio()
    save_spectrogram("live_audio.wav", "live_spectrogram.jpg")

    # Load spectrogram image
    image = Image.open("live_spectrogram.jpg")
    image = transform(image).unsqueeze(0).to(device)

    # Predict
    with torch.no_grad():
        output = model(image)
        predicted_class = torch.argmax(output).item()

    labels = ["Distress", "Normal"]
    print(f"\n🔍 Predicted Class: {labels[predicted_class]}\n")

# Run the classification once
classify_audio()
