from PIL import Image
import os

def optimize_image(src_name, dest_name, max_w, max_h):
    src_path = os.path.join('assets/images', src_name)
    dest_path = os.path.join('assets/images', dest_name)
    
    im = Image.open(src_path)
    # Check bbox to crop unnecessary transparent borders if any
    alpha = im.split()[-1]
    bbox = alpha.getbbox()
    if bbox:
        # Give a small 2px padding
        w, h = im.size
        crop_box = (
            max(0, bbox[0] - 2),
            max(0, bbox[1] - 2),
            min(w, bbox[2] + 2),
            min(h, bbox[3] + 2),
        )
        im = im.crop(crop_box)
    
    # Calculate scale factor
    scale = min(max_w / im.width, max_h / im.height, 1.0)
    new_w = int(im.width * scale)
    new_h = int(im.height * scale)
    
    resized = im.resize((new_w, new_h), Image.Resampling.LANCZOS)
    resized.save(dest_path, 'PNG', optimize=True)
    orig_kb = os.path.getsize(src_path) / 1024
    new_kb = os.path.getsize(dest_path) / 1024
    print(f"{src_name} ({orig_kb:.1f} KB) -> {dest_name} ({resized.size[0]}x{resized.size[1]}, {new_kb:.1f} KB)")

if __name__ == '__main__':
    # Bird: in-game ~54x46 -> 256 max width is super sharp 4x retina
    optimize_image('bird_new.png', 'bird.png', 240, 240)
    
    # Cloud: in-game ~160x80 -> 512 max width is crisp 3x retina
    optimize_image('cloud_new.png', 'cloud.png', 512, 256)
    
    # Ground: in-game ~100px tall -> 640x220
    optimize_image('ground_new.png', 'ground.png', 640, 240)
    
    # Pipe Cap: in-game ~76x38 -> 240x120
    optimize_image('pipe_cap_new.png', 'pipe_cap.png', 240, 120)
    
    # Pipe Body: in-game ~66px wide -> 200x200
    optimize_image('pipe_body_new.png', 'pipe_body.png', 200, 200)

    # Clean up the raw 1MB *_new.png files
    for raw in ['bird_new.png', 'cloud_new.png', 'ground_new.png', 'pipe_body_new.png', 'pipe_cap_new.png']:
        raw_path = os.path.join('assets/images', raw)
        if os.path.exists(raw_path):
            os.remove(raw_path)
            print(f"Removed temporary bulky file: {raw}")

    print("All new assets optimized and integrated successfully!")
