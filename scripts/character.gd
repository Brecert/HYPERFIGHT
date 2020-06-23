extends Node2D

export  var player_num = 1
export  var cpu = false
export  var size = Vector2(12, 46)

class InputAction:
	var input = ""
	var time = 0
	var press = true

class OnlineInput:
	var map = {"left":false, "right":false, "up":false, "down":false, "attack":false, "special":false, "super":false, "dash":false}
	var frame = 0
	var input_delay = 0
	var read = false

class CpuAction:
	var action = ""
	var time = 0
	
	func _init(a, t):
		action = a
		time = t

var inputs = []
var frame_inputs = []
var online_inputs = []
var input_map = {"left":false, "right":false, "up":false, "down":false, "attack":false, "special":false, "super":false, "dash":false}
var online_input_map = {"left":false, "right":false, "up":false, "down":false, "attack":false, "special":false, "super":false, "dash":false}

var online_control = false
var dtdash = true
var score = 0
var score_balls
var cpu_mode = "idle"
var cpu_type = global.CPU_TYPE.normal
var cpu_timer = 0
var cpu_acted = false
var orig_pos = Vector2()
var linear_vel = Vector2()
var kill_knockback = Vector2()
var shadow_offset = 0
var walk_speed = 65
var air_speed = 90
var h_dash_speed = 125
var v_dash_speed = 300
var jump = 350
var h_dash_jump = 150
var gravity = 18
var attack_gravity = 10
var special_move = 70
var special_jump = 150
var left_bound = - 125
var right_bound = 125
var other_player
var last_input = "none"
var last_input_frames = 0
var on_floor = false
var attacking = false
var attacked = false
var can_dash = true
var can_inv_dash = true
var can_attack = true
var dead = false
var killed = false
var can_act = true
var win = false
var move_while_attacking = false
var dash_while_attacking = false
var attack_while_attacking = false
var h_airdashing = false
var v_airdashing = false
var alpha = 1
var curr_frame = 0
var no_act_frames = 0

var curr_frame_delay = 0
var ignore_frame_delay = false
var send_delay = 0
var dash_frames = 10
var curr_dash_frames = 0
var no_dash_frames = 0
var max_no_dash_frames = 10
var dash_inv_frames = 0
var max_dash_inv_frames = 30
var max_airdash_inv_frames = 10
var effect_y_offset = 0
var invincible = false
var can_zero_special = false
var special_pos_relevant = true
var own_hitboxes = []
var is_christmas = false
var is_april_fools = false

onready  var game = get_parent().get_parent()
onready  var sprite = get_node("Sprite")
onready  var hurtbox = get_node("hurtbox")
onready  var anim_player = get_node("AnimationPlayer")
onready  var audio = get_node("AudioStreamPlayer")
onready  var dash_player = get_node("dash_player")
onready  var effect_dash = preload("res://scenes/effect_dash.tscn")
onready  var effect_super_flash = preload("res://scenes/effect_super.tscn")
onready  var effect_parry_flash = preload("res://scenes/effect_parry.tscn")

onready  var snd_dash = preload("res://sounds/dash.ogg")

func check_events():
	is_christmas = global.is_christmas(player_num)
	is_april_fools = global.is_april_fools()

func add_online_input(input_player_num, copy_map, copy_frame, copy_delay, send_packet):
	if player_num == input_player_num:
		var oinput = OnlineInput.new()
		oinput.map = copy_map.duplicate()
		oinput.frame = copy_frame
		oinput.input_delay = copy_delay
		online_inputs.append(oinput)
		
		if global.save_inputs:
			if player_num == 1:
				global.save_player1_input(copy_frame + copy_delay, copy_map)
			else :
				global.save_player2_input(copy_frame + copy_delay, copy_map)
	if not online_control:
		if global.lobby_state == global.LOBBY_STATE.spectate:
			if player_num == input_player_num:
				if player_num == 1:
					game.player1_frame = copy_frame + copy_delay
				else :
					game.player2_frame = copy_frame + copy_delay
		else :
			game.last_other_frame = copy_frame
			game.last_other_delay = copy_delay
	if send_packet:
		game.broadcast_packet_input(input_player_num, copy_map, copy_frame, copy_delay)

