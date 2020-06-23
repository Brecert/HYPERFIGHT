extends Sprite

var select_timer = - 1
var max_select_timer = 30
var inactive_y = 150
var move_factor = 4
var orig_pos
var active = false

onready  var menu_parent = get_parent()
onready  var label_ok = get_node("label_ok")
onready  var label_text = get_node("label_text")
onready  var anim_player = get_node("AnimationPlayer")

func _ready():
	visible = true
	orig_pos = get_position()
	set_position(Vector2(orig_pos.x, orig_pos.y + inactive_y))
	anim_player.play("ok")

func _process(delta):
	if active:
		set_position(Vector2(orig_pos.x, get_position().y + (orig_pos.y - get_position().y) / move_factor * (global.fps * delta)))
		
		if select_timer > 0:
			select_timer -= 1 * (global.fps * delta)
			if select_timer <= 0:
				active = false
			var temp = int(select_timer / 3)
			if temp % 2 == 0:
				label_ok.visible = true
			else :
				label_ok.visible = false
		else :
			label_ok.add_color_override("font_color", Color(0.5, 1, 0.5))
				
			if Input.is_action_just_pressed("player1_attack") or Input.is_action_just_pressed("player1_start") or Input.is_action_just_pressed("player2_attack") or Input.is_action_just_pressed("player2_start"):
				select_timer = max_select_timer
				menu_parent.play_audio(menu_parent.snd_select2)
	else :
		set_position(Vector2(orig_pos.x, get_position().y + (orig_pos.y + inactive_y - get_position().y) / move_factor * (global.fps * delta)))

func set_text(text):
	label_text.text = text
