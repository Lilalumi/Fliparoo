extends Node2D

@onready var CardInPLayScene = preload("res://Scenes/CardInPlay.tscn")
@onready var card_in_play_instance = null

func _process(delta):
	if card_in_play_instance == null:
		_load_card_in_play()

func _load_card_in_play():
	card_in_play_instance = CardInPLayScene.instantiate()
	add_child(card_in_play_instance)