func process_online_input_action(oinput_map, input):
	var action = InputAction.new()
	action.input = input
	if oinput_map[input] and not input_map[input]:
		action.press = false
		inputs.append(action)
		frame_inputs.append(input)
		input_map[input] = true
	elif not oinput_map[input] and input_map[input]:
		action.press = false
		inputs.append(action)
		frame_inputs.append(input)
		input_map[input] = false

func press_input_action(input):
	if global.online:
		online_input_map[input] = true
	elif not input_map[input]:
		var action = InputAction.new()
		action.input = input
		action.press = true
		inputs.append(action)
		frame_inputs.append(input)
		input_map[input] = true

func release_input_action(input):
	if global.online:
		online_input_map[input] = false
	elif input_map[input]:
		var action = InputAction.new()
		action.input = input
		action.press = false
		inputs.append(action)
		frame_inputs.append(input)
		input_map[input] = false

func release_all_actions():
	release_input_action("left")
	release_input_action("right")
	release_input_action("up")
	release_input_action("down")
	release_input_action("attack")
	release_input_action("special")
	release_input_action("super")
	release_input_action("dash")

func process_input_action(input):
	if not global.online or (global.online and online_control):
		var player_prefix = "player1_"
		if player_num != 1 and not global.online:
			player_prefix = "player2_"
		
		if Input.is_action_pressed(player_prefix + input):
			press_input_action(input)
		else :
			release_input_action(input)

func process_online_input(oinput_map):
	process_online_input_action(oinput_map, "left")
	process_online_input_action(oinput_map, "right")
	process_online_input_action(oinput_map, "up")
	process_online_input_action(oinput_map, "down")
	process_online_input_action(oinput_map, "attack")
	process_online_input_action(oinput_map, "special")
	process_online_input_action(oinput_map, "super")
	process_online_input_action(oinput_map, "dash")

func process_input():
	process_input_action("left")
	process_input_action("right")
	process_input_action("up")
	process_input_action("down")
	process_input_action("attack")
	process_input_action("special")
	process_input_action("super")
	process_input_action("dash")
	
	process_online_inputs()

