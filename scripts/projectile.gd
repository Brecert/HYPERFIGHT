extends Node2D

var player
var player_num = 1
var left_bound = - 250
var right_bound = 250
var top_bound = - 250
var bottom_bound = 250
var curr_frame_delay = 0
var effect_hit_timer = 0
var max_effect_hit_timer = 6
var default_shadow_x_offset = 0
var default_shadow_size = 1
var linear_vel = Vector2()
var knockback = Vector2()
var effect_hit = null
var collided = false
var changed_players = false
var destroy_on_hit = true
var destroyed = false
var rotate_effect = true
var effect_on_player = false
var effect_on_proj = false
var knockback_depend_on_player_pos = false
var knockback_flip_with_scale = true
var destroy_out_of_bounds = true
var collide_with_proj = true
var collide_with_char = true
var sucked = false
var can_suck = true
var anim_disabled = false
var proj_shadow = null
var effect_offset = Vector2()
var collided_nodes = []

onready  var game = get_parent().get_parent()
onready  var sprite = get_node("Sprite")
onready  var anim_player = get_node("AnimationPlayer")
onready  var hitbox = get_node("hitbox")
onready  var shadow = preload("res://scenes/shadow.tscn")

func process_move():
	move_and_collide(linear_vel)

func move_and_collide(linear_vel):
	process_collisions()
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

func create_shadow(x_offset, shadow_size):
	if proj_shadow != null:
		proj_shadow.call_deferred("free")
	proj_shadow = shadow.instance()
	proj_shadow.init(self, x_offset, shadow_size)
	game.add_object(proj_shadow)
	default_shadow_x_offset = x_offset
	default_shadow_size = shadow_size

func _enter_tree():
	if shadow != null:
		create_shadow(default_shadow_x_offset, default_shadow_size)

func _exit_tree():
	if proj_shadow != null:
		proj_shadow.call_deferred("free")
		proj_shadow = null

func _ready():
	anim_player.playback_speed = 0
	hitbox.set_monitoring(true)
	create_shadow(default_shadow_x_offset, default_shadow_size)

func get_sprite():
	return sprite

func set_player(player):
	self.player = player

func process(curr_frame, frame_delay):
	if not is_inside_tree():
		return 
	
	if curr_frame_delay <= 0:
		process_move()
		collided_nodes.clear()
		if destroy_out_of_bounds:
			if get_position().x < left_bound:
				force_destroy()
			if get_position().x > right_bound:
				force_destroy()
			if get_position().y < top_bound:
				force_destroy()
			if get_position().y > bottom_bound:
				force_destroy()
		
		if not anim_disabled and anim_player.is_playing():
			anim_player.seek(anim_player.current_animation_position + 1, true)
		if effect_hit_timer > 0:
			effect_hit_timer -= 1
		
		curr_frame_delay = frame_delay
	else :
		curr_frame_delay -= 1

func destroy():
	create_effect_hit()
	destroy_no_effect()

func destroy_no_effect():
	if destroy_on_hit:
		collided = true
		destroyed = true
		force_destroy()

func force_destroy():
	call_deferred("free")
	if hitbox.is_in_group("hitbox"):
		hitbox.remove_from_group("hitbox")

func create_effect_hit():
	create_effect_hit_at(get_position() + Vector2(effect_offset.x * sprite.scale.x, effect_offset.y))

func create_effect_hit_at(effect_pos):
	if effect_hit != null and (effect_hit_timer <= 0 or effect_hit_timer == max_effect_hit_timer):
		var e = effect_hit.instance()
		e.set_position(effect_pos)
		if rotate_effect:
			e.rotation = rotation
		get_parent().add_child(e)
		effect_hit_timer = max_effect_hit_timer

func change_players(new_player):
	player_num = new_player.player_num
	set_player(new_player)
	changed_players = true

func reflect(hitbox_owner):
	sprite.scale.x *= - 1
	change_players(hitbox_owner)

func flip():
	sprite.scale.x *= - 1

func can_collide_with_proj():
	return collide_with_proj

func can_collide_with_char():
	return collide_with_char

func can_destroy_on_hit():
	return destroy_on_hit

func suck():
	if can_suck and not sucked:
		sucked = true
		anim_disabled = true
		return true
	elif not sucked:
		suck_action()
	return false

func suck_action():
	pass

func unsuck():
	sucked = false
	anim_disabled = false

func process_collisions():
	var hitboxes = get_tree().get_nodes_in_group("hitbox")
	var collided = false
	for other_hitbox in hitboxes:
		if hitbox != other_hitbox and hitbox.intersects(other_hitbox):
			process_hitbox_collision(other_hitbox, true)

func process_hitbox_collision(hitbox, call_other):
	var hitbox_owner = hitbox.get_hitbox_owner()
	if not collided:
		if hitbox_owner.is_in_group("char") and collide_with_char:
			if hitbox_owner.can_destroy_other(player_num) and destroy_on_hit:
				destroy()
			elif hitbox_owner.can_kill(player_num):
				player.stop_act()
				var knockback_x = knockback.x
				if knockback_flip_with_scale:
					knockback_x *= sprite.scale.x
				if knockback_depend_on_player_pos:
					knockback_x = knockback.x * sign(hitbox_owner.get_position().x - position.x)
				hitbox_owner.kill(Vector2(knockback_x, knockback.y))
				game.inc_score(player_num)
				if effect_on_player:
					create_effect_hit_at(hitbox_owner.get_position())
				else :
					create_effect_hit()
				if destroy_on_hit:
					destroyed = true
					force_destroy()
				collided = true
			elif hitbox_owner.can_parry(player_num):
				if hitbox_owner.is_in_group("darkgoto"):
					if effect_on_player:
						create_effect_hit_at(hitbox_owner.get_position())
					else :
						create_effect_hit()
					reflect(hitbox_owner)
				elif destroy_on_hit:
					destroyed = true
					destroy()
		elif hitbox_owner.is_in_group("proj") and player_num != hitbox_owner.player_num and collide_with_proj and hitbox_owner.can_collide_with_proj():
			if call_other:
				hitbox_owner.process_hitbox_collision(self.hitbox, false)
			if effect_on_proj:
				if not collided_nodes.has(hitbox_owner.get_name()):
					create_effect_hit_at(hitbox_owner.get_position())
					collided_nodes.append(hitbox_owner.get_name())
				destroy_no_effect()
			else :
				if not collided_nodes.has(hitbox_owner.get_name()):
					destroy()
					collided_nodes.append(hitbox_owner.get_name())
				else :
					destroy_no_effect()
