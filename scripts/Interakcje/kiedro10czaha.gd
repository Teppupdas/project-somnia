extends Node2D

var save_node: NodePath = "../../save"
var ui: NodePath = "../../CanvasLayer"

var base_actions: Array # to zapisywac
var to_action_prompt #zapamioetuje co obecnie ma sie pojawic w actionpromptt

var dialogue_bubble_offset = Vector2(-190, -520)

var player_in_area = false
var is_talking = false #to jest sprawdzane by wstrzymac pokazywanie akcji



func _ready() -> void:
	to_action_prompt = base_actions
func _process(delta: float) -> void:
	pass


func handle_action(action_name: String) -> void:
	match action_name:
		"CZAHA1":
			base_actions.erase(action_name)
			base_actions.append("CZAHA2")
			base_actions.append("CZAHA3")
			base_actions.append("CZAHA5")
			to_action_prompt = base_actions
			
			initiate_dialogue(action_name)
		"CZAHA2": #ty gadasz?
			to_action_prompt = ["CZAHA2-1", "CZAHA2-2"]
			initiate_dialogue(action_name)
		"CZAHA2-1", "CZAHA2-2":
			base_actions.erase("CZAHA2")
			base_actions.push_front("CZAHA4")
			to_action_prompt = base_actions
			get_node(ui).update_action_prompt(to_action_prompt)
		"CZAHA3": #jak stąd wyjść
			base_actions.erase(action_name)
			to_action_prompt = base_actions
			initiate_dialogue(action_name)
		"CZAHA4", "CZAHA5":
			base_actions.erase(action_name)
			to_action_prompt = base_actions
			initiate_dialogue(action_name)
		"CZAHA6": #to jescze nie jest dodawan nigdzie
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
	