func process_cpu():
	match (cpu_mode):
		"idle":
			release_all_actions()
		"left":
			if not cpu_acted:
				release_all_actions()
				press_input_action("left")
				cpu_acted = true
		"right":
			if not cpu_acted:
				release_all_actions()
				press_input_action("right")
				cpu_acted = true
		"up":
			if not cpu_acted:
				release_all_actions()
				press_input_action("up")
				cpu_acted = true
		"down":
			if not cpu_acted:
				release_all_actions()
				press_input_action("down")
				cpu_acted = true
		"move_forward":
			if not cpu_acted:
				release_all_actions()
				cpu_acted = true
			if get_position().x < other_player.get_position().x:
				release_input_action("left")
				press_input_action("right")
			else :
				release_input_action("right")
				press_input_action("left")
		"move_backward":
			if not cpu_acted:
				release_all_actions()
				cpu_acted = true
			if get_position().x < other_player.get_position().x:
				release_input_action("right")
				press_input_action("left")
			else :
				release_input_action("left")
				press_input_action("right")
		"dash_forward":
			if not cpu_acted:
				release_all_actions()
				cpu_acted = true
			if get_position().x < other_player.get_position().x:
				release_input_action("left")
				release_input_action("right")
				press_input_action("right")
			else :
				release_input_action("left")
				release_input_action("right")
				press_input_action("left")
		"dash_backward":
			if not cpu_acted:
				release_all_actions()
				cpu_acted = true
			if get_position().x < other_player.get_position().x:
				release_input_action("left")
				release_input_action("right")
				press_input_action("left")
			else :
				release_input_action("left")
				release_input_action("right")
				press_input_action("right")
		"jump":
			if not cpu_acted:
				press_input_action("up")
			if not on_floor:
				cpu_acted = true
				release_input_action("up")
		"attack":
			if not cpu_acted:
				release_all_actions()
				press_input_action("attack")
				cpu_acted = true
		"down_attack":
			if not cpu_acted and on_floor:
				release_all_actions()
				press_input_action("down")
				press_input_action("attack")
				cpu_acted = true
		"special":
			if not cpu_acted:
				release_all_actions()
				press_input_action("special")
				cpu_acted = true
		"super":
			if not cpu_acted:
				release_all_actions()
				press_input_action("super")
				cpu_acted = true

	if cpu_timer <= 0:
		if cpu_type == global.CPU_TYPE.normal:
			cpu_acted = false
			var cpu_actions = []
			match (cpu_mode):
				"idle", "move_forward", "move_backward", "jump":
					if score >= 1 and (abs(get_special_position().x - other_player.get_position().x) < 32 or not special_pos_relevant) and other_player.can_kill(player_num):
						cpu_actions.append(CpuAction.new("special", 60))
						cpu_actions.append(CpuAction.new("dash_forward", 10))
					if global.cpu_diff == global.CPU_DIFF.normal:
						cpu_actions.append(CpuAction.new("move_forward", rand_range(5, 15)))
						cpu_actions.append(CpuAction.new("move_forward", rand_range(5, 15)))
						cpu_actions.append(CpuAction.new("attack", rand_range(0, 10)))
					else :
						cpu_actions.append(CpuAction.new("move_forward", rand_range(5, 15)))
						cpu_actions.append(CpuAction.new("move_forward", rand_range(5, 15)))
						cpu_actions.append(CpuAction.new("dash_forward", 5))
						cpu_actions.append(CpuAction.new("dash_backward", 5))
						cpu_actions.append(CpuAction.new("attack", rand_range(10, 20)))
					cpu_actions.append(CpuAction.new("jump", rand_range(5, 10)))
					cpu_actions.append(CpuAction.new("jump", rand_range(5, 10)))
					cpu_actions.append(CpuAction.new("down_attack", rand_range(10, 20)))
					if score >= 2:
						if global.get_curr_char(player_num) == global.CHAR.time:
							cpu_actions.append(CpuAction.new("super", 90))
						else :
							cpu_actions.append(CpuAction.new("super", 30))
				"attack":
					if can_zero_special:
						cpu_actions.append(CpuAction.new("left", 5))
						cpu_actions.append(CpuAction.new("right", 5))
						cpu_actions.append(CpuAction.new("up", 5))
						cpu_actions.append(CpuAction.new("down", 5))
						cpu_actions.append(CpuAction.new("special", 30))
					else :
						cpu_actions.append(CpuAction.new("attack", 30))
						cpu_actions.append(CpuAction.new("attack", 30))
						cpu_actions.append(CpuAction.new("dash_forward", 10))
						cpu_actions.append(CpuAction.new("dash_backward", 10))
			if cpu_actions.size() > 0:
				var rand = randi() % cpu_actions.size()
				var cpu_action = cpu_actions[rand]
				cpu_mode = cpu_action.action
				if global.cpu_diff == global.CPU_DIFF.normal:
					cpu_timer = cpu_action.time + 10
				else :
					cpu_timer = cpu_action.time
			else :
				cpu_mode = "idle"
				cpu_timer = 0
		elif cpu_type == global.CPU_TYPE.dummy:
			if get_position().x > 70:
				if sprite.scale.x < 0:
					cpu_mode = "move_forward"
				else :
					cpu_mode = "move_backward"
			else :
				cpu_mode = "idle"
		elif cpu_type == global.CPU_TYPE.dummy_jump_attack:
			if get_position().x > 70:
				if sprite.scale.x < 0:
					cpu_mode = "move_forward"
				else :
					cpu_mode = "move_backward"
			else :
				if cpu_mode == "jump":
					if on_floor and cpu_acted:
						cpu_acted = false
						cpu_mode = "attack"
				elif cpu_mode == "attack":
					if cpu_acted:
						cpu_acted = false
						cpu_mode = "idle"
						cpu_timer = 180
				else :
					release_all_actions()
					cpu_mode = "jump"
					cpu_acted = false
	
	process_online_inputs()

func process_online_inputs():
	if global.online and not game.game_over:
		if online_control:
			add_online_input(player_num, online_input_map, curr_frame, send_delay, not game.game_over)
			

func process_curr_online_inputs():
	if global.online and not game.game_over:
		var i = 0
		while i < online_inputs.size():
			var oinput = online_inputs[i]
			var oframe = oinput.frame + oinput.input_delay
			if curr_frame > oframe:
				online_inputs.remove(i)
				i -= 1
				
			elif curr_frame == oframe:
				process_online_input(oinput.map)
				oinput.read = true
				online_inputs.remove(i)
				i -= 1
			i += 1

func get_special_position():
	return get_position()

func set_cpu_type(cpu_type):
	self.cpu_type = cpu_type
	if cpu_type == global.CPU_TYPE.dummy_jump_attack:
		cpu_mode = "idle"
	release_all_actions()

