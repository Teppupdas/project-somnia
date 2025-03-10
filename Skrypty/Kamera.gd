extends Camera2D

@onready var player = $"../World YSort/Gracz"
var speed = 3

func _ready() -> void:
	pass





func _physics_process(delta: float) -> void:
	global_position = global_position.lerp(player.global_position, delta * speed)
	#global_position = player.global_position
	pass


# nie wiem czy skryptem płynność robić czy godotem w ustawieniach kamery
