from PIL import Image, ImageDraw, ImageFilter
import math
import os

def create_bird():
    size = (160, 160)
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Body (round chubby blue bird)
    # Center (80, 85), radius ~50
    outline_color = (2, 80, 140, 255)
    body_color = (41, 182, 246, 255)
    belly_color = (245, 250, 255, 255)
    beak_color = (255, 152, 0, 255)
    beak_dark = (230, 110, 0, 255)
    blush_color = (255, 138, 128, 200)
    
    # Tail feathers
    tail_pts = [(30, 90), (10, 75), (20, 95), (8, 105), (35, 105)]
    draw.polygon(tail_pts, fill=body_color, outline=outline_color, width=3)
    
    # Crest tuft on head
    crest_pts = [(75, 40), (70, 18), (85, 32), (92, 12), (95, 38)]
    draw.polygon(crest_pts, fill=body_color, outline=outline_color, width=3)

    # Main Body circle
    body_bbox = [35, 42, 135, 138]
    draw.ellipse(body_bbox, fill=body_color, outline=outline_color, width=4)
    
    # Belly (soft white curved patch on front-bottom)
    belly_bbox = [65, 75, 132, 135]
    draw.chord(belly_bbox, start=40, end=210, fill=belly_color)

    # Wing (chubby tear drop)
    wing_pts = [(50, 85), (35, 115), (70, 125), (80, 98)]
    draw.polygon(wing_pts, fill=(3, 155, 229, 255), outline=outline_color, width=3)
    # Wing feather inner lines
    draw.line([(50, 100), (68, 118)], fill=outline_color, width=2)
    
    # Blush on cheek
    draw.ellipse([92, 98, 115, 112], fill=blush_color)
    
    # Eye (large expressive cartoon eye)
    # Outer white sclera
    draw.ellipse([90, 52, 128, 92], fill=(255, 255, 255, 255), outline=outline_color, width=3)
    # Iris (deep blue)
    draw.ellipse([103, 60, 124, 86], fill=(1, 87, 155, 255))
    # Pupil (dark)
    draw.ellipse([107, 64, 122, 82], fill=(10, 20, 40, 255))
    # Highlights (sparkle)
    draw.ellipse([108, 66, 114, 72], fill=(255, 255, 255, 255))
    draw.ellipse([116, 76, 119, 79], fill=(255, 255, 255, 255))
    # Cute cartoon eyebrow
    draw.arc([92, 45, 126, 62], start=200, end=340, fill=outline_color, width=3)

    # Beak (cute orange cone with happy curve)
    beak_pts = [(124, 76), (154, 88), (122, 102)]
    draw.polygon(beak_pts, fill=beak_color, outline=outline_color, width=3)
    draw.line([(124, 88), (145, 89)], fill=beak_dark, width=2)

    img.save('assets/images/bird.png', 'PNG')
    print("Created bird.png")

