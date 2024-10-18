extends Sprite3D

var display_time : float = 5.0 # Temps avant que le texte disparaisse
var fade_duration : float = 1.0 # Durée du fade-in et fade-out
var fade_progress : float = 0.0 # Progression du fade
var is_fading_in : bool = false # Pour savoir si on est en train de faire un fade-in
var is_fading_out : bool = false # Pour savoir si on est en train de faire un fade-out

var timer : Timer # Déclare la variable timer

func _ready() -> void:
	# On s'assure que le sprite texte est invisible au départ (alpha à 0)
	modulate.a = 0.0

	# Création du Timer pour gérer le délai de 5 secondes
	timer = Timer.new()
	timer.set_wait_time(display_time)
	timer.set_one_shot(true)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(timer)

func _process(delta: float) -> void:
	# Gestion du fade-in
	if is_fading_in:
		fade_progress += delta / fade_duration
		modulate.a = lerp(0.0, 1.0, fade_progress) # Alpha va de 0 à 1

		if fade_progress >= 1.0:
			is_fading_in = false # Arrêter le fade-in une fois complet

	# Gestion du fade-out
	elif is_fading_out:
		fade_progress += delta / fade_duration
		modulate.a = lerp(1.0, 0.0, fade_progress) # Alpha va de 1 à 0

		if fade_progress >= 1.0:
			is_fading_out = false # Arrêter le fade-out une fois complet
			visible = false # Rendre l'objet invisible après le fade-out

func _on_player_object_to_heavy() -> void:
	# Réinitialiser le texte et faire apparaître avec fade-in
	visible = true
	is_fading_in = true
	is_fading_out = false # Stopper le fade-out s'il est en cours
	fade_progress = 0.0 # Réinitialiser la progression du fade-in
	
	# Démarrer le timer pour cacher le texte après 5 secondes
	timer.start()
	print('object too heavy!')

func _on_timer_timeout() -> void:
	# Démarrer le fade-out après 5 secondes
	is_fading_out = true
	is_fading_in = false # Assurer que le fade-in s'arrête si en cours
	fade_progress = 0.0 # Réinitialiser la progression du fade-out
	print('text hidden')