func check_player_input(input):
	if not can_act:
		return false
	return input_map[input]
		
func check_player_just_input(input):
	if not can_act:
		return false
	var inputted
	inputted = input_map[input] and frame_inputs.find(input) >= 0
	if inputted:
		last_input = input
		last_input_frames = 0
		return inputted

func stop_act():
	can_act = false
	can_attack = false

func start_act():
	can_act = true
	dead = false
	killed = false
	no_act_frames = 0
	

func start_attack():
	can_attack = true

func is_killed():
	return killed
	
func can_kill(other_num):
	return (can_act or no_act_frames <= 0) and alpha == 1 and not invincible and player_num != other_num and not killed

func can_kill_self():
	return (can_act or no_act_frames <= 0) and alpha == 1 and not invincible and not killed

func can_parry(other_num):
	return false

func can_destroy_other(other_num):
	return false

func kill(knockback):
	killed = true
	kill_knockback = knockback

func kill_effect():
	linear_vel = kill_knockback
	set_position(Vector2(get_position().x, get_position().y - size.y / 2))
	stop_act()
	on_floor = false
	attacking = false
	dead = true
	anim_player.play("fall")
	anim_player.seek(0, true)
	
func inc_score():
	score = score_balls.inc_score()
	
func win_score():
	score = score_balls.win_score()

func dec_score():
	score -= 1
	if score < 0:
		score = 0
	score_balls.use_ball()

func update_score():
	score_balls.remove_temps()
	score = score_balls.score

func set_score(new_score):
	score = new_score
	score_balls.set_score(new_score)

func inc_temp_score_back():
	var orig_temp = score_balls.temp_score
	inc_score()
	while score_balls.temp_score > orig_temp + 1:
		score_balls.use_ball()
	score = score_balls.temp_score

func inc_temp_score():
	var orig_temp = score_balls.temp_score
	inc_score()
	while score_balls.temp_score > orig_temp:
		score_balls.use_ball()
	score = score_balls.temp_score

func get_red_score():
	return score_balls.score

func win():
	win = true

func set_online_control(is_control):
	if not global.debug_mode:
		cpu = false
	online_control = is_control
	
func reset():
	set_position(orig_pos)
	can_dash = true
	attacking = false
	dead = false
	killed = false
	can_attack = false
	win = false
	score = score_balls.reset_score()

func attack():
	pass

func special():
	can_inv_dash = false

func super():
	pass

func attack_condition():
	return true

func special_condition():
	return score > 0

func super_condition():
	return score >= 2

func create_dash_effect(effect_pos, scale_x, rot_deg):
	var e = effect_dash.instance()
	e.set_position(Vector2(effect_pos.x, effect_pos.y + effect_y_offset))
	e.scale.x = scale_x
	e.rotation_degrees = rot_deg
	get_parent().add_child(e)
	play_audio_custom(dash_player, snd_dash)

