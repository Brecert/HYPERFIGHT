extends "res://scripts/projectile_super.gd"

var speed = 15
var max_speed = 600
var knockback_factor = 2
var add_move = Vector2()
var returning = false

onready  var proj_special = preload("res://scenes/proj_yoyo_special.tscn")

func _ready():
	create_shadow(0, 0)
	linear_vel = Vector2(speed * 20, 0)
	destroy_on_hit = false
	knockback = Vector2(0, - 150)
	effect_hit = preload("res://scenes/effect_proj_yoyo_attack_hit.tscn")
	destroy_out_of_bounds = false
	can_suck = false

func _draw():
	draw_line(Vector2(0, 0), player.get_yoyo_pos() - get_position(), Color(1, 1, 1))

func process_move():
	update()
	
	var player_pos = player.get_yoyo_pos()
	if anim_player.current_animation == "start":
		set_position(player_pos)
	else :
		if not returning:
			if anim_player.current_animation != "attack" and not anim_player.is_playing():
				anim_player.play("attack")
			linear_vel += (player_pos - get_position()).normalized() * abs(speed) + add_move / 16
			linear_vel = linear_vel.clamped(max_speed)
			knockback.x = linear_vel.x * knockback_factor
			
		else :
			if anim_player.current_animation != "return":
				anim_player.play("return")
			linear_vel = ((player_pos - get_position()) / 64 * max_speed)
			knockback.x = linear_vel.x * knockback_factor
			
			if abs(get_position().distance_to(player_pos)) <= player.yoyo_return_dist:
				player.curr_proj = null
				force_destroy()
		
		.process_move()

func create_special():
	var p = proj_special.instance()
	p.set_position(get_position())
	p.player_num = player_num
	p.set_player(player)
	get_parent().add_child(p)
	force_destroy()

func disable_collision():
	pass
