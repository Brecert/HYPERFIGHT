extends Node

enum SCREEN{window, window2x, window3x, window4x, full}
enum INPUT_TYPE{key, pad, stick}
enum MODE{versus_player, versus_cpu, online_lobby, online_quickmatch, arcade, tutorial}
enum CHAR{goto, yoyo, kero, time, sword, darkgoto, random, locked}
enum STAGE{dojo, rooftop, lab, company, bridge, blackhole, training, random, locked}
enum STAGE_SELECT{random, choose}
enum CPU_TYPE{normal, dummy, dummy_jump_attack}
enum CPU_DIFF{normal, hard}
enum LOBBY_READY{not_ready, ready, playing}
enum LOBBY_STATE{player1, player2, spectate}
enum LOBBY_ROTATE{none, player1, player2, both}
enum LOBBY_REMATCH{none, bo3, bo5, inf}
enum LOBBY_ROTATION{win, lose, none}
enum LOBBY_OPEN{invite, friends, public}
enum P_TYPE{menu_lobby_owner, menu_lobby_joiner, lobby_init, lobby_ready, lobby_ready_start, lobby_ready_reset, lobby_start, lobby_return, timer_timeout_start, timer_timeout_stop, timer_player1_ready_start, timer_player1_ready_stop, timer_player2_ready_start, timer_player2_ready_stop, cs_highlight, cs_select, cs_back, cs_palette, cs_select_palette, cs_confirmed_player1, cs_confirmed_player2, ss_highlight, ss_select, ss_confirmed, game_input, game_menu, game_ping}

const VERSION = "v2.3.10"

const CONFIG_FILE = "user://config.cfg"
const PALETTE_FILE = "user://palette.cfg"
const CFG_P1S = "player1_setting"
const CFG_P2S = "player2_setting"
const CFG_PS_DTDASH = "dtdash"
const CFG_OPTIONS = "options"
const CFG_OPTIONS_CPUDIFF = "cpu_diff"
const CFG_OPTIONS_SCREEN = "screen_type"
const CFG_OPTIONS_VSYNC = "vsync"
const CFG_OPTIONS_MUSVOL = "music_volume"
const CFG_OPTIONS_SFXVOL = "sfx_volume"
const CFG_UNLOCK = "unlock"
const CFG_UNLOCK_COLOR4_GOTO = "color4_goto"
const CFG_UNLOCK_COLOR4_YOYO = "color4_yoyo"
const CFG_UNLOCK_COLOR4_KERO = "color4_kero"
const CFG_UNLOCK_COLOR4_TIME = "color4_time"
const CFG_UNLOCK_COLOR4_SWORD = "color4_sword"
const CFG_UNLOCK_COLOR4_DARKGOTO = "color4_darkgoto"
const CFG_UNLOCK_CHAR_DARKGOTO = "char_darkgoto"
const CFG_UNLOCK_STAGE_BLACKHOLE = "stage_blackhole"
const CFG_RECORD = "record"
const CFG_RECORD_ARCADE_GOTO = "arcade_goto"
const CFG_RECORD_ARCADE_YOYO = "arcade_yoyo"
const CFG_RECORD_ARCADE_KERO = "arcade_kero"
const CFG_RECORD_ARCADE_TIME = "arcade_time"
const CFG_RECORD_ARCADE_SWORD = "arcade_sword"
const CFG_RECORD_ARCADE_DARKGOTO = "arcade_darkgoto"
const PAL_OPTIONS = "options"
const PAL_OPTIONS_ENABLED = "enabled"
const PAL_OPTIONS_NUM = "num"
const PAL_CUSTOM = "custom"
const PAL_CUSTOM_GOTO = "goto"
const PAL_CUSTOM_YOYO = "yoyo"
const PAL_CUSTOM_KERO = "kero"
const PAL_CUSTOM_TIME = "time"
const PAL_CUSTOM_SWORD = "sword"
const PAL_CUSTOM_DARKGOTO = "darkgoto"

const INPUT_MAP = ["left", "right", "up", "down", "attack", "special", "super", "dash", "start"]

const LOBBY_VERSION = "LOBBY_VERSION"
const LOBBY_NAME = "LOBBY_NAME"
const LOBBY_KEYWORD = "LOBBY_KEYWORD"
const LOBBY_REMATCH_STYLE = "LOBBY_REMATCH_STYLE"
const LOBBY_ROTATION_STYLE = "LOBBY_ROTATION_STYLE"
const LOBBY_MATCH_LIMIT = "LOBBY_MATCH_LIMIT"
const LOBBY_DELAY = "LOBBY_DELAY"
const LOBBY_STAGE_SELECT = "LOBBY_STAGE_SELECT"
const LOBBY_STAGE = "LOBBY_STAGE"
const LOBBY_CHAT = "LOBBY_CHAT"
const LOBBY_PLAYER_ID = "LOBBY_PLAYER_ID"
const LOBBY_PLAYER_READY = "LOBBY_PLAYER_READY"
const MEMBER_LOBBY_DTDASH = "LOBBY_DTDASH"
const MEMBER_LOBBY_WINS = "LOBBY_WINS"
const MEMBER_LOBBY_MATCHES = "LOBBY_MATCHES"
const MEMBER_LOBBY_SKIP = "LOBBY_SKIP"
const MEMBER_LOBBY_CONSEC_MATCHES = "LOBBY_CONSEC_MATCHES"

const LOBBY_MSG_SEP_CHAR = "$"
const LOBBY_MSG_TIMEOUT = "timeout"
const LOBBY_MSG_CHAT = "chat"

onready  var debug_text = preload("res://scenes/debug_text.tscn")

var window_size = Vector2(1024, 600)
var viewport_size = Vector2(256, 150)

var fps = 60
var floor_y = 59
var vsync = true
var beta = false
var save_inputs = false
var debug_mode = false
var debug_texts = false
var infinite_rounds = false
var auto_rematch = false
var print_round_end_frame = false
var print_texts = false
var steam_enabled = false
var html5_ver = false
var custom_palettes_enabled = false

var online = false
var steam_id = 0
var lobby_join = false
var lobby_found = false
var lobby_chat = true
var lobby_rotate = LOBBY_ROTATE.none
var lobby_state = LOBBY_STATE.spectate
var lobby_player1_wins = 0
var lobby_player2_wins = 0
var lobby_chat_msg = ""
var curr_lobby_id = 0
var host_member_id = 0
var other_member_id = 0
var spectator_member_ids = []
var lobby_member_ids = []
var lobby_member_ready = [LOBBY_READY.not_ready, LOBBY_READY.not_ready]
var find_keyword = ""
var find_page = 1
var find_max_page = 1
var host_name = ""
var host_keyword = ""
var host_max_players = 8
var host_rematch = LOBBY_REMATCH.none
var host_rotation = LOBBY_ROTATION.win
var host_match_limit = 0
var host_delay = 0
var host_stage_select = STAGE_SELECT.random
var host_open = LOBBY_OPEN.public
var host_chat = true
var host_page = 1
var host_max_page = 4
var input_delay = 0
var prev_input_delay = 0
var stage_select = STAGE_SELECT.random