func process_move():
	var jumped = false
	if on_floor:
		can_inv_dash = true
	
	if not attacking or move_while_attacking:
		if on_floor:
			can_dash = true
			if not dead or linear_vel.y == 0:
				linear_vel.x = 0
			if check_player_input("left"):
				linear_vel.x -= walk_speed
			if check_player_input("right"):
				linear_vel.x += walk_speed
		if check_player_input("up") and on_floor:
			linear_vel.x = 0
			last_input = "up"
			last_input_frames = 0
			if check_player_input("left"):
				linear_vel.x -= air_speed
				last_input = "upleft"
			if check_player_input("right"):
				linear_vel.x += air_speed
				last_input = "upright"
			linear_vel.y = - jump
			on_floor = false
			jumped = true
	
	if not attacking or move_while_attacking or dash_while_attacking:
		var previous_input = last_input
		var past_input_frames = last_input_frames
		if can_dash:
			alpha = 1
			if no_dash_frames > 0:
				no_dash_frames -= 1
		else :
			if dash_inv_frames > 0:
				dash_inv_frames -= 1
			else :
				alpha = 1
		if not jumped:
			if ((check_player_just_input("left") and (previous_input == "left" or previous_input == "upleft") and past_input_frames <= 12 and dtdash) or (check_player_input("left") and check_player_input("dash"))) and can_dash and no_dash_frames <= 0:
				last_input = "none"
				linear_vel.x = - h_dash_speed
				linear_vel.y = - h_dash_jump
				if on_floor:
					dash_inv_frames = max_dash_inv_frames
				else :
					h_airdashing = true
					curr_dash_frames = 0
					dash_inv_frames = max_airdash_inv_frames
				no_dash_frames = max_no_dash_frames
				on_floor = false
				can_dash = false
				attacking = false
				if can_inv_dash:
					alpha = 0.5
				create_dash_effect(get_position(), - 1, 0)
			if ((check_player_just_input("right") and (previous_input == "right" or previous_input == "upright") and past_input_frames <= 12 and dtdash) or (check_player_input("right") and check_player_input("dash"))) and can_dash and no_dash_frames <= 0:
				last_input = "none"
				linear_vel.x = h_dash_speed
				linear_vel.y = - h_dash_jump
				if on_floor:
					dash_inv_frames = max_dash_inv_frames
				else :
					h_airdashing = true
					curr_dash_frames = 0
					dash_inv_frames = max_airdash_inv_frames
				no_dash_frames = max_no_dash_frames
				on_floor = false
				can_dash = false
				attacking = false
				if can_inv_dash:
					alpha = 0.5
				create_dash_effect(get_position(), 1, 0)
			if not on_floor:
				if ((check_player_just_input("up") and (previous_input == "up" or previous_input == "upleft" or previous_input == "upright") and past_input_frames <= 12 and dtdash) or (check_player_input("up") and check_player_input("dash"))) and can_dash and no_dash_frames <= 0:
					last_input = "none"
					linear_vel.x = 0
					linear_vel.y = 0
					v_airdashing = true
					no_dash_frames = max_no_dash_frames
					dash_inv_frames = max_airdash_inv_frames
					curr_dash_frames = 0
					can_dash = false
					attacking = false
					if can_inv_dash:
						alpha = 0.5
					create_dash_effect(Vector2(get_position().x, get_position().y + 24), 1, - 90)
				if ((check_player_just_input("down") and previous_input == "down" and past_input_frames <= 12 and dtdash) or (check_player_input("down") and check_player_input("dash"))) and can_dash and no_dash_frames <= 0:
					last_input = "none"
					linear_vel.x = 0
					linear_vel.y = v_dash_speed
					v_airdashing = true
					no_dash_frames = max_no_dash_frames
					dash_inv_frames = max_airdash_inv_frames
					curr_dash_frames = 0
					can_dash = false
					attacking = false
					if can_inv_dash:
						alpha = 0.5
					create_dash_effect(get_position(), 1, 90)
		if h_airdashing or v_airdashing:
			if curr_dash_frames >= dash_frames:
				h_airdashing = false
				v_airdashing = false
			else :
				curr_dash_frames += 1
		set_modulate(Color(1, 1, 1, alpha))

	if not attacking or move_while_attacking:
		if on_floor:
			if dead and linear_vel.y > 0:
				if linear_vel.y >= 100:
					linear_vel.y *= - 0.5
					on_floor = false
				else :
					linear_vel.y = 0
			else :
				linear_vel.y = 0
		elif not v_airdashing:
			if h_airdashing:
				linear_vel.y = 0
			else :
				linear_vel.y += gravity

func process_attack():
	pass

func process_anim():
	var new_anim = "idle"
	if win:
		new_anim = "win"
	elif dead:
		if on_floor:
			new_anim = "dead"
		else :
			new_anim = "fall"
	elif attacking:
		if anim_player.current_animation == "super":
			new_anim = "super"
		elif anim_player.current_animation == "special":
			new_anim = "special"
		else :
			new_anim = "attack"
	elif not on_floor:
		new_anim = "jump"
	elif linear_vel.x != 0:
		new_anim = "walk_forwards"
		if sign(sprite.scale.x) != sign(linear_vel.x):
			new_anim = "walk_backwards"
	if anim_player.current_animation != new_anim:
		anim_player.play(new_anim)
		anim_player.seek(0, true)

func preprocess_frame():
	last_input_frames += 1
	if invincible:
		sprite.get_material().set_shader_param("white_amount", 0.5)
	else :
		sprite.get_material().set_shader_param("white_amount", 0)
	
	if not attacking or move_while_attacking:
		adjust_facing()
	
	if ( not attacking or attack_while_attacking) and can_attack and alpha == 1:
		if ((check_player_just_input("attack") and check_player_just_input("special")) or check_player_just_input("super")) and super_condition():
			attacking = true
			super()
		elif check_player_just_input("attack") and attack_condition():
			attacking = true
			attack()
		elif check_player_just_input("special") and special_condition():
			attacking = true
			special()
	
	if not attacking or move_while_attacking or dash_while_attacking:
		process_move()

