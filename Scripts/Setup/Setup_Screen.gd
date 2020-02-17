extends Control

func _ready():
	Game_Server.stop_serving()
	Game_Server.stop_client()
	UDP_Broadcast.listening = true
	UDP_Broadcast.broadcasting = true
	Sound.change_music("res://Sounds/menu.ogg", 15)
