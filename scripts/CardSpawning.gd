extends Node2D

@onready var CardInPLayScene = preload("res://Scenes/CardInPlay.tscn")
@onready var card_in_play_instance = null
@onready var button = $Button


func _ready():
	_load_card_in_play()

func _load_card_in_play():
	if card_in_play_instance != null:
		card_in_play_instance.queue_free()
	
	card_in_play_instance = CardInPLayScene.instantiate()
	add_child(card_in_play_instance)
	card_in_play_instance.position = Vector2(47, 67)


func _on_button_pressed():
	_load_card_in_play()
