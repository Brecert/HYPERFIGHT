extends Node2D

var state = "press"
var press_timer = - 1
var max_press_timer = 60
var min_bg_move = 1
var max_bg_move = 4
var bg_move = min_bg_move
var bg_repeat_pos = 32
var transition_alpha = 1
var change_alpha = 0.1
var selected_color = Color(1, 1, 1)
var logo_pos = Vector2()
var ready_logo_pos = Vector2(55, 0)
var credits_logo_pos = Vector2(300, - 10)
var rebinding = false
var editing = false
var active_buttons
var buttons_max = 6
var buttons_online_max = 3
var buttons_online_findlobby_max = 3
var buttons_online_findlobby_find_max = 1
var buttons_online_findlobby_list_max = 6
var buttons_online_findlobby_join_max = 1
var buttons_online_quickmatch_max = 4
var buttons_online_quickmatch_find_max = 1
var buttons_online_hostlobby_max = 6
var buttons_versus_max = 4
var buttons_solomodes_max = 3
var buttons_news_max = 1
var buttons_options_max = 6
var buttons_options_game_max = 2
var buttons_options_graphics_max = 3
var buttons_options_audio_max = 3
var buttons_options_controls_max = 3
var buttons_options_controls_rebind_max = 12
var buttons_options_credits_max = 1
var option = 1
var max_option = buttons_max
var last_option = 1
var last_online_option = 1
var last_online_find_list_option = 1
var last_options_option = 1
var last_options_controls_option = 1
var ignore_first_delta = true

var curr_lobbies = []
var online_distance_setting = 0
var online_distance_setting_max = 3
var other_member_id = 0
var sent_packet = false
var found_match = false

onready  var audio = get_node("AudioStreamPlayer")
onready  var bg_grid = get_node("bg_grid")
onready  var logo = get_node("logo")
onready  var transition = get_node("transition")
onready  var label_press = get_node("label_press")
onready  var label_ver = get_node("label_ver")
onready  var label_quickmatch_info = get_node("buttons_online_quickmatch_find/button_back/label_info")
onready  var news = get_node("buttons_news/button_back/news")
onready  var buttons = get_node("buttons")
onready  var button_options = get_node("buttons/button_options")
onready  var button_quit = get_node("buttons/button_quit")
onready  var buttons_online = get_node("buttons_online")
onready  var buttons_online_findlobby = get_node("buttons_online_findlobby")
onready  var buttons_online_findlobby_find = get_node("buttons_online_findlobby_find")
onready  var buttons_online_findlobby_list = get_node("buttons_online_findlobby_list")
onready  var buttons_online_findlobby_join = get_node("buttons_online_findlobby_join")
onready  var buttons_online_quickmatch = get_node("buttons_online_quickmatch")
onready  var buttons_online_quickmatch_find = get_node("buttons_online_quickmatch_find")
onready  var buttons_online_hostlobby = get_node("buttons_online_hostlobby")
onready  var buttons_versus = get_node("buttons_versus")
onready  var buttons_solomodes = get_node("buttons_solomodes")
onready  var buttons_news = get_node("buttons_news")
onready  var buttons_options = get_node("buttons_options")
onready  var buttons_options_game = get_node("buttons_options_game")
onready  var buttons_options_graphics = get_node("buttons_options_graphics")
onready  var buttons_options_audio = get_node("buttons_options_audio")
onready  var buttons_options_controls = get_node("buttons_options_controls")
onready  var buttons_options_controls_p1 = get_node("buttons_options_controls_p1")
onready  var buttons_options_controls_p2 = get_node("buttons_options_controls_p2")
onready  var button_options_controls_p1_dtdash = get_node("buttons_options_controls_p1/button_dtdash")
onready  var button_options_controls_p2_dtdash = get_node("buttons_options_controls_p2/button_dtdash")
onready  var buttons_options_credits = get_node("buttons_options_credits")
onready  var menu_banner = get_node("menu_banner")
onready  var menu_pattern = get_node("menu_pattern")
onready  var menu_pattern2 = get_node("menu_pattern2")
onready  var menu_ok = get_node("menu_ok")
onready  var lobby_find_timer = get_node("lobby_find_timer")
onready  var match_make_timer = get_node("match_make_timer")

