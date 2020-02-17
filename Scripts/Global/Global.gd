extends Node

onready var Name_Generator := load("res://Scripts/Utility/name-generator.gd")
onready var my_name : String = Name_Generator.generate(5,8)
var UPNP_state := "uninitialized"
var external_ip := ""
var color := Color("#339db5") setget color_set
signal color_changed
# udp_data = {ip: {is_server: bool, last_tick: int, name: ''}}
var udp_data := {} setget udp_data_set
signal udp_data_changed
# game_state = {network_id: {name: '', cards: []}}
var game_state := {} setget game_state_set
signal game_state_changed

func color_set(value : Color) -> void:
	Sound.play_sfx("res://Sounds/Buttons/on.wav")
	color = value
	emit_signal("color_changed")

func udp_data_set(value : Dictionary) -> void:
	udp_data = value
	emit_signal("udp_data_changed")

func game_state_set(value : Dictionary) -> void:
	game_state = value
	emit_signal("game_state_changed")

func _ready() -> void:
	OS.set_borderless_window(true)
	OS.set_window_maximized(true)
	OS.set_window_size(OS.get_screen_size())
	OS.set_window_position(Vector2(0, 0))
	randomize()