func adjust_facing():
	if get_position().x < other_player.get_position().x:
		sprite.scale.x = 1
	elif get_position().x > other_player.get_position().x:
		sprite.scale.x = - 1

func process_frame():
	if not attacking or move_while_attacking:
		if can_dash and other_player.can_dash and not ((position.x <= left_bound and sprite.scale.x > 0) or (position.x >= right_bound and sprite.scale.x < 0)) and position.y - size.y + 32 <= other_player.position.y + 32 and position.y + 32 >= other_player.position.y - other_player.size.y + 32:
			correct_player_collisions()
	
	var last_anim = anim_player.current_animation
	anim_player.seek(anim_player.current_animation_position + 1, true)
	if not anim_player.is_playing() or (anim_player.current_animation_position >= anim_player.current_animation_length and not anim_player.get_animation(anim_player.current_animation).loop):
		_on_AnimationPlayer_animation_finished(last_anim)
	
	on_floor = hurtbox.get_global_rect().position.y + hurtbox.rect_size.y >= global.floor_y
	
	process_attack()
	
	if linear_vel == Vector2.ZERO:
		process_collisions()
	else :
		var move = abs(linear_vel.x) / global.fps
		while move > 0:
			var move_amount = sign(linear_vel.x)
			if move < 1:
				move_amount = move * sign(linear_vel.x)
			move -= 1
			position.x += move_amount
			if process_collisions():
				position.x -= move_amount
				break
		move = abs(linear_vel.y) / global.fps
		while move > 0:
			var move_amount = sign(linear_vel.y)
			if move < 1:
				move_amount = move * sign(linear_vel.y)
			move -= 1
			position.y += move_amount
			if process_collisions():
				position.y -= move_amount
				break
	
	own_hitboxes.clear()
	
	on_floor = hurtbox.get_global_rect().position.y + hurtbox.rect_size.y >= global.floor_y
	if on_floor:
		position.y = global.floor_y - hurtbox.rect_size.y - hurtbox.rect_position.y
	
	process_anim()
		
	if get_position().x < left_bound:
		set_position(Vector2(left_bound, get_position().y))
		process_edge_hit()
	if get_position().x > right_bound:
		set_position(Vector2(right_bound, get_position().y))
		process_edge_hit()

func check_dead():
	if killed and not dead:
		kill_effect()
	if not can_act:
		no_act_frames += 1

func process_edge_hit():
	if anim_player.current_animation == "special":
		linear_vel.x *= - 0.1
	if (position.x <= left_bound and sprite.scale.x < 0) or (position.x >= right_bound and sprite.scale.x > 0):
		linear_vel.x = 0

func correct_player_collisions():
	if (sprite.scale.x > 0 or position.x >= right_bound or other_player.position.x >= right_bound) and position.x + size.x / 2 > other_player.position.x - other_player.size.x / 2 and position.x + size.x / 2 <= other_player.position.x + other_player.size.x / 2:
		if (other_player.on_floor and (linear_vel.x != 0 or (linear_vel.x == 0 and other_player.linear_vel.x == 0))) or ( not on_floor and linear_vel.x != 0):
			position.x = other_player.position.x - other_player.size.x / 2 - size.x / 2
		if on_floor and other_player.on_floor and linear_vel.x != 0 and other_player.linear_vel.x == 0:
			other_player.position.x += linear_vel.x / 200
	elif (sprite.scale.x < 0 or position.x <= left_bound or other_player.position.x <= left_bound) and position.x - size.x / 2 < other_player.position.x + other_player.size.x / 2 and position.x - size.x / 2 >= other_player.position.x - other_player.size.x / 2:
		if (other_player.on_floor and (linear_vel.x != 0 or (linear_vel.x == 0 and other_player.linear_vel.x == 0))) or ( not on_floor and linear_vel.x != 0):
			position.x = other_player.position.x + other_player.size.x / 2 + size.x / 2
		if on_floor and other_player.on_floor and linear_vel.x != 0 and other_player.linear_vel.x == 0:
			other_player.position.x += linear_vel.x / 200

func get_sprite():
	return sprite

func set_other_player(new_other_player):
	other_player = new_other_player

