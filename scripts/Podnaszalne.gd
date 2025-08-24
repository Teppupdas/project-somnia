extends Node2D


var player: NodePath = "../Gracz"
var save_node: NodePath = "../../save"
var ui: NodePath = "../../CanvasLayer"

func _on_area_2d_body_entered(body: Node2D) -> void:
	get_node(player).max_health += 1
	get_node(player).current_health += 1
	 
	get_node(ui).set_max_heart(get_node(player).max_health)
	get_node(ui).update_hearts(get_node(player).current_health)

	
	
	queue_free()
