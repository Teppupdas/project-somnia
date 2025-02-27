extends CanvasLayer

@onready var pasekSerc = $Serduszka
@onready var heartPrefab = preload("res://Interfejsik/serce.tscn")

@onready var pauzyMenu = $PauseMenuPanel
@onready var Label1 = $PauseMenuPanel/VBoxContainer/Label1
@onready var Label2 = $PauseMenuPanel/VBoxContainer/Label2
@onready var Label3 = $PauseMenuPanel/VBoxContainer/Label3
var pauzaAktywna
var opcjaPauzyWybrana

@onready var mapTexture = $mapTexture
@onready var mapCursor = $mapTexture/cursorTexture
var mapaAktywna
var mapBounds = Rect2(200, 200, 3840 - 100 - 2*200, 2160 - 100 - 2*200) # -rozmiar kursora -2x margines ze zwyklej storny. bo jeden zeruje do krawedzi a drugi dopiero dodaje margines
var currentQuests = ["KILL", "TALK"]


@onready var actionPromptPanel  = $actionPromptPanel
@onready var actionPromptContainer = $actionPromptPanel/actionPromptContainer
var actionPromptActive = false
var selectedAction = 0
var actionLabels: Array = []
var currentActionObject = null


const Kolorwybrania = Color8(220, 20, 60)
const Kolorniewybrania = Color8(255, 255, 255)
const Kolornieaktywny = Color8(112, 112, 112)



func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) #ukrycie myszki
	
	#TranslationServer.set_locale(OS.get_locale()) #auto jezyk z systemu. nie testowane.
	TranslationServer.set_locale("pl")
	

	pauzaAktywna = false
	pauzyMenu.hide()
	pasekSerc.show()
	get_tree().paused = false
	opcjaPauzyWybrana = 1
	
	mapaAktywna = false
	mapTexture.hide()




func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pauza"):
		if mapaAktywna: # sprawia ze da sie wylaczyc mape escapem. przetestowac to na padzie itp
			toggleMap()
		else:
			togglePause()

	if pauzaAktywna:
		if Input.is_action_just_pressed("UIdol"):
			navigateOption(1, "pause")
		elif Input.is_action_just_pressed("UIgora"):
			navigateOption(-1, "pause")
		if Input.is_action_just_pressed("potwierdz"):
			match opcjaPauzyWybrana:
				1:
					togglePause()
				2:
					pass
				3:
					get_tree().quit()


	if Input.is_action_just_pressed("mapa") and not pauzaAktywna:
		toggleMap()
		

	if mapaAktywna:
		var move_vector = Vector2.ZERO
		if Input.is_action_pressed("prawo"):
			move_vector.x += 1
		if Input.is_action_pressed("lewo"):
			move_vector.x -= 1
		if Input.is_action_pressed("dol"):
			move_vector.y += 1
		if Input.is_action_pressed("gora"):
			move_vector.y -= 1

		mapCursor.position += move_vector.normalized() * 3000 * delta
		mapCursor.position = mapCursor.position.clamp(mapBounds.position, mapBounds.end)



	if actionPromptActive and not pauzaAktywna:
		if currentActionObject.isTalking:
			return  # Zignoruj wszystkie interakcje, jeśli obiekt mówi

		if Input.is_action_just_pressed("UIdol"):
			navigateOption(1, "action")
		elif Input.is_action_just_pressed("UIgora"):
			navigateOption(-1, "action")
		elif Input.is_action_just_pressed("potwierdz"):   #to gdy wyjscie z pauzy za pomoco wznow to tez sie klika gowno
			currentActionObject.handleAction(actionLabels[selectedAction].text)






func setMaxHeart(maxHealth: int):
	for i in range(maxHealth):
		var heart = heartPrefab.instantiate()
		pasekSerc.add_child(heart)

func updateHearts(currentHealth):
	var hearts = pasekSerc.get_children()

	for i in range(currentHealth):
		hearts[i].update(true)

	for i in range(currentHealth, hearts.size()):
		hearts[i].update(false)




func togglePause():
	pauzaAktywna = !pauzaAktywna
	get_tree().paused = pauzaAktywna
	pauzyMenu.visible = pauzaAktywna
	opcjaPauzyWybrana = 1
	highlightOption(opcjaPauzyWybrana, "pause")

func toggleMap():
	mapaAktywna = !mapaAktywna
	mapTexture.visible = mapaAktywna
	get_tree().paused = mapaAktywna









func showActionPrompt(actions: Array, actionObject: Node2D):
	currentActionObject = actionObject
	
	if actionObject.isTalking:  # Jeśli ten obiekt mówi, nie pokazuj opcji
		return
	
	for action in actions:
		var label = Label.new()
		label.text = action
		label.set("theme_override_font_sizes/font_size", 48)
		actionPromptContainer.add_child(label)
		actionLabels.append(label)
	selectedAction = 0
	highlightOption(selectedAction, "action")
	actionPromptActive = true
	actionPromptPanel.show()

