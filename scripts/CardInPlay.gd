extends Node2D

@onready var sprite_front = $Front
@onready var sprite_back = $Back
@onready var button = $Button
@onready var animation_player = $AnimationPlayer

@onready var deck_playing = get_node("/root/Board/DeckPlaying")
var remaining_cards = 0

#Control de lado visible
var up_front = false
var up_down = true

# Propiedades de la carta
var suit: String = ""  # Añadir la propiedad "suit"
var number: int = 0    # Añadir la propiedad "number"
var modifier: String = "none"  # Añadir la propiedad "modifier"

#variables efectos
var wave_amplitude = 0
var wave_speed = 2
var rotation_amplitude = 0
var rotation_speed = 1.5
var time = 0

# Definir señales personalizadas
signal card_instantiated
signal card_flipped_to_front
signal card_flipped_to_back
signal card_destroyed


func _ready():
	await get_tree().create_timer(0.01).timeout
	# Emitir la señal cuando la carta se instancia
	emit_signal("card_instantiated", self)
	#Animacion aparicion
	animation_player.play("appear")
	#Animacion ola y rotación
	wave_amplitude = randf_range(2, 5)
	rotation_amplitude = randf_range(1, 5)
	#Elige carta frontal
	_choose_card()
	
	set_process(true)
	
func _process(delta):
	time += delta
	#Efecto wave
	var wave_offset = sin(time * wave_speed) + wave_amplitude
	position.y = 68 + wave_offset
	position.x = 46 + sin(time * wave_speed) * wave_amplitude
	#Efecto rotacion
	var rotation_offset = sin(time * rotation_speed) * deg_to_rad(rotation_amplitude)
	rotation = rotation_offset
	

func _choose_card():
	remaining_cards = int(deck_playing.deck_playing.size())
	if remaining_cards == 0:
		print("Game Over")
	else:
		var card = deck_playing.deck_playing.pop_back()
		suit = card.suit
		number = card.number
		modifier = card.modifier
		
		sprite_front.texture = card.image
		
	_show_back()
			
func _show_front():
	sprite_front.visible = true
	sprite_back.visible = false
	up_front = true
	up_down = false
	emit_signal("card_flipped_to_front", self)

func _show_back():
	sprite_front.visible = false
	sprite_back.visible = true
	up_front = false
	up_down = true
	emit_signal("card_flipped_to_back", self)
	
func _on_button_pressed():
	if up_front:
		_flip_to_back()
	else:
		_flip_to_front()
		
# Flip hacia el dorso
func _flip_to_back():
	animation_player.play("flip_to_back")
	await animation_player.animation_finished
	_show_back()
	
# Flip hacia el frente
func _flip_to_front():
	animation_player.play("flip_to_front")
	await animation_player.animation_finished
	_show_front()
	
# Flip hacia el dorso
func _flip_to_back_failed_check():
	animation_player.play("flip_to_back")
	await animation_player.animation_finished
	_show_back()
	
# Desinstanciar con efecto de fade y crecimiento
func _destroy_with_effect():
	animation_player.play("destroy")
	await animation_player.animation_finished
	emit_signal("card_destroyed", self)
	queue_free()  # Destruir el nodo
