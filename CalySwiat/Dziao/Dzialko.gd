extends StaticBody2D
@onready var pocisk = preload("res://CalySwiat/Dziao/PociskPrefab.tscn")


func _ready() -> void:
	var Pocisk = pocisk.instantiate()
	add_child(Pocisk)
	var timer = Timer.new()
	timer.wait_time = 2
	timer.one_shot = false
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	timer.start()

func _on_Timer_timeout() -> void:
	var Pocisk = pocisk.instantiate()
	add_child(Pocisk)


func _process(delta: float) -> void:


	pass
