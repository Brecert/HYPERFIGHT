extends "res://scripts/character.gd"

export  var tongue_pos = Vector2()

var attack_speed = 400
var min_attack_speed = attack_speed
var attack_speed_inc = 10
var attack_knockback = Vector2(0, - 250)
var suck_proj
var suck_proj_path
var suck_vel = Vector2()
var sucked = false
var attack_down_timer = 0
var attack_down_timer_max = 60

onready  var audio2 = get_node("AudioStreamPlayer2")
onready  var hitbox_special = get_node("hitbox_special")
onready  var attack_down_recharge_player = get_node("attack_down_recharge_player")

onready  var proj_attack_down = preload("res://scenes/proj_kero_attack_down.tscn")
onready  var proj_super = preload("res://scenes/proj_kero_super.tscn")
onready  var effect_hit = preload("res://scenes/effect_kero_attack_hit.tscn")
onready  var afterimage = preload("res://scenes/afterimage.tscn")

onready  var snd_attack = preload("res://sounds/char_kero_attack.ogg")
onready  var snd_attack_down = preload("res://sounds/char_kero_attack_down.ogg")
onready  var snd_special = preload("res://sounds/char_kero_special.ogg")
onready  var snd_special_swallow = preload("res://sounds/char_kero_special_swallow.ogg")
onready  var snd_super_swallow = preload("res://sounds/char_kero_super_swallow.ogg")
onready  var snd_super = preload("res://sounds/char_kero_super.ogg")
onready  var snd_super_flash = preload("res://sounds/super_flash.ogg")
onready  var snd_hit = preload("res://sounds/char_kero_hit.ogg")

func special_condition():
	return score > 0 or sucked

func super_condition():
	return score >= 2 or (score >= 1 and sucked)

func attack():
	attacked = false
	if check_player_input("down"):
		if sucked:
			anim_player.play("special_spit")
		elif attack_down_timer <= 0:
			anim_player.play("attack_down")
		else :
			anim_player.play("attack_down_fail")
	elif not on_floor:
		if sucked:
			anim_player.play("attack_air_sucked")
		else :
			anim_player.play("attack_air")
	linear_vel.x = 0
	linear_vel.y = 0
	sprite.frame = 0

func special():
	.special()
	attacked = false
	if sucked:
		inc_temp_score()
		if suck_proj.is_in_group("super"):
			inc_temp_score()
		suck_proj.queue_free()
		suck_proj = null
		sucked = false
		anim_player.play("special_swallow")
		play_audio(snd_special_swallow)
	else :
		anim_player.play("special")
		dec_score()
		play_audio(snd_special)
	linear_vel.x = 0
	linear_vel.y = 0
	sprite.frame = 0

func super():
	attacked = false
	if sucked:
		inc_temp_score()
		inc_temp_score()
		suck_proj.queue_free()
		suck_proj = null
		sucked = false
		anim_player.play("special_swallow")
		dec_score()
		play_audio(snd_super_swallow)
	else :
		anim_player.play("super")
		for i in range(2):
			dec_score()
	linear_vel.x = 0
	linear_vel.y = 0
	sprite.frame = 0
	play_audio_custom(audio2, snd_super_flash)
	create_super_flash(Vector2(10 * sprite.scale.x, 12))

func kill(knockback):
	.kill(knockback)
	play_audio(snd_hit)

func _ready():
	size = Vector2(12, 22)
	shadow_offset = - 1
	walk_speed = 80
	jump = 400
	h_dash_speed = 250
	effect_y_offset = 16
	special_pos_relevant = false