var menu_init = false
var menu_option = 1
var player1_char = CHAR.goto
var player1_palette = - 1
var player1_cpu = false
var player1_dtdash = true
var player2_char = CHAR.goto
var player2_palette = 0
var player2_cpu = false
var player2_dtdash = true
var stage = STAGE.dojo
var mode = MODE.versus_player
var online_char = CHAR.goto
var online_palette = - 1
var online_stage = STAGE.dojo
var arcade_stage = 0
var arcade_continues = 0
var arcade_time = 0
var max_arcade_stage = 5
var cpu_diff = CPU_DIFF.normal
var music_volume = 8
var music_volume_db = 0
var sfx_volume = 9
var sfx_volume_db = 0
var screen_type = SCREEN.window4x

var unlock_color4_goto = false
var unlock_color4_yoyo = false
var unlock_color4_kero = false
var unlock_color4_time = false
var unlock_color4_sword = false
var unlock_color4_darkgoto = false
var unlock_char_darkgoto = false
var unlock_stage_blackhole = false

var record_arcade_goto = - 1
var record_arcade_yoyo = - 1
var record_arcade_kero = - 1
var record_arcade_time = - 1
var record_arcade_sword = - 1
var record_arcade_darkgoto = - 1

var num_custom_palettes = 3
var palette_default_goto = ["000000", "65b7d5", "2d4f7b", "912323", "551515", "191533", "05040d", "2f2116", "150e07"]
var palette_default_yoyo = ["cc6c40", "ae4b31", "94ead3", "58c2c8", "7baad5", "697abb", "ea94d3", "e079e6", "e0fff7"]
var palette_default_kero = ["56bb27", "33621d", "d02a16", "cbd51e", "ffffff", "b3b3b3", "484848", "dce17b", "85d561"]
var palette_default_time = ["c33929", "b32616", "594442", "402d2b", "ffd700", "fbe8b4", "eebd86"]
var palette_default_sword = ["eaeaea", "c8c8c8", "0d0d0d", "000000", "043318", "021904", "f2ba7b", "ee9e64"]
var palette_default_darkgoto = ["130b26", "020508", "718471", "42513e", "2f2116", "150e07", "912323", "551515", "ffffff"]
var palette_custom_goto = []
var palette_custom_yoyo = []
var palette_custom_kero = []
var palette_custom_time = []
var palette_custom_sword = []
var palette_custom_darkgoto = []

var arcade_chars = []

func create_debug_text(text):
	if debug_texts:
		create_text(text)

func create_info_text(text):
	create_text(text)

func create_text(text):
	var highest_y = 145
	var debug_texts = get_tree().get_nodes_in_group("debug")
	for t in debug_texts:
		if t.get_position().y < highest_y:
			highest_y = t.get_position().y
	
	var t = debug_text.instance()
	get_parent().add_child(t)
	t.set_position(Vector2(4, highest_y - 10))
	t.set_text(text)
	
	if print_texts:
		print(text)

func load_config():
	if steam_enabled:
		var init = Steam.steamInit()
		if not init:
			print("Failed to init Steam, quitting game")
			get_tree().quit()
		else :
			Steam.connect("join_requested", self, "join_requested")
			Steam.connect("lobby_created", self, "lobby_created")
			Steam.connect("lobby_joined", self, "lobby_joined")
			Steam.connect("lobby_chat_update", self, "lobby_chat_update")
			Steam.connect("lobby_data_update", self, "lobby_data_update")
			Steam.connect("lobby_message", self, "lobby_message")
			Steam.connect("p2p_session_request", self, "p2p_session_request")
			Steam.connect("p2p_session_connect_fail", self, "p2p_session_connect_fail")
			steam_id = Steam.getSteamID()
			host_name = (Steam.getPersonaName() + "'s lobby").substr(0, 24)
	
	var config = ConfigFile.new()
	config.load(CONFIG_FILE)
	
	cpu_diff = get_config_value(config, CFG_OPTIONS, CFG_OPTIONS_CPUDIFF, cpu_diff)
	screen_type = get_config_value(config, CFG_OPTIONS, CFG_OPTIONS_SCREEN, screen_type)
	vsync = get_config_value(config, CFG_OPTIONS, CFG_OPTIONS_VSYNC, vsync)
	if html5_ver:
		music_volume = get_config_value(config, CFG_OPTIONS, CFG_OPTIONS_MUSVOL, 0)
		sfx_volume = get_config_value(config, CFG_OPTIONS, CFG_OPTIONS_SFXVOL, 0)
		unlock_color4_goto = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_COLOR4_GOTO, true)
		unlock_color4_yoyo = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_COLOR4_YOYO, true)
		unlock_color4_kero = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_COLOR4_KERO, true)
		unlock_color4_time = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_COLOR4_TIME, true)
		unlock_color4_sword = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_COLOR4_SWORD, true)
		unlock_color4_darkgoto = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_COLOR4_DARKGOTO, true)
		unlock_char_darkgoto = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_CHAR_DARKGOTO, true)
		unlock_stage_blackhole = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_STAGE_BLACKHOLE, true)
	else :
		music_volume = get_config_value(config, CFG_OPTIONS, CFG_OPTIONS_MUSVOL, music_volume)
		sfx_volume = get_config_value(config, CFG_OPTIONS, CFG_OPTIONS_SFXVOL, sfx_volume)
		unlock_color4_goto = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_COLOR4_GOTO, unlock_color4_goto)
		unlock_color4_yoyo = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_COLOR4_YOYO, unlock_color4_yoyo)
		unlock_color4_kero = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_COLOR4_KERO, unlock_color4_kero)
		unlock_color4_time = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_COLOR4_TIME, unlock_color4_time)
		unlock_color4_sword = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_COLOR4_SWORD, unlock_color4_sword)
		unlock_color4_darkgoto = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_COLOR4_DARKGOTO, unlock_color4_darkgoto)
		unlock_char_darkgoto = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_CHAR_DARKGOTO, unlock_char_darkgoto)
		unlock_stage_blackhole = get_config_value(config, CFG_UNLOCK, CFG_UNLOCK_STAGE_BLACKHOLE, unlock_stage_blackhole)
	record_arcade_goto = get_config_value(config, CFG_RECORD, CFG_RECORD_ARCADE_GOTO, record_arcade_goto)
	record_arcade_yoyo = get_config_value(config, CFG_RECORD, CFG_RECORD_ARCADE_YOYO, record_arcade_yoyo)
	record_arcade_kero = get_config_value(config, CFG_RECORD, CFG_RECORD_ARCADE_KERO, record_arcade_kero)
	record_arcade_time = get_config_value(config, CFG_RECORD, CFG_RECORD_ARCADE_TIME, record_arcade_time)
	record_arcade_sword = get_config_value(config, CFG_RECORD, CFG_RECORD_ARCADE_SWORD, record_arcade_sword)
	record_arcade_darkgoto = get_config_value(config, CFG_RECORD, CFG_RECORD_ARCADE_DARKGOTO, record_arcade_darkgoto)
	config.save(CONFIG_FILE)
	load_input(config)
	
	set_music_volume()
	set_sfx_volume()
	set_screen_type()
	set_vsync()
	
	config = ConfigFile.new()
	config.load(PALETTE_FILE)
	
	custom_palettes_enabled = get_config_value(config, PAL_OPTIONS, PAL_OPTIONS_ENABLED, custom_palettes_enabled)
	num_custom_palettes = get_config_value(config, PAL_OPTIONS, PAL_OPTIONS_NUM, num_custom_palettes)
	palette_custom_goto.resize(num_custom_palettes)
	palette_custom_yoyo.resize(num_custom_palettes)
	palette_custom_kero.resize(num_custom_palettes)
	palette_custom_time.resize(num_custom_palettes)
	palette_custom_sword.resize(num_custom_palettes)
	palette_custom_darkgoto.resize(num_custom_palettes)
	for i in range(num_custom_palettes):
		var palette_num = i + 1
		palette_custom_goto[i] = get_config_value(config, PAL_CUSTOM + str(palette_num), PAL_CUSTOM_GOTO, palette_default_goto)
		palette_custom_yoyo[i] = get_config_value(config, PAL_CUSTOM + str(palette_num), PAL_CUSTOM_YOYO, palette_default_yoyo)
		palette_custom_kero[i] = get_config_value(config, PAL_CUSTOM + str(palette_num), PAL_CUSTOM_KERO, palette_default_kero)
		palette_custom_time[i] = get_config_value(config, PAL_CUSTOM + str(palette_num), PAL_CUSTOM_TIME, palette_default_time)
		palette_custom_sword[i] = get_config_value(config, PAL_CUSTOM + str(palette_num), PAL_CUSTOM_SWORD, palette_default_sword)
		palette_custom_darkgoto[i] = get_config_value(config, PAL_CUSTOM + str(palette_num), PAL_CUSTOM_DARKGOTO, palette_default_darkgoto)
	config.save(PALETTE_FILE)

