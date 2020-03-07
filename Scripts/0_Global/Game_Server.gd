extends Node

var is_client := false
var is_server := false
var port := (30000 + randi() % 3001)
var peer := NetworkedMultiplayerENet.new()

var setup_screen := load("res://Screens/Setup.tscn")
var play_screen := load("res://Screens/Play.tscn")

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	peer.connect("connection_succeeded", self, "_connection_succeeded")

func _player_connected(id : int) -> void:
	rpc_id(id, "register_player", new_data())

func _player_disconnected(id : int) -> void:
	match get_tree().get_current_scene().get_name():
		"Lobby":
			Global.game_state.erase(id)
			# Trigger setter
			Global.game_state_set(Global.game_state)
		"Play":
			print("player disconnected: ", id)
			#get_tree().change_scene_to(setup_screen)

func _server_disconnected() -> void:
	match get_tree().get_current_scene().get_name():
		"Lobby":
			get_tree().change_scene_to(setup_screen)
		"Play":
			get_tree().change_scene_to(setup_screen)

func _connection_succeeded() -> void:
	Global.game_state[peer.get_unique_id()] = new_data()
	is_client = true
	
remote func register_player(player_data : Dictionary) -> void:
	var id = get_tree().get_rpc_sender_id()
	Global.game_state[id] = player_data

remotesync func start_game() -> void:
	get_tree().change_scene_to(play_screen)

remotesync func send_data(data, cards_id : int) -> void:
	var sender_id = get_tree().get_rpc_sender_id()
	Global.game_state[cards_id]["cards"].append(data)
	Global.game_state[cards_id]["played_by"].append(sender_id)
	# Trigger signal
	Global.game_state_set(Global.game_state)

func start_serving(retries : int = 3) -> int:
	var err : int
	if !is_server:
		err = peer.create_server(port, 32)
		if err == OK:
			Global.game_state[1] = new_data()
			get_tree().set_network_peer(peer)
			is_server = true
			return err
		elif retries > 0:
			port = (30000 + randi() % 3001)
			start_serving(retries - 1)
	return err

func stop_serving() -> void:
	if is_server:
		UDP_Broadcast.udp.put_var("stop_serving")
		peer.close_connection()
		is_server = false
		Global.game_state = {}

func start_client(ip : String, server_port : int):
	if is_client == false:
		get_tree().set_network_peer(null)
		var err := peer.create_client(ip, server_port)
		if err == OK:
			get_tree().set_network_peer(peer)
			is_client = true

func stop_client() -> void:
	if is_client == true:
		peer.close_connection()
		is_client = false
		Global.game_state = {}

func new_data() -> Dictionary:
	return {'name': Global.my_name, 'cards': [], 'played_by': []}