func play_audio(snd):
	audio.volume_db = global.sfx_volume_db
	audio.stream = snd
	audio.play(0)

func play_audio_custom(player, snd):
	player.volume_db = global.sfx_volume_db
	player.stream = snd
	player.play(0)

func create_super_flash(offset):
	var e = effect_super_flash.instance()
	e.set_position(get_position() + offset)
	e.scale.x = sprite.scale.x
	get_parent().add_child(e)
	game.super_flash()

func create_parry_flash(offset):
	var e = effect_parry_flash.instance()
	e.set_position(get_position() + offset)
	get_parent().add_child(e)
	game.parry_flash()

func _ready():
	orig_pos = get_position()
	hurtbox.set_monitoring(true)
	anim_player.playback_speed = 0
	anim_player.play("idle")
	set_palette()
	if player_num == 1:
		score_balls = get_node("../../GUILayer/label_player1/score_balls")
	else :
		score_balls = get_node("../../GUILayer/label_player2/score_balls")
		sprite.scale.x = - 1

func process_collisions():
	var hitboxes = get_tree().get_nodes_in_group("hitbox")
	for other_hitbox in hitboxes:
		if hurtbox != other_hitbox and hurtbox.intersects(other_hitbox):
			process_hitbox_collision(other_hitbox)
		for own_hitbox_arr in own_hitboxes:
			var own_hitbox = own_hitbox_arr[0]
			var coll_func = own_hitbox_arr[1]
			if own_hitbox != other_hitbox and own_hitbox.intersects(other_hitbox):
				call(coll_func, other_hitbox)

func process_own_hitbox(hitbox, coll_func):
	if hitbox.is_monitoring():
		own_hitboxes.append([hitbox, coll_func])

func process_hitbox_collision(hitbox):
	var hitbox_owner = hitbox.get_hitbox_owner()
	if hitbox.is_in_group("proj") and hitbox.can_collide_with_char():
		hitbox_owner.process_hitbox_collision(hurtbox, false)

func preprocess(curr_frame, frame_delay):
	self.curr_frame = curr_frame
	if other_player != null:
		if game.input_delay >= game.prev_delay:
			send_delay = game.prev_delay
			if cpu:
				process_cpu()
			else :
				process_input()
		if game.input_delay > game.prev_delay:
			send_delay = game.input_delay
			if cpu:
				process_cpu()
			else :
				process_input()
		process_curr_online_inputs()
		
		if curr_frame_delay <= 0 or ignore_frame_delay:
			cpu_timer -= 1
			preprocess_frame()

func process(curr_frame, frame_delay):
	if other_player != null:
		if curr_frame_delay <= 0 or ignore_frame_delay:
			process_frame()
			
			if ignore_frame_delay or curr_frame_delay < 0:
				frame_delay = 0
				curr_frame_delay = 0
			else :
				curr_frame_delay = frame_delay
		else :
			curr_frame_delay -= 1
			no_dash_frames = max_no_dash_frames
		
		if get_position().x < left_bound:
			set_position(Vector2(left_bound, get_position().y))
		if get_position().x > right_bound:
			set_position(Vector2(right_bound, get_position().y))
		
		if inputs.size() > 0:
			inputs[inputs.size() - 1].time += 1
		frame_inputs.clear()

func set_palette():
	set_palette_sprite(sprite)

func set_palette_sprite(palette_sprite):
	palette_sprite.get_material().set_shader_param("threshold", 0.001)
	var char_name = global.player1_char
	var palette_num = global.player1_palette
	if player_num != 1:
		char_name = global.player2_char
		palette_num = global.player2_palette
	if palette_num >= 0:
		var palette = global.get_char_palette(char_name, - 1)
		if palette != null:
			for i in range(palette.size()):
				set_palette_color(palette_sprite, palette[i], i, true)
		palette = global.get_char_palette(char_name, palette_num)
		if palette != null:
			for i in range(palette.size()):
				set_palette_color(palette_sprite, palette[i], i, false)

func set_palette_color(palette_sprite, palette_color, palette_num, default):
	if default:
		palette_sprite.get_material().set_shader_param("color_o" + str(palette_num), palette_color)
	else :
		palette_sprite.get_material().set_shader_param("color_n" + str(palette_num), palette_color)
			
func _on_AnimationPlayer_animation_finished(anim_name):
	if attacking:
		attacking = false
		anim_player.play("idle")