func load_input(config):
	for i in range(6):
		var prefix = "player1_"
		var suffix = "key"
		var type = INPUT_TYPE.key
		match i:
			1:
				suffix = "pad"
				type = INPUT_TYPE.pad
			2:
				suffix = "stick"
				type = INPUT_TYPE.stick
			3:
				prefix = "player2_"
				suffix = "key"
			4:
				prefix = "player2_"
				suffix = "pad"
				type = INPUT_TYPE.pad
			5:
				prefix = "player2_"
				suffix = "stick"
				type = INPUT_TYPE.stick
		if config.has_section(prefix + suffix):
			for input in config.get_section_keys(prefix + suffix):
				var event
				match type:
					INPUT_TYPE.key:
						event = InputEventKey.new()
						event.scancode = OS.find_scancode_from_string(config.get_value(prefix + suffix, input))
					INPUT_TYPE.pad:
						event = InputEventJoypadButton.new()
						var input_str = config.get_value(prefix + suffix, input)
						var split = input_str.find(",")
						event.device = int(input_str.left(split))
						event.button_index = int(input_str.right(split + 1))
					INPUT_TYPE.stick:
						event = InputEventJoypadMotion.new()
						var input_str = config.get_value(prefix + suffix, input)
						var split = input_str.find(",")
						event.device = int(input_str.left(split))
						input_str = input_str.right(split + 1)
						split = input_str.find(",")
						event.axis = int(input_str.left(split))
						event.axis_value = int(input_str.right(split + 1))
				for old_event in InputMap.get_action_list(prefix + input):
					match type:
						INPUT_TYPE.key:
							if old_event is InputEventKey:
								InputMap.action_erase_event(prefix + input, old_event)
						INPUT_TYPE.pad:
							if old_event is InputEventJoypadButton:
								InputMap.action_erase_event(prefix + input, old_event)
						INPUT_TYPE.stick:
							if old_event is InputEventJoypadMotion:
								InputMap.action_erase_event(prefix + input, old_event)
				InputMap.action_add_event(prefix + input, event)
		else :
			set_input_default_p1()
			set_input_default_p2()
	
	player1_dtdash = config.get_value(CFG_P1S, CFG_PS_DTDASH, true)
	player2_dtdash = config.get_value(CFG_P2S, CFG_PS_DTDASH, true)

func save_config_value(section, key, value):
	var config = ConfigFile.new()
	config.load(CONFIG_FILE)
	config.set_value(section, key, value)
	config.save(CONFIG_FILE)

func get_config_value(config, section, key, value):
	if not config.has_section(section) or not config.has_section_key(section, key):
		config.set_value(section, key, value)
		return value
	return config.get_value(section, key, value)

func set_cpu_diff():
	save_config_value(CFG_OPTIONS, CFG_OPTIONS_CPUDIFF, cpu_diff)

func set_music_volume():
	if music_volume > 0:
		music_volume_db = - 4 * (10 - music_volume)
	else :
		music_volume_db = - 100
	global_audio.volume_db = music_volume_db
	save_config_value(CFG_OPTIONS, CFG_OPTIONS_MUSVOL, music_volume)

func set_sfx_volume():
	if sfx_volume > 0:
		sfx_volume_db = - 4 * (10 - sfx_volume)
	else :
		sfx_volume_db = - 100
	save_config_value(CFG_OPTIONS, CFG_OPTIONS_SFXVOL, sfx_volume)

func set_screen_type():
	OS.window_fullscreen = (screen_type == SCREEN.full)
	match screen_type:
		SCREEN.window:
			window_size = viewport_size
		SCREEN.window2x:
			window_size = viewport_size * 2
		SCREEN.window3x:
			window_size = viewport_size * 3
		SCREEN.window4x:
			window_size = viewport_size * 4
	if screen_type != SCREEN.full:
		OS.set_window_size(window_size)
	save_config_value(CFG_OPTIONS, CFG_OPTIONS_SCREEN, screen_type)

func set_vsync():
	OS.set_use_vsync(vsync)
	save_config_value(CFG_OPTIONS, CFG_OPTIONS_VSYNC, vsync)

