extends Node2D

var curr_frame = 0
var frame_delay = 0
var input_delay = global.input_delay
var prev_delay = input_delay
var target_delay = input_delay
var change_delay_timer = 0
var max_change_delay_timer = 10
var delay_buffer = 5
var player1_frame = 0
var player2_frame = 0
var last_other_frame = 0
var last_other_delay = 0
var last_ping_time = OS.get_ticks_msec()
var double_frame_time = 2 * (1 / 60.0) * 1000

var transition_alpha = 1
var change_alpha = 0.06
var win_player_num = - 1
var state = "fight"
var unpaused_state = "fight"
var max_win_timer = 90
var max_round_win_timer = 60
var win_timer = max_win_timer
var delay_timer = - 1
var max_delay_timer = 30
var player_xoffset = 70
var player_yoffset = 35
var player1
var player2
var player1_scored = false
var player2_scored = false
var my_player
var press_timer = - 1
var max_press_timer = 60
var tutorial_timer = - 1
var max_tutorial_timer = 180
var tutorial_index = 0
var option = 1
var other_option = - 1
var max_option = 4
var game_over = false
var paused = false
var paused_music = false
var pause_music_pos

onready  var label_player1 = get_node("GUILayer/label_player1")
onready  var label_player1_wins = get_node("GUILayer/label_player1/label_wins")
onready  var label_player2 = get_node("GUILayer/label_player2")
onready  var label_player2_wins = get_node("GUILayer/label_player2/label_wins")
onready  var label_delay = get_node("GUILayer/label_delay")
onready  var label_paused = get_node("GUILayer/label_paused_node/label_paused")
onready  var label_center = get_node("GUILayer/label_center_node/label_center")
onready  var label_timer = get_node("GUILayer/label_timer_node/label_time")
onready  var transition = get_node("GUILayer/transition")
onready  var menu_banner = get_node("GUILayer/menu_banner")
onready  var buttons_menu = get_node("GUILayer/buttons_menu")
onready  var buttons_menu_online = get_node("GUILayer/buttons_menu_online")
onready  var buttons_rematch = get_node("GUILayer/buttons_rematch")
onready  var buttons_continue = get_node("GUILayer/buttons_continue")
onready  var buttons_continue_label = get_node("GUILayer/buttons_continue/button_continue/label_continues")
onready  var buttons_restart = get_node("GUILayer/buttons_restart")
onready  var buttons_restart_label = get_node("GUILayer/buttons_restart/button_restart/label_continues")
onready  var buttons_pause = get_node("GUILayer/buttons_pause")
onready  var buttons_pause_arcade = get_node("GUILayer/buttons_pause_arcade")
onready  var buttons_pause_tutorial = get_node("GUILayer/buttons_pause_tutorial")
onready  var textbox = get_node("GUILayer/textbox")
onready  var move_lists = get_node("GUILayer/move_lists")
onready  var move_list_p1 = get_node("GUILayer/move_lists/move_list_p1")
onready  var player1_shadow = get_node("objects/player1_shadow")
onready  var player2_shadow = get_node("objects/player2_shadow")
onready  var audio = get_node("AudioStreamPlayer")
onready  var objects = get_node("objects")
onready  var bg_game = get_node("bg_game")
onready  var online_timer = get_node("online_timer")

onready  var char_goto = preload("res://scenes/char_goto.tscn")
onready  var char_yoyo = preload("res://scenes/char_yoyo.tscn")
onready  var char_kero = preload("res://scenes/char_kero.tscn")
onready  var char_time = preload("res://scenes/char_time.tscn")
onready  var char_sword = preload("res://scenes/char_sword.tscn")
onready  var char_darkgoto = preload("res://scenes/char_darkgoto.tscn")

onready  var snd_select = preload("res://sounds/select.ogg")
onready  var snd_select2 = preload("res://sounds/select2.ogg")
onready  var snd_ready = preload("res://sounds/ready.ogg")
onready  var snd_fight = preload("res://sounds/fight.ogg")
onready  var snd_fight2 = preload("res://sounds/fight2.ogg")
onready  var snd_fight3 = preload("res://sounds/fight3.ogg")
onready  var snd_player1win = preload("res://sounds/player1win.ogg")
onready  var snd_player2win = preload("res://sounds/player2win.ogg")
onready  var snd_ko = preload("res://sounds/ko.ogg")
onready  var snd_superko = preload("res://sounds/superko.ogg")
onready  var snd_perfect = preload("res://sounds/perfect.ogg")
onready  var snd_stronghit = preload("res://sounds/stronghit.ogg")
onready  var msc_theme_goto = preload("res://sounds/theme_goto.ogg")
onready  var msc_theme_yoyo = preload("res://sounds/theme_yoyo.ogg")
onready  var msc_theme_kero = preload("res://sounds/theme_kero.ogg")
onready  var msc_theme_time = preload("res://sounds/theme_time.ogg")
onready  var msc_theme_sword = preload("res://sounds/theme_sword.ogg")
onready  var msc_theme_darkgoto = preload("res://sounds/theme_darkgoto.ogg")