def create_pipes():
    # Pipe Cap (Head) - width 108, height 48
    cap_w, cap_h = 108, 48
    img_cap = Image.new('RGBA', (cap_w, cap_h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img_cap)
    
    border_color = (15, 60, 25, 255)
    main_green = (76, 175, 80, 255)
    highlight_green = (165, 214, 167, 255)
    shadow_green = (46, 125, 50, 255)
    
    # Rounded rect cap
    d.rounded_rectangle([2, 2, cap_w - 3, cap_h - 3], radius=6, fill=main_green, outline=border_color, width=4)
    # Highlight band on left
    d.rectangle([14, 6, 26, cap_h - 7], fill=highlight_green)
    # Subtle inner shadow on right
    d.rectangle([cap_w - 22, 6, cap_w - 8, cap_h - 7], fill=shadow_green)
    img_cap.save('assets/images/pipe_cap.png', 'PNG')

    # Pipe Body - width 96, height 160 (repeatable)
    body_w, body_h = 96, 160
    img_body = Image.new('RGBA', (body_w, body_h), (0, 0, 0, 0))
    d2 = ImageDraw.Draw(img_body)
    
    # Body rectangle
    d2.rectangle([2, 0, body_w - 3, body_h], fill=main_green, outline=border_color, width=4)
    # Highlight band on left
    d2.rectangle([10, 0, 22, body_h], fill=highlight_green)
    # Shadow on right
    d2.rectangle([body_w - 18, 0, body_w - 6, body_h], fill=shadow_green)
    img_body.save('assets/images/pipe_body.png', 'PNG')
    print("Created pipe_cap.png and pipe_body.png")

def create_ground():
    # Ground tile - width 240, height 110
    w, h = 240, 110
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Earth base
    earth_color = (194, 142, 85, 255)
    earth_stripe = (168, 118, 65, 255)
    grass_color = (102, 187, 106, 255)
    grass_highlight = (165, 214, 167, 255)
    grass_border = (46, 125, 50, 255)
    
    d.rectangle([0, 16, w, h], fill=earth_color)
    
    # Diagonal earth stripes for cartoon depth
    for x in range(-50, w + 50, 30):
        d.polygon([(x, 18), (x + 16, 18), (x + 36, h), (x + 20, h)], fill=earth_stripe)
        
    # Grass banner across top
    d.rectangle([0, 0, w, 18], fill=grass_color)
    d.line([(0, 0), (w, 0)], fill=grass_highlight, width=3)
    d.line([(0, 18), (w, 18)], fill=grass_border, width=3)
    
    # Cute little grass blades hanging down
    for x in range(5, w, 18):
        d.polygon([(x, 18), (x + 7, 26), (x + 14, 18)], fill=grass_color, outline=grass_border)
        
    img.save('assets/images/ground.png', 'PNG')
    print("Created ground.png")

def create_cloud():
    w, h = 260, 130
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    cloud_white = (255, 255, 255, 240)
    cloud_shade = (220, 235, 245, 220)
    
    # Bottom flat/shadow
    d.ellipse([20, 45, 240, 115], fill=cloud_shade)
    # Puffy white circles
    d.ellipse([15, 40, 95, 110], fill=cloud_white)
    d.ellipse([70, 15, 165, 105], fill=cloud_white)
    d.ellipse([135, 25, 225, 105], fill=cloud_white)
    d.ellipse([180, 50, 250, 110], fill=cloud_white)
    d.rectangle([35, 70, 230, 110], fill=cloud_white)
    
    img.save('assets/images/cloud.png', 'PNG')
    print("Created cloud.png")

def create_medal():
    size = (120, 120)
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Ribbon (red & blue)
    ribbon_red = (239, 83, 80, 255)
    ribbon_blue = (66, 165, 245, 255)
    d.polygon([(40, 10), (25, 60), (45, 55), (60, 10)], fill=ribbon_red)
    d.polygon([(80, 10), (95, 60), (75, 55), (60, 10)], fill=ribbon_blue)
    
    # Golden Medal Coin
    gold_border = (180, 130, 10, 255)
    gold_fill = (255, 215, 0, 255)
    gold_light = (255, 245, 157, 255)
    
    d.ellipse([20, 30, 100, 110], fill=gold_fill, outline=gold_border, width=4)
    d.ellipse([28, 38, 92, 102], fill=gold_light, outline=gold_border, width=2)
    
    # Star in center
    cx, cy, r_out, r_in = 60, 70, 22, 10
    pts = []
    for i in range(10):
        angle = -math.pi / 2 + i * math.pi / 5
        r = r_out if i % 2 == 0 else r_in
        pts.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    d.polygon(pts, fill=gold_border)
    
    img.save('assets/images/medal.png', 'PNG')
    print("Created medal.png")

if __name__ == '__main__':
    create_bird()
    create_pipes()
    create_ground()
    create_cloud()
    create_medal()
    print("All image assets created successfully!")