func set_input(player1, event, input):
	var input_valid = true
	var prefixes = ["player1_", "player2_"]
	var prefix = "player1_"
	var suffix = "key"
	var input_str
	if not player1:
		prefix = "player2_"
	if event is InputEventJoypadMotion:
		suffix = "stick"
		input_str = str(event.device) + "," + str(event.axis) + "," + str(event.axis_value)
		var swap_event = null
		for old_event in InputMap.get_action_list(prefix + input):
			if old_event is InputEventJoypadMotion:
				InputMap.action_erase_event(prefix + input, old_event)
				swap_event = old_event
		for other_input in INPUT_MAP:
			var input_found = false
			for other_prefix in prefixes:
				if other_prefix == prefix and other_input == input:
					continue
				for other_event in InputMap.get_action_list(other_prefix + other_input):
					if other_event is InputEventJoypadMotion and other_event.device == event.device and other_event.axis == event.axis and other_event.axis_value == event.axis_value:
						InputMap.action_erase_event(other_prefix + other_input, other_event)
						if swap_event != null:
							InputMap.action_add_event(other_prefix + other_input, swap_event)
							var swap_input_str = str(swap_event.device) + "," + str(swap_event.axis) + "," + str(swap_event.axis_value)
							save_config_value(other_prefix + suffix, other_input, swap_input_str)
						input_found = true
						break
				if input_found:
					break
			if input_found:
				break
	elif event is InputEventJoypadButton:
		suffix = "pad"
		input_str = str(event.device) + "," + str(event.button_index)
		var swap_event = null
		for old_event in InputMap.get_action_list(prefix + input):
			if old_event is InputEventJoypadButton:
				InputMap.action_erase_event(prefix + input, old_event)
				swap_event = old_event
		for other_input in INPUT_MAP:
			var input_found = false
			for other_prefix in prefixes:
				if other_prefix == prefix and other_input == input:
					continue
				for other_event in InputMap.get_action_list(other_prefix + other_input):
					if other_event is InputEventJoypadButton and other_event.device == event.device and other_event.button_index == event.button_index:
						InputMap.action_erase_event(other_prefix + other_input, other_event)
						if swap_event != null:
							InputMap.action_add_event(other_prefix + other_input, swap_event)
							var swap_input_str = str(swap_event.device) + "," + str(swap_event.button_index)
							save_config_value(other_prefix + suffix, other_input, swap_input_str)
						input_found = true
						break
				if input_found:
					break
			if input_found:
				break
	elif event is InputEventKey:
		input_str = OS.get_scancode_string(event.scancode)
		var swap_event = null
		for old_event in InputMap.get_action_list(prefix + input):
			if old_event is InputEventKey:
				InputMap.action_erase_event(prefix + input, old_event)
				swap_event = old_event
		for other_input in INPUT_MAP:
			var input_found = false
			for other_prefix in prefixes:
				if other_prefix == prefix and other_input == input:
					continue
				for other_event in InputMap.get_action_list(other_prefix + other_input):
					if other_event is InputEventKey and other_event.scancode == event.scancode:
						InputMap.action_erase_event(other_prefix + other_input, other_event)
						if swap_event != null:
							InputMap.action_add_event(other_prefix + other_input, swap_event)
							var swap_input_str = OS.get_scancode_string(swap_event.scancode)
							save_config_value(other_prefix + suffix, other_input, swap_input_str)
						input_found = true
						break
				if input_found:
					break
			if input_found:
				break
	else :
		input_valid = false
	if input_valid:
		InputMap.action_add_event(prefix + input, event)
		save_config_value(prefix + suffix, input, input_str)

func set_input_from_scancode(player1, scancode, input):
	var event = InputEventKey.new()
	event.scancode = scancode
	set_input(player1, event, input)

func set_input_from_button(player1, device, button_index, input):
	var event = InputEventJoypadButton.new()
	event.device = device
	event.button_index = button_index
	set_input(player1, event, input)

func set_input_from_axis(player1, device, axis, axis_value, input):
	var event = InputEventJoypadMotion.new()
	event.device = device
	event.axis = axis
	event.axis_value = axis_value
	set_input(player1, event, input)

func erase_axis_inputs(player1):
	var prefix = "player1_"
	if not player1:
		prefix = "player2_"
	for input in INPUT_MAP:
		for old_event in InputMap.get_action_list(prefix + input):
			if old_event is InputEventJoypadMotion:
				InputMap.action_erase_event(prefix + input, old_event)
	var config = ConfigFile.new()
	config.load(CONFIG_FILE)
	config.erase_section(prefix + "stick")
	config.save(CONFIG_FILE)

func set_input_default_p1():
	set_input_from_scancode(true, OS.find_scancode_from_string("A"), "left")
	set_input_from_scancode(true, OS.find_scancode_from_string("D"), "right")
	set_input_from_scancode(true, OS.find_scancode_from_string("W"), "up")
	set_input_from_scancode(true, OS.find_scancode_from_string("S"), "down")
	set_input_from_scancode(true, OS.find_scancode_from_string("G"), "attack")
	set_input_from_scancode(true, OS.find_scancode_from_string("H"), "special")
	set_input_from_scancode(true, OS.find_scancode_from_string("J"), "super")
	set_input_from_scancode(true, OS.find_scancode_from_string("K"), "dash")
	set_input_from_scancode(true, OS.find_scancode_from_string("Enter"), "start")
	
	set_input_from_button(true, 0, 14, "left")
	set_input_from_button(true, 0, 15, "right")
	set_input_from_button(true, 0, 12, "up")
	set_input_from_button(true, 0, 13, "down")
	set_input_from_button(true, 0, 0, "attack")
	set_input_from_button(true, 0, 1, "special")
	set_input_from_button(true, 0, 2, "super")
	set_input_from_button(true, 0, 7, "dash")
	set_input_from_button(true, 0, 11, "start")
	
	
	set_input_from_axis(true, 0, 0, - 1, "left")
	set_input_from_axis(true, 0, 0, 1, "right")
	set_input_from_axis(true, 0, 1, - 1, "up")
	set_input_from_axis(true, 0, 1, 1, "down")
	
	player1_dtdash = true
	save_config_value(CFG_P1S, CFG_PS_DTDASH, true)

func set_input_default_p2():
	set_input_from_scancode(false, OS.find_scancode_from_string("Left"), "left")
	set_input_from_scancode(false, OS.find_scancode_from_string("Right"), "right")
	set_input_from_scancode(false, OS.find_scancode_from_string("Up"), "up")
	set_input_from_scancode(false, OS.find_scancode_from_string("Down"), "down")
	set_input_from_scancode(false, OS.find_scancode_from_string("End"), "attack")
	set_input_from_scancode(false, OS.find_scancode_from_string("PageDown"), "special")
	set_input_from_scancode(false, OS.find_scancode_from_string("Delete"), "super")
	set_input_from_scancode(false, OS.find_scancode_from_string("Insert"), "dash")
	set_input_from_scancode(false, OS.find_scancode_from_string("Kp Enter"), "start")
	
	set_input_from_button(false, 1, 14, "left")
	set_input_from_button(false, 1, 15, "right")
	set_input_from_button(false, 1, 12, "up")
	set_input_from_button(false, 1, 13, "down")
	set_input_from_button(false, 1, 0, "attack")
	set_input_from_button(false, 1, 1, "special")
	set_input_from_button(false, 1, 2, "super")
	set_input_from_button(false, 1, 7, "dash")
	set_input_from_button(false, 1, 11, "start")
	
	
	set_input_from_axis(false, 1, 0, - 1, "left")
	set_input_from_axis(false, 1, 0, 1, "right")
	set_input_from_axis(false, 1, 1, - 1, "up")
	set_input_from_axis(false, 1, 1, 1, "down")
	
	player2_dtdash = true
	save_config_value(CFG_P2S, CFG_PS_DTDASH, true)

