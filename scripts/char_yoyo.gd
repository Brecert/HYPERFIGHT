extends "res://scripts/character.gd"

export  var yoyo_pos = Vector2()

var curr_proj = null
var proj_move = 120
var holding = false
var hold_frames = - 1
var max_hold_frames = 30
var hold_speed = 0
var min_hold_speed = 5
var max_hold_speed = 30
var hold_speed_factor = 2
var yoyo_return_dist = 8
var created_attack = true
var stun_vel = 180

onready  var audio2 = get_node("AudioStreamPlayer2")

onready  var proj_attack = preload("res://scenes/proj_yoyo_attack.tscn")
onready  var proj_super = preload("res://scenes/proj_yoyo_super.tscn")
onready  var effect_hit = preload("res://scenes/effect_proj_yoyo_attack_hit.tscn")

onready  var snd_attack = preload("res://sounds/char_yoyo_attack.ogg")
onready  var snd_special = preload("res://sounds/char_yoyo_special.ogg")
onready  var snd_special_boom = preload("res://sounds/char_yoyo_special_boom.ogg")
onready  var snd_super = preload("res://sounds/char_yoyo_super.ogg")
onready  var snd_super_flash = preload("res://sounds/super_flash.ogg")
onready  var snd_hit = preload("res://sounds/char_yoyo_hit.ogg")
onready  var snd_stun = preload("res://sounds/parry.ogg")

func attack_condition():
	return curr_proj == null or holding

func special_condition():
	return curr_proj != null and score > 0

func super_condition():
	return curr_proj == null and score >= 2

func attack():
	anim_player.play("attack")
	anim_player.seek(0, true)
	attacked = false
	sprite.frame = 0
	if not holding:
		play_audio(snd_attack)

func special():
	.special()
	if curr_proj != null and holding:
		curr_proj.create_special()
		curr_proj = null
		holding = false
		anim_player.play("special")
		sprite.frame = 0
		linear_vel.x *= 0.25
		linear_vel.y = 0
		dec_score()
		play_audio(snd_special)
		play_audio_custom(audio2, snd_special_boom)

func super():
	attacked = false
	anim_player.play("super")
	sprite.frame = 0
	for i in range(2):
		dec_score()
	play_audio(snd_super)
	play_audio_custom(audio2, snd_super_flash)
	create_super_flash(Vector2(10 * sprite.scale.x, 7))

func kill(knockback):
	.kill(knockback)
	play_audio(snd_hit)
	holding = false
	hold_frames = - 1
	if curr_proj != null:
		curr_proj.disable_collision()
		curr_proj.returning = true
		if created_attack:
			curr_proj.holding = false

func _ready():
	size = Vector2(12, 39)
	effect_y_offset = 8
	h_dash_speed = 120
	walk_speed = 70

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
		if anim_player.current_animation == "stun":
			new_anim = "stun"
		elif anim_player.current_animation == "super":
			new_anim = "super"
		elif anim_player.current_animation == "special":
			new_anim = "special"
		else :
			if holding:
				new_anim = "attack_hold"
			else :
				new_anim = "attack"
			
	elif not on_floor:
		new_anim = "jump"
	elif linear_vel.x != 0:
		new_anim = "walk_forwards"
		if sign(sprite.scale.x) != sign(linear_vel.x):
			new_anim = "walk_backwards"
	elif holding or curr_proj != null:
		new_anim = "idle_hold"
	if anim_player.current_animation != new_anim:
		anim_player.play(new_anim)
		anim_player.seek(0, true)

func get_special_position():
	if curr_proj != null:
		return get_yoyo_pos()
	else :
		return get_position()

func process_attack():
	invincible = anim_player.current_animation == "special"
	can_zero_special = attacking
	special_pos_relevant = curr_proj != null and not attacking
	
	if anim_player.current_animation != "special" and anim_player.current_animation != "super" and check_player_just_input("special") and curr_proj != null and not holding and curr_proj.can_hold() and curr_proj.can_collide_with_char():
		curr_proj.holding = true
		curr_proj.create_hold_effect()
		holding = true
		attacking = false
		hold_speed = min_hold_speed
	if attacking:
		if anim_player.current_animation == "stun":
			if not anim_player.is_playing():
				attacking = false
			linear_vel.x *= 0.9
			if on_floor:
				linear_vel.y = 0
			else :
				linear_vel.y += gravity
		elif anim_player.current_animation == "special":
			if not anim_player.is_playing():
				attacking = false
			if on_floor:
				linear_vel.x = 0
				linear_vel.y = 0
			else :
				linear_vel.y = attack_gravity
		else :
			if not holding:
				if on_floor:
					linear_vel.x = 0
					linear_vel.y = 0
				else :
					linear_vel.y += gravity
			if not attacked:
				if not holding:
					if sprite.frame >= 1:
						attacked = true
						var p
						if anim_player.current_animation == "super":
							p = proj_super.instance()
							created_attack = false
						else :
							p = proj_attack.instance()
							created_attack = true
						if anim_player.current_animation == "super":
							p.set_position(get_position() + yoyo_pos)
						else :
							p.set_position(Vector2(get_position().x, get_position().y + 7))
						p.speed *= sprite.scale.x
						p.player_num = player_num
						p.set_player(self)
						get_parent().add_child(p)
						curr_proj = p
						hold_frames = 0
				else :
					attacked = true
					on_floor = false
			elif attacked and curr_proj != null:
				
				curr_proj.add_move = Vector2(0, 0)
				if check_player_input("left"):
					curr_proj.add_move.x -= proj_move
				if check_player_input("right"):
					curr_proj.add_move.x += proj_move
				if check_player_input("up"):
					curr_proj.add_move.y -= proj_move
				if check_player_input("down"):
					curr_proj.add_move.y += proj_move
				curr_proj.add_move = curr_proj.add_move.clamped(proj_move)
				if created_attack:
					if hold_frames >= 0 and not holding:
						if not check_player_input("attack"):
							hold_frames = - 1
						else :
							hold_frames += 1
					elif holding:
						hold_speed *= hold_speed_factor
						if hold_speed > max_hold_speed:
							hold_speed = max_hold_speed
						linear_vel += (curr_proj.get_position() - get_position()).normalized() * hold_speed
						if get_position().distance_to(curr_proj.get_position()) <= yoyo_return_dist * 2:
							holding = false
							attacking = false
							curr_proj.force_destroy()
							curr_proj = null
						elif check_player_just_input("attack"):
							holding = false
							hold_frames = - 1
							curr_proj.holding = false
							curr_proj.returning = true
							anim_player.play("attack")
							anim_player.seek(33, true)
				else :
					if curr_proj != null and (anim_player.current_animation_position >= 156 or not can_act):
						curr_proj.returning = true
	
	
	

func stun():
	if attacking and anim_player.current_animation != "stun" and anim_player.current_animation != "attack_hold":
		anim_player.play("stun")
		linear_vel.x = stun_vel * - sprite.scale.x
		audio.stop()
		play_audio_custom(audio2, snd_stun)
		return true
	return false

func stop_attacking():
	if anim_player.current_animation != "stun":
		attacking = false

func get_yoyo_pos():
	return get_position() + Vector2(yoyo_pos.x * sprite.scale.x, yoyo_pos.y)
