extends Camera2D

@onready var player = $"../World YSort/Gracz"
var speed = 3

var camera_offset = Vector2.ZERO

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	camera_offset = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)) * 800



func _physics_process(delta: float) -> void:
	var target_position = player.global_position + camera_offset
	global_position = global_position.lerp(target_position, delta * speed)
	#global_position = player.global_position
	pass


# nie wiem czy skryptem płynność robić czy godotem w ustawieniach kamery