func save_unlocks():
	var config = ConfigFile.new()
	config.load(CONFIG_FILE)
	config.set_value(CFG_UNLOCK, CFG_UNLOCK_COLOR4_GOTO, unlock_color4_goto)
	config.set_value(CFG_UNLOCK, CFG_UNLOCK_COLOR4_YOYO, unlock_color4_yoyo)
	config.set_value(CFG_UNLOCK, CFG_UNLOCK_COLOR4_KERO, unlock_color4_kero)
	config.set_value(CFG_UNLOCK, CFG_UNLOCK_COLOR4_TIME, unlock_color4_time)
	config.set_value(CFG_UNLOCK, CFG_UNLOCK_COLOR4_SWORD, unlock_color4_sword)
	config.set_value(CFG_UNLOCK, CFG_UNLOCK_COLOR4_DARKGOTO, unlock_color4_darkgoto)
	config.set_value(CFG_UNLOCK, CFG_UNLOCK_CHAR_DARKGOTO, unlock_char_darkgoto)
	config.set_value(CFG_UNLOCK, CFG_UNLOCK_STAGE_BLACKHOLE, unlock_stage_blackhole)
	config.save(CONFIG_FILE)

func save_records():
	var config = ConfigFile.new()
	config.load(CONFIG_FILE)
	config.set_value(CFG_RECORD, CFG_RECORD_ARCADE_GOTO, record_arcade_goto)
	config.set_value(CFG_RECORD, CFG_RECORD_ARCADE_YOYO, record_arcade_yoyo)
	config.set_value(CFG_RECORD, CFG_RECORD_ARCADE_KERO, record_arcade_kero)
	config.set_value(CFG_RECORD, CFG_RECORD_ARCADE_TIME, record_arcade_time)
	config.set_value(CFG_RECORD, CFG_RECORD_ARCADE_SWORD, record_arcade_sword)
	config.set_value(CFG_RECORD, CFG_RECORD_ARCADE_DARKGOTO, record_arcade_darkgoto)
	config.save(CONFIG_FILE)

func get_color_array_from_string_array(str_array):
	var color_array = []
	for i in range(str_array.size()):
		color_array.append(Color(str_array[i]))
	return color_array

func get_char_palette(char_name, palette_num):
	var max_default_num = get_char_max_palette(char_name)
	var p = palette_num - max_default_num - 1
	if custom_palettes_enabled:
		max_default_num -= num_custom_palettes
	match char_name:
		CHAR.goto:
			match palette_num:
				- 1:
					return get_color_array_from_string_array(palette_default_goto)
				0:
					return [Color("1c0b00"), Color("cf9942"), Color("874a29"), Color("26a684"), Color("124d48"), Color("1b6b15"), Color("093813"), Color("0f2b2e"), Color("09151a")]
				1:
					return [Color("290b0b"), Color("e388b4"), Color("914369"), Color("21b833"), Color("226329"), Color("962121"), Color("5c1f19"), Color("7d4622"), Color("40210d")]
				_:
					if palette_num == max_default_num:
						return [Color("000000"), Color("d7e7f7"), Color("8396a3"), Color("ff80aa"), Color("ba344f"), Color("b39779"), Color("63472e"), Color("421b0d"), Color("210c05")]
					else :
						return get_color_array_from_string_array(palette_custom_goto[p])
		CHAR.yoyo:
			match palette_num:
				- 1:
					return get_color_array_from_string_array(palette_default_yoyo)
				0:
					return [Color("333333"), Color("1a1a1a"), Color("9f95e5"), Color("7958c7"), Color("999999"), Color("737373"), Color("cc845e"), Color("de6304"), Color("e0fff7")]
				1:
					return [Color("fff28c"), Color("dbbf1f"), Color("f54949"), Color("e60000"), Color("f0f0f0"), Color("d9d9d9"), Color("c47695"), Color("eb75a4"), Color("ff8c8c")]
				_:
					if palette_num == max_default_num:
						return [Color("bd7d1e"), Color("945b25"), Color("403a3a"), Color("332b2b"), Color("7399de"), Color("4277c7"), Color("faff70"), Color("f26b6b"), Color("666161")]
					else :
						return get_color_array_from_string_array(palette_custom_yoyo[p])
		CHAR.kero:
			match palette_num:
				- 1:
					return get_color_array_from_string_array(palette_default_kero)
				0:
					return [Color("a8291b"), Color("660500"), Color("068f81"), Color("86ebdf"), Color("000000"), Color("bfb600"), Color("6b5206"), Color("e8a184"), Color("e66722")]
				1:
					return [Color("a8934d"), Color("5e5115"), Color("00d13f"), Color("affa8e"), Color("abffff"), Color("4bcbf2"), Color("3e9bc9"), Color("c4c382"), Color("fbffa8")]
				_:
					if palette_num == max_default_num:
						return [Color("4667eb"), Color("2e3e8f"), Color("ff2942"), Color("cbffc7"), Color("f556e0"), Color("f00088"), Color("d41176"), Color("399ef7"), Color("40ff96")]
					else :
						return get_color_array_from_string_array(palette_custom_kero[p])
		CHAR.time:
			match palette_num:
				- 1:
					return get_color_array_from_string_array(palette_default_time)
				0:
					return [Color("d1c515"), Color("bd9100"), Color("20076e"), Color("0a0029"), Color("31b07f"), Color("fbe8b4"), Color("eebd86")]
				1:
					return [Color("e36a00"), Color("bd4b13"), Color("fafafa"), Color("b8b8b8"), Color("8fa5ff"), Color("fbe8b4"), Color("eebd86")]
				_:
					if palette_num == max_default_num:
						return [Color("88ff00"), Color("47c234"), Color("f02929"), Color("b81414"), Color("ffffff"), Color("fbe8b4"), Color("eebd86")]
					else :
						return get_color_array_from_string_array(palette_custom_time[p])
		CHAR.sword:
			match palette_num:
				- 1:
					return get_color_array_from_string_array(palette_default_sword)
				0:
					return [Color("2b2932"), Color("14131a"), Color("5d5c5e"), Color("4b4552"), Color("ebeaca"), Color("d1d1b0"), Color("f2ba7b"), Color("ee9e64")]
				1:
					return [Color("0f4b75"), Color("002843"), Color("1d1c1b"), Color("0d0c0a"), Color("dae4ea"), Color("bec5c9"), Color("f2ba7b"), Color("ee9e64")]
				_:
					if palette_num == max_default_num:
						return [Color("e3c100"), Color("c49700"), Color("d9d9d9"), Color("b3b3b3"), Color("262626"), Color("1a1a1a"), Color("f2ba7b"), Color("ee9e64")]
					else :
						return get_color_array_from_string_array(palette_custom_sword[p])
		CHAR.darkgoto:
			match palette_num:
				- 1:
					return get_color_array_from_string_array(palette_default_darkgoto)
				0:
					return [Color("f0d526"), Color("826a33"), Color("9c7149"), Color("5e3f23"), Color("664c49"), Color("452a27"), Color("73ff00"), Color("33ad11"), Color("fbffcc")]
				1:
					return [Color("00ff88"), Color("16a85d"), Color("fffeeb"), Color("c2c0a1"), Color("868b9e"), Color("3f434f"), Color("ff4f7b"), Color("a81638"), Color("ffffff")]
				_:
					if palette_num == max_default_num:
						return [Color("ff7700"), Color("a14b00"), Color("404040"), Color("262626"), Color("826835"), Color("59491f"), Color("a22fcc"), Color("591d78"), Color("ebccff")]
					else :
						return get_color_array_from_string_array(palette_custom_darkgoto[p])
	return null

