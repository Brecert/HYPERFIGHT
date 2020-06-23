extends "res://scripts/character.gd"

var super_timer = 0
var min_super_timer = 80
var max_super_timer = 210
var super_frame_delay = 240
var last_music_pos = 0
var attack_down_move = 550

onready  var hitbox_attack_down = get_node("hitbox_attack_down")
onready  var hitbox_special = get_node("hitbox_special")
onready  var proj_attack = preload("res://scenes/proj_time_attack.tscn")
onready  var proj_attack_short = preload("res://scenes/proj_time_attack_short.tscn")
onready  var proj_super = preload("res://scenes/proj_goto_super.tscn")
onready  var effect_hit = preload("res://scenes/effect_time_special_hit.tscn")
onready  var effect_hit_down = preload("res://scenes/effect_time_attack_down_hit.tscn")
onready  var effect_super = preload("res://scenes/effect_time_super.tscn")
onready  var effect_super_end = preload("res://scenes/effect_time_super_end.tscn")

onready  var snd_attack = preload("res://sounds/char_time_attack.ogg")
onready  var snd_attack_down = preload("res://sounds/char_time_attack_down.ogg")
onready  var snd_special = preload("res://sounds/char_time_special.ogg")
onready  var snd_super = preload("res://sounds/char_time_super.ogg")
onready  var snd_super_boom = preload("res://sounds/char_time_super_boom.ogg")
onready  var snd_super_boom_end = preload("res://sounds/char_time_super_boom_end.ogg")
onready  var snd_hit = preload("res://sounds/char_time_hit.ogg")

func attack():
	attacked = false
	if check_player_input("down") and on_floor:
		anim_player.play("attack_down")
		play_audio(snd_attack_down)
	else :
		if is_christmas:
			anim_player.play("attack_chr")
		else :
			anim_player.play("attack")
		play_audio(snd_attack)
	linear_vel.x *= 0.25
	linear_vel.y = 0
	sprite.frame = 0

func special():
	.special()
	attacked = false
	if is_christmas:
		anim_player.play("special_chr")
	else :
		anim_player.play("special")
	linear_vel.x *= 0.5
	sprite.frame = 0
	dec_score()
	play_audio(snd_special)

func super():
	attacked = false
	anim_player.play("super")
	linear_vel.x = 0
	linear_vel.y = 0
	sprite.frame = 0
	for i in range(2):
		dec_score()
	play_audio(snd_super)

func super_condition():
	return not ignore_frame_delay and score >= 2

func kill(knockback):
	.kill(knockback)
	play_audio(snd_hit)

func can_kill(other_num):
	return .can_kill(other_num) and super_timer <= 0

func can_kill_self():
	return .can_kill_self() and super_timer <= 0

func create_dash_effect(effect_pos, scale_x, rot_deg):
	var e = effect_dash.instance()
	if super_timer > 0:
		e.curr_frame_delay = super_timer + (super_frame_delay - max_super_timer)
	e.set_position(effect_pos)
	e.scale.x = scale_x
	e.rotation_degrees = rot_deg
	get_parent().add_child(e)
	play_audio_custom(dash_player, snd_dash)

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
		if anim_player.current_animation == "super_end":
			new_anim = "super_end"
		elif anim_player.current_animation == "super":
			new_anim = "super"
		elif anim_player.current_animation == "special":
			new_anim = "special"
		elif anim_player.current_animation == "special_chr":
			new_anim = "special_chr"
		else :
			if anim_player.current_animation == "attack_down":
				new_anim = "attack_down"
			elif anim_player.current_animation == "attack_short_chr":
				new_anim = "attack_short_chr"
			elif anim_player.current_animation == "attack_short":
				new_anim = "attack_short"
			elif anim_player.current_animation == "attack_chr":
				new_anim = "attack_chr"
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

