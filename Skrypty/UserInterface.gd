extends CanvasLayer

@onready var pasekSerc = $Serduszka
@onready var heartPrefab = preload("res://Interfejsik/serce.tscn")

@onready var pauzyMenu = $PauseMenuPanel
@onready var Label1 = $PauseMenuPanel/VBoxContainer/Label1
@onready var Label2 = $PauseMenuPanel/VBoxContainer/Label2
var pauzaAktywna
var opcjaPauzyWybrana


@onready var actionPromptPanel  = $actionPromptPanel
@onready var actionPromptContainer = $actionPromptPanel/actionPromptContainer
#@onready var actionLabel = 
var actionPromptActive = false
var selectedAction = 0
var actionLabels: Array = []
signal actionConfirmed(actionName)

@onready var dialoguePanel = $dialoguePanel
@onready var dialogueText = $dialoguePanel/RichTextLabel

const Kolorwybrania = Color8(220, 20, 60)
const Kolorniewybrania = Color8(255, 255, 255)





func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) #ukrycie myszki
	
	#TranslationServer.set_locale(OS.get_locale()) #auto jezyk z systemu. nie testowane.
	TranslationServer.set_locale("pl")
	

	pauzaAktywna = false
	pauzyMenu.hide()
	pasekSerc.show()
	get_tree().paused = false
	opcjaPauzyWybrana = 1




func _process(delta: float) -> void:	
	if pauzaAktywna:
		if Input.is_action_just_pressed("pauza"):
			pauzaAktywna = false
			pauzyMenu.hide()
			pasekSerc.show()
			if actionPromptActive:
				actionPromptPanel.show()
			get_tree().paused = false
			opcjaPauzyWybrana = 1


		if Input.is_action_just_pressed("potwierdz"):
			match opcjaPauzyWybrana:
				1:
					pauzaAktywna = false
					pauzyMenu.hide()
					pasekSerc.show()
					get_tree().paused = false
				2:
					get_tree().quit()


		if Input.is_action_just_pressed("gora"):
			match opcjaPauzyWybrana:
				1:
					opcjaPauzyWybrana = 2
				2:
					opcjaPauzyWybrana = 1
		if Input.is_action_just_pressed("dol"):
			match opcjaPauzyWybrana:
				1:
					opcjaPauzyWybrana = 2
				2:
					opcjaPauzyWybrana = 1


		match opcjaPauzyWybrana:
			1:
				Label1.set("theme_override_colors/font_color", Kolorwybrania)
				Label2.set("theme_override_colors/font_color", Kolorniewybrania)
			2:
				Label1.set("theme_override_colors/font_color", Kolorniewybrania)
				Label2.set("theme_override_colors/font_color", Kolorwybrania)

	elif Input.is_action_just_pressed("pauza"):
		pauzaAktywna = true
		get_tree().paused = true
		pasekSerc.hide()
		actionPromptPanel.hide()
		pauzyMenu.show()

	if actionPromptActive:
		if Input.is_action_just_pressed("UIdol"):
			navigateAction(-1)
		elif Input.is_action_just_pressed("UIgora"):
			navigateAction(1)
		elif Input.is_action_just_pressed("potwierdz"):
			emit_signal("actionConfirmed", actionLabels[selectedAction].text)






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








func showActionPrompt(actions: Array):
	for action in actions:
		var label = Label.new()
		label.text = action
		label.set("theme_override_font_sizes/font_size", 48)
		actionPromptContainer.add_child(label)
		actionLabels.append(label)
	selectedAction = 0
	highlightAction(selectedAction)
	actionPromptActive = true
	actionPromptPanel.show()

func hideActionPrompt():
	actionPromptActive = false
	actionPromptPanel.hide()
	for child in actionPromptContainer.get_children():
		child.queue_free()
	actionLabels.clear()


func navigateAction(direction: int): # to przerobic aby bylo tez do zmiany pauzy i innych takich jesli beda ale to kiedy indziej
	if actionLabels.size() == 0: return
	selectedAction = (selectedAction + direction) % actionLabels.size()
	if selectedAction < 0:
		selectedAction = actionLabels.size() - 1
	highlightAction(selectedAction)

func highlightAction(index: int):
	for i in range(actionLabels.size()):
		var label = actionLabels[i]
		if i == index:
			label.set("theme_override_colors/font_color", Kolorwybrania)
		else:
			label.set("theme_override_colors/font_color", Kolorniewybrania)








func startConversation(tekst: String):
	dialoguePanel.show()
	dialogueText.text = tekst
	
func endConversation():
	dialoguePanel.hide()
	dialogueText.text = ""