onready  var find_rect = get_node("buttons_online_findlobby_list/button_back/find_rect")
onready  var button_lobby1 = get_node("buttons_online_findlobby_list/button_lobby1")
onready  var button_lobby2 = get_node("buttons_online_findlobby_list/button_lobby2")
onready  var button_lobby3 = get_node("buttons_online_findlobby_list/button_lobby3")
onready  var button_lobby4 = get_node("buttons_online_findlobby_list/button_lobby4")
onready  var button_findpage = get_node("buttons_online_findlobby_list/button_findpage")
onready  var label_lobby_name = get_node("buttons_online_findlobby_list/button_back/find_rect/label_name")
onready  var label_lobby_members = get_node("buttons_online_findlobby_list/button_back/find_rect/label_members")
onready  var label_lobby_rematch = get_node("buttons_online_findlobby_list/button_back/find_rect/label_rematch")
onready  var label_lobby_rotation = get_node("buttons_online_findlobby_list/button_back/find_rect/label_rotation")
onready  var label_lobby_matchlimit = get_node("buttons_online_findlobby_list/button_back/find_rect/label_matchlimit")
onready  var label_lobby_delay = get_node("buttons_online_findlobby_list/button_back/find_rect/label_delay")
onready  var label_lobby_stageselect = get_node("buttons_online_findlobby_list/button_back/find_rect/label_stageselect")
onready  var label_lobby_chat = get_node("buttons_online_findlobby_list/button_back/find_rect/label_chat")

onready  var snd_select = preload("res://sounds/select.ogg")
onready  var snd_select2 = preload("res://sounds/select2.ogg")

class lobby_class:
	var lobby_id = 0
	var lobby_name = ""
	var keyword = ""
	var members = 0
	var max_members = 0
	var rematch_style = global.LOBBY_REMATCH.none
	var rotation_style = global.LOBBY_ROTATION.win
	var match_limit = 0
	var delay = 0
	var stage_select = global.STAGE_SELECT.random
	var chat = true

func _ready():
	global.leave_lobby(false)
	
	global_audio.stop()
	active_buttons = buttons
	logo_pos = logo.get_position()
	label_ver.visible = false
	label_ver.text = global.VERSION
	transition.visible = true
	bg_grid.get_material().set_shader_param("threshold", 0.01)
	bg_grid.get_material().set_shader_param("color_o0", Color(0.5, 0.5, 0.5))
	bg_grid.get_material().set_shader_param("color_n0", Color(0.25, 0.25, 0.25))
	bg_grid.get_material().set_shader_param("color_o1", Color(0.75, 0.75, 0.75))
	bg_grid.get_material().set_shader_param("color_n1", Color(0.35, 0.35, 0.35))
	if global.menu_init or (global.mode == global.MODE.online_lobby or global.mode == global.MODE.online_quickmatch):
		label_press.visible = false
		label_ver.visible = true
		menu_pattern.activate()
		menu_pattern2.activate()
		activate_buttons(buttons, - 1)
		state = "menu"
		logo_pos = ready_logo_pos
		logo.set_position(logo_pos)
		menu_banner.activate()
		global.menu_init = true
	if global.mode == global.MODE.online_quickmatch:
		change_buttons(buttons_online_quickmatch, buttons_online_quickmatch_max)
	elif global.mode == global.MODE.online_lobby and not global.lobby_join:
		change_buttons(buttons_online_hostlobby, buttons_online_hostlobby_max)
	elif global.lobby_found:
		change_buttons(buttons_online_findlobby, buttons_online_findlobby_max)
		global.lobby_found = false
	
	if global.steam_enabled:
		Steam.connect("lobby_created", self, "lobby_created")
		Steam.connect("lobby_joined", self, "lobby_joined")
		Steam.connect("p2p_session_request", self, "p2p_session_request")
		Steam.connect("p2p_session_connect_fail", self, "p2p_session_connect_fail")
		Steam.connect("lobby_match_list", self, "lobby_match_list")
	
	if global.html5_ver:
		button_quit.visible = false
		buttons_max = 5
		max_option = 5
		button_options.set_orig_pos(Vector2( - 67, 45))

func no_menu_buttons():
	return active_buttons == buttons_online_findlobby_find or active_buttons == buttons_online_findlobby_join or active_buttons == buttons_online_quickmatch_find or active_buttons == buttons_options_credits or active_buttons == buttons_news or active_buttons == buttons_options_controls_p1 or active_buttons == buttons_options_controls_p2

