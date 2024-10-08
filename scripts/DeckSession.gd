extends Node

var deck_session = []
var hand_size_session = 0
var unflip_count_session = 0

@onready var start_button = $StartGame

@onready var deck_core = get_node("/root/Main/DeckCore")

@onready var LevelSelectorScene = preload("res://Scenes/LevelSelector.tscn")

func _ready():
	if not start_button.is_connected("pressed", Callable(self, "_on_start_game_pressed")):
		start_button.connect("pressed", Callable(self, "_on_start_game_pressed"))
		
# Función que se llama cuando se presiona el botón "Start Game"
func _on_start_game_pressed():
	_copy_deck()
	start_button.visible = false
	
	if LevelSelectorScene is PackedScene:
		var instance = LevelSelectorScene.instantiate()
		add_child(instance)
		instance.set_global_position(Vector2.ZERO)
	else:
		print("Error: El recurso no es un PackedScene")
	

# Copia las cartas de deck_core a deck_session
func _copy_deck():
	deck_session.clear()  # Limpiar cualquier carta existente en deck_session
	for card in deck_core.deck_core:
		deck_session.append(card.duplicate())  # Hacer una copia de cada carta para evitar referencias directas
	hand_size_session = deck_core.hand_size_core
	unflip_count_session = deck_core.unflip_count_core
	
