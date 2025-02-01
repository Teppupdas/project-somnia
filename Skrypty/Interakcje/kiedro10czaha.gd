extends Node2D

var saveNode: NodePath = "../../save"
var UI: NodePath = "../../CanvasLayer"

var baseActions: Array = ["CZAHA1"] # to zapisywac
var toActionPrompt #zapamioetuje co obecnie ma sie pojawic w actionpromptt





func _ready() -> void:
	toActionPrompt = baseActions
func _process(delta: float) -> void:
	pass



func handleAction(actionName: String) -> void:
	print("Wybrano kurwa opcję: ", actionName)
	$"../../CanvasLayer/debugLabel".text = actionName
	match actionName:
		"CZAHA1":
			baseActions.erase(actionName)
			baseActions.append("CZAHA2")
			baseActions.append("CZAHA3")
			baseActions.append("CZAHA5")
			
			startConv(actionName)
		"CZAHA2": #ty gadasz?
			baseActions.erase(actionName)
			toActionPrompt = ["CZAHA2-1", "CZAHA2-2"]
			startConv(actionName)
		"CZAHA2-1":
			baseActions.push_front("CZAHA4")
			toActionPrompt = baseActions
			get_node(UI).updateActionPrompt(toActionPrompt)
		"CZAHA2-2":
			baseActions.push_front("CZAHA4")
			toActionPrompt = baseActions
			get_node(UI).updateActionPrompt(toActionPrompt)
		"CZAHA3": #jak stąd wyjść
			baseActions.erase(actionName)
			toActionPrompt = baseActions
			startConv(actionName)
			get_node(saveNode).storyState = 1
		"CZAHA4": #a ty co tu robisz
			baseActions.erase(actionName)
			toActionPrompt = baseActions
			startConv(actionName)
		"CZAHA5": #loremipsum
			baseActions.erase(actionName)
			toActionPrompt = baseActions
			startConv(actionName)
		"CZAHA6": #to jescze nie jest dodawan nigdzie
			startConv(actionName)





func startConv(baseKey: String):
	var index = 1
	
	while true: # to na razie wyswietla ostatnie a nie po kolei XD
		var key: String = baseKey + "." + str(index)
	
		if tr(key) == key:  # Sprawdza, czy klucz istnieje
			break  # Jeśli nie istnieje, przerywa pętlę
	
		get_node(UI).startConversation(key)
		index += 1  # Przechodzi do kolejnego klucza
	if toActionPrompt:
		get_node(UI).updateActionPrompt(toActionPrompt)
	else:
		get_node(UI).hideActionPrompt()




func _on_area_2d_body_entered(body: Node2D) -> void:
	if toActionPrompt:
		print("toactionpromtpo istnieje")
		get_node(UI).showActionPrompt(toActionPrompt, self)
	else:
		print("toactjionprmoe nie isnieje")

func _on_area_2d_body_exited(body: Node2D) -> void:
	get_node(UI).hideActionPrompt()




#znikanie dialogu chwile po wypowiedzeniu go?   aaa jak to zrobic
#wywolywanie tego interfejsu gadania
#potwierdzanie aby przejsc do nastpenego dialogu i w tym czasie brak actionprompt
#anulowanie tego po jakims czasie czy cos jesli gracz nie skanczy gadac
#moze jednak wszystko w jednej wypowiedzi 
#co gdy gracz spierdoli w polowie dialogu jak jest wybor jakis, ma czekac w nieskonczonosc?

#ZDECYDOWAĆ JAK MA WYGLĄDAĆ TO OKNO DIALOGU





	#okno z dialogiem postaci
	#zapisywanie stanu tego obiektu w save
	#swieczke przerobic pierwej lub nie pierwej; zdecydowanie nie pierwej
