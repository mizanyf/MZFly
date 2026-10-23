import math
import struct
import wave
import random

SAMPLE_RATE = 44100

def write_wav(filename, samples):
    with wave.open(filename, 'w') as wav_file:
        n_channels = 1
        sampwidth = 2
        wav_file.setparams((n_channels, sampwidth, SAMPLE_RATE, len(samples), 'NONE', 'not compressed'))
        raw_data = bytearray()
        for s in samples:
            # Clamp sample to -1.0 to 1.0
            val = max(-1.0, min(1.0, s))
            int_val = int(val * 32767.0)
            raw_data.extend(struct.pack('<h', int_val))
        wav_file.writeframes(raw_data)

def generate_flap():
    duration = 0.14
    total_samples = int(duration * SAMPLE_RATE)
    samples = []
    phase = 0.0
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        progress = t / duration
        # Pitch rises from 220Hz to 580Hz
        freq = 220.0 + 360.0 * (progress ** 0.8)
        phase += 2.0 * math.pi * freq / SAMPLE_RATE
        
        # Sine wave blended with subtle filtered noise
        tone = math.sin(phase)
        noise = (random.random() * 2.0 - 1.0) * 0.15
        val = tone * 0.85 + noise
        
        # Envelope: fast attack (10ms), smooth decay
        if progress < 0.1:
            env = progress / 0.1
        else:
            env = math.cos((progress - 0.1) / 0.9 * (math.pi / 2))
        
        samples.append(val * env * 0.75)
    return samples

def generate_score():
    duration = 0.35
    total_samples = int(duration * SAMPLE_RATE)
    samples = []
    phase1 = 0.0
    phase2 = 0.0
    
    # Two note chime: Note 1 (659 Hz - E5) for first 0.1s, Note 2 (1046 Hz - C6) for remaining
    split = 0.09
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        if t < split:
            freq = 659.25
            env = min(1.0, (t / 0.01)) * math.exp(-t * 8.0)
            phase1 += 2.0 * math.pi * freq / SAMPLE_RATE
            # Add harmonic
            tone = math.sin(phase1) + 0.3 * math.sin(phase1 * 2.0)
            val = tone * env * 0.6
        else:
            t2 = t - split
            freq = 1046.5
            env = min(1.0, (t2 / 0.01)) * math.exp(-t2 * 6.0)
            phase2 += 2.0 * math.pi * freq / SAMPLE_RATE
            tone = math.sin(phase2) + 0.25 * math.sin(phase2 * 2.0) + 0.1 * math.sin(phase2 * 3.0)
            val = tone * env * 0.7
        samples.append(val)
    return samples

def generate_hit():
    duration = 0.22
    total_samples = int(duration * SAMPLE_RATE)
    samples = []
    phase = 0.0
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        progress = t / duration
        # Pitch drops rapidly from 340Hz to 65Hz
        freq = 340.0 * math.exp(-progress * 7.0) + 65.0
        phase += 2.0 * math.pi * freq / SAMPLE_RATE
        
        # Punchy square/sine combo + noise burst
        tone = math.sin(phase) * 0.7 + (1.0 if math.sin(phase) > 0 else -1.0) * 0.2
        noise_level = max(0.0, 1.0 - progress * 4.0) * 0.3
        noise = (random.random() * 2.0 - 1.0) * noise_level
        val = tone + noise
        
        # Envelope: punchy instant attack, exponential decay
        env = math.exp(-progress * 6.5)
        samples.append(val * env * 0.8)
    return samples

def generate_click():
    duration = 0.045
    total_samples = int(duration * SAMPLE_RATE)
    samples = []
    phase = 0.0
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        progress = t / duration
        freq = 900.0 + 400.0 * progress
        phase += 2.0 * math.pi * freq / SAMPLE_RATE
        val = math.sin(phase)
        env = (1.0 - progress) ** 2.0
        samples.append(val * env * 0.5)
    return samples

def generate_gameover():
    duration = 0.55
    total_samples = int(duration * SAMPLE_RATE)
    samples = []
    phase = 0.0
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        progress = t / duration
        # Sad slide downwards with vibrato
        vibrato = math.sin(2.0 * math.pi * 7.0 * t) * 12.0
        freq = 480.0 * (1.0 - progress * 0.65) + vibrato
        phase += 2.0 * math.pi * freq / SAMPLE_RATE
        tone = math.sin(phase) + 0.2 * math.sin(phase * 2.0)
        env = math.exp(-progress * 3.5)
        samples.append(tone * env * 0.6)
    return samples