func _process(delta):
	if ignore_first_delta:
		delta = 0
		ignore_first_delta = false
	
	if global.steam_enabled:
		Steam.run_callbacks()
		
		if active_buttons == buttons_online_quickmatch_find and sent_packet:
			var packet_size = Steam.getAvailableP2PPacketSize(0)
			while packet_size > 0:
				var packet_dict = Steam.readP2PPacket(packet_size, 0)
				var packet = packet_dict["data"]
				var packet_type = packet[0]
				match packet_type:
					global.P_TYPE.menu_lobby_owner:
						global.create_debug_text("Got owner packet")
						global.set_char(packet[1], packet[2], 1)
						if global.online_char != global.CHAR.random:
							global.set_char(global.online_char, global.online_palette, 2)
						global.differ_palettes()
						global.stage = packet[3]
						get_tree().change_scene("res://scenes/vsscreen.tscn")
					global.P_TYPE.menu_lobby_joiner:
						global.create_debug_text("Got joiner packet")
						global.input_delay = packet[1]
						if global.online_char != global.CHAR.random:
							global.set_char(global.online_char, global.online_palette, 1)
						global.set_char(packet[2], packet[3], 2)
						global.differ_palettes()
						global.stage = global.online_stage
						get_tree().change_scene("res://scenes/vsscreen.tscn")
				packet_size = Steam.getAvailableP2PPacketSize(0)
		elif not active_buttons == buttons_online_quickmatch_find:
			var packet_size = Steam.getAvailableP2PPacketSize(0)
			while packet_size > 0:
				Steam.readP2PPacket(packet_size, 0)
				packet_size = Steam.getAvailableP2PPacketSize(0)
	
	transition.set_modulate(Color(1, 1, 1, transition_alpha))
	if logo_pos.distance_to(logo.get_position()) > 1:
		logo.set_position(logo.get_position() + (logo_pos - logo.get_position()) / 4 * (global.fps * delta))
	else :
		logo.set_position(logo_pos)
	if no_menu_buttons():
		label_ver.visible = false
	elif state != "press":
		label_ver.visible = true
	if menu_ok.active:
		transition.set_modulate(Color(1, 1, 1, 0.75))
	elif state == "press":
		if transition_alpha > 0:
			transition_alpha -= change_alpha * (global.fps * delta)
		if (Input.is_action_just_pressed("player1_attack") or Input.is_action_just_pressed("player1_start") or Input.is_action_just_pressed("player2_attack") or Input.is_action_just_pressed("player2_start")) and press_timer < 0:
			press_timer = max_press_timer
			bg_move = max_bg_move
			menu_pattern.activate()
			menu_pattern2.activate()
			play_audio(snd_select)
		if press_timer > 0:
			press_timer -= 1 * (global.fps * delta)
			var flash = int(press_timer / 3)
			if flash % 2 == 0:
				label_press.visible = true
			else :
				label_press.visible = false
		elif press_timer != - 1 and press_timer <= 0:
			bg_grid.position.x = 0
			label_press.visible = false
			label_ver.visible = true
			menu_banner.activate()
			activate_buttons(buttons, - 1)
			global.menu_init = true
			state = "menu"
	elif state == "menu":
		if no_menu_buttons():
			logo_pos = credits_logo_pos
			menu_pattern.visible = false
			menu_pattern2.visible = false
		else :
			logo_pos = ready_logo_pos
			menu_pattern.visible = true
			menu_pattern2.visible = true
		if transition_alpha > 0:
			transition_alpha -= change_alpha * (global.fps * delta)
		if bg_move > min_bg_move:
			bg_move -= 1
		
		if not rebinding and not editing:
			if Input.is_action_just_pressed("player1_up") or Input.is_action_just_pressed("player2_up"):
				option -= 1
				if active_buttons == buttons_online_findlobby_list and global.find_page == global.find_max_page and option > (curr_lobbies.size() - 1) % 4 + 1 and option < 5:
					option = (curr_lobbies.size() - 1) % 4 + 1
				if active_buttons == buttons_online_hostlobby and global.host_page == global.host_max_page and option > 2 and option < 5:
					option = 2
			if Input.is_action_just_pressed("player1_down") or Input.is_action_just_pressed("player2_down"):
				option += 1
				if active_buttons == buttons_online_findlobby_list and global.find_page == global.find_max_page and option > (curr_lobbies.size() - 1) % 4 + 1 and option < 5:
					option = 5
				if active_buttons == buttons_online_hostlobby and global.host_page == global.host_max_page and option > 2 and option < 5:
					option = 5
			if option < 1:
				option = max_option
			elif option > max_option:
				option = 1
			set_lobby_find_labels()
			
		var just_rebound = rebinding
		rebinding = false
		editing = false
		for button in active_buttons.get_children():
			if button.highlight(option):
				selected_color = button.color
			if button.rebinding:
				rebinding = true
			if button.editing:
				editing = true
		if not rebinding and not just_rebound and not editing:
			if Input.is_action_just_pressed("player1_attack") or Input.is_action_just_pressed("player1_start") or Input.is_action_just_pressed("player2_attack") or Input.is_action_just_pressed("player2_start"):
				var selected = false
				for button in active_buttons.get_children():
					if (button.select(option)):
						selected = true
				if selected:
					press_timer = max_press_timer
					bg_move = max_bg_move
					transition_alpha = 0
					play_audio(snd_select2)
					state = "select"
			if Input.is_action_just_pressed("player1_special") or Input.is_action_just_pressed("player2_special"):
				menu_banner.activate()
				news.set_active(false)
				if active_buttons == buttons_online or active_buttons == buttons_versus or active_buttons == buttons_solomodes or active_buttons == buttons_news or active_buttons == buttons_options:
					change_buttons(buttons, buttons_max)
				elif active_buttons == buttons_online_findlobby or active_buttons == buttons_online_hostlobby or active_buttons == buttons_online_quickmatch:
					change_buttons(buttons_online, buttons_online_max)
				elif active_buttons == buttons_online_findlobby_find or active_buttons == buttons_online_findlobby_list:
					change_buttons(buttons_online_findlobby, buttons_online_findlobby_max)
				elif active_buttons == buttons_online_findlobby_join:
					change_buttons(buttons_online_findlobby_list, buttons_online_findlobby_list_max)
				elif active_buttons == buttons_online_quickmatch_find:
					change_buttons(buttons_online_quickmatch, buttons_online_quickmatch_max)
					global.leave_lobby(false)
				elif active_buttons == buttons_options_game or active_buttons == buttons_options_graphics or active_buttons == buttons_options_audio or active_buttons == buttons_options_controls or active_buttons == buttons_options_credits:
					change_buttons(buttons_options, buttons_options_max)
				elif active_buttons == buttons_options_controls_p1 or active_buttons == buttons_options_controls_p2:
					change_buttons(buttons_options_controls, buttons_options_controls_max)
		elif editing:
			if Input.is_action_just_pressed("player1_start") or Input.is_action_just_pressed("player2_start"):
				for button in active_buttons.get_children():
					button.select(option)
	else :
		global.menu_option = option
		menu_banner.activate()
		news.set_active(false)
		lobby_find_timer.stop()
		if active_buttons == buttons and global.menu_option == 6:
			get_tree().quit()
		elif (active_buttons == buttons_online and global.menu_option == 3) or (active_buttons == buttons_versus and global.menu_option == 4) or (active_buttons == buttons_solomodes and global.menu_option == 3) or (active_buttons == buttons_news and global.menu_option == 1) or (active_buttons == buttons_options and global.menu_option == 6):
			change_buttons(buttons, buttons_max)
		elif (active_buttons == buttons and global.menu_option == 1) or (active_buttons == buttons_online_findlobby and global.menu_option == 3) or (active_buttons == buttons_online_quickmatch and global.menu_option == 4) or (active_buttons == buttons_online_hostlobby and global.menu_option == 6):
			if global.steam_enabled:
				change_buttons(buttons_online, buttons_online_max)
			else :
				menu_ok.set_text("Only available in the Steam version.")
				menu_ok.active = true
				state = "menu"
		elif (active_buttons == buttons_online and global.menu_option == 1) or (active_buttons == buttons_online_findlobby_find and global.menu_option == 1) or (active_buttons == buttons_online_findlobby_list and global.menu_option == 6) or (active_buttons == buttons_online_quickmatch_find and global.menu_option == 1):
			if active_buttons == buttons_online_quickmatch_find:
				global.leave_lobby(false)
			if global.beta:
				menu_ok.set_text("Not available in the beta version.")
				menu_ok.active = true
				state = "menu"
			else :
				change_buttons(buttons_online_findlobby, buttons_online_findlobby_max)
		elif (active_buttons == buttons_online_findlobby_join and global.menu_option == 1):
			change_buttons(buttons_online_findlobby_list, buttons_online_findlobby_list_max)
		elif active_buttons == buttons_online_findlobby and global.menu_option == 1:
			change_buttons(buttons_online_findlobby_find, buttons_online_findlobby_find_max)
			menu_banner.deactivate()
			start_lobby_search()
		elif active_buttons == buttons_online_findlobby_list and global.menu_option < 5:
			change_buttons(buttons_online_findlobby_join, buttons_online_findlobby_join_max)
			menu_banner.deactivate()
			var lobby_index = (global.menu_option - 1) + ((global.find_page - 1) * 4)
			if lobby_index < curr_lobbies.size():
				global.lobby_found = true
				global.join_lobby(curr_lobbies[lobby_index].lobby_id, true)
		elif active_buttons == buttons_online_quickmatch and global.menu_option == 1:
			change_buttons(buttons_online_quickmatch_find, buttons_online_quickmatch_find_max)
			menu_banner.deactivate()
			start_match_search()
			label_quickmatch_info.text = "Finding matches at distance 0..."
		elif active_buttons == buttons_online and global.menu_option == 2:
			change_buttons(buttons_online_hostlobby, buttons_online_hostlobby_max)
		elif active_buttons == buttons and global.menu_option == 2:
			change_buttons(buttons_versus, buttons_versus_max)
		elif active_buttons == buttons and global.menu_option == 3:
			change_buttons(buttons_solomodes, buttons_solomodes_max)
		elif active_buttons == buttons and global.menu_option == 4:
			change_buttons(buttons_news, buttons_news_max)
			menu_banner.deactivate()
			news.set_active(true)
		elif (active_buttons == buttons and global.menu_option == 5) or (active_buttons == buttons_options_game and global.menu_option == 2) or (active_buttons == buttons_options_graphics and global.menu_option == 3) or (active_buttons == buttons_options_audio and global.menu_option == 3) or (active_buttons == buttons_options_controls and global.menu_option == 3) or (active_buttons == buttons_options_credits and global.menu_option == 1):
			change_buttons(buttons_options, buttons_options_max)
		elif active_buttons == buttons_options and global.menu_option == 1:
			change_buttons(buttons_options_game, buttons_options_game_max)
		elif active_buttons == buttons_options and global.menu_option == 2:
			if global.html5_ver:
				menu_ok.set_text("Not available in the HTML5 version.")
				menu_ok.active = true
				state = "menu"
			else :
				change_buttons(buttons_options_graphics, buttons_options_graphics_max)
		elif active_buttons == buttons_options and global.menu_option == 3:
			change_buttons(buttons_options_audio, buttons_options_audio_max)
		elif (active_buttons == buttons_options and global.menu_option == 4) or (active_buttons == buttons_options_controls_p1 and global.menu_option == 12) or (active_buttons == buttons_options_controls_p2 and global.menu_option == 12):
			change_buttons(buttons_options_controls, buttons_options_controls_max)
		elif active_buttons == buttons_options_controls and global.menu_option == 1:
			change_buttons(buttons_options_controls_p1, buttons_options_controls_rebind_max)
			menu_banner.deactivate()
		elif active_buttons == buttons_options_controls and global.menu_option == 2:
			change_buttons(buttons_options_controls_p2, buttons_options_controls_rebind_max)
			menu_banner.deactivate()
		elif active_buttons == buttons_options_controls_p1 and global.menu_option == 11:
			global.set_input_default_p1()
			_on_button_rebound()
			button_options_controls_p1_dtdash.set_label_text()
			state = "menu"
			menu_banner.deactivate()
		elif active_buttons == buttons_options_controls_p2 and global.menu_option == 11:
			global.set_input_default_p2()
			_on_button_rebound()
			button_options_controls_p2_dtdash.set_label_text()
			state = "menu"
			menu_banner.deactivate()
		elif active_buttons == buttons_options and global.menu_option == 5:
			change_buttons(buttons_options_credits, buttons_options_credits_max)
			menu_banner.deactivate()
		elif press_timer > 0:
			press_timer -= 1 * (global.fps * delta)
			if press_timer < max_press_timer / 2 and transition_alpha < 1:
				transition_alpha += change_alpha * (global.fps * delta)
		else :
			global.lobby_found = false
			if active_buttons == buttons_solomodes:
				if global.menu_option == 1:
					global.init_arcade()
					get_tree().change_scene("res://scenes/charselect.tscn")
				elif global.menu_option == 2:
					global.init_tutorial()
					get_tree().change_scene("res://scenes/vsscreen.tscn")
			elif active_buttons == buttons_online:
				if global.menu_option == 1:
					global.init_online_lobby()
					get_tree().change_scene("res://scenes/charselect.tscn")
			elif active_buttons == buttons_online_hostlobby:
				if global.menu_option == 1:
					global.init_online_lobby()
					get_tree().change_scene("res://scenes/online_lobby.tscn")
			elif active_buttons == buttons_versus:
				if global.menu_option == 1:
					global.init_p1_vs_p2()
				elif global.menu_option == 2:
					global.init_p1_vs_cpu()
				elif global.menu_option == 3:
					global.init_cpu_vs_cpu()
				get_tree().change_scene("res://scenes/charselect.tscn")
			else :
				state == "menu"
	if bg_move != 0:
		if state == "press":
			bg_grid.position.x += bg_move * (global.fps * delta)
		else :
			bg_grid.position.y += bg_move * (global.fps * delta)
		if bg_grid.position.x > bg_repeat_pos:
			bg_grid.position.x = - bg_repeat_pos
		elif bg_grid.position.x < - bg_repeat_pos:
			bg_grid.position.x = bg_repeat_pos
		if bg_grid.position.y > bg_repeat_pos:
			bg_grid.position.y = - bg_repeat_pos
		elif bg_grid.position.y < - bg_repeat_pos:
			bg_grid.position.y = bg_repeat_pos
		if state != "press":
			var target_color = selected_color
			var color = bg_grid.get_material().get_shader_param("color_n0")
			bg_grid.get_material().set_shader_param("color_n0", color.linear_interpolate(target_color, 0.1 * (global.fps * delta)))
			color = bg_grid.get_material().get_shader_param("color_n0")
			color = color.lightened(0.1)
			bg_grid.get_material().set_shader_param("color_n1", color)
	
	if global.steam_enabled:
		var lobby_id = global.curr_lobby_id
		var curr_lobby_members = Steam.getNumLobbyMembers(lobby_id)
		if active_buttons == buttons_online_quickmatch_find and curr_lobby_members == 2 and not sent_packet:
			var lobby_owner = Steam.getLobbyOwner(lobby_id)
			var other_member
			for i in range(curr_lobby_members):
				var lobby_member = Steam.getLobbyMemberByIndex(lobby_id, i)
				if lobby_owner != lobby_member:
					other_member = lobby_member
			if global.lobby_join:
				global.other_member_id = lobby_owner
				send_packet_lobby_joiner(lobby_owner)
				global.create_debug_text("Sent joiner packet")
			else :
				global.other_member_id = other_member
				global.online_stage = global.get_random_stage()
				send_packet_lobby_owner(other_member)
				global.create_debug_text("Sent owner packet")
			Steam.acceptP2PSessionWithUser(global.other_member_id)
			sent_packet = true
			match_make_timer.start()
			label_quickmatch_info.text = "Match found! Waiting for " + Steam.getFriendPersonaName(global.other_member_id) + "..."