func process_attack():
	invincible = false
	if super_timer > 0:
		invincible = true
		super_timer -= 1
		if super_timer <= 0:
			game.frame_delay = 0
			game.set_inverted(false)
			curr_frame_delay = - 1
			ignore_frame_delay = false
			attacking = true
			anim_player.play("super_end")
			var e = effect_super_end.instance()
			e.frame_delay_override = true
			e.set_position(get_position())
			get_parent().add_child(e)
			play_audio(snd_super_boom_end)
			global_audio.play(last_music_pos)
	if attacking:
		if anim_player.current_animation == "super":
			if not ignore_frame_delay and (anim_player.current_animation_position >= 90 or (anim_player.current_animation_position >= 45 and not check_player_input("super") and game.state != "ko" and game.state != "ready")):
				ignore_frame_delay = true
				
				var minus_time = 210
				if anim_player.current_animation_position >= 90:
					minus_time = 0
				super_timer += min_super_timer + max_super_timer - minus_time
				game.frame_delay = min_super_timer + super_frame_delay - minus_time
				game.set_inverted(true)
				var e = effect_super.instance()
				e.frame_delay_override = true
				e.set_position(get_position())
				get_parent().add_child(e)
				play_audio(snd_super_boom)
				last_music_pos = global_audio.get_playback_position()
				global_audio.stop()
				anim_player.seek(90, true)
		elif anim_player.current_animation == "special" or anim_player.current_animation == "special_chr":
			invincible = true
			if attacked:
				if on_floor and sprite.frame <= 3:
					linear_vel.x = 0
					anim_player.seek(282)
			elif sprite.frame >= 2:
				position.y -= 256
				linear_vel.y = attack_gravity * 100
				on_floor = false
				attacked = true
			process_own_hitbox(hitbox_special, "_on_hitbox_special_collided")
		elif anim_player.current_animation == "attack_down":
			if attacked:
				linear_vel.x *= 0.85
			else :
				linear_vel.x = 0
				if sprite.frame >= 2:
					linear_vel.x = attack_down_move * sprite.scale.x
					attacked = true
			linear_vel.y = 0
			process_own_hitbox(hitbox_attack_down, "_on_hitbox_attack_down_collided")
		elif anim_player.current_animation == "attack" or anim_player.current_animation == "attack_chr":
			if on_floor:
				linear_vel.x = 0
				linear_vel.y = 0
			else :
				linear_vel.y = attack_gravity
			if not attacked:
				if not check_player_input("attack") and sprite.frame <= 3:
					
					if is_christmas:
						anim_player.play("attack_short_chr")
					else :
						anim_player.play("attack_short")
					anim_player.seek(13, true)
				elif sprite.frame >= 5:
					var p = proj_attack.instance()
					if super_timer > 0:
						p.curr_frame_delay = super_timer + (super_frame_delay - max_super_timer)
					if check_player_input("up"):
						p.vert_speed -= 60
					if check_player_input("down"):
						p.vert_speed += 60
					p.set_position(Vector2(get_position().x + 12 * sprite.scale.x, get_position().y))
					p.player_num = player_num
					p.set_player(self)
					get_parent().add_child(p)
					p.sprite.scale.x = sprite.scale.x
					p.set_rot()
					if anim_player.current_animation == "attack_chr":
						p.set_christmas()
					attacked = true
		elif anim_player.current_animation == "attack_short" or anim_player.current_animation == "attack_short_chr":
			if on_floor:
				linear_vel.x = 0
				linear_vel.y = 0
			else :
				linear_vel.y = attack_gravity
			if not attacked:
				if sprite.frame >= 5:
					var p = proj_attack_short.instance()
					if super_timer > 0:
						p.curr_frame_delay = super_timer + (super_frame_delay - max_super_timer)
					if (check_player_input("left") and sprite.scale.x > 0) or (check_player_input("right") and sprite.scale.x < 0):
						p.speed -= 60
					if (check_player_input("right") and sprite.scale.x > 0) or (check_player_input("left") and sprite.scale.x < 0):
						p.speed += 60
					p.set_position(Vector2(get_position().x + 12 * sprite.scale.x, get_position().y))
					p.player_num = player_num
					p.set_player(self)
					get_parent().add_child(p)
					p.sprite.scale.x = sprite.scale.x
					if anim_player.current_animation == "attack_short_chr":
						p.set_christmas()
					attacked = true
		else :
			linear_vel.x = 0
			linear_vel.y = 0

