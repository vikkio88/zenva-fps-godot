extends Spatial

func _enter_tree():
	play()

func play():
	$Particles.emitting = true
