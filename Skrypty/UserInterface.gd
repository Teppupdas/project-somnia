extends CanvasLayer

@onready var pasekSerc = $Serduszka
@onready var heartPrefab = preload("res://Interfejsik/serce.tscn")

@onready var pauzyMenu = $PauseMenuPanel
@onready var Label1 = $PauseMenuPanel/VBoxContainer/Label1
@onready var Label2 = $PauseMenuPanel/VBoxContainer/Label2
var pauzaAktywna
var opcjaPauzyWybrana


@onready var actionPromptPanel  = $ActionPrompt
@onready var actionLabel = $ActionPrompt/Label
var actionPromptActive = false

@onready var dialoguePanel = $dialoguePanel
@onready var dialogueText = $dialoguePanel/RichTextLabel





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
				Label1.set("theme_override_colors/font_color", Color8(220, 20, 60))
				Label2.set("theme_override_colors/font_color", Color8(255, 255, 255))
			2:
				Label1.set("theme_override_colors/font_color", Color8(255,255,255))
				Label2.set("theme_override_colors/font_color", Color8(220, 20, 60))

	elif Input.is_action_just_pressed("pauza"):
		pauzaAktywna = true
		get_tree().paused = true
		pasekSerc.hide()
		actionPromptPanel.hide()
		pauzyMenu.show()




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





func showActionPrompt(text: String):
	actionPromptActive = true
	actionLabel.text = text
	actionPromptPanel.show()

func hideActionPrompt():
	actionPromptActive = false
	actionPromptPanel.hide()

func startConversation(tekst: String):
	dialoguePanel.show()
	dialogueText.text = tekst
	
func endConversation():
	dialoguePanel.hide()
	dialogueText.text = ""
