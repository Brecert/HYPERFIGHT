extends "res://scripts/projectile.gd"

func _ready():
	knockback = Vector2(100, - 250)
	effect_hit = preload("res://scenes/effect_proj_yoyo_special_hit.tscn")
	destroy_on_hit = false
	knockback_depend_on_player_pos = true
	effect_on_player = true
	can_suck = false

func process_move():
	linear_vel = Vector2(0, 0)
	if not anim_player.is_playing():
		force_destroy()
	
	.process_move()

func reflect(hitbox_owner):
	change_players(hitbox_owner)
