
#signal actionConfirmed(actionName)
#emit_signal("actionConfirmed", actionLabels[selectedAction].text)

#get_node(UI).connect("actionConfirmed", onActionConfirmed) #nazwa sygnalu, nazwa funckji
#func onActionConfirmed(actionName: String) -> void:
