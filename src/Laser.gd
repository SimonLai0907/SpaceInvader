extends RigidBody2D



signal destroy()

func _ready() -> void:
	pass
	
func setup(side, startposition):
	if side == "Player":
		linear_velocity.y *= -1
		set_collision_mask_bit(1, true)
	else:
		set_collision_mask_bit(0, true)
		$AnimatedSprite.play("Alien")
	position = startposition

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	if $AnimatedSprite.animation == "Player":
		emit_signal("destroy")
	queue_free()