func activate_buttons(set_buttons, prev_layer):
	for button in set_buttons.get_children():
		button.activate(prev_layer)

func deactivate_buttons(set_buttons, prev_layer):
	for button in set_buttons.get_children():
		button.deactivate(prev_layer)

func change_buttons(new_buttons, new_max_option):
	if new_buttons == buttons:
		option = last_option
	elif (new_buttons == buttons_online or new_buttons == buttons_versus or new_buttons == buttons_solomodes or new_buttons == buttons_news or new_buttons == buttons_options) and active_buttons == buttons:
		last_option = option
		option = 1
	elif new_buttons == buttons_online and active_buttons != buttons:
		option = last_online_option
	elif new_buttons != buttons and active_buttons == buttons_online:
		last_online_option = option
		option = 1
	elif new_buttons == buttons_online_findlobby_join and active_buttons == buttons_online_findlobby_list:
		last_online_find_list_option = option
		option = 1
	elif new_buttons == buttons_online_findlobby_list and active_buttons == buttons_online_findlobby_join:
		option = last_online_find_list_option
	elif new_buttons == buttons_options and active_buttons != buttons:
		option = last_options_option
	elif new_buttons != buttons and active_buttons == buttons_options:
		last_options_option = option
		option = 1
	elif new_buttons == buttons_options_controls and active_buttons != buttons_options:
		option = last_options_controls_option
	elif new_buttons != buttons_options and active_buttons == buttons_options_controls:
		last_options_controls_option = option
		option = 1
	else :
		option = 1
	var prev_layer
	var next_layer = 0
	for button in active_buttons.get_children():
		button.select_timer = - 1
		prev_layer = button.layer
	for button in new_buttons.get_children():
		next_layer = button.layer
		break
	deactivate_all_buttons(next_layer)
	active_buttons = new_buttons
	activate_buttons(active_buttons, prev_layer)
	max_option = new_max_option
	state = "menu"