func process_attack():
	invincible = anim_player.current_animation == "special"
	
	if attack_down_timer > 0:
		attack_down_timer -= 1
		if attack_down_timer <= 0:
			attack_down_recharge_player.play("recharge")
	
	if attacking:
		if anim_player.current_animation == "special":
			if suck_proj != null:
				if get_parent().has_node(suck_proj_path):
					suck_proj.set_position(get_position() + Vector2(tongue_pos.x * sprite.scale.x, tongue_pos.y))
				else :
					suck_proj = null
			process_own_hitbox(hitbox_special, "_on_hitbox_special_collided")
		elif anim_player.current_animation == "special_swallow" or anim_player.current_animation == "attack_down_fail":
			pass
		elif anim_player.current_animation == "special_spit":
			if not attacked and sprite.frame >= 3:
				get_parent().add_child(suck_proj)
				suck_proj.unsuck()
				suck_proj.set_position(Vector2(get_position().x + 16 * sprite.scale.x, get_position().y + 12))
				suck_proj.linear_vel = suck_vel
				if sign(suck_proj.linear_vel.x) != sprite.scale.x:
					suck_proj.linear_vel.x *= - 1
				if suck_proj.sprite.scale.x != sprite.scale.x:
					suck_proj.flip()
				suck_proj.set_player(self)
				suck_proj = null
				sucked = false
				play_audio(snd_attack_down)
				attacked = true
		elif anim_player.current_animation == "attack_down" or anim_player.current_animation == "super":
			if not attacked and sprite.frame >= 3:
				var p
				if anim_player.current_animation == "attack_down":
					p = proj_attack_down.instance()
					play_audio(snd_attack_down)
					attack_down_timer = attack_down_timer_max
				else :
					p = proj_super.instance()
					play_audio(snd_super)
				p.set_position(Vector2(get_position().x + 16 * sprite.scale.x, get_position().y + 12))
				p.player_num = player_num
				p.set_player(self)
				get_parent().add_child(p)
				p.linear_vel.x = p.speed * sprite.scale.x
				attacked = true
		else :
			if anim_player.current_animation == "attack" or anim_player.current_animation == "attack_air" or anim_player.current_animation == "attack_sucked" or anim_player.current_animation == "attack_air_sucked":
				if sprite.frame >= 4 and not attacked:
					attack_speed = min_attack_speed
					linear_vel.y = 0
					if on_floor:
						linear_vel.x = attack_speed * sprite.scale.x
						linear_vel.y = 0
					else :
						linear_vel.y = attack_speed * 0.6
						if sucked:
							anim_player.play("attack_air_sucked")
						else :
							anim_player.play("attack_air")
					play_audio(snd_attack)
					attacked = true
				elif attacked:
					attack_speed += attack_speed_inc
					if on_floor:
						linear_vel.x = attack_speed * sprite.scale.x
					else :
						linear_vel.x = (attack_speed * 0.6) * sprite.scale.x
				else :
					linear_vel.x = 0
					linear_vel.y = 0
				if (anim_player.current_animation == "attack_air" or anim_player.current_animation == "attack_air_sucked") and on_floor:
					if sucked:
						anim_player.play("attack_hit_sucked")
					else :
						anim_player.play("attack_hit")
					anim_player.seek(0, true)
					linear_vel = Vector2(linear_vel.x * - 0.1, attack_knockback.y)
					var e = effect_hit.instance()
					e.set_position(Vector2(get_position().x + sprite.scale.x * 16, get_position().y + 24))
					get_parent().add_child(e)
			elif not on_floor:
				linear_vel.y += gravity
			if curr_frame % 6 == 0:
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
			if (anim_player.current_animation == "attack_hit" or anim_player.current_animation == "attack_hit_sucked") and on_floor and sprite.frame >= 2:
				anim_player.play("idle")
				attacking = false
		
		
	
	
	

func process_anim():
	var new_anim = "idle"
	if sucked:
		new_anim = "idle_sucked"
	if win:
		if sucked:
			new_anim = "win_sucked"
		else :
			new_anim = "win"
	elif sucked:
		if dead:
			if on_floor:
				new_anim = "dead_sucked"
			else :
				new_anim = "fall_sucked"
		elif attacking:
			if anim_player.current_animation == "special_spit":
				new_anim = "special_spit"
			elif anim_player.current_animation == "attack_air_sucked":
				new_anim = "attack_air_sucked"
			elif anim_player.current_animation == "attack_hit_sucked":
				new_anim = "attack_hit_sucked"
			else :
				new_anim = "attack_sucked"
		else :
			if not on_floor:
				new_anim = "jump_sucked"
			elif linear_vel.x != 0:
				new_anim = "walk_forwards_sucked"
				if sign(sprite.scale.x) != sign(linear_vel.x):
					new_anim = "walk_backwards_sucked"
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
		elif anim_player.current_animation == "special_spit":
			new_anim = "special_spit"
		elif anim_player.current_animation == "special_swallow":
			new_anim = "special_swallow"
		elif anim_player.current_animation == "attack_down":
			new_anim = "attack_down"
		elif anim_player.current_animation == "attack_down_fail":
			new_anim = "attack_down_fail"
		elif anim_player.current_animation == "attack_air":
			new_anim = "attack_air"
		elif anim_player.current_animation == "attack_hit":
			new_anim = "attack_hit"
		else :
			new_anim = "attack"
	else :
		if not on_floor:
			new_anim = "jump"
		elif linear_vel.x != 0:
			new_anim = "walk_forwards"
			if sign(sprite.scale.x) != sign(linear_vel.x):
				new_anim = "walk_backwards"
	if anim_player.current_animation != new_anim:
		anim_player.play(new_anim)
		anim_player.seek(0, true)

