extends Button

var player_id : int

func _pressed() -> void:
	Sound.play_sfx("res://Assets/SFX/button2.wav", -3.0, 2.0)
	get_node('/root/End/Review').player_id = player_id