func deactivate_all_buttons(next_layer):
	deactivate_buttons(buttons, next_layer)
	deactivate_buttons(buttons_online, next_layer)
	deactivate_buttons(buttons_online_findlobby, next_layer)
	deactivate_buttons(buttons_online_findlobby_find, next_layer)
	deactivate_buttons(buttons_online_findlobby_list, next_layer)
	deactivate_buttons(buttons_online_findlobby_join, next_layer)
	deactivate_buttons(buttons_online_quickmatch, next_layer)
	deactivate_buttons(buttons_online_quickmatch_find, next_layer)
	deactivate_buttons(buttons_online_hostlobby, next_layer)
	deactivate_buttons(buttons_versus, next_layer)
	deactivate_buttons(buttons_solomodes, next_layer)
	deactivate_buttons(buttons_news, next_layer)
	deactivate_buttons(buttons_options, next_layer)
	deactivate_buttons(buttons_options_game, next_layer)
	deactivate_buttons(buttons_options_graphics, next_layer)
	deactivate_buttons(buttons_options_audio, next_layer)
	deactivate_buttons(buttons_options_controls, next_layer)
	deactivate_buttons(buttons_options_controls_p1, next_layer)
	deactivate_buttons(buttons_options_controls_p2, next_layer)
	deactivate_buttons(buttons_options_credits, next_layer)

