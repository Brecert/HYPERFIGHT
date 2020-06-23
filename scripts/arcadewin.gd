extends Node2D

var state = "congrats"
var max_press_timer = 120
var press_timer = max_press_timer
var bg_move = 4
var bg_grid_edge = 128
var transition_alpha = 1
var change_alpha = 0.1
var ignore_first_delta = true

onready  var audio = get_node("AudioStreamPlayer")
onready  var bg_grid = get_node("bg_grid")
onready  var bg_blank = get_node("bg_blank")
onready  var transition = get_node("transition")
onready  var preview_player1 = get_node("preview_player1")
onready  var label_congrats = get_node("label_congrats")
onready  var label_time = get_node("label_time")
onready  var label_time2 = get_node("label_time/label_time2")
onready  var label_unlock = get_node("label_unlock")
onready  var button_ok = get_node("button_ok")

onready  var msc_arcade_win = preload("res://sounds/arcade_win.ogg")
onready  var snd_select = preload("res://sounds/select.ogg")
onready  var snd_select2 = preload("res://sounds/select2.ogg")

func _ready():
	global_audio.stop()
	global_audio.stream = msc_arcade_win
	global_audio.play(0)
	transition.visible = true
	preview_player1.set_char(global.player1_char)
	preview_player1.set_palette_num(global.player1_palette)
	preview_player1.select()
	label_time.visible = false
	label_unlock.visible = false
	button_ok.active = false

func _process(delta):
	if ignore_first_delta:
		delta = 0
		ignore_first_delta = false
	
	transition.set_modulate(Color(1, 1, 1, transition_alpha))
	preview_player1.process(delta)
	if state == "congrats":
		if transition_alpha > 0:
			transition_alpha -= change_alpha * (global.fps * delta)
		if press_timer > 0:
			press_timer -= 1 * (global.fps * delta)
		elif press_timer <= 0:
			label_time.visible = true
			var time = global.get_record_arcade(global.player1_char)
			if time < 0 or global.arcade_time < time:
				label_time2.text = "New record!"
				global.set_record_arcade(global.player1_char, global.arcade_time)
			var mins = global.arcade_time / 3600
			var secs = (global.arcade_time / 60) % 60
			var msecs = floor((global.arcade_time % 60) * 16.667)
			if mins > 99:
				mins = 99
			label_time.text = "%02d:%02d:%03d" % [mins, secs, msecs]
			press_timer = max_press_timer
			state = "time"
	elif state == "time":
		if press_timer > 0:
			press_timer -= 1 * (global.fps * delta)
		elif press_timer <= 0:
			state = "unlock"
	elif state == "unlock":
		if not global.is_color4_unlocked(global.player1_char):
			global.unlock_color4(global.player1_char)
			label_unlock.visible = true
			label_unlock.text = global.get_char_real_name(global.player1_char) + "
Color 4"
			press_timer = max_press_timer
			play_audio(snd_select)
			state = "unlocked"
		else :
			var unlock_char = global.unlock_char()
			if unlock_char != null:
				label_unlock.visible = true
				label_unlock.text = "Character
" + global.get_char_real_name(unlock_char)
				press_timer = max_press_timer
				play_audio(snd_select)
				state = "unlocked"
			else :
				var unlock_stage = global.unlock_stage()
				if unlock_stage != null:
					label_unlock.visible = true
					label_unlock.text = "Stage
" + global.get_stage_real_name(unlock_stage)
					press_timer = max_press_timer
					play_audio(snd_select)
					state = "unlocked"
				else :
					button_ok.active = true
					state = "ok"
	elif state == "unlocked":
		if press_timer > 0:
			press_timer -= 1 * (global.fps * delta)
		elif press_timer <= 0:
			state = "unlock"
	elif state == "ok":
		button_ok.highlight(1)
		if Input.is_action_just_pressed("player1_attack"):
			button_ok.select(1)
			press_timer = max_press_timer / 2
			play_audio(snd_select2)
			state = "ok_select"
	elif state == "ok_select":
		if press_timer > 0:
			press_timer -= 1 * (global.fps * delta)
		elif press_timer <= 0:
			state = "transition"
	else :
		if transition_alpha < 4:
			transition_alpha += change_alpha * (global.fps * delta)
		else :
			get_tree().change_scene("res://scenes/menu.tscn")
	if bg_move != 0:
		bg_grid.set_position(Vector2(bg_grid.get_position().x + bg_move * (global.fps * delta), bg_grid.get_position().y))
		if bg_grid.get_position().x > bg_grid_edge:
			bg_grid.set_position(Vector2( - bg_grid_edge, get_position().y))
		elif bg_grid.get_position().x < - bg_grid_edge:
			bg_grid.set_position(Vector2(bg_grid_edge, get_position().y))

func play_audio(snd):
	audio.volume_db = global.sfx_volume_db
	audio.stream = snd
	audio.play(0)
