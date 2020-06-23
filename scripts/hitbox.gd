extends ReferenceRect

export  var monitoring = false

var hitbox_owner
var transform_owner
var flip_with_scale = true

func _physics_process(delta):
	update()

func get_hitbox():
	var global_origin = rect_global_position - rect_position
	var hitbox = get_rect()
	var owner_scale_x = get_transform_owner().get_scale().x
	if owner_scale_x < 0:
		hitbox.position.x *= - 1
		hitbox.position.x -= hitbox.size.x
	hitbox.position += global_origin
	return hitbox

func get_all_hitboxes():
	var hitboxes = []
	if monitoring:
		hitboxes.append(get_hitbox())
	for child in get_children():
		if child.is_monitoring():
			hitboxes.append(child.get_hitbox())
	return hitboxes

func intersects(other_hitbox):
	var hitboxes = get_all_hitboxes()
	for other_box in other_hitbox.get_all_hitboxes():
		for box in hitboxes:
			if box.intersects(other_box):
				return true
	return false

func get_hitbox_owner():
	if hitbox_owner == null:
		set_hitbox_owner(get_parent())
	return hitbox_owner

func get_transform_owner():
	if transform_owner == null:
		set_transform_owner(get_parent().get_sprite())
	return transform_owner

func is_monitoring():
	return monitoring

func set_hitbox_owner(hitbox_owner):
	self.hitbox_owner = hitbox_owner
	for child in get_children():
		child.set_hitbox_owner(hitbox_owner)

func set_transform_owner(transform_owner):
	self.transform_owner = transform_owner
	for child in get_children():
		child.set_transform_owner(transform_owner)

func set_monitoring(monitoring):
	self.monitoring = monitoring

func _draw():
	if global.debug_mode and monitoring:
		var hitbox = get_rect()
		hitbox.position = Vector2.ZERO
		var owner_scale_x = get_transform_owner().get_scale().x
		if owner_scale_x < 0 and flip_with_scale:
			hitbox.position.x -= rect_position.x * 2
			hitbox.position.x -= hitbox.size.x
		draw_rect(hitbox, Color.red, false)
