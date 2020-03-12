extends Stretch_Grid

const ready_label = preload("res://Screens/Components/Ready_Label.tscn")
const Start_Hover_stylebox = preload("res://Screens/Styles/Start_Hover.tres")
onready var Need_Players := get_node("../Need_Players")

func _ready() -> void:
	Log.if_error(Global.connect("game_state_changed", self, "_on_game_state_changed"),
				 'Failed: Global.connect("game_state_changed", self, "_on_game_state_changed")')
	_on_game_state_changed()

func _on_game_state_changed() -> void:
	refresh()

func refresh() -> void:
	for child in get_children():
		child.queue_free()
	
	var player_num := Global.game_state.size()
	if player_num < 4:
		Start_Hover_stylebox.set_border_color(Color("#FFA300"))
		if OS.is_debug_build():
			Start_Hover_stylebox.set_border_color(Color("#008751"))
			Need_Players.text = "Debug build, less than 4 players allowed."
		else:
			Need_Players.text = "Need %s more players to start." % String(4 - player_num)
		Need_Players.set_visible(true)
	else:
		Start_Hover_stylebox.set_border_color(Color("#008751"))
		Need_Players.set_visible(false)
	
	for player in Global.game_state.keys():
		create_ready_label(Global.game_state[player]["name"])
	
#	if OS.is_debug_build():
#		var udp_data = {"1": {"name": "bob"},
#						"3": {"name": "race"},
#						"4": {"name": "jeff"},
#						"5": {"name": "cody"},
#						"6": {"name": "elise"},
#						"7": {"name": "matt"},}
#		for player in udp_data.keys():
#			create_ready_label(udp_data[player]["name"])

func create_ready_label(text : String) -> void:
	var instance = ready_label.instance()
	add_child(instance)
	instance.text = text