def generate_bgm():
    # 8-bar loop at 130 BPM, 4 beats per bar -> 8 * (60/130) * 2 = 7.3846 seconds
    bpm = 130.0
    beat_dur = 60.0 / bpm
    bar_dur = beat_dur * 4.0
    total_bars = 4
    total_duration = bar_dur * total_bars
    total_samples = int(total_duration * SAMPLE_RATE)
    samples = [0.0] * total_samples
    
    # Chord progression: C (C4,E4,G4), G (G3,B3,D4), Am (A3,C4,E4), F (F3,A3,C4)
    # Frequencies
    notes = {
        'C3': 130.81, 'E3': 164.81, 'F3': 174.61, 'G3': 196.00, 'A3': 220.00, 'B3': 246.94,
        'C4': 261.63, 'D4': 293.66, 'E4': 329.63, 'F4': 349.23, 'G4': 392.00, 'A4': 440.00, 'B4': 493.88,
        'C5': 523.25, 'D5': 587.33, 'E5': 659.25, 'G5': 783.99
    }
    
    # Melody line (bar, beat, note, duration in beats)
    melody = [
        # Bar 0 (C)
        (0, 0.0, 'E4', 0.8), (0, 1.0, 'G4', 0.8), (0, 2.0, 'C5', 0.8), (0, 3.0, 'E5', 0.8),
        # Bar 1 (G)
        (1, 0.0, 'D5', 0.8), (1, 1.0, 'B4', 0.8), (1, 2.0, 'G4', 1.6),
        # Bar 2 (Am)
        (2, 0.0, 'C5', 0.8), (2, 1.0, 'E5', 0.8), (2, 2.0, 'D5', 0.8), (2, 3.0, 'C5', 0.8),
        # Bar 3 (F)
        (3, 0.0, 'A4', 0.8), (3, 1.0, 'C5', 0.8), (3, 2.0, 'G4', 1.8),
    ]
    
    # Bass line (bar, root note)
    bass = [
        (0, 'C3'), (1, 'G3'), (2, 'A3'), (3, 'F3')
    ]
    
    for bar_idx, root in bass:
        bar_start_t = bar_idx * bar_dur
        for beat in range(4):
            t_start = bar_start_t + beat * beat_dur
            start_samp = int(t_start * SAMPLE_RATE)
            dur_samp = int(beat_dur * 0.75 * SAMPLE_RATE)
            freq = notes[root]
            phase = 0.0
            for i in range(dur_samp):
                if start_samp + i >= total_samples:
                    break
                phase += 2.0 * math.pi * freq / SAMPLE_RATE
                # Smooth bass tone
                val = (math.sin(phase) + 0.3 * math.sin(phase * 2.0)) * 0.22
                env = math.exp(-(i / dur_samp) * 3.0)
                samples[start_samp + i] += val * env
                
    for bar_idx, beat, note, dur_beats in melody:
        t_start = bar_idx * bar_dur + beat * beat_dur
        start_samp = int(t_start * SAMPLE_RATE)
        dur_samp = int(dur_beats * beat_dur * SAMPLE_RATE)
        freq = notes[note]
        phase = 0.0
        for i in range(dur_samp):
            if start_samp + i >= total_samples:
                break
            phase += 2.0 * math.pi * freq / SAMPLE_RATE
            # Bright cheerful flute/synth tone
            tone = math.sin(phase) * 0.6 + math.sin(phase * 2.0) * 0.25 + math.sin(phase * 3.0) * 0.1
            env = math.exp(-(i / dur_samp) * 2.8) * min(1.0, (i / (SAMPLE_RATE * 0.015)))
            samples[start_samp + i] += tone * env * 0.25
            
    # Normalize
    max_val = max(abs(s) for s in samples) or 1.0
    samples = [s / max_val * 0.7 for s in samples]
    return samples

if __name__ == '__main__':
    print("Generating sfx...")
    write_wav('assets/audio/sfx/flap.wav', generate_flap())
    write_wav('assets/audio/sfx/score.wav', generate_score())
    write_wav('assets/audio/sfx/hit.wav', generate_hit())
    write_wav('assets/audio/sfx/click.wav', generate_click())
    write_wav('assets/audio/sfx/gameover.wav', generate_gameover())
    print("Generating music...")
    write_wav('assets/audio/music/bgm.wav', generate_bgm())
    print("Audio generation completed!")
