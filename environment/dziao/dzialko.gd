extends StaticBody2D
@onready var pocisk = preload("res://environment/dziao/pocisk_prefab.tscn")


func _ready() -> void:
	var pocisk = pocisk.instantiate()
	add_child(pocisk)
	var timer = Timer.new()
	timer.wait_time = 2
	timer.one_shot = false
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	timer.start()

func _on_Timer_timeout() -> void:
	var pocisk = pocisk.instantiate()
	add_child(pocisk)


func _process(delta: float) -> void:


	pass
