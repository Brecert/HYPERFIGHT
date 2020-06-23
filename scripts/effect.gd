extends Sprite

var curr_frame_delay = 0
var frame_delay_override = false

onready  var game = get_parent().get_parent()
onready  var anim_player = get_node("AnimationPlayer")

func _ready():
	anim_player.playback_speed = 0

func process(curr_frame, frame_delay):
	if curr_frame_delay <= 0 or frame_delay_override:
		anim_player.seek(anim_player.current_animation_position + 1, true)
		if not anim_player.is_playing() or (anim_player.current_animation_position >= anim_player.current_animation_length and not anim_player.get_animation(anim_player.current_animation).loop):
			_on_AnimationPlayer_animation_finished(anim_player.current_animation)
		
		curr_frame_delay = frame_delay
	else :
		curr_frame_delay -= 1

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
