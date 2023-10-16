import sys
from colorsys import hsv_to_rgb 

h = (1.0 - float(sys.argv[1]) * 0.01) * 0.33

hsv = [h, 1.0, 1.0]

color_rgb = hsv_to_rgb(hsv[0], hsv[1], hsv[2])
print ('#%02x%02x%02x' % ( int(color_rgb[0] * 255), int(color_rgb[1] * 255), int(color_rgb[2] * 255)))