func get_char_max_palette(char_name):
	var palette_count = - 1
	match char_name:
		CHAR.goto:
			if unlock_color4_goto:
				palette_count += 3
			else :
				palette_count += 2
		CHAR.yoyo:
			if unlock_color4_yoyo:
				palette_count += 3
			else :
				palette_count += 2
		CHAR.kero:
			if unlock_color4_kero:
				palette_count += 3
			else :
				palette_count += 2
		CHAR.time:
			if unlock_color4_time:
				palette_count += 3
			else :
				palette_count += 2
		CHAR.sword:
			if unlock_color4_sword:
				palette_count += 3
			else :
				palette_count += 2
		CHAR.darkgoto:
			if unlock_color4_darkgoto:
				palette_count += 3
			else :
				palette_count += 2
	if custom_palettes_enabled and char_name != CHAR.random:
		palette_count += num_custom_palettes
	return palette_count

func get_char_debug_name(char_name):
	match char_name:
		CHAR.goto:
			return "goto"
		CHAR.yoyo:
			return "yoyo"
		CHAR.kero:
			return "kero"
		CHAR.time:
			return "time"
		CHAR.sword:
			return "sword"
		CHAR.darkgoto:
			return "darkgoto"
		CHAR.locked:
			return "locked"
		CHAR.random:
			return "random"
	return "goto"

func get_char_real_name(char_name):
	match char_name:
		CHAR.goto:
			return "Shoto Goto"
		CHAR.yoyo:
			return "Yo-Yona"
		CHAR.kero:
			return "Dr. Kero"
		CHAR.time:
			return "Don McRon"
		CHAR.sword:
			return "Vince Volt"
		CHAR.darkgoto:
			return "Dark Goto"
		CHAR.locked:
			return "???"
		CHAR.random:
			return "RANDOM"
	return "Shoto Goto"

func get_char_stage(char_name):
	match char_name:
		CHAR.goto:
			return STAGE.dojo
		CHAR.yoyo:
			return STAGE.rooftop
		CHAR.kero:
			return STAGE.lab
		CHAR.time:
			return STAGE.company
		CHAR.sword:
			return STAGE.bridge
		CHAR.darkgoto:
			return STAGE.blackhole
	return STAGE.dojo

func get_stage_debug_name(stage_name):
	match stage_name:
		STAGE.dojo:
			return "dojo"
		STAGE.rooftop:
			return "rooftop"
		STAGE.lab:
			return "lab"
		STAGE.company:
			return "company"
		STAGE.bridge:
			return "bridge"
		STAGE.blackhole:
			return "blackhole"
		STAGE.training:
			return "training"
		STAGE.locked:
			return "locked"
		STAGE.random:
			return "random"
	return "dojo"

func get_stage_real_name(stage_name):
	match stage_name:
		STAGE.dojo:
			return "Afternoon Dojo"
		STAGE.rooftop:
			return "School Rooftop"
		STAGE.lab:
			return "Underground Lab"
		STAGE.company:
			return "DonCorp"
		STAGE.bridge:
			return "Sunset Bridge"
		STAGE.blackhole:
			return "The Singularity"
		STAGE.training:
			return "Training (Beta)"
		STAGE.locked:
			return "???"
		STAGE.random:
			return "RANDOM"
	return "Afternoon Dojo"

func get_curr_char(player_num):
	if player_num == 1:
		return player1_char
	else :
		return player2_char

func get_random_char():
	var chars = [CHAR.goto, CHAR.yoyo, CHAR.kero, CHAR.time, CHAR.sword]
	if unlock_char_darkgoto:
		chars.append(CHAR.darkgoto)
	var r = randi() % chars.size()
	return chars[r]

func get_random_stage():
	var stages = [STAGE.dojo, STAGE.rooftop, STAGE.lab, STAGE.company, STAGE.bridge]
	if unlock_stage_blackhole:
		stages.append(STAGE.blackhole)
	var r = randi() % stages.size()
	return stages[r]

func get_random_palette(char_name):
	var palettes = get_char_max_palette(char_name) + 2
	var r = randi() % palettes - 1
	return r

func set_char(char_name, palette_num, player_num):
	if palette_num > get_char_max_palette(char_name):
		palette_num = - 1
	if player_num == 1:
		if char_name == CHAR.random:
			player1_char = get_random_char()
			player1_palette = get_random_palette(player1_char)
		else :
			player1_char = char_name
			player1_palette = palette_num
	else :
		if char_name == CHAR.random:
			player2_char = get_random_char()
			player2_palette = get_random_palette(player2_char)
		else :
			player2_char = char_name
			player2_palette = palette_num

func set_stage(stage_name):
	if stage_name == STAGE.random:
		stage = get_random_stage()
	else :
		stage = stage_name

func set_palette(palette_num, player_num):
	if player_num == 1:
		if palette_num > get_char_max_palette(player1_char):
			palette_num = - 1
		player1_palette = palette_num
	else :
		if palette_num > get_char_max_palette(player2_char):
			palette_num = - 1
		player2_palette = palette_num

func differ_palettes():
	if player1_char == player2_char and player1_palette == player2_palette:
		if player1_palette == - 1:
			player2_palette = 0
		else :
			player2_palette = - 1

func init_p1_vs_p2():
	mode = MODE.versus_player
	online = false
	player1_cpu = false
	player2_cpu = false

func init_p1_vs_cpu():
	mode = MODE.versus_cpu
	online = false
	player1_cpu = false
	player2_cpu = true

func init_cpu_vs_cpu():
	mode = MODE.versus_cpu
	online = false
	player1_cpu = true
	player2_cpu = true

func init_online_lobby():
	mode = MODE.online_lobby
	online = true
	if debug_mode:
		player1_cpu = true
		player2_cpu = true
	else :
		player1_cpu = false
		player2_cpu = false
	lobby_join = false
	curr_lobby_id = 0
	stage = STAGE.dojo

func init_online_quickmatch(join):
	mode = MODE.online_quickmatch
	online = true
	player1_cpu = false
	player2_cpu = false
	lobby_join = join
	stage = STAGE.dojo

func init_online_lobby_join():
	mode = MODE.online_lobby
	online = true
	if debug_mode:
		player1_cpu = true
		player2_cpu = true
	else :
		player1_cpu = false
		player2_cpu = false
	lobby_join = true
	stage = STAGE.dojo

func init_arcade():
	mode = MODE.arcade
	online = false
	player1_cpu = false
	player2_cpu = true

func init_tutorial():
	mode = MODE.tutorial
	online = false
	player1_cpu = false
	player2_cpu = true
	player1_char = CHAR.goto
	player1_palette = - 1
	player2_char = CHAR.goto
	player2_palette = 0
	stage = STAGE.rooftop

