extends Node2D

var save_node: NodePath = "../../save"
var ui: NodePath = "../../CanvasLayer"

var base_actions: Array = ["GAD1", "GAD2"] # to zapisywac
var to_action_prompt #zapamioetuje co obecnie ma sie pojawic w actionpromptt

var dialogue_bubble_offset = Vector2(0, 200)

var player_in_area = false
var is_talking = false #to jest sprawdzane by wstrzymac pokazywanie akcji



func _ready() -> void:
	to_action_prompt = base_actions
func _process(delta: float) -> void:
	pass


func handle_action(action_name: String) -> void:
	match action_name:
		"GAD1":
			initiate_dialogue(action_name)
		"GAD2":
			initiate_dialogue(action_name)




func initiate_dialogue(base_key: String):
	#if tr(key) == key:  # Sprawdza, czy klucz istnieje
	get_node(ui).dialogue_bubble(base_key + ".")
	
	#jesli tablica pusta to wylaczyc action prompt a jesli cos jest to zaktualizowac
	if to_action_prompt:
		get_node(ui).update_action_prompt(to_action_prompt)
	else:
		get_node(ui).hide_action_prompt()




func _on_area_2d_body_entered(body: Node2D) -> void:
	player_in_area = true
	if to_action_prompt:
		get_node(ui).show_action_prompt(to_action_prompt, self)


func _on_area_2d_body_exited(body: Node2D) -> void:
	player_in_area = false
	get_node(ui).hide_action_prompt()
