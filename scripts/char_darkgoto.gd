extends "res://scripts/character.gd"

var attack_down_jump = 350
var attack_down_gravity = 16
var extra_dash = true
var reflected = false

onready  var audio2 = get_node("AudioStreamPlayer2")
onready  var hitbox_attack_down = get_node("hitbox_attack_down")

onready  var proj_attack = preload("res://scenes/proj_darkgoto_attack.tscn")
onready  var proj_super = preload("res://scenes/proj_darkgoto_super.tscn")
onready  var effect_hit = preload("res://scenes/effect_proj_darkgoto_attack_hit.tscn")
onready  var effect_attack = preload("res://scenes/effect_darkgoto_attack.tscn")
onready  var effect_super = preload("res://scenes/effect_darkgoto_super.tscn")

onready  var snd_attack = preload("res://sounds/char_darkgoto_attack.ogg")
onready  var snd_attack_down = preload("res://sounds/char_darkgoto_attack_down.ogg")
onready  var snd_special = preload("res://sounds/char_darkgoto_special.ogg")
onready  var snd_special_reflect = preload("res://sounds/char_darkgoto_special_reflect.ogg")
onready  var snd_super = preload("res://sounds/char_darkgoto_super.ogg")
onready  var snd_super_flash = preload("res://sounds/super_flash.ogg")
onready  var snd_hit = preload("res://sounds/char_darkgoto_hit.ogg")
onready  var snd_parry = preload("res://sounds/parry.ogg")

onready  var snd_attack_old = preload("res://sounds/char_darkgoto_attack_old.ogg")
onready  var snd_attack_down_old = preload("res://sounds/char_darkgoto_attack_down_old.ogg")
onready  var snd_super_old = preload("res://sounds/char_darkgoto_super_old.ogg")
onready  var snd_hit_old = preload("res://sounds/char_darkgoto_hit_old.ogg")

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
	elif on_floor:
		anim_player.play("attack_upwards")
		linear_vel.x *= 0.25
		linear_vel.y = 0
		if is_april_fools:
			play_audio(snd_attack_old)
		else :
			play_audio(snd_attack)
	else :
		anim_player.play("attack_downwards")
		linear_vel.x *= 0.25
		linear_vel.y = 0
		if is_april_fools:
			play_audio(snd_attack_old)
		else :
			play_audio(snd_attack)
	sprite.frame = 0

func special():
	.special()
	reflected = false
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
	if on_floor:
		anim_player.play("super_upwards")
	else :
		anim_player.play("super_downwards")
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
	invincible = ((anim_player.current_animation == "special" or anim_player.current_animation == "special_reflect") and reflected)
	if on_floor:
		extra_dash = true
	else :
		if not can_dash and alpha == 1 and extra_dash:
			can_dash = true
			extra_dash = false
	
	if attacking:
		if anim_player.current_animation == "special" or anim_player.current_animation == "special_reflect":
			if on_floor:
				linear_vel.x = 0
				linear_vel.y = 0
			else :
				linear_vel.y += attack_gravity
		else :
			reflected = false
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
					var up = anim_player.current_animation == "attack_upwards" or anim_player.current_animation == "super_upwards"
					var y_offset = 12
					if anim_player.current_animation == "super_upwards" or anim_player.current_animation == "super_downwards":
						p = proj_super.instance()
						e = effect_super.instance()
					else :
						p = proj_attack.instance()
						e = effect_attack.instance()
					if up:
						y_offset = - y_offset
					p.set_position(Vector2(get_position().x + 18 * sprite.scale.x, get_position().y + y_offset))
					p.player_num = player_num
					p.set_player(self)
					get_parent().add_child(p)
					p.set_up(sprite.scale.x, up)
					e.set_position(Vector2(get_position().x + 18 * sprite.scale.x, get_position().y + y_offset))
					e.scale.x = sprite.scale.x
					e.rotation = p.sprite.rotation
					get_parent().add_child(e)
					attacked = true
	else :
		if anim_player.current_animation != "special":
			reflected = false

func process_anim():
	dash_while_attacking = false
	var new_anim = "idle"
	if win:
		new_anim = "win"
	elif dead:
		if on_floor:
			new_anim = "dead"
		else :
			new_anim = "fall"
	elif attacking:
		if (anim_player.current_animation == "super_upwards" or anim_player.current_animation == "super_downwards") and sprite.frame >= 1:
			dash_while_attacking = true
		if anim_player.current_animation == "super_upwards":
			new_anim = "super_upwards"
		elif anim_player.current_animation == "super_downwards":
			new_anim = "super_downwards"
		elif anim_player.current_animation == "special":
			new_anim = "special"
		elif anim_player.current_animation == "special_reflect":
			new_anim = "special_reflect"
		else :
			if anim_player.current_animation == "attack_down":
				new_anim = "attack_down"
			elif anim_player.current_animation == "attack_upwards":
				new_anim = "attack_upwards"
			else :
				new_anim = "attack_downwards"
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
	if player_num != other_num and anim_player.current_animation == "special" and not reflected:
		inc_temp_score_back()
		create_parry_flash(Vector2(20 * sprite.scale.x, 0))
		reflected = true
		invincible = true
		anim_player.play("special_reflect")
		anim_player.seek(0, true)
		play_audio_custom(audio2, snd_parry)
		if is_april_fools:
			play_audio(snd_attack_down_old)
		else :
			play_audio(snd_special_reflect)
		return true
	return false

func can_kill(other_num):
	return .can_kill(other_num) and anim_player.current_animation != "special"

func _ready():
	shadow_offset = 1
	if global.mode == global.MODE.arcade and global.arcade_stage == global.max_arcade_stage and player_num == 2:
		walk_speed = 90
		air_speed = 160
	else :
		walk_speed = 70
		air_speed = 100
	jump = 350
	gravity = 16
	special_move = 120
	h_dash_speed = 140

func _on_hitbox_attack_down_collided(other_hitbox):
	var hitbox_owner = other_hitbox.get_hitbox_owner()
	if hitbox_owner.is_in_group("char"):
		if hitbox_owner.can_kill(player_num):
			stop_act()
			hitbox_owner.kill(Vector2(80 * sprite.scale.x, - 350))
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