func process_body_collision(collision, body):
	if body.is_in_group("proj"):
		body.process_body_collision(self, false)
	elif body.is_in_group("floor") or (body.is_in_group("char") and collision.normal == Vector2(0, - 1)):
		if body.is_in_group("char") and body.can_kill(player_num) and (anim_player.current_animation == "special" or anim_player.current_animation == "special_chr"):
			stop_act()
			body.kill(Vector2(50 * sprite.scale.x, - 250))
			body.linear_vel = linear_vel / 2
			game.inc_score(player_num)
			var e = effect_hit.instance()
			e.set_position(body.get_position())
			get_parent().add_child(e)
		else :
			on_floor = true
			if body.is_in_group("floor"):
				orig_pos.y = position.y

func start_act():
	can_act = true
	dead = false
	killed = false
	no_act_frames = 0
	
	

func _ready():
	size = Vector2(12, 50)
	walk_speed = 55
	h_dash_speed = 150

func _on_AnimationPlayer_animation_finished(anim_name):
	if attacking:
		attacking = false
		if anim_name == "special" or anim_name == "special_chr":
			linear_vel.x = - jump * sprite.scale.x / 2
			linear_vel.y = - jump
			position.y -= 20
			on_floor = false
		elif anim_name == "attack_down":
			linear_vel.x = 0
			anim_player.play("idle")
		else :
			anim_player.play("idle")

func _on_hitbox_attack_down_collided(other_hitbox):
	var hitbox_owner = other_hitbox.get_hitbox_owner()
	if hitbox_owner.is_in_group("char"):
		if hitbox_owner.can_kill(player_num):
			stop_act()
			hitbox_owner.kill(Vector2(100 * sprite.scale.x, - 250))
			if game.frame_delay > 0:
				hitbox_owner.linear_vel = Vector2(100 * sprite.scale.x, - 250)
				hitbox_owner.on_floor = false
			game.inc_score(player_num)
			var e = effect_hit_down.instance()
			if super_timer > 0:
				e.curr_frame_delay = super_timer + (super_frame_delay - max_super_timer)
			e.set_position(Vector2(get_position().x + sprite.scale.x * 32, get_position().y + 28))
			e.scale.x = sprite.scale.x
			get_parent().add_child(e)
		elif hitbox_owner.can_parry(player_num):
			var e = effect_hit_down.instance()
			if super_timer > 0:
				e.curr_frame_delay = super_timer + (super_frame_delay - max_super_timer)
			e.set_position(Vector2(get_position().x + sprite.scale.x * 8, get_position().y + 28))
			e.scale.x = sprite.scale.x
			get_parent().add_child(e)
			if hitbox_owner.is_in_group("darkgoto"):
				linear_vel.x *= - 1
				sprite.scale.x *= - 1

func _on_hitbox_special_collided(other_hitbox):
	var hitbox_owner = other_hitbox.get_hitbox_owner()
	if hitbox_owner.is_in_group("char"):
		if hitbox_owner.can_kill(player_num):
			stop_act()
			hitbox_owner.kill(Vector2(50 * sprite.scale.x, 500))
			if game.frame_delay > 0:
				hitbox_owner.linear_vel = Vector2(50 * sprite.scale.x, 500)
			game.inc_score(player_num)
			var e = effect_hit.instance()
			if super_timer > 0:
				e.curr_frame_delay = super_timer + (super_frame_delay - max_super_timer)
			e.set_position(Vector2(hitbox_owner.get_position().x, hitbox_owner.get_position().y + 16))
			get_parent().add_child(e)
		elif hitbox_owner.can_parry(player_num):
			if hitbox_owner.is_in_group("darkgoto"):
				linear_vel.x *= - 1
				sprite.scale.x *= - 1
			var e = effect_hit.instance()
			if super_timer > 0:
				e.curr_frame_delay = super_timer + (super_frame_delay - max_super_timer)
			e.set_position(Vector2(hitbox_owner.get_position().x, hitbox_owner.get_position().y + 16))
			get_parent().add_child(e)
