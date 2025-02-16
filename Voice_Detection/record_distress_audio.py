import sounddevice as sd
import wavio

# Recording settings
duration = 5  # Duration in seconds
fs = 16000  # Sample rate (16 kHz)

print("Recording distress sound... Shout something like 'Help! Stop!'")
audio = sd.rec(int(duration * fs), samplerate=fs, channels=1, dtype='int16')
sd.wait()

# Save the recorded audio
wavio.write("distress_sound.wav", audio, fs, sampwidth=2)
print("Recording saved as distress_sound.wav")
