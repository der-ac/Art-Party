extends Control

# history format will be an array of arrays, sub arrays are segments from pen
# down to pen up, so undo will just be a pop and so on
var history := [[]]
var _pen = null
var mouse_locs = PoolVector2Array()
var undo := false
var speed := 0

func _ready():
	var viewport = Viewport.new()
	var rect = get_rect()
	viewport.size = rect.size
	viewport.usage = Viewport.USAGE_2D
	
	viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
	viewport.render_target_v_flip = true
	
	_pen = Node2D.new()
	viewport.add_child(_pen)
	_pen.connect("draw", self, "_on_draw")
	add_child(viewport)
	
	var rt = viewport.get_texture()
	var board = TextureRect.new()
	board.set_texture(rt)
	add_child(board)
	
	mouse_locs.append(get_viewport().get_mouse_position())

func _process(_delta):
	mouse_locs.append(get_viewport().get_mouse_position())
	if mouse_locs.size() > 15:
		mouse_locs.remove(0)
	var acc = 0
	for index in (mouse_locs.size() - 1):
		acc += (mouse_locs[index] - mouse_locs[index + 1]).length()
	acc /= (mouse_locs.size() - 1)
	speed = acc

# Input section

func _gui_input(event):
	if event is InputEventMouseButton \
				and event.button_index == BUTTON_LEFT \
				and event.pressed:
		history[-1].append({"position": mouse_locs[-1],
							"speed": speed,
							"color": Global.color})
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		history[-1].append({"position": mouse_locs[-1],
							"speed": speed,
							"color": Global.color})
		_pen.update()
	elif history[-1].size() > 0:
		history.append([])
		
func _on_Undo_Button_button_down():
	undo()

func undo() -> void:
	if history.size() > 1:
		history.remove(history.size()-2)
		undo = true
		_pen.update()

# Drawing section
func _on_draw():
	if undo:
		_pen.draw_rect(get_rect(), Color("#f5f1ed"))
		for stroke in history:
			for offset in range(stroke.size()):
				draw_brush(stroke, -offset - 1)
		undo = false
	if history[-1].size() > 0:
		draw_brush(history[-1])
	elif history.size() > 1:
		draw_brush(history[-2])

func draw_pen():
	var h_size = history[-1].size() - 1
	var radius = 10
	if h_size >= 1:
		_pen.draw_circle(history[-1][h_size]["position"],
						 radius, Global.color)
		_pen.draw_line(history[-1][h_size - 1]["position"],
					   history[-1][h_size]["position"], Global.color,
					   radius * 2)

func draw_brush(stroke : Array, offset := -1) -> void:
	var size := stroke.size()
	if size + offset >= 1 and offset < 0:
		var tangent = (stroke[offset - 1]["position"] - \
					   stroke[offset]["position"]).tangent()
		if tangent == Vector2(0,0):
			tangent = Vector2(1,1)
		var factor = 3.5
		var base_width = 5
		var minus_width = 20
		var width = []
		for i in range(2):
			width.append(stroke[offset - i]["speed"])
			if width[i] > minus_width * factor:
				width[i] = minus_width * factor
			width[i] = tangent.normalized() * \
					   (base_width + width[i] / factor)
			_pen.draw_circle(stroke[offset - i]["position"],
							 width[-i].length(), stroke[offset]["color"])

		var points = PoolVector2Array()
		points.append(stroke[offset]["position"] - width[0])
		points.append(stroke[offset]["position"] + width[0])
		points.append(stroke[offset - 1]["position"] + width[1])
		points.append(stroke[offset - 1]["position"] - width[1])
		_pen.draw_polygon(points,PoolColorArray([stroke[offset]["color"]]))

