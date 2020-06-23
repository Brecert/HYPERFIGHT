extends Sprite

export  var player1 = true

var max_pages = 4
var curr_page = 1

onready  var char_spr = get_node("char_spr")
onready  var label_char = get_node("label_char")
onready  var label_move = get_node("label_move")
onready  var label_desc = get_node("label_desc")
onready  var label_command = get_node("label_command")
onready  var label_page = get_node("label_page")
onready  var arrow_left = get_node("arrow_left")
onready  var arrow_right = get_node("arrow_right")
onready  var game = get_parent().get_parent().get_parent()

onready  var p2_texture = preload("res://graphics/move_list_border_p2.png")

onready  var goto_attack = preload("res://graphics/move_list_goto_attack.png")
onready  var goto_attack_down = preload("res://graphics/move_list_goto_attack_down.png")
onready  var goto_special = preload("res://graphics/move_list_goto_special.png")
onready  var goto_super = preload("res://graphics/move_list_goto_super.png")
onready  var yoyo_attack = preload("res://graphics/move_list_yoyo_attack.png")
onready  var yoyo_attack_hold = preload("res://graphics/move_list_yoyo_attack_hold.png")
onready  var yoyo_special = preload("res://graphics/move_list_yoyo_special.png")
onready  var yoyo_special_hold = preload("res://graphics/move_list_yoyo_special_hold.png")
onready  var yoyo_super = preload("res://graphics/move_list_yoyo_super.png")
onready  var kero_attack = preload("res://graphics/move_list_kero_attack.png")
onready  var kero_attack_air = preload("res://graphics/move_list_kero_attack_air.png")
onready  var kero_attack_down = preload("res://graphics/move_list_kero_attack_down.png")
onready  var kero_special = preload("res://graphics/move_list_kero_special.png")
onready  var kero_special_spit = preload("res://graphics/move_list_kero_special_spit.png")
onready  var kero_special_swallow = preload("res://graphics/move_list_kero_special_swallow.png")
onready  var kero_super = preload("res://graphics/move_list_kero_super.png")
onready  var time_attack_short = preload("res://graphics/move_list_time_attack_short.png")
onready  var time_attack = preload("res://graphics/move_list_time_attack.png")
onready  var time_attack_down = preload("res://graphics/move_list_time_attack_down.png")
onready  var time_special = preload("res://graphics/move_list_time_special.png")
onready  var time_super = preload("res://graphics/move_list_time_super.png")
onready  var sword_attack = preload("res://graphics/move_list_sword_attack.png")
onready  var sword_attack_buffed = preload("res://graphics/move_list_sword_attack_buffed.png")
onready  var sword_teleport = preload("res://graphics/move_list_sword_teleport.png")
onready  var sword_attack_down = preload("res://graphics/move_list_sword_attack_down.png")
onready  var sword_attack_down_buffed = preload("res://graphics/move_list_sword_attack_down_buffed.png")
onready  var sword_special = preload("res://graphics/move_list_sword_special.png")
onready  var sword_super = preload("res://graphics/move_list_sword_super.png")
onready  var darkgoto_ability = preload("res://graphics/move_list_darkgoto_ability.png")
onready  var darkgoto_attack = preload("res://graphics/move_list_darkgoto_attack.png")
onready  var darkgoto_attack_down = preload("res://graphics/move_list_darkgoto_attack_down.png")
onready  var darkgoto_special = preload("res://graphics/move_list_darkgoto_special.png")
onready  var darkgoto_super = preload("res://graphics/move_list_darkgoto_super.png")

func _ready():
	var player_char = global.player1_char
	if not player1:
		player_char = global.player2_char
		texture = p2_texture
		label_char.add_color_override("font_color", Color(0, 0.5, 1))
		label_move.add_color_override("font_color", Color(0.5, 0.75, 1))
		label_command.add_color_override("font_color", Color(0.5, 0.75, 1))
		arrow_left.set_modulate(Color(0.5, 0.75, 1))
		arrow_right.set_modulate(Color(0.5, 0.75, 1))
		if global.player2_cpu:
			visible = false
	match player_char:
		global.CHAR.yoyo:
			max_pages = 5
		global.CHAR.kero:
			max_pages = 8
		global.CHAR.time:
			max_pages = 5
		global.CHAR.sword:
			max_pages = 8
		global.CHAR.darkgoto:
			max_pages = 5
		_:
			max_pages = 4
	set_page()

