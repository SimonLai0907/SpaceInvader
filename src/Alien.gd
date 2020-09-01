extends Area2D

class_name Alien

export var Type = 0
export var MoveDistance = 5
export var score = 10
signal AddScore(score)

func _ready():
	pass

func move(direction):
	var distance = MoveDistance
	if direction == PI / 2:
		distance = MoveDistance * 5
#	if $AnimatedSprite.animation.begins_with("type"):
	position += Vector2(cos(direction) * distance, sin(direction) * distance)
	$AnimatedSprite.frame = 1 - $AnimatedSprite.frame
#	if $AnimatedSprite.frame == 0:
#		$AnimatedSprite.frame = 1
#	else:
#		$AnimatedSprite.frame = 0

func explode():
	$AnimatedSprite.play("explode%d" % Type)
	$CollisionShape2D.set_deferred("disabled", true)
	remove_from_group("Alien")
	
func _on_Laser_entered(body):
	explode()
	emit_signal("AddScore", score)
	body.queue_free()

func _on_animation_finished():
	if $AnimatedSprite.animation.begins_with("explode"):
		queue_free()
