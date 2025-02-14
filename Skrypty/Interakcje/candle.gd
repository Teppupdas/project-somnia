extends Node2D


var zapalona = false
@onready var animationPlayer = $AnimationPlayer
@onready var saveNode = $"../../save"
var UI: NodePath = "../../CanvasLayer"
var toActionPrompt: Array = []

func _ready() -> void:
	
	saveNode.connect("candleActimel", candleActimelization) #nazwa sygnalu, nazwa funckji
	animationPlayer.play("zgaszona")
	$Sprite2D.material.set_shader_parameter("visible", false)


func _process(delta: float) -> void:
	pass


func candleActimelization(): #to robi ze swieczek mnozna uzwyac. wywolane po gadaniu z czaszku lub przy wczytywaniu
	toActionPrompt.append("ZAPAL")
	$Sprite2D.material.set_shader_parameter("visible", true)
	# nie wyłączać shadera dla jakiejs instancji a wlaczac dla inej  bo sie jebie


func handleAction(actionName: String) -> void:
	match actionName:
		"ZAPAL":
			#if not zapalona:
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
	if toActionPrompt:
		get_node(UI).showActionPrompt(toActionPrompt, self)
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	get_node(UI).hideActionPrompt()