func init_arcade_mode(char_name):
	arcade_stage = 0
	arcade_continues = 2
	arcade_time = 0
	arcade_chars = [CHAR.goto, CHAR.yoyo, CHAR.kero, CHAR.time, CHAR.sword, CHAR.darkgoto]
	var char_index = arcade_chars.find(char_name)
	if char_index >= 0:
		arcade_chars.remove(char_index)
	if player1_char == CHAR.darkgoto:
		arcade_chars.erase(CHAR.goto)
	else :
		arcade_chars.erase(CHAR.darkgoto)
	player2_palette = - 1
	set_next_arcade_char()

func set_next_arcade_char():
	arcade_stage += 1
	if arcade_stage > max_arcade_stage:
		return false
	elif arcade_stage == max_arcade_stage or arcade_chars.size() < 0:
		if player1_char == CHAR.darkgoto:
			player2_char = CHAR.goto
		else :
			player2_char = CHAR.darkgoto
	else :
		var r = randi() % arcade_chars.size()
		player2_char = arcade_chars[r]
		arcade_chars.remove(r)
	stage = get_char_stage(player2_char)
	return true

func unlock_color4(char_name):
	match char_name:
		CHAR.goto:
			unlock_color4_goto = true
		CHAR.yoyo:
			unlock_color4_yoyo = true
		CHAR.kero:
			unlock_color4_kero = true
		CHAR.time:
			unlock_color4_time = true
		CHAR.sword:
			unlock_color4_sword = true
		CHAR.darkgoto:
			unlock_color4_darkgoto = true
	save_unlocks()

func is_color4_unlocked(char_name):
	match char_name:
		CHAR.goto:
			return unlock_color4_goto
		CHAR.yoyo:
			return unlock_color4_yoyo
		CHAR.kero:
			return unlock_color4_kero
		CHAR.time:
			return unlock_color4_time
		CHAR.sword:
			return unlock_color4_sword
		CHAR.darkgoto:
			return unlock_color4_darkgoto

func unlock_char():
	if not unlock_char_darkgoto and unlock_color4_goto and unlock_color4_yoyo and unlock_color4_kero and unlock_color4_time and unlock_color4_sword:
		unlock_char_darkgoto = true
		save_unlocks()
		return CHAR.darkgoto
	return null

func unlock_stage():
	if player1_char == CHAR.darkgoto and not unlock_stage_blackhole:
		unlock_stage_blackhole = true
		save_unlocks()
		return STAGE.blackhole
	return null

func get_record_arcade(char_name):
	match char_name:
		CHAR.goto:
			return record_arcade_goto
		CHAR.yoyo:
			return record_arcade_yoyo
		CHAR.kero:
			return record_arcade_kero
		CHAR.time:
			return record_arcade_time
		CHAR.sword:
			return record_arcade_sword
		CHAR.darkgoto:
			return record_arcade_darkgoto
	return null

func set_record_arcade(char_name, time):
	match char_name:
		CHAR.goto:
			record_arcade_goto = time
		CHAR.yoyo:
			record_arcade_yoyo = time
		CHAR.kero:
			record_arcade_kero = time
		CHAR.time:
			record_arcade_time = time
		CHAR.sword:
			record_arcade_sword = time
		CHAR.darkgoto:
			record_arcade_darkgoto = time
	save_records()

func send_lobby_chat_msg(msg):
	var name_msg = Steam.getPersonaName() + ": " + msg
	add_lobby_chat_msg(name_msg)
	var chat_str = global.LOBBY_MSG_CHAT + global.LOBBY_MSG_SEP_CHAR + name_msg
	Steam.sendLobbyChatMsg(curr_lobby_id, chat_str)

func add_lobby_chat_msg(msg):
	var time = OS.get_time()
	var time_str = "[%02d:%02d]" % [time["hour"], time["minute"]] + " "
	if not lobby_chat_msg.empty():
		lobby_chat_msg += ""
	lobby_chat_msg += time_str + msg

func join_requested(lobby_id, requester_id):
	lobby_found = false
	join_lobby(lobby_id, true)

func get_lobby_data(key):
	return Steam.getLobbyData(curr_lobby_id, key)

func get_lobby_member_data(user_id, key):
	return Steam.getLobbyMemberData(curr_lobby_id, user_id, key)

func set_lobby_data(key, value):
	if Steam.setLobbyData(curr_lobby_id, key, value):
		create_debug_text("Set lobby data " + key + " to " + value)

func set_lobby_member_data(key, value):
	Steam.setLobbyMemberData(curr_lobby_id, key, value)
	create_debug_text("Set lobby member data " + key + " to " + value)

func update_lobby_member_data():
	for i in range(8):
		if i < lobby_member_ids.size():
			set_lobby_data(LOBBY_PLAYER_ID + str(i + 1), str(lobby_member_ids[i]))
		else :
			set_lobby_data(LOBBY_PLAYER_ID + str(i + 1), "-1")
	update_lobby_ready_data()

func update_lobby_ready_data():
	for i in range(2):
		set_lobby_data(LOBBY_PLAYER_READY + str(i + 1), str(lobby_member_ready[i]))

func update_lobby_stage_data():
	if stage_select == STAGE_SELECT.random:
		stage = get_random_stage()
		set_lobby_data(LOBBY_STAGE, str(stage))

func get_lobby_stage_data():
	stage = int(get_lobby_data(LOBBY_STAGE))

func lobby_chat_update(lobby_id, user_id, change_user_id, chat_state):
	if lobby_join:
		match chat_state:
			2, 4:
				if user_id == host_member_id:
					create_info_text("Lobby was disbanded because host left.")
					leave_lobby(true)
	else :
		match chat_state:
			1:
				create_debug_text("Lobby member joined.")
				if not lobby_member_ids.has(user_id):
					lobby_member_ids.append(user_id)
				update_lobby_member_data()
			2, 4:
				if chat_state == 2:
					create_debug_text("Lobby member left.")
				else :
					create_debug_text("Lobby member disconnected.")
				var change_scene = false
				if (lobby_member_ids.size() >= 1 and user_id == lobby_member_ids[0]) or (lobby_member_ids.size() >= 2 and user_id == lobby_member_ids[1]):
					lobby_member_ready = [LOBBY_READY.not_ready, LOBBY_READY.not_ready]
					update_lobby_ready_data()
					change_scene = true
				lobby_member_ids.erase(user_id)
				spectator_member_ids.erase(user_id)
				update_lobby_member_data()
				if change_scene:
					broadcast_packet_lobby_return()
					if get_tree().get_current_scene().get_name() != "online_lobby":
						get_tree().change_scene("res://scenes/online_lobby.tscn")

func lobby_data_update(success, lobby_id, user_id, key):
	if lobby_join and curr_lobby_id == lobby_id and Steam.getLobbyData(lobby_id, LOBBY_VERSION) != VERSION:
		create_info_text("Could not join lobby! Reason: Version mismatch.")
		leave_lobby(true)
	lobby_member_ids.clear()
	for i in range(8):
		var player_id = int(get_lobby_data(LOBBY_PLAYER_ID + str(i + 1)))
		if player_id >= 0:
			lobby_member_ids.append(player_id)
		else :
			break
	for i in range(2):
		lobby_member_ready[i] = int(get_lobby_data(LOBBY_PLAYER_READY + str(i + 1)))

