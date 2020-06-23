extends "res://scripts/projectile.gd"

var curr_frame = 0

func _ready():
	destroy_on_hit = false
	knockback = Vector2(50, - 250)
	effect_hit = preload("res://scenes/effect_sword_attack_hit.tscn")
	can_suck = false
	effect_on_player = true
	effect_on_proj = true

func process_move():
	curr_frame += 0.4
	sprite.region_rect.position.x = 256 * floor(curr_frame)
	if self.curr_frame > 4:
		force_destroy()
	
	.process_move()

func set_length(length):
	sprite.region_rect.size.x = abs(length)
	hitbox.rect_size.x = abs(length)
	sprite.scale.x = sign(length)

func reflect(hitbox_owner):
	change_players(hitbox_owner)
