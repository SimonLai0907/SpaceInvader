extends Area2D

func _on_Laser_entered(body):
	body.queue_free()
	queue_free()

func _on_Alien_entered(area):
	queue_free()
