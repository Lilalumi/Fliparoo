extends Node2D

var DeckPlayingScene = preload("res://Scenes/DeckPlaying.tscn")
var CardSpawningScene = preload("res://Scenes/CardSpawning.tscn")

var rows = 4
var cols = 6
var spacing = Vector2(120, 160)

func _ready():
	_instantiate_deck_playing()
	_create_board()
	
func _instantiate_deck_playing():
	var deck_playing_instance = DeckPlayingScene.instantiate()
	add_child(deck_playing_instance)  # Añadir DeckPlaying al árbol de nodos

func _create_board():
	for row in range(rows):
		for col in range(cols):
			var card_spawning_instance = CardSpawningScene.instantiate()  # Crear una instancia de CardSpawning
			add_child(card_spawning_instance)  # Añadir al árbol de nodos

			var position = Vector2(col * spacing.x, row * spacing.y) + Vector2(50, 50)  # Ajusta el offset según necesites
			card_spawning_instance.set_global_position(position)
