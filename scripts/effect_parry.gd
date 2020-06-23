extends "res://scripts/effect.gd"

func process(curr_frame, frame_delay):
	anim_player.seek(anim_player.current_animation_position + 1, true)
	if not anim_player.is_playing() or (anim_player.current_animation_position >= anim_player.current_animation_length and not anim_player.get_animation(anim_player.current_animation).loop):
		_on_AnimationPlayer_animation_finished(anim_player.current_animation)
	
	curr_frame_delay = frame_delay

func _on_AnimationPlayer_animation_finished(anim_name):
	game.set_zero_delay()
	queue_free()
