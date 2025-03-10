extends Node2D


var player: NodePath = "../Gracz"
var saveNode: NodePath = "../../save"
var UI: NodePath = "../../CanvasLayer"

func _on_area_2d_body_entered(body: Node2D) -> void:
	get_node(player).maxHealth += 1
	get_node(player).currentHealth += 1
	 
	get_node(UI).setMaxHeart(get_node(player).maxHealth)
	get_node(UI).updateHearts(get_node(player).currentHealth)

	
	
	queue_free()