func play_audio(snd):
	audio.volume_db = global.sfx_volume_db
	audio.stream = snd
	audio.play(0)

func lobby_created(result, lobby_id):
	global.create_debug_text("Lobby created! ID: " + str(lobby_id))
	global.curr_lobby_id = lobby_id
	if Steam.setLobbyData(lobby_id, global.LOBBY_VERSION, global.VERSION):
		global.create_debug_text("Set lobby data " + global.LOBBY_VERSION + " to " + global.VERSION)

func p2p_session_request(user_id):
	if active_buttons == buttons_online_quickmatch_find and global.other_member_id == user_id:
		Steam.acceptP2PSessionWithUser(user_id)
		global.create_debug_text("Accepted P2P session with ID: " + str(user_id))
	else :
		global.create_debug_text("Refused P2P session with ID: " + str(user_id))

func p2p_session_connect_fail(user_id, reason):
	global.leave_lobby(false)
	if active_buttons == buttons_online_quickmatch_find:
		start_match_search()
	if global.debug_texts:
		global.create_debug_text("Failed P2P session with ID: " + str(user_id))
	else :
		global.create_info_text("Lobby closed! Reason: Failed P2P session with other lobby member.")

func lobby_match_list(lobbies):
	if active_buttons == buttons_online_quickmatch_find and not sent_packet:
		if lobbies.size() > 0:
			for lobby in lobbies:
				if Steam.getNumLobbyMembers(global.curr_lobby_id) < 2 and Steam.getNumLobbyMembers(lobby) == 1 and global.curr_lobby_id != lobby and Steam.getLobbyOwner(lobby) != Steam.getSteamID():
					global.join_lobby(lobby, false)
					lobby_find_timer.stop()
					global.init_online_quickmatch(true)
					global.input_delay = 0
					label_quickmatch_info.text = "Match found! Connecting..."
					global.create_debug_text("Trying to join lobby...")
					match_make_timer.start()
					return 
		if online_distance_setting < online_distance_setting_max:
			online_distance_setting += 1
			Steam.addRequestLobbyListDistanceFilter(online_distance_setting)
			Steam.requestLobbyList()
			label_quickmatch_info.text = "Finding matches at distance " + str(online_distance_setting) + "..."
			global.create_debug_text("Finding lobbies at distance " + str(online_distance_setting) + "...")
		elif global.curr_lobby_id <= 0:
			Steam.createLobby(3, 2)
			global.init_online_quickmatch(false)
			global.create_debug_text("Could not find lobbies, creating own...")
			label_quickmatch_info.text = "No matches found. Restarting search..."
		else :
			global.create_debug_text("Could not find lobbies.")
			label_quickmatch_info.text = "No matches found. Restarting search..."
	elif active_buttons == buttons_online_findlobby_find:
		curr_lobbies.clear()
		menu_banner.activate()
		if lobbies.size() > 0:
			for lobby_id in lobbies:
				var lobby_version = Steam.getLobbyData(lobby_id, global.LOBBY_VERSION)
				var lobby_keyword = Steam.getLobbyData(lobby_id, global.LOBBY_KEYWORD)
				var lobby_members = Steam.getNumLobbyMembers(lobby_id)
				var lobby_max = Steam.getLobbyMemberLimit(lobby_id)
				if global.VERSION == lobby_version and global.find_keyword == lobby_keyword:
					var lobby = lobby_class.new()
					lobby.lobby_id = lobby_id
					lobby.lobby_name = Steam.getLobbyData(lobby_id, global.LOBBY_NAME)
					lobby.keyword = lobby_keyword
					lobby.members = lobby_members
					lobby.max_members = lobby_max
					lobby.rematch_style = int(Steam.getLobbyData(lobby_id, global.LOBBY_REMATCH_STYLE))
					lobby.rotation_style = int(Steam.getLobbyData(lobby_id, global.LOBBY_ROTATION_STYLE))
					lobby.match_limit = int(Steam.getLobbyData(lobby_id, global.LOBBY_MATCH_LIMIT))
					lobby.delay = int(Steam.getLobbyData(lobby_id, global.LOBBY_DELAY))
					lobby.stage_select = int(Steam.getLobbyData(lobby_id, global.LOBBY_STAGE_SELECT))
					lobby.chat = bool(int(Steam.getLobbyData(lobby_id, global.LOBBY_CHAT)))
					curr_lobbies.append(lobby)
			if curr_lobbies.size() > 0:
				option = 1
				global.find_page = 1
				global.find_max_page = 1 + ((curr_lobbies.size() - 1) / 4)
				button_findpage.set_label_text()
				set_lobby_find_buttons()
				set_lobby_find_labels()
				change_buttons(buttons_online_findlobby_list, buttons_online_findlobby_list_max)
			else :
				change_buttons(buttons_online_findlobby, buttons_online_findlobby_max)
				global.create_info_text("No lobbies found.")
		else :
			change_buttons(buttons_online_findlobby, buttons_online_findlobby_max)
			global.create_info_text("No lobbies found.")

