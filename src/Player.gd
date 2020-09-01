extends Area2D

signal Damage(damage)
export var Speed = 300
var Direction = 0.0
var ScreenSize
export var Laser: PackedScene
var Ammo = 2
export var MaxAmmo = 2
var CoolTime = 0.0
export var CoolTimeLimit = 0.3

func _ready() -> void:
	ScreenSize = get_viewport_rect().size

func _process(delta: float) -> void:
	CoolTime += delta
	Direction = 0.0
	if Input.is_action_pressed("ui_left"):
		Direction -= 1
	if Input.is_action_pressed("ui_right"):
		Direction += 1
	position.x = clamp(position.x + Direction * Speed * delta, 25, ScreenSize.x - 25)
	if Input.is_action_just_pressed("ui_select") and Ammo > 0 and CoolTime > CoolTimeLimit and !$CollisionPolygon2D.disabled:
		Shoot()

func initialize():
	$CollisionPolygon2D.set_deferred("disabled", false)
#	set_collision_layer_bit(0, true)
	$AnimationPlayer.play("Normal")
	visible = true
	position.x = ScreenSize.x / 2

func Shoot():
	Ammo -= 1
	CoolTime = 0.0
	var laser = Laser.instance()
	laser.setup("Player", $LazerPosition.global_position)
	get_parent().add_child(laser)
	laser.connect("destroy", self, "_ammo_recover")

func _ammo_recover():
	if Ammo < MaxAmmo:
		Ammo += 1
		
func _on_Laser_entered(body):
	body.queue_free()
	$CollisionPolygon2D.set_deferred("disabled", true)
#	set_collision_layer_bit(0, false)
	$RecoverTimer.start(1.0)
	emit_signal("Damage", 1)
	
func _on_RecoverTimer_timeout():
	$CollisionPolygon2D.set_deferred("disabled", false)
#	set_collision_layer_bit(0, true)
	$AnimationPlayer.play("Normal")

func _on_Alien_entered(area):
#	set_collision_layer_bit(0, false)
	$CollisionPolygon2D.set_deferred("disabled", true)
	emit_signal("Damage", 3)
