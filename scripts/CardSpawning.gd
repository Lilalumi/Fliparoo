extends Node2D

@onready var CardInPLayScene = preload("res://Scenes/CardInPlay.tscn")
@onready var card_in_play_instance = null
@onready var board = get_node("/root/Board")  # Asegúrate de que este camino es correcto para encontrar Board

func _process(delta):
	if card_in_play_instance == null:
		_load_card_in_play()

func _load_card_in_play():
	var card_in_play_id_counter = 0
	
	card_in_play_instance = CardInPLayScene.instantiate()
	add_child(card_in_play_instance)
	# Asignar un ID único a cada CardInPlay
	card_in_play_instance.name = "CardSpawning_" + str(card_in_play_instance)
	card_in_play_id_counter += 1
	# Conectar las señales a Board.gd después de instanciar la carta
	board.connect_card_signals(card_in_play_instance)
