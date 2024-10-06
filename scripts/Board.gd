extends Node2D

var DeckPlayingScene = preload("res://Scenes/DeckPlaying.tscn")
var CardSpawningScene = preload("res://Scenes/CardSpawning.tscn")

var rows = 4
var cols = 6
var spacing = Vector2(120, 160)

@onready var deck_label = $UI/Deck
@onready var deck_playing_instance = null

func _ready():
	_instantiate_deck_playing()
	_create_board()

func _process(delta):
	_update_deck_label()
	
func _instantiate_deck_playing():
	deck_playing_instance = DeckPlayingScene.instantiate()
	add_child(deck_playing_instance)  # Añadir DeckPlaying al árbol de nodos

func _create_board():
	for row in range(rows):
		for col in range(cols):
			var card_spawning_instance = CardSpawningScene.instantiate()  # Crear una instancia de CardSpawning
			add_child(card_spawning_instance)  # Añadir al árbol de nodos

			var position = Vector2(col * spacing.x, row * spacing.y) + Vector2(50, 50)  # Ajusta el offset según necesites
			card_spawning_instance.set_global_position(position)
			
func _update_deck_label():
	if deck_playing_instance != null:
		var remaining_cards = deck_playing_instance.deck_playing.size()
		deck_label.text = "Deck: " + str(remaining_cards)
