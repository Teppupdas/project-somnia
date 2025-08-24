extends Node2D


@onready var save_node = $"../../save"
var UI: NodePath = "../../CanvasLayer"
var to_action_prompt: Array = ["ZAPAL"]

var player_in_area = false
var is_talking = false #to jest sprawdzane by wstrzymac pokazywanie akcji

func _ready() -> void:
	
	#$Sprite2D.material.set_shader_parameter("visible", false)
	pass

func _process(delta: float) -> void:
	pass


	# nie wyłączać shadera dla jakiejs instancji a wlaczac dla inej  bo sie jebie


func handle_action(action_name: String) -> void:
	match action_name:
		"ZAPAL":
			get_node(UI).hide_action_prompt()
			save_node.set_pentagram(self) #wysyla do save node ze pentagram chce zmienic
			save_node.save_game()
			
			#animacja
			var tween = create_tween()
			tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.1)
			tween.tween_property($Sprite2D, "modulate", Color.RED, 0.3)









func _on_area_2d_body_entered(body: Node2D) -> void:
	player_in_area = true
	if to_action_prompt:
		get_node(UI).show_action_prompt(to_action_prompt, self)
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	player_in_area = false
	get_node(UI).hide_action_prompt()