func updateActionPrompt(actions: Array):
	if currentActionObject.isTalking:  # Jeśli mówi, nie aktualizuj
		return
	
	for child in actionPromptContainer.get_children():
		child.queue_free()
	actionLabels.clear()
	for action in actions:
		var label = Label.new()
		label.text = action
		label.set("theme_override_font_sizes/font_size", 48)
		actionPromptContainer.add_child(label)
		actionLabels.append(label)
	selectedAction = 0
	highlightOption(selectedAction, "action")

func hideActionPrompt():
	actionPromptActive = false
	actionPromptPanel.hide()
	for child in actionPromptContainer.get_children():
		child.queue_free()
	actionLabels.clear()






func navigateOption(direction: int, context: String):
	if context == "action":
		if actionLabels.size() == 0: return
		selectedAction = (selectedAction + direction) % actionLabels.size()
		if selectedAction < 0:
			selectedAction = actionLabels.size() - 1
		highlightOption(selectedAction, context)
	
	if context == "pause":
		var maxOpcji = 3  # Ilość opcji w menu pauzy
		opcjaPauzyWybrana = (opcjaPauzyWybrana + direction) % maxOpcji
		if opcjaPauzyWybrana < 1:  # Ponieważ opcje są od 1 do 3
			opcjaPauzyWybrana = maxOpcji
		highlightOption(opcjaPauzyWybrana, context)

func highlightOption(index: int, context: String):
	if context == "action":
		for i in range(actionLabels.size()):
			var label = actionLabels[i]
			if i == index:
				label.set("theme_override_colors/font_color", Kolorwybrania)
			else:
				label.set("theme_override_colors/font_color", Kolorniewybrania)
				
	if context == "pause":
		Label1.set("theme_override_colors/font_color", Kolorwybrania if index == 1 else Kolorniewybrania)
		Label2.set("theme_override_colors/font_color", Kolorwybrania if index == 2 else Kolorniewybrania)
		Label3.set("theme_override_colors/font_color", Kolorwybrania if index == 3 else Kolorniewybrania)








func dialogueBubble(dialogueKey: String):
	
	var thisBubbleActionObject = currentActionObject #obiekt posiadajacy bobleka tego konkretnego
	var localizedText = tr(dialogueKey)
	var dialoguePanel = Panel.new()
	var dialogueText = RichTextLabel.new()
	
	thisBubbleActionObject.isTalking = true
	
	
	for child in currentActionObject.get_children():
		if child is Panel:
			child.queue_free()
	




	
	dialoguePanel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM) 
	dialoguePanel.size = Vector2(500, 300)  # Ustawienie rozmiaru panelu
	#dialoguePanel.add_theme_stylebox_override("panel", StyleBoxFlat.new()) # Ustawienie stylu
	
	
	dialogueText.custom_minimum_size = Vector2(500, 300)  # Ustawienie minimalnego rozmiaru dla label
	dialogueText.set("theme_override_font_sizes/normal_font_size", 28)
	dialogueText.set("theme_override_colors/default_color", Color.WHITE)



	
	currentActionObject.add_child(dialoguePanel)
	dialoguePanel.add_child(dialogueText)
	dialoguePanel.position = currentActionObject.dialogueBubbleOffset
	
	
	
	
	#pokazywanie tylko wybranego dialogu na czas animacji mowienia
	for i in range(actionLabels.size()):
		if i == selectedAction:
			actionLabels[i].set("theme_override_colors/font_color", Kolornieaktywny)
		else:
			actionLabels[i].hide()


	#dialogueText.text = localizedText
	for i in range(len(localizedText)): # ta petla tobi wypisywanie sie tekstu po literce
		dialogueText.text = localizedText.substr(0, i + 1)
		await get_tree().create_timer(0.015).timeout

	thisBubbleActionObject.isTalking = false

	if thisBubbleActionObject.playerInArea:
			updateActionPrompt(thisBubbleActionObject.toActionPrompt)

	#czekanie az gracza nie bedzie w area ponad 5 sekund
	var remainingTime = 5.0 # ile sekund czeka bez gracza w area
	var currentRemainingTime = remainingTime
	
	while currentRemainingTime > 0.0: 
		await get_tree().process_frame
		if thisBubbleActionObject.playerInArea:
			currentRemainingTime = remainingTime  #resetowanie licznika jesli gracz w area
		else:
			currentRemainingTime -= get_process_delta_time()  #zmniejszanie licnzika jesli gracz poza area

	#usuwanie jesli dalej istnieje bo moze byc usuniety wczesniej przez zastapienie
	if is_instance_valid(dialoguePanel):
		dialoguePanel.queue_free()
