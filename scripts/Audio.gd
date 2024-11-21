extends Node

func play(sound: AudioStream):
	var new_player = AudioStreamPlayer.new()
	new_player.stream = sound
	add_child(new_player)
	new_player.play()
	
	# Use a Timer to check when the sound is done
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = sound.get_length()  # AudioStream's length in seconds
	timer.one_shot = true

	# Use Callables to connect signals in Godot 4.0
	timer.timeout.connect(new_player.queue_free)
	timer.timeout.connect(timer.queue_free)

	timer.start()
