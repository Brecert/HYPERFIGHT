extends Node2D

var max_transition_timer = 40
var transition_timer = max_transition_timer

onready  var logo = get_node("logo")

func _init():
	var cmdline_args = OS.get_cmdline_args()
	if cmdline_args.size() > 0:
		var parse_lobby_id = false
		for arg in cmdline_args:
			if arg == "+connect_lobby":
				parse_lobby_id = true
			elif parse_lobby_id:
				global.load_config()
				global.join_requested(0, arg)

func _ready():
	global.load_config()

func _process(delta):
	transition_timer -= 1 * (global.fps * delta)
	if transition_timer <= 0:
		if logo.visible:
			logo.visible = false
		else :
			get_tree().change_scene("res://scenes/menu.tscn")
		transition_timer = max_transition_timer