func set_lobby_find_buttons():
	var base_index = ((global.find_page - 1) * 4)
	for i in range(4):
		var curr_button = button_lobby1
		match i:
			1:
				curr_button = button_lobby2
			2:
				curr_button = button_lobby3
			3:
				curr_button = button_lobby4
		curr_button.visible = false
		if base_index + i < curr_lobbies.size():
			curr_button.visible = true
			curr_button.text = curr_lobbies[base_index + i].lobby_name
			if len(curr_button.text) > 12:
				curr_button.text = curr_button.text.substr(0, 11)
				curr_button.text += "..."
			curr_button.set_label_text()

func set_lobby_find_labels():
	var lobby_index = (option - 1) + ((global.find_page - 1) * 4)
	if option <= 4 and lobby_index < curr_lobbies.size():
		var curr_lobby = curr_lobbies[lobby_index]
		find_rect.visible = true
		label_lobby_name.text = curr_lobby.lobby_name
		label_lobby_members.text = str(curr_lobby.members) + "/" + str(curr_lobby.max_members)
		label_lobby_rematch.text = "Rematch: "
		match curr_lobby.rematch_style:
			global.LOBBY_REMATCH.none:
				label_lobby_rematch.text += "None"
			global.LOBBY_REMATCH.bo3:
				label_lobby_rematch.text += "Best of 3"
			global.LOBBY_REMATCH.bo5:
				label_lobby_rematch.text += "Best of 5"
			global.LOBBY_REMATCH.inf:
				label_lobby_rematch.text += "Inf"
		label_lobby_rotation.text = "Rotation: "
		match curr_lobby.rotation_style:
			global.LOBBY_ROTATION.win:
				label_lobby_rotation.text += "Winner Stays"
			global.LOBBY_ROTATION.lose:
				label_lobby_rotation.text += "Loser Stays"
			global.LOBBY_ROTATION.none:
				label_lobby_rotation.text += "None Stay"
		label_lobby_matchlimit.text = "Consec. Stay Limit: "
		if curr_lobby.match_limit > 0:
			label_lobby_matchlimit.text += str(curr_lobby.match_limit)
		else :
			label_lobby_matchlimit.text += "None"
		label_lobby_delay.text = "Delay: "
		if curr_lobby.delay > 0:
			label_lobby_delay.text += str(curr_lobby.delay)
		else :
			label_lobby_delay.text += "Auto"
		label_lobby_stageselect.text = "Stage Select: "
		match curr_lobby.stage_select:
			global.STAGE_SELECT.random:
				label_lobby_stageselect.text += "Random"
			global.STAGE_SELECT.choose:
				label_lobby_stageselect.text += "Choose"
		label_lobby_chat.text = "Chat: "
		if curr_lobby.chat:
			label_lobby_chat.text += "Enabled"
		else :
			label_lobby_chat.text += "Disabled"
	else :
		find_rect.visible = false

