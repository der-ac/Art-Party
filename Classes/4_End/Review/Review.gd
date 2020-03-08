extends Control

var player_id : int setget set_player_id
var display_turn := 1
var scores := {}

const score_game = preload("res://Classes/Utility/score_game.gd")
const Turn_Is_Canvas_stylebox = preload("res://Screens/Styles/Turn_Is_Canvas.tres")
const Word_stylebox = preload("res://Screens/Styles/Review_Word.tres")
const Turn_stylebox = preload("res://Screens/Styles/Review_Turn.tres")

func set_player_id(value : int) -> void:
	player_id = value
	scores = score_game.calculate_stack(Global.game_state, player_id)
	display_turn = 1
	update_display(display_turn)
	visible = true

func _on_Back_pressed() -> void:
	if display_turn > 1:
		update_display(display_turn - 1)

func _on_Forward_pressed() -> void:
	if display_turn < Global.game_state[player_id]["cards"].size() - 1:
		update_display(display_turn + 1)

func _on_Return_pressed():
	Sound.play_sfx("res://Assets/SFX/button1.wav", 0, 0.75)
	visible = false
	$Canvas.history = [[]]
	$Canvas.redraw()
	
func update_display(turn : int) -> void:
	display_turn = turn
	var played_by = Global.game_state[player_id]["played_by"][turn]
	$Controls/Turn.text = String(turn) + ". " + Global.game_state[played_by]["name"]
	
	if scores[played_by]:
		Sound.play_sfx("res://Assets/SFX/good.wav")
		Turn_Is_Canvas_stylebox.set_border_color(Color("#008751"))
		Turn_stylebox.set_border_color(Color("#008751"))
		$Controls/Points.text = "+" + String(scores[played_by])
		$Controls/Points.set_visible(true)
	else:
		Sound.play_sfx("res://Assets/SFX/bad.wav", -3, .75)
		Turn_Is_Canvas_stylebox.set_border_color(Color("#FF004D"))
		Turn_stylebox.set_border_color(Color("#FF004D"))
		$Controls/Points.set_visible(false)
	
	if turn % 2:
		Word_stylebox.set_border_color(Color("#83769C"))
		$Turn_Is_Canvas.visible = true
		$Controls/Word.text = Global.game_state[player_id]["cards"][turn - 1]
		$Canvas.history = Global.game_state[player_id]["cards"][turn]
		$Canvas.redraw()
	else:
		if scores[played_by]:
			Word_stylebox.set_border_color(Color("#008751"))
		else:
			Word_stylebox.set_border_color(Color("#FF004D"))
		$Turn_Is_Canvas.visible = false
		$Controls/Word.text = Global.game_state[player_id]["cards"][turn]