func _process(delta):
	if game.paused:
		if player1:
			if Input.is_action_just_pressed("player1_left"):
				curr_page -= 1
				if curr_page < 1:
					curr_page = 1
			if Input.is_action_just_pressed("player1_right"):
				curr_page += 1
				if curr_page > max_pages:
					curr_page = max_pages
		else :
			if Input.is_action_just_pressed("player2_left"):
				curr_page -= 1
				if curr_page < 1:
					curr_page = 1
			if Input.is_action_just_pressed("player2_right"):
				curr_page += 1
				if curr_page > max_pages:
					curr_page = max_pages
		set_page()

func set_page():
	var curr_char = global.player1_char
	if not player1:
		curr_char = global.player2_char
	var move_text = ""
	var desc_text = ""
	var command_text = ""
	arrow_left.visible = true
	arrow_right.visible = true
	if curr_page == 1:
		arrow_left.visible = false
	elif curr_page == max_pages:
		arrow_right.visible = false
	match curr_char:
		global.CHAR.goto:
			match curr_page:
				1:
					char_spr.texture = goto_attack
					move_text = "Blazing Sun"
					desc_text = "Can be angled by holding UP/DOWN before shot."
					command_text = "ATTACK"
				2:
					char_spr.texture = goto_attack_down
					move_text = "Rising Fist"
					desc_text = "Close uppercut. Can perform in air."
					command_text = "DOWN + ATK"
				3:
					char_spr.texture = goto_special
					move_text = "Parry"
					desc_text = "Gain point back and red point if landed."
					command_text = "SPECIAL"
				4:
					char_spr.texture = goto_super
					move_text = "Super Shoto Attack"
					desc_text = "Large fireball. Can be angled UP/DOWN."
					command_text = "SUPER"
		global.CHAR.yoyo:
			match curr_page:
				1:
					char_spr.texture = yoyo_attack
					move_text = "Yo-yo Attack"
					desc_text = "Can angle in any dir. Stuns you on contact with proj."
					command_text = "ATTACK"
				2:
					char_spr.texture = yoyo_attack_hold
					move_text = "Yo-yo Reel"
					desc_text = "When anchored: reel in towards yo-yo."
					command_text = "ATTACK"
				3:
					char_spr.texture = yoyo_special
					move_text = "Yo-yo Anchor"
					desc_text = "No points needed. Anchor yo-yo in place."
					command_text = "SPECIAL"
				4:
					char_spr.texture = yoyo_special_hold
					move_text = "Remote Blast"
					desc_text = "When anchored: explodes yo-yo in small blast."
					command_text = "SPECIAL"
				5:
					char_spr.texture = yoyo_super
					move_text = "Super Yo-yo"
					desc_text = "Large yo-yo. Can be angled in any direction."
					command_text = "SUPER"
		global.CHAR.kero:
			match curr_page:
				1:
					char_spr.texture = kero_attack
					move_text = "Flying Kick (Grnd)"
					desc_text = "Kick forward til object or edge of stage is hit."
					command_text = "ATTACK"
				2:
					char_spr.texture = kero_attack_air
					move_text = "Flying Kick (Air)"
					desc_text = "Kick diagonally downward til object or floor is hit."
					command_text = "ATTACK"
				3:
					char_spr.texture = kero_attack_down
					move_text = "Gravity Ball"
					desc_text = "Stays btwn rounds, can kick. Re-charge 1/sec."
					command_text = "DOWN + ATK"
				4:
					char_spr.texture = kero_special_spit
					move_text = "Spit Back"
					desc_text = "W/ suck: spit out proj. at opposite velocity."
					command_text = "DOWN + ATK"
				5:
					char_spr.texture = kero_special
					move_text = "Tongue Shot"
					desc_text = "No hitbox. Sucks in most proj. including supers."
					command_text = "SPECIAL"
				6:
					char_spr.texture = kero_special_swallow
					move_text = "Swallow"
					desc_text = "W/ suck: gain 1 red pt. (2 for supers). No pts needed."
					command_text = "SPECIAL"
				7:
					char_spr.texture = kero_super
					move_text = "Trap Ball"
					desc_text = "No gravity, bounces along walls. Can be kicked."
					command_text = "SUPER"
				8:
					char_spr.texture = kero_special_swallow
					move_text = "Super Swallow"
					desc_text = "W/ suck: gain 2 red pts. Only 1 pt. needed."
					command_text = "SUPER"
		global.CHAR.time:
			match curr_page:
				1:
					char_spr.texture = time_attack_short
					move_text = "Taste Ketchup"
					desc_text = "Change trajectory with LEFT/RIGHT."
					command_text = "ATTACK"
				2:
					char_spr.texture = time_attack
					move_text = "Taste Fries"
					desc_text = "Fast projectile. Angle with UP/DOWN."
					command_text = "ATK (HOLD)"
				3:
					char_spr.texture = time_attack_down
					move_text = "Slider"
					desc_text = "Only works grounded. Forward slide attack."
					command_text = "DOWN + ATK"
				4:
					char_spr.texture = time_special
					move_text = "Slamburger"
					desc_text = "Teleports up, slams down. Keeps horiz. momentum."
					command_text = "SPECIAL"
				5:
					char_spr.texture = time_super
					move_text = "Clock Out"
					desc_text = "Stop time (hold for full charge). Not an instant win."
					command_text = "SUPER"
		global.CHAR.sword:
			match curr_page:
				1:
					char_spr.texture = sword_attack
					move_text = "Piercing Stab"
					desc_text = "Time button release to extend distance."
					command_text = "ATTACK"
				2:
					char_spr.texture = sword_attack_buffed
					move_text = "Piercing Stab+"
					desc_text = "When buffed: teleports and creates trail hitbox."
					command_text = "ATTACK"
				3:
					char_spr.texture = sword_teleport
					move_text = "Teleport"
					desc_text = "Can do once while charging Piercing Stab."
					command_text = "ANY DIR."
				4:
					char_spr.texture = sword_attack_down
					move_text = "Rolling Slice"
					desc_text = "Only works grounded. LEFT/RIGHT changes momentum."
					command_text = "DOWN + ATK"
				5:
					char_spr.texture = sword_attack_down_buffed
					move_text = "Rolling Slice+"
					desc_text = "When buffed: move further, destroy projectiles."
					command_text = "DOWN + ATK"
				6:
					char_spr.texture = sword_special
					move_text = "Volt Charge"
					desc_text = "Buffs Piercing Stab or Rolling Slice once."
					command_text = "SPECIAL"
				7:
					char_spr.texture = sword_special
					move_text = "Thunderbolt-V"
					desc_text = "Three fast vertical bolts that span stage height."
					command_text = "SUPER"
				8:
					char_spr.texture = sword_super
					move_text = "Thunderbolt-H"
					desc_text = "When buffed: horizontal bolt that spans stage width."
					command_text = "SUPER"
		global.CHAR.darkgoto:
			match curr_page:
				1:
					char_spr.texture = darkgoto_ability
					move_text = "Double Air Dash"
					desc_text = "Can dash twice in the air."
					command_text = "ABILITY"
				2:
					char_spr.texture = darkgoto_attack
					move_text = "Dark Sun"
					desc_text = "Diagonally upwards on ground, downwards in air."
					command_text = "ATTACK"
				3:
					char_spr.texture = darkgoto_attack_down
					move_text = "Vengeful Fist"
					desc_text = "Can perform in air. Further than Rising Fist."
					command_text = "DOWN + ATK"
				4:
					char_spr.texture = darkgoto_special
					move_text = "Reflect"
					desc_text = "Gain point back + red point + reflect atk if landed."
					command_text = "SPECIAL"
				5:
					char_spr.texture = darkgoto_super
					move_text = "Super Evil Attack"
					desc_text = "Trajectory like Dark Sun. Can dash cancel recovery."
					command_text = "SUPER"
	label_char.text = global.get_char_real_name(curr_char)
	label_move.text = move_text
	label_desc.text = desc_text
	label_command.text = command_text
	label_page.text = str(curr_page)