func send_packet_lobby_owner(other_member_id):
	var packet = PoolByteArray()
	packet.append(global.P_TYPE.menu_lobby_owner)
	if global.online_char == global.CHAR.random:
		global.set_char(global.online_char, global.online_palette, 1)
		packet.append(global.player1_char)
		packet.append(global.player1_palette)
	else :
		packet.append(global.online_char)
		packet.append(global.online_palette)
	packet.append(global.online_stage)
	Steam.sendP2PPacket(other_member_id, packet, 2, 0)

func send_packet_lobby_joiner(other_member_id):
	var packet = PoolByteArray()
	packet.append(global.P_TYPE.menu_lobby_joiner)
	packet.append(global.input_delay)
	if global.online_char == global.CHAR.random:
		global.set_char(global.online_char, global.online_palette, 2)
		packet.append(global.player2_char)
		packet.append(global.player2_palette)
	else :
		packet.append(global.online_char)
		packet.append(global.online_palette)
	Steam.sendP2PPacket(other_member_id, packet, 2, 0)

func start_match_search():
	global.leave_lobby(false)
	online_distance_setting = 0
	sent_packet = false
	found_match = false
	Steam.addRequestLobbyListDistanceFilter(online_distance_setting)
	Steam.requestLobbyList()
	lobby_find_timer.start()

func start_lobby_search():
	Steam.requestLobbyList()

func lobby_joined(lobby_id, perm, locked, response):
	if response != 1 and active_buttons == buttons_online_findlobby_join:
		change_buttons(buttons_online_findlobby_list, buttons_online_findlobby_list_max)
		menu_banner.activate()

func _on_lobby_find_timer_timeout():
	online_distance_setting = 0
	Steam.requestLobbyList()
	if not sent_packet:
		label_quickmatch_info.text = "Finding matches at distance 0..."

func _on_match_make_timer_timeout():
	var packet_size = Steam.getAvailableP2PPacketSize(0)
	while packet_size > 0:
		Steam.readP2PPacket(packet_size, 0)
		packet_size = Steam.getAvailableP2PPacketSize(0)
	start_match_search()
	label_quickmatch_info.text = "Finding matches at distance 0..."

func _on_button_findpage_find_page_changed():
	set_lobby_find_buttons()

func _on_button_rebound():
	for button in buttons_options_controls_p1.get_children():
		button.set_rebind_text()
	for button in buttons_options_controls_p2.get_children():
		button.set_rebind_text()
