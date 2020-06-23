extends "res://scripts/character.gd"

var attack_down_jump = 300
var attack_down_gravity = 14
var parried = false

onready  var audio2 = get_node("AudioStreamPlayer2")
onready  var hitbox_attack_down = get_node("hitbox_attack_down")

onready  var proj_attack = preload("res://scenes/proj_goto_attack.tscn")
onready  var proj_super = preload("res://scenes/proj_goto_super.tscn")
onready  var effect_hit = preload("res://scenes/effect_proj_goto_attack_hit.tscn")
onready  var effect_attack = preload("res://scenes/effect_goto_attack.tscn")
onready  var effect_super = preload("res://scenes/effect_goto_super.tscn")

onready  var snd_attack = preload("res://sounds/char_goto_attack.ogg")
onready  var snd_attack_down = preload("res://sounds/char_goto_attack_down.ogg")
onready  var snd_special = preload("res://sounds/char_goto_special.ogg")
onready  var snd_special_parry = preload("res://sounds/char_goto_special_parry.ogg")
onready  var snd_super = preload("res://sounds/char_goto_super.ogg")
onready  var snd_super_flash = preload("res://sounds/super_flash.ogg")
onready  var snd_hit = preload("res://sounds/char_goto_hit.ogg")
onready  var snd_parry = preload("res://sounds/parry.ogg")

onready  var snd_attack_old = preload("res://sounds/char_goto_attack_old.ogg")
onready  var snd_attack_down_old = preload("res://sounds/char_goto_attack_down_old.ogg")
onready  var snd_super_old = preload("res://sounds/char_goto_super_old.ogg")
onready  var snd_hit_old = preload("res://sounds/char_goto_hit_old.ogg")

func attack():
	attacked = false
	if check_player_input("down"):
		anim_player.play("attack_down")
		linear_vel.x = special_move * sprite.scale.x
		linear_vel.y = 0
		if is_april_fools:
			play_audio(snd_attack_down_old)
		else :
			play_audio(snd_attack_down)
	else :
		anim_player.play("attack")
		linear_vel.x *= 0.25
		linear_vel.y = 0
		if is_april_fools:
			play_audio(snd_attack_old)
		else :
			play_audio(snd_attack)
	sprite.frame = 0

func special():
	.special()
	parried = false
	anim_player.play("special")
	if on_floor:
		linear_vel.x = 0
		linear_vel.y = 0
	else :
		linear_vel.x *= 0.25
		linear_vel.y *= 0.25
	sprite.frame = 0
	play_audio(snd_special)
	dec_score()

func super():
	attacked = false
	anim_player.play("super")
	linear_vel.x *= 0.25
	linear_vel.y = 0
	sprite.frame = 0
	for i in range(2):
		dec_score()
	if is_april_fools:
		play_audio(snd_super_old)
	else :
		play_audio(snd_super)
	play_audio_custom(audio2, snd_super_flash)
	create_super_flash(Vector2( - 10 * sprite.scale.x, 0))

func kill(knockback):
	.kill(knockback)
	if is_april_fools:
		play_audio(snd_hit_old)
	else :
		play_audio(snd_hit)

func process_attack():
	invincible = (anim_player.current_animation == "special" and parried)
	
	if attacking:
		if anim_player.current_animation == "special":
			if on_floor:
				linear_vel.x = 0
				linear_vel.y = 0
			else :
				linear_vel.y += attack_gravity
		else :
			parried = false
			if anim_player.current_animation == "attack_down":
				if not attacked:
					if sprite.frame >= 1:
						linear_vel.y = - attack_down_jump
						on_floor = false
						attacked = true
					else :
						linear_vel.y = 0
				else :
					if on_floor:
						linear_vel.x = 0
						linear_vel.y = 0
						attacking = false
					else :
						linear_vel.y += attack_down_gravity
				
				process_own_hitbox(hitbox_attack_down, "_on_hitbox_attack_down_collided")
			else :
				if on_floor:
					linear_vel.x = 0
					linear_vel.y = 0
				else :
					linear_vel.y = attack_gravity
				if not attacked and sprite.frame >= 1:
					var p
					var e
					if anim_player.current_animation == "super":
						p = proj_super.instance()
						e = effect_super.instance()
					else :
						p = proj_attack.instance()
						e = effect_attack.instance()
					if check_player_input("up"):
						p.vert_speed -= 30
					if check_player_input("down"):
						p.vert_speed += 30
					p.set_position(Vector2(get_position().x + 16 * sprite.scale.x, get_position().y))
					p.player_num = player_num
					p.set_player(self)
					get_parent().add_child(p)
					p.sprite.scale.x = sprite.scale.x
					p.set_rot()
					e.set_position(Vector2(get_position().x + 25 * sprite.scale.x, get_position().y))
					e.scale.x = sprite.scale.x
					e.rotation = p.rotation
					get_parent().add_child(e)
					attacked = true
	else :
		if anim_player.current_animation != "special":
			parried = false

func process_anim():
	var new_anim = "idle"
	if win:
		new_anim = "win"
	elif dead:
		if on_floor:
			new_anim = "dead"
		else :
			new_anim = "fall"
	elif anim_player.current_animation == "special":
		new_anim = "special"
	elif attacking:
		if anim_player.current_animation == "super":
			new_anim = "super"
		else :
			if anim_player.current_animation == "attack_down":
				new_anim = "attack_down"
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

func can_parry(other_num):
	if player_num != other_num and anim_player.current_animation == "special" and not parried:
		inc_temp_score_back()
		create_parry_flash(Vector2(10 * sprite.scale.x, 0))
		parried = true
		attacking = false
		invincible = true
		anim_player.seek(0, true)
		play_audio_custom(audio2, snd_parry)
		if is_april_fools:
			play_audio(snd_hit_old)
		else :
			play_audio(snd_special_parry)
		return true
	return false

func can_kill(other_num):
	return .can_kill(other_num) and anim_player.current_animation != "special"

func _ready():
	if global.mode == global.MODE.arcade and global.arcade_stage == global.max_arcade_stage and player_num == 2:
		walk_speed = 90
		air_speed = 160
	shadow_offset = 1

func _on_hitbox_attack_down_collided(other_hitbox):
	var hitbox_owner = other_hitbox.get_hitbox_owner()
	if hitbox_owner.is_in_group("char"):
		if hitbox_owner.can_kill(player_num):
			stop_act()
			hitbox_owner.kill(Vector2(75 * sprite.scale.x, - 325))
			game.inc_score(player_num)
			var e = effect_hit.instance()
			e.set_position(hitbox_owner.get_position())
			get_parent().add_child(e)
		elif hitbox_owner.can_parry(player_num):
			var e = effect_hit.instance()
			e.set_position(Vector2(hitbox_owner.position.x + hitbox_owner.sprite.scale.x * 8, hitbox_owner.position.y))
			if hitbox_owner.is_in_group("darkgoto"):
				linear_vel.x *= - 1
				sprite.scale.x *= - 1
				e.set_position(Vector2(hitbox_owner.position.x + hitbox_owner.sprite.scale.x * 16, hitbox_owner.position.y))
			get_parent().add_child(e)