func lobby_message(result, user_id, msg, type):
	var char_idx = msg.find(LOBBY_MSG_SEP_CHAR)
	var msg_data = msg.right(char_idx + 1)
	match msg.left(char_idx):
		LOBBY_MSG_TIMEOUT:
			if steam_id == int(msg_data):
				leave_lobby(true)
				create_info_text("Kicked from lobby! Reason: Timed out.")
		LOBBY_MSG_CHAT:
			if steam_id != user_id:
				add_lobby_chat_msg(msg_data)

func p2p_session_request(user_id):
	Steam.acceptP2PSessionWithUser(user_id)
	create_debug_text("Accepted P2P session with ID: " + str(user_id))

func p2p_session_connect_fail(user_id, reason):
	create_debug_text("Failed P2P session with ID: " + str(user_id))
	if lobby_join and lobby_member_ids.has(user_id):
		leave_lobby(true)
		create_info_text("Lobby left! Reason: Failed P2P session with another lobby member.")

func lobby_created(result, lobby_id):
	create_debug_text("Lobby created! ID: " + str(lobby_id))
	curr_lobby_id = lobby_id
	lobby_rotate = LOBBY_ROTATE.none
	set_lobby_data(LOBBY_VERSION, VERSION)
	set_lobby_data(LOBBY_NAME, host_name)
	set_lobby_data(LOBBY_KEYWORD, host_keyword)
	set_lobby_data(LOBBY_REMATCH_STYLE, str(host_rematch))
	set_lobby_data(LOBBY_ROTATION_STYLE, str(host_rotation))
	set_lobby_data(LOBBY_MATCH_LIMIT, str(host_match_limit))
	set_lobby_data(LOBBY_DELAY, str(host_delay))
	set_lobby_data(LOBBY_STAGE_SELECT, str(host_stage_select))
	set_lobby_data(LOBBY_CHAT, str(int(host_chat)))
	update_lobby_member_data()
	update_lobby_stage_data()

func lobby_joined(lobby_id, perm, locked, response):
	if response == 1:
		create_debug_text("Lobby joined! ID: " + str(lobby_id))
		curr_lobby_id = lobby_id
		lobby_chat_msg = ""
		host_member_id = Steam.getLobbyOwner(curr_lobby_id)
		input_delay = int(get_lobby_data(LOBBY_DELAY))
		stage_select = int(get_lobby_data(LOBBY_STAGE_SELECT))
		lobby_chat = bool(int(get_lobby_data(LOBBY_CHAT)))
		set_lobby_member_data(MEMBER_LOBBY_DTDASH, str(int(player1_dtdash)))
		set_lobby_member_data(MEMBER_LOBBY_WINS, str(0))
		set_lobby_member_data(MEMBER_LOBBY_MATCHES, str(0))
		set_lobby_member_data(MEMBER_LOBBY_SKIP, str(0))
		set_lobby_member_data(MEMBER_LOBBY_CONSEC_MATCHES, str(0))
		if lobby_join:
			get_tree().change_scene("res://scenes/online_lobby.tscn")
	elif response == 4:
		create_info_text("Could not join lobby! Reason: Lobby is full.")
	else :
		create_info_text("Could not join lobby! Reason: Unexpected error.")

func join_lobby(lobby_id, mode_lobby):
	create_info_text("Attempting to join lobby...")
	if curr_lobby_id == lobby_id:
		create_info_text("Could not join lobby! Reason: Already in this lobby.")
	else :
		Steam.joinLobby(lobby_id)
		if mode_lobby:
			init_online_lobby_join()

func leave_lobby(change_scene):
	if other_member_id > 0:
		if Steam.closeP2PSessionWithUser(other_member_id):
			create_debug_text("Closed P2P session with user ID: " + str(other_member_id))
		other_member_id = 0
	if curr_lobby_id > 0:
		Steam.leaveLobby(curr_lobby_id)
		create_debug_text("Left lobby ID: " + str(curr_lobby_id))
		curr_lobby_id = 0
		if change_scene:
			get_tree().change_scene("res://scenes/menu.tscn")

func broadcast_packet_lobby_return():
	if global.curr_lobby_id > 0:
		var packet = PoolByteArray()
		packet.append(global.P_TYPE.lobby_return)
		broadcast_packet_all(packet)

func broadcast_packet_all(packet):
	if not lobby_join:
		for i in range(len(lobby_member_ids)):
			var user_id = lobby_member_ids[i]
			if user_id != steam_id:
				Steam.sendP2PPacket(user_id, packet, 2, 0)

func broadcast_packet(packet):
	if lobby_join:
		Steam.sendP2PPacket(other_member_id, packet, 2, 0)
		if other_member_id != host_member_id:
			Steam.sendP2PPacket(host_member_id, packet, 2, 0)
	else :
		if not lobby_state == LOBBY_STATE.spectate:
			Steam.sendP2PPacket(other_member_id, packet, 2, 0)
		relay_packet(packet)

func relay_packet(packet):
	for i in range(len(spectator_member_ids)):
		var user_id = spectator_member_ids[i]
		if user_id != steam_id:
			Steam.sendP2PPacket(user_id, packet, 2, 0)

func empty_packet_stream():
	var packet_size = Steam.getAvailableP2PPacketSize(0)
	while packet_size > 0:
		var packet_dict = Steam.readP2PPacket(packet_size, 0)
		packet_size = Steam.getAvailableP2PPacketSize(0)

func clear_input_files():
	var dir = Directory.new()
	dir.remove("user://player1.txt")
	dir.remove("user://player2.txt")
	dir.remove("user://player12.txt")
	dir.remove("user://player22.txt")

func save_player1_input(frame, data):
	var file = File.new()
	var file_name = "user://player1.txt"
	if lobby_join:
		file_name = "user://player12.txt"
	if file.file_exists(file_name):
		file.open(file_name, File.READ_WRITE)
		file.seek_end()
	else :
		file.open(file_name, File.WRITE)
	file.store_line(str(frame) + to_json(data))
	file.close()

func save_player2_input(frame, data):
	var file = File.new()
	var file_name = "user://player2.txt"
	if lobby_join:
		file_name = "user://player22.txt"
	if file.file_exists(file_name):
		file.open(file_name, File.READ_WRITE)
		file.seek_end()
	else :
		file.open(file_name, File.WRITE)
	file.store_line(str(frame) + to_json(data))
	file.close()

func is_christmas(player_num):
	var date = OS.get_date()
	return date["month"] == 12 and date["day"] >= 18 and date["day"] <= 31 and unlock_color4_time and ((player_num == 1 and player1_char == CHAR.time and player1_palette == 2) or
		(player_num == 2 and player2_char == CHAR.time and player2_palette == 2))

func is_april_fools():
	var date = OS.get_date()
	return date["month"] == 4 and date["day"] == 1
