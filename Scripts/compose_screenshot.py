#!/usr/bin/env python3
"""Compose App Store marketing screenshots: green background, rounded headline, framed screenshot.

usage: compose.py <source.png> <output.png> <canvas_w> <canvas_h> <headline...>
"""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

BACKGROUND = (0, 214, 105)
BEZEL = (22, 22, 24)
FONT_PATH = "/System/Library/Fonts/SFCompactRounded.ttf"


def headline_font(size):
    font = ImageFont.truetype(FONT_PATH, size)
    font.set_variation_by_name("Heavy")
    return font


def wrap(draw, text, font, max_width):
    lines, current = [], ""
    for word in text.split():
        candidate = f"{current} {word}".strip()
        if draw.textlength(candidate, font=font) <= max_width:
            current = candidate
        else:
            lines.append(current)
            current = word
    lines.append(current)
    return lines


def compose(source, output, width, height, headline):
    canvas = Image.new("RGB", (width, height), BACKGROUND)
    draw = ImageDraw.Draw(canvas)

    font = headline_font(int(width * 0.072))
    lines = wrap(draw, headline, font, width * 0.86)
    line_height = int(font.size * 1.12)
    y = int(height * 0.052)
    for line in lines:
        text_width = draw.textlength(line, font=font)
        draw.text(((width - text_width) / 2, y), line, font=font, fill="white")
        y += line_height

    shot = Image.open(source).convert("RGB")
    top = max(y + int(height * 0.03), int(height * 0.17))
    frame_width = int(width * 0.80)
    bezel = int(width * (0.016 if shot.height / shot.width < 1.5 else 0.022))
    inner_width = frame_width - 2 * bezel
    inner_height = int(inner_width * shot.height / shot.width)
    frame_height = inner_height + 2 * bezel
    max_height = height - top - int(height * 0.03)
    if frame_height > max_height:
        scale = max_height / frame_height
        frame_width = int(frame_width * scale)
        bezel = int(bezel * scale)
        inner_width = frame_width - 2 * bezel
        inner_height = int(inner_width * shot.height / shot.width)
        frame_height = inner_height + 2 * bezel
    x0 = (width - frame_width) // 2
    # iPhones have large display corners; iPads have small ones and a status bar hugging the corner.
    is_tablet = shot.height / shot.width < 1.5
    outer_radius = int(frame_width * (0.05 if is_tablet else 0.115))
    inner_radius = int(inner_width * (0.03 if is_tablet else 0.095))

    shadow = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [x0, top + int(height * 0.012), x0 + frame_width, top + frame_height + int(height * 0.012)],
        radius=outer_radius, fill=(0, 0, 0, 90))
    shadow = shadow.filter(ImageFilter.GaussianBlur(int(width * 0.03)))
    canvas.paste(shadow, (0, 0), shadow)

    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle([x0, top, x0 + frame_width, top + frame_height], radius=outer_radius, fill=BEZEL)
    shot = shot.resize((inner_width, inner_height), Image.LANCZOS)
    mask = Image.new("L", shot.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, inner_width - 1, inner_height - 1], radius=inner_radius, fill=255)
    canvas.paste(shot, (x0 + bezel, top + bezel), mask)
    canvas.save(output, optimize=True)
    print(f"wrote {output} {width}x{height} lines={len(lines)}")


if __name__ == "__main__":
    src, out, w, h = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
    compose(src, out, w, h, " ".join(sys.argv[5:]))
