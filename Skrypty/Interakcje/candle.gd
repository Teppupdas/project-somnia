extends Node2D


var playerInArea = false
var zapalona = false
@onready var animationPlayer = $AnimationPlayer
@onready var saveNode = $"../../save"
var UI: NodePath = "../../CanvasLayer"

func _ready() -> void:
	animationPlayer.play("zgaszona")
	if saveNode.storyState == 0 or  saveNode.storyState == null:
		$Sprite2D.material.set_shader_parameter("visible", false)


func _process(delta: float) -> void:
	if saveNode.storyState != 0:
		$Sprite2D.material.set_shader_parameter("visible", true)
		# zamienic to na sygnal
		# nie wyłączać w przypadku instancji bo wylacza wszystkie i sie jebie w przypadku swieczek
		if playerInArea and Input.is_action_just_pressed("potwierdz") and not zapalona:
			saveNode.setCandle(self) #wysyla do save node ze swieczka chce zmienic
			saveNode.saveGame()






# Funkcja zapalająca świeczkę
func turnOnCandle() -> void:
	animationPlayer.play("zapalona")
	zapalona = true
	get_node(UI).hideActionPrompt()



# Funkcja gasząca świeczkę
func turnOffCandle() -> void:
	animationPlayer.play("zgaszona")
	zapalona = false




func _on_area_2d_body_entered(body: Node2D) -> void:
	playerInArea = true
	if not zapalona and saveNode.storyState != 0:
		get_node(UI).showActionPrompt(["ZAPAL"])
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	playerInArea = false
	get_node(UI).hideActionPrompt()