func process_edge_hit():
	if attacking and (anim_player.current_animation == "attack" or anim_player.current_animation == "attack_air" or anim_player.current_animation == "attack_sucked" or anim_player.current_animation == "attack_air_sucked") and (on_floor or linear_vel.y == 0):
		on_floor = false
		if sucked:
			anim_player.play("attack_hit_sucked")
		else :
			anim_player.play("attack_hit")
		anim_player.seek(0, true)
		linear_vel = Vector2(linear_vel.x * - 0.1, attack_knockback.y)
		var e = effect_hit.instance()
		e.set_position(Vector2(get_position().x + sprite.scale.x * 4, get_position().y + 16))
		get_parent().add_child(e)

func process_hitbox_collision(hitbox):
	var hitbox_owner = hitbox.get_hitbox_owner()
	if hitbox_owner.is_in_group("proj") and not invincible:
		if hitbox_owner.is_in_group("proj_kero") and player_num == hitbox_owner.player_num:
			if hitbox_owner.can_collide_with_own_player():
				if linear_vel == Vector2(0, 0):
					hitbox_owner.linear_vel *= - 1
				else :
					if attacking and attacked:
						hitbox_owner.linear_vel = linear_vel.normalized() * 600
					else :
						hitbox_owner.linear_vel = linear_vel.normalized() * 300
					linear_vel *= - 1
				hitbox_owner.player_collided = true
				hitbox_owner.set_uncollidable()
				var e = effect_hit.instance()
				e.set_position(Vector2(get_position().x + sprite.scale.x * 16, get_position().y + 16).linear_interpolate(hitbox_owner.get_position(), 0.5))
				get_parent().add_child(e)
				if attacking and attacked:
					if sucked:
						anim_player.play("attack_hit_sucked")
					else :
						anim_player.play("attack_hit")
					anim_player.seek(0, true)
					on_floor = false
					if linear_vel.y == 0:
						linear_vel.y = attack_knockback.y
		else :
			hitbox_owner.process_hitbox_collision(hurtbox, false)
	
	
	
	
	
	
	elif hitbox_owner.is_in_group("char") and attacking and (anim_player.current_animation == "attack" or anim_player.current_animation == "attack_air" or anim_player.current_animation == "attack_sucked" or anim_player.current_animation == "attack_air_sucked") and sprite.frame >= 4:
		var reflected = false
		if hitbox_owner.can_kill(player_num):
			
						
			
			stop_act()
			hitbox_owner.kill(Vector2(50 * sprite.scale.x, - 250))
			game.inc_score(player_num)
			var e = effect_hit.instance()
			e.set_position(Vector2(get_position().x + sprite.scale.x * 16, get_position().y + 24).linear_interpolate(hitbox_owner.get_position(), 0.1))
			get_parent().add_child(e)
			if hitbox_owner.is_in_group("kero") and hitbox_owner.can_act:
				hitbox_owner.process_hitbox_collision(hurtbox)
		elif hitbox_owner.can_parry(player_num):
			if hitbox_owner.is_in_group("darkgoto"):
				linear_vel.x *= - 1
				sprite.scale.x *= - 1
				reflected = true
			var e = effect_hit.instance()
			e.set_position(Vector2(get_position().x + sprite.scale.x * 16, get_position().y + 24).linear_interpolate(hitbox_owner.get_position(), 0.1))
			get_parent().add_child(e)
		if not reflected and hitbox_owner.alpha == 1:
			if sucked:
				anim_player.play("attack_hit_sucked")
			else :
				anim_player.play("attack_hit")
			anim_player.seek(0, true)
			on_floor = false
			linear_vel = Vector2(linear_vel.x * - 0.1, attack_knockback.y)

func _on_hitbox_special_collided(other_hitbox):
	var hitbox_owner = other_hitbox.get_hitbox_owner()
	if hitbox_owner.is_in_group("proj") and suck_proj == null and hitbox_owner.suck():
		suck_proj = hitbox_owner
		suck_proj_path = get_parent().get_path_to(suck_proj)
		suck_proj.reflect(self)
		suck_vel = suck_proj.linear_vel
		suck_proj.linear_vel = Vector2.ZERO

func _on_AnimationPlayer_animation_finished(anim_name):
	if attacking:
		attacking = false
		if anim_name == "special" and suck_proj != null:
			sucked = true
			get_parent().remove_child(suck_proj)
		anim_player.play("idle")
