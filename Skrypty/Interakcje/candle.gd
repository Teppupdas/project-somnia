extends Node2D


var playerInArea = false
var zapalona
@onready var animationPlayer = $AnimationPlayer
@onready var saveNode = $"../../save"

@onready var label = $UI

func _ready() -> void:
	animationPlayer.play("zgaszona")
	label.visible = true


func _process(delta: float) -> void:
	if playerInArea and Input.is_action_just_pressed("potwierdz") and not zapalona:
		saveNode.setCandle(self) #wysyla do save node ze swieczka chce zmienic
		saveNode.saveGame()





# Funkcja zapalająca świeczkę
func turnOnCandle() -> void:
	animationPlayer.play("zapalona")
	zapalona = true
	label.visible = false


# Funkcja gasząca świeczkę
func turnOffCandle() -> void:
	animationPlayer.play("zgaszona")
	zapalona = false
	label.visible = true





func _on_area_2d_body_entered(body: Node2D) -> void:
	playerInArea = true
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	playerInArea = false
