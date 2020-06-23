extends "res://scripts/hitbox.gd"

func _ready():
	flip_with_scale = false

func get_hitbox_owner():
	if hitbox_owner == null:
		set_hitbox_owner(get_parent().get_parent())
	return hitbox_owner

func get_transform_owner():
	if transform_owner == null:
		set_transform_owner(get_parent().get_parent().get_sprite())
	return transform_owner
