extends Sprite

var fade_amount = 0.04
var alpha = 1 - fade_amount

func process(curr_frame, frame_delay):
	set_modulate(Color(1, 1, 1, alpha))
	if alpha <= 0:
		queue_free()
	alpha -= fade_amount

func set_palette(char_name, palette_num):
	get_material().set_shader_param("threshold", 0.001)
	if palette_num >= 0:
		var palette = global.get_char_palette(char_name, - 1)
		if palette != null:
			for i in range(palette.size()):
				set_palette_color(palette[i], i, true)
		palette = global.get_char_palette(char_name, palette_num)
		if palette != null:
			for i in range(palette.size()):
				set_palette_color(palette[i], i, false)

func set_palette_color(palette_color, palette_num, default):
	if default:
		get_material().set_shader_param("color_o" + str(palette_num), palette_color)
	else :
		get_material().set_shader_param("color_n" + str(palette_num), palette_color)