func _ready():
	
	
	
	
	
	
	play_stage_music()
	label_center.text = "Ready..."
	label_delay.visible = global.online and global.lobby_state != global.LOBBY_STATE.spectate
	init_players()
	play_audio(snd_ready)

	if global.online:
		if global.mode == global.MODE.online_quickmatch:
			max_option = 2
		label_player1.text = Steam.getFriendPersonaName(global.lobby_member_ids[0])
		label_player2.text = Steam.getFriendPersonaName(global.lobby_member_ids[1])
		if not global.lobby_state == global.LOBBY_STATE.spectate:
			if global.lobby_state == global.LOBBY_STATE.player2:
				my_player = player2
				player1.set_online_control(false)
				player2.set_online_control(true)
			else :
				my_player = player1
				player1.set_online_control(true)
				player2.set_online_control(false)
				if global.prev_input_delay <= 0:
					send_packet_ping()
		player1.dtdash = bool(int(global.get_lobby_member_data(global.lobby_member_ids[0], global.MEMBER_LOBBY_DTDASH)))
		player2.dtdash = bool(int(global.get_lobby_member_data(global.lobby_member_ids[1], global.MEMBER_LOBBY_DTDASH)))
	else :
		if global.mode == global.MODE.arcade:
			buttons_pause = buttons_pause_arcade
			max_option = 3
		elif global.mode == global.MODE.tutorial:
			buttons_pause = buttons_pause_tutorial
			max_option = 2
			tutorial_timer = max_tutorial_timer
			player1.stop_act()
			player2.cpu_type = global.CPU_TYPE.dummy
	
	global.clear_input_files()
	
	if global.online:
		if global.prev_input_delay <= 0:
			input_delay = 1
			global.prev_input_delay = 1
		else :
			input_delay = global.prev_input_delay
		set_wins_labels()

func set_wins_labels():
	if global.lobby_player1_wins > 0:
		label_player1_wins.visible = true
		label_player1_wins.text = str(global.lobby_player1_wins) + " win"
		if global.lobby_player1_wins > 1:
			label_player1_wins.text += "s"
	if global.lobby_player2_wins > 0:
		label_player2_wins.visible = true
		label_player2_wins.text = str(global.lobby_player2_wins) + " win"
		if global.lobby_player2_wins > 1:
			label_player2_wins.text += "s"

func init_players():
	label_player1.text = global.get_char_real_name(global.player1_char)
	if global.player1_cpu:
		label_player1.add_color_override("font_color", Color(0.5, 0.5, 0.5))
	label_player2.text = global.get_char_real_name(global.player2_char)
	if global.player2_cpu:
		label_player2.add_color_override("font_color", Color(0.8, 0.8, 0.8))
		move_list_p1.position.y += 36
	player1 = get_char_instance(global.player1_char)
	player1.player_num = 1
	player1.set_position(Vector2( - player_xoffset, player_yoffset))
	player2 = get_char_instance(global.player2_char)
	player2.player_num = 2
	player2.set_position(Vector2(player_xoffset, player_yoffset))
	player1.check_events()
	player2.check_events()
	add_object(player1)
	add_object(player2)
	player1.reset()
	player1.set_other_player(player2)
	player1.cpu = global.player1_cpu
	if not player1.cpu:
		player1.dtdash = global.player1_dtdash
	player2.reset()
	player2.set_other_player(player1)
	player2.cpu = global.player2_cpu
	if not player2.cpu:
		player2.dtdash = global.player2_dtdash
	player1_shadow.init(player1, player1.shadow_offset, 0)
	player2_shadow.init(player2, player2.shadow_offset, 0)
	transition.visible = true

func play_stage_music():
	if not global_audio.playing:
		match global.stage:
			global.STAGE.dojo:
				global_audio.stream = msc_theme_goto
			global.STAGE.rooftop:
				global_audio.stream = msc_theme_yoyo
			global.STAGE.lab:
				global_audio.stream = msc_theme_kero
			global.STAGE.company:
				global_audio.stream = msc_theme_time
			global.STAGE.bridge:
				global_audio.stream = msc_theme_sword
			global.STAGE.blackhole:
				global_audio.stream = msc_theme_darkgoto
			global.STAGE.training:
				global_audio.stream = msc_theme_goto
		global_audio.play(0)

func add_object(new_object):
	objects.add_child(new_object)

func set_inverted(inverted):
	bg_game.set_inverted(inverted)

func super_flash():
	bg_game.set_modulate(Color(0.4, 0.4, 1))
	frame_delay = 15

func parry_flash():
	bg_game.set_modulate(Color(0.75, 0.75, 1))
	frame_delay = 5

func set_zero_delay():
	bg_game.set_modulate(Color(1, 1, 1))
	if frame_delay > 2:
		frame_delay = 0

func get_char_instance(char_name):
	match char_name:
		global.CHAR.goto:
			return char_goto.instance()
		global.CHAR.yoyo:
			return char_yoyo.instance()
		global.CHAR.kero:
			return char_kero.instance()
		global.CHAR.time:
			return char_time.instance()
		global.CHAR.sword:
			return char_sword.instance()
		global.CHAR.darkgoto:
			return char_darkgoto.instance()
	return char_goto.instance()

func inc_score(player_num):
	if state != "super":
		if win_player_num < 0:
			win_player_num = player_num
		elif win_player_num != player_num:
			win_player_num = 0
		max_win_timer = max_round_win_timer
		win_timer = max_win_timer
		frame_delay = 2
		delay_timer = max_delay_timer
		state = "ko"
		play_audio(snd_stronghit)
		if global.print_round_end_frame:
			print(curr_frame)
	
