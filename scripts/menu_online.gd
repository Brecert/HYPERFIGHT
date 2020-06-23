extends Node2D

onready  var init_controls = get_node("init_controls")
onready  var edit_connect_ip = get_node("init_controls/edit_connect_ip")
onready  var edit_connect_port = get_node("init_controls/edit_connect_port")
onready  var edit_create_port = get_node("init_controls/edit_create_port")
onready  var label_info = get_node("label_info")
onready  var button_startgame = get_node("button_startgame")

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	button_startgame.visible = false


var player_info = {}

var my_info = {char_name = global.player1_char, player_num = 1}
var players_done = []

func _player_connected(id):
	label_info.text = "Player " + str(id) + " connected to server."
	if get_tree().is_network_server():
		button_startgame.visible = true

func _player_disconnected(id):
	label_info.text = "Player " + str(id) + " disconnected from server."
	player_info.erase(id)
	if get_tree().is_network_server():
		button_startgame.visible = false

func _connected_ok():
	my_info["player_num"] = 2
	label_info.text = "Connected to server."
	rpc("register_player", get_tree().get_network_unique_id(), my_info)

func _server_disconnected():
	get_tree().set_network_peer(null)
	label_info.text = "Disconnected from server!"
	init_controls.visible = true

func _connected_fail():
	get_tree().set_network_peer(null)
	label_info.text = "Failed to connect to server!"
	init_controls.visible = true

remote func register_player(id, info):
				
				player_info[id] = info
				
				if get_tree().is_network_server():
								
								rpc_id(id, "register_player", 1, my_info)
								
								for peer_id in player_info:
												rpc_id(id, "register_player", peer_id, player_info[peer_id])

func _on_button_connect_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(edit_connect_ip.text, int(edit_connect_port.text))
	get_tree().set_network_peer(peer)
	get_tree().set_meta("network_peer", peer)
	init_controls.visible = false
	label_info.text = "Connecting..."

func _on_button_create_pressed():
	var port = int(edit_create_port.text)
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, 1)
	get_tree().set_network_peer(peer)
	get_tree().set_meta("network_peer", peer)
	init_controls.visible = false
	label_info.text = "Created server on port " + str(port)

sync func pre_configure_game():
	get_tree().set_pause(true)
	
	var selfPeerID = get_tree().get_network_unique_id()
	
	
	var game = load("res://scenes/game.tscn").instance()
	get_node("/root").add_child(game)
	
	
	var my_player = game.get_char_instance(my_info["char_name"])
	my_player.set_name(str(selfPeerID))
	my_player.set_network_master(selfPeerID)
	my_player.set_online_control(true)
	game.my_player = my_player
	
	
	for p in player_info:
		var other_player = game.get_char_instance(player_info[p]["char_name"])
		other_player.set_name(str(p))
		other_player.set_online_control(false)
		if get_tree().is_network_server():
			global.player1_char = my_info["char_name"]
			global.player2_char = player_info[p]["char_name"]
			game.init_players_online(my_player, other_player)
		else :
			global.player1_char = player_info[p]["char_name"]
			global.player2_char = my_info["char_name"]
			game.init_players_online(other_player, my_player)
		break
	
	
	if not get_tree().is_network_server():
		rpc_id(1, "done_preconfiguring", selfPeerID)

remote func done_preconfiguring(who):
	
	assert (get_tree().is_network_server())
	assert (who in player_info)
	assert ( not who in players_done)
	
	players_done.append(who)
	
	if players_done.size() == player_info.size():
					rpc("post_configure_game")

sync func post_configure_game():
	get_tree().set_pause(false)
	queue_free()
	

func _on_button_startgame_pressed():
	rpc("pre_configure_game")
