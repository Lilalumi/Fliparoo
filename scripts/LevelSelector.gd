extends Control

@onready var level1_button = $Nivel1
var BoardScene = preload("res://Scenes/Board.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	level1_button.connect("pressed", Callable(self, "_on_level_pressed"))

func _on_nivel_1_pressed():
	_load_board()
	level1_button.visible = false
	
func _load_board():
	var board_instance = BoardScene.instantiate()
	get_tree().root.add_child(board_instance)