func win(player_num):
	if win_player_num < 0 or state == "ko":
		win_player_num = player_num
	elif win_player_num != player_num:
		win_player_num = 0
	max_win_timer = max_round_win_timer
	win_timer = max_win_timer
	frame_delay = 2
	delay_timer = max_delay_timer
	state = "super"
	play_audio(snd_stronghit)
	if global.print_round_end_frame:
		print(curr_frame)

func _physics_process(delta):
	if global.steam_enabled:
		Steam.run_callbacks()
		
		if global.online and state != "menu_select_online":
			var packet_size = Steam.getAvailableP2PPacketSize(0)
			while packet_size > 0:
				var packet_dict = Steam.readP2PPacket(packet_size, 0)
				var packet = packet_dict["data"]
				var sender_id = packet_dict["steamIDRemote"]
				var packet_type = packet[0]
				match packet_type:
					global.P_TYPE.lobby_init:
						if not global.lobby_join:
							global.spectator_member_ids.erase(sender_id)
					global.P_TYPE.game_input:
						var copy_frame = int(packet.subarray(11, - 1).get_string_from_ascii())
						var copy_delay = packet[10]
						var copy_map = {"left":bool(packet[2]), "right":bool(packet[3]), "up":bool(packet[4]), "down":bool(packet[5]), "attack":bool(packet[6]), "special":bool(packet[7]), "super":bool(packet[8]), "dash":bool(packet[9])}
						player1.add_online_input(packet[1], copy_map, copy_frame, copy_delay, false)
						player2.add_online_input(packet[1], copy_map, copy_frame, copy_delay, false)
					global.P_TYPE.game_menu:
						var player1 = (packet[1] == 1)
						var info_text
						if player1 and global.lobby_member_ids.size() > 0:
							info_text = Steam.getFriendPersonaName(global.lobby_member_ids[0]) + " selected "
						elif player2 and global.lobby_member_ids.size() > 1:
							info_text = Steam.getFriendPersonaName(global.lobby_member_ids[1]) + " selected "
						if global.lobby_state == global.LOBBY_STATE.spectate and player1:
							option = packet[2]
						else :
							other_option = packet[2]
						if global.mode == global.MODE.online_lobby:
							if state == "other_player_wait":
								state = "menu_select_online"
								press_timer = max_press_timer
								if option > 1 or other_option > 1:
									global_audio.stop()
							elif global.lobby_state == global.LOBBY_STATE.spectate:
								state = "other_player_wait"
							match packet[2]:
								1:
									info_text += "Rematch"
								2:
									info_text += "Stage Select"
								3:
									info_text += "Char. Select"
								4:
									info_text += "Back to Lobby"
						else :
							if state == "other_player_wait":
								state = "rematch_select"
								if option > 1 or other_option > 1:
									global_audio.stop()
							match other_option:
								1:
									info_text += "Rematch"
								2:
									info_text += "Main Menu"
						global.create_info_text(info_text)
						play_audio(snd_select2)
					global.P_TYPE.game_ping:
						var ping_time = OS.get_ticks_msec() - last_ping_time
						last_ping_time = OS.get_ticks_msec()
						target_delay = ceil((ping_time + delay_buffer) / double_frame_time)
						send_packet_ping()
					global.P_TYPE.lobby_return:
						if global.lobby_join:
							get_tree().change_scene("res://scenes/online_lobby.tscn")
							break
				packet_size = Steam.getAvailableP2PPacketSize(0)
				
				if not global.lobby_join and packet_type != global.P_TYPE.lobby_init and packet_type != global.P_TYPE.game_ping:
					global.relay_packet(packet)
	
	transition.set_modulate(Color(1, 1, 1, transition_alpha))
	label_timer.text = str(int(online_timer.time_left))
	
	if frame_delay <= 0:
		bg_game.set_modulate(Color(1, 1, 1))
	if paused and move_lists.position.x > 1:
		move_lists.position.x += (0 - move_lists.position.x) / 4
	elif not paused and move_lists.position.x < 199:
		move_lists.position.x += (200 - move_lists.position.x) / 4
	if paused and state != "pause_select":
		if transition_alpha < 0.75:
			transition_alpha += change_alpha
		
		if Input.is_action_just_pressed("player1_up") or (Input.is_action_just_pressed("player2_up") and not global.player2_cpu):
			option -= 1
		if Input.is_action_just_pressed("player1_down") or (Input.is_action_just_pressed("player2_down") and not global.player2_cpu):
			option += 1
		if option < 1:
			option = max_option
		elif option > max_option:
			option = 1
			
		for button in buttons_pause.get_children():
			button.active = true
			button.highlight(option)
		if Input.is_action_just_pressed("player1_attack") or (Input.is_action_just_pressed("player2_attack") and not global.player2_cpu):
			for button in buttons_pause.get_children():
				button.select(option)
			press_timer = max_press_timer
			play_audio(snd_select2)
			state = "pause_select"
	elif state == "menu":
		get_tree().set_network_peer(null)
		if transition_alpha < 0.75:
			transition_alpha += change_alpha
		
		if not global.online or global.lobby_state != global.LOBBY_STATE.spectate:
			if Input.is_action_just_pressed("player1_up") or (Input.is_action_just_pressed("player2_up") and not global.player2_cpu):
				option -= 1
			if Input.is_action_just_pressed("player1_down") or (Input.is_action_just_pressed("player2_down") and not global.player2_cpu):
				option += 1
			if option < 1:
				option = max_option
			elif option > max_option:
				option = 1
			
		var curr_buttons = buttons_menu
		if global.mode == global.MODE.online_lobby:
			curr_buttons = buttons_menu_online
		for button in curr_buttons.get_children():
			button.active = true
			button.highlight(option)
		
		if not global.online or global.lobby_state != global.LOBBY_STATE.spectate:
			if Input.is_action_just_pressed("player1_attack") or (Input.is_action_just_pressed("player2_attack") and not global.player2_cpu) or global.auto_rematch:
				for button in curr_buttons.get_children():
					button.select(option)
				press_timer = max_press_timer
				play_audio(snd_select2)
				if global.mode == global.MODE.online_lobby:
					broadcast_packet_menu()
					if other_option > 0:
						state = "menu_select_online"
						if option > 1 or other_option > 1:
							global_audio.stop()
					else :
						state = "other_player_wait"
				else :
					state = "menu_select"
					if option != 1:
						global_audio.stop()
	elif state == "rematch":
		get_tree().set_network_peer(null)
		if transition_alpha < 0.75:
			transition_alpha += change_alpha
		
		if Input.is_action_just_pressed("player1_up") or (Input.is_action_just_pressed("player2_up") and not global.player2_cpu):
			option -= 1
		if Input.is_action_just_pressed("player1_down") or (Input.is_action_just_pressed("player2_down") and not global.player2_cpu):
			option += 1
		if option < 1:
			option = max_option
		elif option > max_option:
			option = 1
			
		for button in buttons_rematch.get_children():
			button.active = true
			button.highlight(option)
		if Input.is_action_just_pressed("player1_attack") or (Input.is_action_just_pressed("player2_attack") and not global.player2_cpu):
			for button in buttons_rematch.get_children():
				button.select(option)
			press_timer = max_press_timer
			play_audio(snd_select2)
			broadcast_packet_menu()
			if option == 2 or other_option > 0:
				state = "rematch_select"
				if option > 1 or other_option > 1:
					global_audio.stop()
			else :
				state = "other_player_wait"
	elif state == "continue":
		get_tree().set_network_peer(null)
		if transition_alpha < 0.75:
			transition_alpha += change_alpha
		
		if Input.is_action_just_pressed("player1_up"):
			option -= 1
		if Input.is_action_just_pressed("player1_down"):
			option += 1
		if option < 1:
			option = max_option
		elif option > max_option:
			option = 1
		
		buttons_continue_label.text = "Continues: " + str(global.arcade_continues)
		for button in buttons_continue.get_children():
			button.active = true
			button.highlight(option)
		if Input.is_action_just_pressed("player1_attack"):
			for button in buttons_continue.get_children():
				button.select(option)
			press_timer = max_press_timer
			play_audio(snd_select2)
			state = "continue_select"
			if option != 1:
				global_audio.stop()
			else :
				global.arcade_continues -= 1
				buttons_continue_label.text = "Continues: " + str(global.arcade_continues)
	elif state == "restart":
		get_tree().set_network_peer(null)
		if transition_alpha < 0.75:
			transition_alpha += change_alpha
		
		if Input.is_action_just_pressed("player1_up"):
			option -= 1
		if Input.is_action_just_pressed("player1_down"):
			option += 1
		if option < 1:
			option = max_option
		elif option > max_option:
			option = 1
		
		buttons_restart_label.text = "Continues: " + str(global.arcade_continues)
		for button in buttons_restart.get_children():
			button.active = true
			button.highlight(option)
		if Input.is_action_just_pressed("player1_attack"):
			for button in buttons_restart.get_children():
				button.select(option)
			press_timer = max_press_timer
			play_audio(snd_select2)
			state = "restart_select"
			if option != 1:
				global_audio.stop()
	elif state == "menu_select":
		if press_timer > 0:
			press_timer -= 1
			if transition_alpha < 0.75:
				transition_alpha = 0.75
			if press_timer < max_press_timer / 2 and transition_alpha < 1.5:
				buttons_menu.visible = false
				move_lists.visible = false
				menu_banner.deactivate()
				transition_alpha += change_alpha / 4
		else :
			match option:
				1:
					get_tree().change_scene("res://scenes/game.tscn")
				2:
					get_tree().change_scene("res://scenes/stageselect.tscn")
				3:
					get_tree().change_scene("res://scenes/charselect.tscn")
				4:
					get_tree().change_scene("res://scenes/menu.tscn")
			queue_free()
	elif state == "menu_select_online":
		label_timer.visible = false
		if press_timer > 0:
			press_timer -= 1
			if transition_alpha < 0.75:
				transition_alpha = 0.75
			if press_timer < max_press_timer / 2 and transition_alpha < 1.5:
				buttons_menu_online.visible = false
				move_lists.visible = false
				menu_banner.deactivate()
				transition_alpha += change_alpha / 4
		else :
			var m_option = max(option, other_option)
			match m_option:
				1:
					global.prev_input_delay = input_delay
					get_tree().change_scene("res://scenes/game.tscn")
				2:
					get_tree().change_scene("res://scenes/stageselect.tscn")
				3:
					get_tree().change_scene("res://scenes/charselect.tscn")
				4:
					if global.lobby_state != global.LOBBY_STATE.spectate:
						var consec_matches = global.get_lobby_member_data(global.steam_id, global.MEMBER_LOBBY_CONSEC_MATCHES)
						global.set_lobby_member_data(global.MEMBER_LOBBY_CONSEC_MATCHES, str(int(consec_matches) + 1))
					get_tree().change_scene("res://scenes/online_lobby.tscn")
			queue_free()
	elif state == "rematch_select":
		if press_timer > 0:
			press_timer -= 1
			if transition_alpha < 0.75:
				transition_alpha = 0.75
			if press_timer < max_press_timer / 2 and transition_alpha < 1.5:
				buttons_rematch.visible = false
				move_lists.visible = false
				menu_banner.deactivate()
				transition_alpha += change_alpha / 4
		else :
			var m_option = max(option, other_option)
			match m_option:
				1:
					get_tree().change_scene("res://scenes/game.tscn")
				2:
					global.leave_lobby(false)
					get_tree().change_scene("res://scenes/menu.tscn")
			queue_free()
	elif state == "continue_select":
		if press_timer > 0:
			press_timer -= 1
			if transition_alpha < 0.75:
				transition_alpha = 0.75
			if press_timer < max_press_timer / 2 and transition_alpha < 1.5:
				buttons_continue.visible = false
				move_lists.visible = false
				menu_banner.deactivate()
				transition_alpha += change_alpha / 4
		else :
			match option:
				1:
					get_tree().change_scene("res://scenes/game.tscn")
				2:
					get_tree().change_scene("res://scenes/charselect.tscn")
				3:
					get_tree().change_scene("res://scenes/menu.tscn")
			queue_free()
	elif state == "restart_select":
		if press_timer > 0:
			press_timer -= 1
			if transition_alpha < 0.75:
				transition_alpha = 0.75
			if press_timer < max_press_timer / 2 and transition_alpha < 1.5:
				buttons_restart.visible = false
				move_lists.visible = false
				menu_banner.deactivate()
				transition_alpha += change_alpha / 4
		else :
			match option:
				1:
					global.init_arcade_mode(global.player1_char)
					get_tree().change_scene("res://scenes/vsscreen.tscn")
				2:
					get_tree().change_scene("res://scenes/charselect.tscn")
				3:
					get_tree().change_scene("res://scenes/menu.tscn")
			queue_free()
	elif state == "pause_select":
		if press_timer > 0:
			press_timer -= 1
			if transition_alpha < 0.75:
				transition_alpha = 0.75
			if press_timer < max_press_timer / 2 and transition_alpha < 1.5 and option != 1:
				buttons_pause.visible = false
				move_lists.visible = false
				label_paused.visible = false
				menu_banner.deactivate()
				transition_alpha += change_alpha / 4
		else :
			if global.mode == global.MODE.arcade:
				match option:
					1:
						paused = false
						menu_banner.deactivate()
						label_paused.visible = false
						state = unpaused_state
						for button in buttons_pause.get_children():
							button.active = false
						if not paused_music:
							global_audio.play(pause_music_pos)
					2:
						get_tree().change_scene("res://scenes/charselect.tscn")
					3:
						get_tree().change_scene("res://scenes/menu.tscn")
			elif global.mode == global.MODE.tutorial:
				match option:
					1:
						paused = false
						menu_banner.deactivate()
						label_paused.visible = false
						state = unpaused_state
						for button in buttons_pause.get_children():
							button.active = false
						if not paused_music:
							global_audio.play(pause_music_pos)
					2:
						get_tree().change_scene("res://scenes/menu.tscn")
			else :
				match option:
					1:
						paused = false
						menu_banner.deactivate()
						label_paused.visible = false
						state = unpaused_state
						for button in buttons_pause.get_children():
							button.active = false
						if not paused_music:
							global_audio.play(pause_music_pos)
					2:
						get_tree().change_scene("res://scenes/stageselect.tscn")
					3:
						get_tree().change_scene("res://scenes/charselect.tscn")
					4:
						get_tree().change_scene("res://scenes/menu.tscn")
			if option != 1:
				queue_free()
	elif state == "end_tutorial":
		if transition_alpha < 0.75:
			transition_alpha += change_alpha
		else :
			state = "pause_select"
			option = 2
	elif state == "next_stage":
		if transition_alpha < 4:
			transition_alpha += change_alpha
		else :
			if global.set_next_arcade_char():
				get_tree().change_scene("res://scenes/vsscreen.tscn")
			else :
				get_tree().change_scene("res://scenes/arcadewin.tscn")
			queue_free()
	else :
		if transition_alpha > 0:
			transition_alpha -= change_alpha
		if global.mode == global.MODE.arcade:
			global.arcade_time += 1
	
	
	
	
	if global.mode == global.MODE.tutorial and not paused:
		if tutorial_timer > 0:
			tutorial_timer -= 1
		elif tutorial_timer == 0:
			match tutorial_index:
				0:
					textbox.add_message("Welcome to HYPERFIGHT!")
					textbox.next_message()
					max_tutorial_timer = 300
				1:
					textbox.add_message("We're going to start with the basics of movement, so listen closely.")
					textbox.next_message()
					max_tutorial_timer = 300
				2:
					textbox.add_message("Try moving left and right. You can also jump straight up, forwards, and backwards.")
					textbox.next_message()
					max_tutorial_timer = 900
					player1.stop_act()
					player1.start_act()
				3:
					textbox.add_message("Even if you jump over and switch sides with your opponent, you'll always be facing them.")
					textbox.next_message()
					max_tutorial_timer = 600
				4:
					textbox.add_message("Another key part of movement is dashing.")
					textbox.next_message()
					max_tutorial_timer = 300
				5:
					textbox.add_message("On the ground, double tap left or right, or hold the Left/Right + Dash buttons, to perform a dash.")
					textbox.next_message()
					max_tutorial_timer = 900
				6:
					textbox.add_message("In the air, you can dash in any direction! However, dashing up will only keep you in place.")
					textbox.next_message()
					max_tutorial_timer = 600
				7:
					textbox.add_message("It's very important to master dashing, as you're granted invincibility during a dash.")
					textbox.next_message()
					max_tutorial_timer = 450
				8:
					textbox.add_message("Now try attacking your opponent! Press the Attack button to use your normal attack.")
					textbox.next_message()
					max_tutorial_timer = - 1
					player1.start_attack()
				9:
					textbox.add_message("Good! Some attacks can even be angled by holding a direction while attacking.")
					textbox.next_message()
					max_tutorial_timer = 360
				10:
					textbox.add_message("Your character may have multiple normal attacks, so try checking the move list from the pause menu.")
					textbox.next_message()
					max_tutorial_timer = 360
				11:
					textbox.add_message("Any attack you land on your opponent is a knockout, winning the round.")
					textbox.next_message()
					max_tutorial_timer = 360
				12:
					textbox.add_message("Points are shown above your name, and you get 1 point for winning a round.")
					textbox.next_message()
					max_tutorial_timer = 360
				13:
					textbox.add_message("In this game, you'll have to risk some of your points to gain access to stronger moves.")
					textbox.next_message()
					max_tutorial_timer = 360
				14:
					textbox.add_message("Your special attack can only be used if you have at least 1 point. For Shoto Goto, it's a parry.")
					textbox.next_message()
					max_tutorial_timer = 360
				15:
					textbox.add_message("Try parrying your opponent's attack!")
					textbox.next_message()
					max_tutorial_timer = - 1
					player1.set_score(1)
					player2.set_score(0)
					player1.start_act()
					player2.start_act()
					player2.set_cpu_type(global.CPU_TYPE.dummy_jump_attack)
					player1.start_attack()
					player2.start_attack()
				16:
					textbox.add_message("Time your parry with the opponent's projectile. Try again! (Be sure to parry only once.)")
					textbox.next_message()
					max_tutorial_timer = - 1
					player1.set_score(1)
					player2.set_score(0)
					player1.start_act()
					player2.start_act()
					player1.start_attack()
					player2.start_attack()
					
				17:
					textbox.add_message("Good! You're invincible while using a special attack, so use them to beat out normal attacks.")
					textbox.next_message()
					player2.set_cpu_type(global.CPU_TYPE.dummy)
					max_tutorial_timer = 450
				18:
					textbox.add_message("However, you lose invincibility on airdashes until you hit the ground, so be careful!")
					textbox.next_message()
					max_tutorial_timer = 450
				19:
					textbox.add_message("Note that a point used for a move cannot be used for another move in the same round.")
					textbox.next_message()
					max_tutorial_timer = 450
				20:
					textbox.add_message("Usable points are green, while used points are red. If you lose the round, you also lose your red points.")
					textbox.next_message()
					max_tutorial_timer = 450
				21:
					textbox.add_message("However, if you win the round, you keep the points you used and get to use them again for the next round!")
					textbox.next_message()
					max_tutorial_timer = 450
				22:
					textbox.add_message("Some moves have special properties. You might notice that your character now has one green and one red point.")
					textbox.next_message()
					max_tutorial_timer = 450
				23:
					textbox.add_message("Because you successfully landed the parry, you got back the green point you used plus one red point.")
					textbox.next_message()
					max_tutorial_timer = 450
				24:
					textbox.add_message("Now try using your super attack by pressing the Super button, or Attack + Special buttons at the same time.")
					textbox.next_message()
					max_tutorial_timer = - 1
					player1.set_score(2)
					player1.start_act()
					player2.start_act()
					player1.start_attack()
				25:
					textbox.add_message("Try hitting the opponent with your super attack.")
					textbox.next_message()
					max_tutorial_timer = - 1
					player1.set_score(2)
					player1.start_act()
					player2.start_act()
					player1.start_attack()
				26:
					textbox.add_message("Nice work! Your super attack costs 2 points, but for most characters,")
					textbox.next_message()
					max_tutorial_timer = 300
				27:
					textbox.add_message("landing it will instantly win you the whole game!")
					textbox.next_message()
					max_tutorial_timer = 300
				28:
					textbox.add_message("That's all for the tutorial. Try fighting computer opponents in VS CPU or ARCADE MODE to grow stronger!")
					textbox.next_message()
					max_tutorial_timer = 450
				29:
					textbox.next_message()
					state = "end_tutorial"
			if tutorial_index != 16 and tutorial_index != 25:
				tutorial_index += 1
			tutorial_timer = max_tutorial_timer
		if state == "ko" and (tutorial_index == 9 or tutorial_index == 16 or tutorial_index == 25):
			tutorial_timer = 60
		if state != "ko" and tutorial_index == 16 and player1.anim_player.current_animation != "special":
			if player1.score == 0 and player1.get_red_score() >= 1 and tutorial_timer < 0:
				tutorial_timer = 1
			elif player1.score == 1 and player1.get_red_score() > 1:
				tutorial_timer = 1
				tutorial_index = 17
				player1.stop_act()
		if state == "super" and tutorial_index == 25:
			tutorial_timer = 60
			tutorial_index = 26
	
	if ( not global.online or (((global.lobby_state != global.LOBBY_STATE.spectate and curr_frame <= last_other_frame + last_other_delay) or (global.lobby_state == global.LOBBY_STATE.spectate and curr_frame <= min(player1_frame, player2_frame))) or curr_frame <= 0 or game_over)) and not paused:
		prev_delay = input_delay
		if global.online:
			if global.input_delay <= 0:
				if change_delay_timer <= 0:
					if input_delay > target_delay:
						input_delay -= 1
					elif input_delay < target_delay:
						input_delay += 1
					if input_delay < 1:
						input_delay = 1
					elif input_delay > 12:
						input_delay = 12
					change_delay_timer = max_change_delay_timer
				else :
					change_delay_timer -= 1
				if curr_frame <= 0:
					prev_delay = input_delay
			else :
				input_delay = global.input_delay
			label_delay.text = "Delay: " + str(input_delay) + "f"
		
		bg_game.process(curr_frame, frame_delay)
		textbox.process()
		player1.preprocess(curr_frame, frame_delay)
		player2.preprocess(curr_frame, frame_delay)
		for object in objects.get_children():
			object.process(curr_frame, frame_delay)
		player1.check_dead()
		player2.check_dead()
		
		if win_timer > 0:
			win_timer -= 1
		if delay_timer > 0:
			delay_timer -= 1
		if win_timer == 0:
			win_timer_act()
		if delay_timer == 0:
			delay_timer_act()
		
		curr_frame += 1
	
	if not global.online and (Input.is_action_just_pressed("player1_start") or (Input.is_action_just_pressed("player2_start") and not global.player2_cpu)) and state != "menu" and state != "continue" and state != "restart" and state != "menu_select" and state != "continue_select" and state != "restart_select" and state != "pause_select" and state != "end_tutorial" and state != "next_stage":
		if paused:
			paused = false
			menu_banner.deactivate()
			label_paused.visible = false
			for button in buttons_pause.get_children():
				button.active = false
			play_audio(snd_select2)
			if not paused_music:
				global_audio.play(pause_music_pos)
		else :
			paused = true
			menu_banner.activate()
			label_paused.visible = true
			unpaused_state = state
			option = 1
			player1.release_all_actions()
			player2.release_all_actions()
			play_audio(snd_select2)
			pause_music_pos = global_audio.get_playback_position()
			paused_music = not global_audio.playing
			global_audio.stop()

