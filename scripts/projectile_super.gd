extends "res://scripts/projectile.gd"

func process_hitbox_collision(hitbox, call_other):
	var hitbox_owner = hitbox.get_hitbox_owner()
	if not collided:
		if hitbox_owner.is_in_group("char"):
			if hitbox_owner.can_kill(player_num) or hitbox_owner.can_parry(player_num):
				player.stop_act()
				var knockback_x = knockback.x
				if knockback_flip_with_scale:
					knockback_x *= sprite.scale.x
				if knockback_depend_on_player_pos:
					knockback_x = knockback.x * sign(hitbox_owner.get_position().x - position.x)
				hitbox_owner.kill(Vector2(knockback_x, knockback.y))
				game.win(player_num)
				if effect_on_player:
					create_effect_hit_at(hitbox_owner.get_position())
				else :
					create_effect_hit()
				if destroy_on_hit:
					collided = true
					destroyed = true
					force_destroy()
		elif hitbox_owner.is_in_group("proj"):
			if call_other:
				hitbox_owner.process_hitbox_collision(self.hitbox, false)
			if (hitbox_owner.can_destroy_on_hit() or call_other) and not collided_nodes.has(hitbox_owner.get_name()):
				if effect_on_proj:
					create_effect_hit_at(hitbox_owner.get_position())
				else :
					create_effect_hit()
				collided_nodes.append(hitbox_owner.get_name())
			if destroy_on_hit and hitbox_owner.is_in_group("super"):
				collided = true
				destroyed = true
				force_destroy()
