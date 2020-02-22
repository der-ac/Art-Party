extends Button

var setup_screen := load("res://Screens/Setup.tscn")

func _ready() -> void:
	if Game_Server.is_server != true:
		rect_position.y = 10
		rect_size.y = 1060
		
func _pressed() -> void:
	Sound.play_sfx("res://Assets/SFX/button1.wav", 0.0, 0.5)
	get_tree().change_scene_to(setup_screen)