func win_timer_act():
	win_timer = max_win_timer
	if state == "ko":
		label_center.visible = true
		if win_player_num == 1:
			player1.inc_score()
			player2.update_score()
			player1_scored = true
			label_center.text = "K.O.!"
		elif win_player_num == 2:
			player2.inc_score()
			player1.update_score()
			player2_scored = true
			label_center.text = "K.O.!"
		else :
			player1.inc_score()
			player2.inc_score()
			player1_scored = true
			player2_scored = true
			label_center.text = "DOUBLE K.O.!"
		play_audio(snd_ko)
		state = "ready"
		win_player_num = - 1
		if not global.infinite_rounds:
			if player1.score >= 5 and player2.score >= 5:
				state = "draw"
			elif player1.score >= 5 or player2.score >= 5:
				state = "win"
			if state != "ready":
				win_timer = 90
	elif state == "super":
		label_center.visible = true
		if win_player_num == 1:
			player1.win_score()
			player2.update_score()
			player1_scored = true
			label_center.text = "SUPER K.O.!!"
		elif win_player_num == 2:
			player2.win_score()
			player1.update_score()
			player2_scored = true
			label_center.text = "SUPER K.O.!!"
		else :
			player1.win_score()
			player2.win_score()
			player1_scored = true
			player2_scored = true
			label_center.text = "DOUBLE SUPER K.O.!"
		play_audio(snd_superko)
		if global.infinite_rounds:
			state = "ready"
		else :
			if player1.score >= 5 and player2.score >= 5:
				state = "draw"
			else :
				state = "win"
			if state != "ready":
				win_timer = 90
	elif state == "win":
		state = "premenu"
		game_over = true
		max_win_timer = 120
		if player1.score >= 5:
			label_center.text = "Player 1 wins!"
			player1.win()
			if not player2_scored:
				state = "perfect"
			play_audio(snd_player1win)
			global.lobby_player1_wins += 1
		else :
			label_center.text = "Player 2 wins!"
			player2.win()
			if not player1_scored:
				state = "perfect"
			play_audio(snd_player2win)
			global.lobby_player2_wins += 1
		if global.online:
			set_wins_labels()
		win_timer = max_win_timer
	elif state == "draw":
		state = "premenu"
		game_over = true
		label_center.text = "DRAW"
		max_win_timer = 120
		win_timer = max_win_timer
	elif state == "ready":
		if global.mode != global.MODE.tutorial:
			player1.start_act()
			player2.start_act()
		label_center.text = "Ready..."
		state = "fight"
		max_win_timer = 60
		win_timer = max_win_timer
	elif state == "fight":
		if global.mode != global.MODE.tutorial:
			player1.start_attack()
			player2.start_attack()
		label_center.text = "FIGHT!"
		var rand = randi() % 3
		if rand == 0:
			play_audio(snd_fight)
		elif rand == 1:
			play_audio(snd_fight2)
		else :
			play_audio(snd_fight3)
		state = "go"
		max_win_timer = 60
		win_timer = max_win_timer
	elif state == "perfect":
		label_center.text = "PERFECT"
		play_audio(snd_perfect)
		state = "premenu"
		win_timer = 90
	elif state == "premenu":
		label_center.visible = false
		win_timer = - 1
		if global.mode == global.MODE.arcade:
			if player1.score >= 5 and player2.score < 5:
				state = "next_stage"
			elif global.arcade_continues > 0:
				state = "continue"
				menu_banner.activate()
			else :
				state = "restart"
				menu_banner.activate()
		elif global.mode == global.MODE.online_quickmatch:
			state = "rematch"
			option = 1
			menu_banner.activate()
		elif global.mode == global.MODE.online_lobby:
			if (global.lobby_state == global.LOBBY_STATE.player1 and player1.score >= 5 and player2.score < 5) or (global.lobby_state == global.LOBBY_STATE.player2 and player2.score >= 5 and player1.score < 5):
				var wins = global.get_lobby_member_data(global.steam_id, global.MEMBER_LOBBY_WINS)
				global.set_lobby_member_data(global.MEMBER_LOBBY_WINS, str(int(wins) + 1))
			if global.lobby_state != global.LOBBY_STATE.spectate:
				var matches = global.get_lobby_member_data(global.steam_id, global.MEMBER_LOBBY_MATCHES)
				global.set_lobby_member_data(global.MEMBER_LOBBY_MATCHES, str(int(matches) + 1))
			
			var rematch_style = int(global.get_lobby_data(global.LOBBY_REMATCH_STYLE))
			var rotation_style = int(global.get_lobby_data(global.LOBBY_ROTATION_STYLE))
			
			if global.lobby_player1_wins > global.lobby_player2_wins:
				global.lobby_rotate = global.LOBBY_ROTATE.player2
			elif global.lobby_player1_wins < global.lobby_player2_wins:
				global.lobby_rotate = global.LOBBY_ROTATE.player1
			else :
				global.lobby_rotate = global.LOBBY_ROTATE.both
			
			if rotation_style == global.LOBBY_ROTATION.lose:
				if global.lobby_rotate == global.LOBBY_ROTATE.player1:
					global.lobby_rotate = global.LOBBY_ROTATE.player2
				elif global.lobby_rotate == global.LOBBY_ROTATE.player2:
					global.lobby_rotate = global.LOBBY_ROTATE.player1
			elif rotation_style == global.LOBBY_ROTATION.none:
				global.lobby_rotate = global.LOBBY_ROTATE.both
			
			if rematch_style == global.LOBBY_REMATCH.inf or (rematch_style == global.LOBBY_REMATCH.bo5 and max(global.lobby_player1_wins, global.lobby_player2_wins) < 3) or (rematch_style == global.LOBBY_REMATCH.bo3 and max(global.lobby_player1_wins, global.lobby_player2_wins) < 2):
				state = "menu"
				option = 1
				menu_banner.activate()
				online_timer.start()
				label_timer.visible = true
			else :
				state = "menu_select_online"
				option = 4
				press_timer = max_press_timer
		elif global.mode != global.MODE.tutorial:
			state = "menu"
			option = 1
			menu_banner.activate()
	else :
		label_center.visible = false
		win_timer = - 1

