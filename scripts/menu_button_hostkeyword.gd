extends "res://scripts/menu_button.gd"

func check_page():
	return page == global.host_page

func get_edit_text():
	return global.host_keyword

func set_edit_text():
	.set_edit_text()
	global.host_keyword = line_edit.text
