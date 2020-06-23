extends "res://scripts/menu_button.gd"

func get_edit_text():
	return global.find_keyword

func set_edit_text():
	.set_edit_text()
	global.find_keyword = line_edit.text
