extends Camera2D

@onready var player = $"../World YSort/Gracz"
var speed = 3

var cameraOffset = Vector2.ZERO

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	cameraOffset = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)) * 800



func _physics_process(delta: float) -> void:
	var targetPosition = player.global_position + cameraOffset
	global_position = global_position.lerp(targetPosition, delta * speed)
	#global_position = player.global_position
	pass


# nie wiem czy skryptem płynność robić czy godotem w ustawieniach kamery
