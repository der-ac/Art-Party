extends Button

const setup_screen = preload("res://Screens/Setup.tscn")
		
func _pressed() -> void:
	Sound.play_sfx("res://Assets/SFX/button1.wav", 0.0, 0.75)
	get_tree().change_scene_to(setup_screen)
