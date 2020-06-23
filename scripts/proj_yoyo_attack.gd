extends "res://scripts/projectile.gd"

var speed = 600
var min_speed = speed
var knockback_factor = 0.75
var add_move = Vector2()
var returning = false
var holding = false
var can_collide = true
var exceptions = []
var left_hold_bound = - 125
var right_hold_bound = 125
var up_hold_bound = - 75
var down_hold_bound = 75
var last_player_pos = Vector2()

onready  var effect_hold = preload("res://scenes/effect_proj_yoyo_attack_hold.tscn")
onready  var proj_special = preload("res://scenes/proj_yoyo_special.tscn")

func _ready():
	knockback = Vector2(0, - 150)
	effect_hit = preload("res://scenes/effect_proj_yoyo_attack_hit.tscn")
	destroy_on_hit = false
	destroy_out_of_bounds = false
	can_suck = false

func _draw():
	draw_line(Vector2(0, 0), player.get_yoyo_pos() - get_position(), Color(1, 1, 1))

func create_hold_effect():
	var e = effect_hold.instance()
	e.set_position(get_position())
	get_parent().add_child(e)

func process_move():
	update()
	
	var collision = null
	var player_pos = player.get_yoyo_pos()
	if holding:
		can_collide = true
		linear_vel = Vector2(0, 0)
		if player.holding and player.attacking:
			if anim_player.current_animation != "drag":
				anim_player.play("drag")
		else :
			if anim_player.current_animation != "hold":
				anim_player.play("hold")
		if collided:
			holding = false
			player.holding = false
			player.hold_frames = - 1
			player.attacking = true
			player.attacked = true
	else :
		if anim_player.current_animation != "attack" and can_collide:
			anim_player.play("attack")
		
		
		
		
		if not returning:
			speed *= 0.775
			if abs(speed) < 6 or player.dead:
				speed = abs(speed)
				returning = true
			linear_vel = Vector2(speed, 0) + add_move
			knockback.x = linear_vel.x * knockback_factor
		else :
			speed = abs(speed)
			if speed < min_speed:
				speed *= 1.3
			else :
				speed = min_speed
			
			linear_vel = ((player_pos - get_position()) / 10 * speed) + add_move
			knockback.x = linear_vel.x * knockback_factor
			if abs(get_position().distance_to(player_pos)) <= player.yoyo_return_dist and not destroyed:
				player.stop_attacking()
				player.curr_proj = null
				destroyed = true
				force_destroy()
		
		
		
		
			
	last_player_pos = player.get_position()
	
	collide_with_char = not holding and can_collide
	
	.process_move()

func disable_collision():
	can_collide = false
	if anim_player.current_animation != "hold":
		anim_player.play("hold")

func can_hold():
	return position.x >= left_hold_bound and position.x <= right_hold_bound and position.y >= up_hold_bound and position.y <= down_hold_bound

func create_special():
	var p = proj_special.instance()
	p.set_position(get_position())
	p.player_num = player_num
	p.set_player(player)
	get_parent().add_child(p)
	destroy()

func destroy():
	force_destroy()

func reflect(body):
	returning = not returning
	if not returning:
		speed *= player.sprite.scale.x
	player.anim_player.seek(6, true)

func suck_action():
	disable_collision()
	if player.stun():
		create_effect_hit()

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
				create_effect_hit_at(hitbox_owner.get_position())
				if destroy_on_hit:
					destroyed = true
					force_destroy()
				collided = true
			elif hitbox_owner.can_parry(player_num):
				if hitbox_owner.is_in_group("darkgoto"):
					reflect(hitbox_owner)
				disable_collision()
				if player.stun():
					create_effect_hit_at(hitbox_owner.get_position())
		elif hitbox_owner.is_in_group("proj") and player_num != hitbox_owner.player_num and collide_with_proj and hitbox_owner.can_collide_with_proj():
			if call_other:
				hitbox_owner.process_hitbox_collision(self.hitbox, false)
			disable_collision()
			if player.stun():
				create_effect_hit()
