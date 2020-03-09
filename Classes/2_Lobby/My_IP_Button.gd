extends Button

var upnp := UPNP.new()
onready var Game_Players := get_node("/root/Lobby/Information/Game_Players")
onready var Address = get_node("/root/Lobby/Information/Address")
onready var UPNP_Bad = get_node("/root/Lobby/Information/UPNP_Bad")
onready var UPNP_Good = get_node("/root/Lobby/Information/UPNP_Good")

func _ready() -> void:
	if Game_Server.is_server != true:
		set_visible(false)

func _pressed() -> void:
	Address.set_visible(!Address.is_visible())
	if Address.is_visible():
		try_UPNP()
		
	else:
		UPNP_Bad.set_visible(false)
		UPNP_Good.set_visible(false)
	Game_Players.refresh()
	OS.set_clipboard(Address.text)
	text = "copied"
	$Copy_Timer.start()

func _on_Copy_Timer_timeout() -> void:
	text = "my IP"

func _on_HTTPRequest_request_completed(_result: int, 
									   _response_code: int,
									   _headers: PoolStringArray,
									   body: PoolByteArray) -> void:
	set_address(body.get_string_from_utf8())

func set_address(address) -> void:
	Global.external_ip = address
	Address.text = "%s:%s" % [address, Game_Server.port]

func try_UPNP() -> void:
	if Global.UPNP_state == "uninitialized":
		if upnp.discover() == 0:
			var gateway = upnp.get_gateway()
			if gateway.is_valid_gateway() and gateway.add_port_mapping(Game_Server.port) == 0:
				set_address(gateway.query_external_address())
				Global.UPNP_state = "succeeded"
		if Global.external_ip == "":
			Global.UPNP_state = "failed"
			$HTTPRequest.request("http://ipinfo.io/ip")
	if Global.UPNP_state == "succeeded":
		Sound.play_sfx("res://Assets/SFX/good.wav", -5)
		UPNP_Good.set_visible(true)
	if Global.UPNP_state == "failed":
		Sound.play_sfx("res://Assets/SFX/bad.wav", -10, .75)
		UPNP_Bad.set_visible(true)
