"""Generate short, original Game Arena UI sound effects (PCM WAV)."""

import math
import os
import random
import struct
import wave


OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
RATE = 22050


def write(name, notes, duration=0.12, noise=0.0):
    count = int(RATE * duration)
    samples = []
    rng = random.Random(name)
    for i in range(count):
        t = i / RATE
        envelope = max(0.0, 1 - i / count) ** 2
        value = noise * (rng.random() * 2 - 1)
        for frequency, start, length, amplitude in notes:
            local = t - start
            if 0 <= local < length:
                decay = max(0.0, 1 - local / length) ** 2
                value += amplitude * decay * math.sin(2 * math.pi * frequency * local)
        samples.append(max(-1.0, min(1.0, value * envelope)))
    os.makedirs(OUT, exist_ok=True)
    with wave.open(os.path.join(OUT, name + ".wav"), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        wav.writeframes(b"".join(struct.pack("<h", int(s * 32767)) for s in samples))


write("tap", [(880, 0, 0.045, 0.58)], 0.06, 0.035)
write("select", [(660, 0, 0.07, 0.35), (990, 0.045, 0.09, 0.38)], 0.15)
write("correct", [(660, 0, 0.12, 0.36), (880, 0.08, 0.14, 0.34), (1320, 0.18, 0.2, 0.3)], 0.4)
write("incorrect", [(280, 0, 0.15, 0.45), (220, 0.1, 0.19, 0.34)], 0.33)
write("start", [(523, 0, 0.14, 0.32), (659, 0.12, 0.14, 0.32), (784, 0.24, 0.22, 0.34)], 0.52)
write("victory", [(523, 0, 0.18, 0.3), (659, 0.13, 0.18, 0.3), (784, 0.26, 0.18, 0.3), (1047, 0.39, 0.36, 0.33)], 0.85)
