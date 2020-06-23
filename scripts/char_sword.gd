extends "res://scripts/character.gd"

var teleported = false
var teleport_move = 60
var buffed = false
var buffs = 0
var buff_add = 1
var max_buffs = 1
var attack_move = 100
var attack_down_jump = 400
var attack_down_move = 12
var attack_down_move_buffed = 16

onready  var anim_player2 = get_node("AnimationPlayer2")
onready  var audio2 = get_node("AudioStreamPlayer2")
onready  var hitbox_attack = get_node("hitbox_attack")
onready  var effect_buffed = get_node("effect_buffed")
onready  var phantom = get_node("phantom")

onready  var proj_attack = preload("res://scenes/proj_goto_attack.tscn")
onready  var proj_super = preload("res://scenes/proj_goto_super.tscn")
onready  var effect_hit = preload("res://scenes/effect_sword_attack_hit.tscn")
onready  var afterimage = preload("res://scenes/afterimage.tscn")
onready  var illusion = preload("res://scenes/char_sword_illusion.tscn")
onready  var proj_special_trail = preload("res://scenes/proj_sword_special_trail.tscn")
onready  var proj_super_trail = preload("res://scenes/proj_sword_super_trail.tscn")

onready  var snd_attack = preload("res://sounds/char_sword_attack.ogg")
onready  var snd_attack_charge = preload("res://sounds/char_sword_attack_charge.ogg")
onready  var snd_attack_buffed = preload("res://sounds/char_sword_attack_buffed.ogg")
onready  var snd_attack_down = preload("res://sounds/char_sword_attack_down.ogg")
onready  var snd_attack_down_buffed = preload("res://sounds/char_sword_attack_down_buffed.ogg")
onready  var snd_special = preload("res://sounds/char_sword_special.ogg")
onready  var snd_super = preload("res://sounds/char_sword_super.ogg")
onready  var snd_super_flash = preload("res://sounds/super_flash.ogg")
onready  var snd_hit = preload("res://sounds/char_sword_hit.ogg")

func attack():
	attacked = false
	if check_player_input("down") and on_floor:
		anim_player.play("attack_down_start")
		if buffed:
			play_audio(snd_attack_down)
		else :
			play_audio(snd_attack_down)
	else :
		anim_player.play("attack_charge")
		phantom.offset.x = 0
		
	sprite.frame = 0

func special():
	.special()
	anim_player.play("special")
	linear_vel.x = 0
	linear_vel.y = 0
	sprite.frame = 0
	dec_score()
	play_audio(snd_special)

func super():
	attacked = false
	if buffed:
		anim_player.play("super_buffed")
		buffs -= 1
		if buffs <= 0:
			buffed = false
		create_super_flash(Vector2(18 * sprite.scale.x, 0))
	else :
		anim_player.play("super")
		create_super_flash(Vector2(0, - 28))
	linear_vel.x *= 0.25
	sprite.frame = 0
	for i in range(2):
		dec_score()
	play_audio(snd_super)
	play_audio_custom(audio2, snd_super_flash)

func kill(knockback):
	.kill(knockback)
	play_audio(snd_hit)

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
		if anim_player.current_animation == "super_buffed":
			new_anim = "super_buffed"
		elif anim_player.current_animation == "super":
			new_anim = "super"
		elif anim_player.current_animation == "special":
			new_anim = "special"
		else :
			if anim_player.current_animation == "attack_down_start":
				new_anim = "attack_down_start"
			elif anim_player.current_animation == "attack_down_end":
				new_anim = "attack_down_end"
			elif anim_player.current_animation == "attack_down_buffed":
				new_anim = "attack_down_buffed"
			elif anim_player.current_animation == "attack_down":
				new_anim = "attack_down"
			elif anim_player.current_animation == "attack_charge":
				new_anim = "attack_charge"
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
	invincible = anim_player.current_animation == "special"
	effect_buffed.visible = buffed and not dead
	effect_buffed.scale.x = sprite.scale.x
	anim_player2.seek(anim_player2.current_animation_position + 1, true)
	phantom.visible = false
	
	if attacking:
		if anim_player.current_animation == "special":
			if sprite.frame >= 4:
				buffs += buff_add
				if buffs > max_buffs:
					buffs = max_buffs
				buffed = true
		else :
			if on_floor:
				if not attacked:
					linear_vel.x = 0
				else :
					linear_vel.x *= 0.9
				linear_vel.y = 0
				if anim_player.current_animation == "attack_down" or anim_player.current_animation == "attack_down_buffed":
					anim_player.play("attack_down_end")
			else :
				linear_vel.x *= 0.95
				if anim_player.current_animation == "attack_down":
					if check_player_input("left"):
						linear_vel.x -= attack_down_move
					if check_player_input("right"):
						linear_vel.x += attack_down_move
					linear_vel.y += attack_gravity * 2
				elif anim_player.current_animation == "attack_down_buffed":
					if check_player_input("left"):
						linear_vel.x -= attack_down_move_buffed
					if check_player_input("right"):
						linear_vel.x += attack_down_move_buffed
					linear_vel.y += attack_gravity * 2
				elif not (anim_player.current_animation == "attack" and sprite.frame <= 2):
					linear_vel.y += attack_gravity
				else :
					linear_vel.y = 0
			if not attacked and anim_player.current_animation == "attack_charge":
				if buffed:
					phantom.visible = true
					phantom.texture = sprite.texture
					phantom.hframes = sprite.hframes
					phantom.frame = sprite.frame
					phantom.scale.x = sprite.scale.x
					phantom.offset.x += 4
				if not teleported:
					teleported = true
					var before_pos = position
					if check_player_just_input("left"):
						position.x -= teleport_move
					elif check_player_just_input("right"):
						position.x += teleport_move
					elif check_player_just_input("up"):
						position.y -= teleport_move
					elif check_player_just_input("down") and not on_floor:
						position.y += teleport_move
						if position.y > 47:
							position.y = 47
					else :
						teleported = false
					if teleported:
						create_inner_illusion(before_pos)
						create_outer_illusion(position)
				if sprite.frame >= 3 and not check_player_input("attack"):
					anim_player.play("attack")
					if buffed:
						create_inner_illusion(position)
						linear_vel.x = 0
						var length = (30 + 20 * (sprite.frame - 3)) * sprite.scale.x
						var t = proj_special_trail.instance()
						get_parent().add_child(t)
						t.set_position(Vector2(position.x, position.y + 3))
						t.player_num = player_num
						t.set_player(self)
						t.set_length(length)
						position.x += length
						buffs -= 1
						if buffs <= 0:
							buffed = false
						create_outer_illusion(position)
						linear_vel.x += 200 * sprite.scale.x
						play_audio(snd_attack_buffed)
					else :
						linear_vel.x += (100 + 100 * (sprite.frame - 3)) * sprite.scale.x
						play_audio(snd_attack)
					anim_player.seek(0, true)
					attacked = true
			elif not attacked and (anim_player.current_animation == "super" or anim_player.current_animation == "super_buffed"):
				if sprite.frame >= 4:
					var t = proj_super_trail.instance()
					get_parent().add_child(t)
					t.set_position(Vector2(position.x, position.y + 3))
					t.set_length(256 * sprite.scale.x)
					if anim_player.current_animation == "super":
						t.set_vertical(true, proj_super_trail)
					t.player_num = player_num
					t.set_player(self)
					attacked = true
			elif sprite.frame <= 1 and anim_player.current_animation == "attack":
				create_afterimage()
			
			process_own_hitbox(hitbox_attack, "_on_hitbox_attack_collided")
	else :
		teleported = false

