extends Node2D


@onready var saveNode = $"../../save"
var UI: NodePath = "../../CanvasLayer"
var toActionPrompt: Array = ["ZAPAL"]

var playerInArea = false
var isTalking = false #to jest sprawdzane by wstrzymac pokazywanie akcji

func _ready() -> void:
	
	#$Sprite2D.material.set_shader_parameter("visible", false)
	pass

func _process(delta: float) -> void:
	pass


	# nie wyłączać shadera dla jakiejs instancji a wlaczac dla inej  bo sie jebie


func handleAction(actionName: String) -> void:
	match actionName:
		"ZAPAL":
			get_node(UI).hideActionPrompt()
			saveNode.setPentagram(self) #wysyla do save node ze pentagram chce zmienic
			saveNode.saveGame()
			
			#animacja
			var tween = create_tween()
			tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.1)
			tween.tween_property($Sprite2D, "modulate", Color.RED, 0.3)









func _on_area_2d_body_entered(body: Node2D) -> void:
	playerInArea = true
	if toActionPrompt:
		get_node(UI).showActionPrompt(toActionPrompt, self)
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	playerInArea = false
	get_node(UI).hideActionPrompt()