func play_audio(snd):
	audio.volume_db = global.sfx_volume_db
	audio.stream = snd
	audio.play(0)

func delay_timer_act():
	frame_delay -= 2
	if frame_delay <= 0:
		frame_delay = 0
		delay_timer = - 1
	else :
		delay_timer = max_delay_timer

func broadcast_packet_input(input_player_num, copy_map, copy_frame, copy_delay):
	if global.other_member_id > 0:
		var packet = PoolByteArray()
		packet.append(global.P_TYPE.game_input)
		packet.append(input_player_num)
		packet.append(int(copy_map["left"]))
		packet.append(int(copy_map["right"]))
		packet.append(int(copy_map["up"]))
		packet.append(int(copy_map["down"]))
		packet.append(int(copy_map["attack"]))
		packet.append(int(copy_map["special"]))
		packet.append(int(copy_map["super"]))
		packet.append(int(copy_map["dash"]))
		packet.append(copy_delay)
		packet.append_array(str(copy_frame).to_ascii())
		global.broadcast_packet(packet)

func broadcast_packet_menu():
	if global.other_member_id > 0:
		var packet = PoolByteArray()
		packet.append(global.P_TYPE.game_menu)
		if global.lobby_state == global.LOBBY_STATE.player1:
			packet.append(1)
		else :
			packet.append(2)
		packet.append(option)
		global.broadcast_packet(packet)

func send_packet_ping():
	if global.other_member_id > 0:
		var packet = PoolByteArray()
		packet.append(global.P_TYPE.game_ping)
		Steam.sendP2PPacket(global.other_member_id, packet, 2, 0)

func _on_online_timer_timeout():
	if state == "menu" and global.lobby_state != global.LOBBY_STATE.spectate:
		state = "menu_select_online"
		option = 4
		press_timer = max_press_timer
		broadcast_packet_menu()