func create_afterimage():
	var a = afterimage.instance()
	a.set_position(get_position())
	a.texture = sprite.texture
	a.hframes = sprite.hframes
	a.frame = sprite.frame
	a.scale.x = sprite.scale.x
	a.alpha = 0.5
	if player_num == 1:
		a.set_palette(global.player1_char, global.player1_palette)
	else :
		a.set_palette(global.player2_char, global.player2_palette)
	get_parent().add_child(a)

func create_inner_illusion(pos):
	for x in range(2):
		var i = illusion.instance()
		i.set_position(pos)
		i.texture = sprite.texture
		i.hframes = sprite.hframes
		i.frame = sprite.frame
		i.scale.x = sprite.scale.x
		i.alpha = 1
		i.left = bool(x)
		if player_num == 1:
			i.set_palette(global.player1_char, global.player1_palette)
		else :
			i.set_palette(global.player2_char, global.player2_palette)
		get_parent().add_child(i)

func create_outer_illusion(pos):
	for x in range(2):
		var i = illusion.instance()
		i.set_position(pos)
		i.position.x -= 25 - (x * 50)
		i.texture = sprite.texture
		i.hframes = sprite.hframes
		i.frame = sprite.frame
		i.scale.x = sprite.scale.x
		i.alpha = 1
		i.left = bool(x)
		if player_num == 1:
			i.set_palette(global.player1_char, global.player1_palette)
		else :
			i.set_palette(global.player2_char, global.player2_palette)
		get_parent().add_child(i)

func _ready():
	shadow_offset = 1
	h_dash_speed = 150
	attack_gravity = 10
	special_pos_relevant = false
	anim_player2.playback_speed = 0
	set_palette_sprite(phantom)

func _on_hitbox_attack_collided(other_hitbox):
	var hitbox_owner = other_hitbox.get_hitbox_owner()
	if hitbox_owner.is_in_group("char") and attacking:
		if hitbox_owner.can_kill(player_num):
			stop_act()
			hitbox_owner.kill(Vector2(50 * sprite.scale.x, - 250))
			game.inc_score(player_num)
			var e = effect_hit.instance()
			if anim_player.current_animation == "attack":
				e.set_position(Vector2(get_position().x + sprite.scale.x * 32, get_position().y + 3))
			else :
				e.set_position(Vector2(hitbox_owner.get_position().x, hitbox_owner.get_position().y))
			get_parent().add_child(e)
		elif hitbox_owner.can_parry(player_num):
			if hitbox_owner.is_in_group("darkgoto"):
				linear_vel.x *= - 1
				sprite.scale.x *= - 1
			var e = effect_hit.instance()
			e.set_position(Vector2(hitbox_owner.get_position().x, hitbox_owner.get_position().y))
			get_parent().add_child(e)

func _on_AnimationPlayer_animation_finished(anim_name):
	if attacking:
		if anim_name == "attack_down_start":
			if buffed:
				anim_player.play("attack_down_buffed")
				buffs -= 1
				if buffs <= 0:
					buffed = false
			else :
				anim_player.play("attack_down")
			position.y -= 4
			linear_vel.y -= attack_down_jump
			on_floor = false
			attacked = true
		elif anim_name == "attack_charge":
			anim_player.play("attack")
			linear_vel.x += attack_move * sprite.scale.x
			attacked = true
		else :
			linear_vel.x = 0
			attacking = false
	anim_player.seek(0, true)









func can_destroy_other(other_num):
	if player_num != other_num and anim_player.current_animation == "attack_down_buffed":
		return true
	return false
