extends Node

export var Alien: PackedScene
export var Laser: PackedScene
export var Block: PackedScene
var AlienRow = 3
export var AlienCol = 6
var AlienCount = AlienRow * AlienCol
export var MoveTime = 1.0
var MoveDirection = 0.0
var Score = 0
var Level = 1
var Lives = 3

func _ready() -> void:
	randomize()
	$HUD/Message.visible = false
	$HUD.set_lives(Lives)
	$HUD.set_score(Score)
	game_start()
	create_block()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_end"):
		get_tree().call_group("Alien", "explode")

func game_start():
	get_tree().call_group("Laser", "queue_free")
	get_tree().call_group("Alien", "queue_free")
	var StartPt = $AlienStartPoint.global_position
	var Grid = Vector2(80, 60)
	for row in range(AlienRow):
		for col in range(AlienCol):
			var mob = Alien.instance()
			mob.position = Vector2(StartPt.x + (-float(AlienCol - 1) / 2 + col) * Grid.x, StartPt.y + row * Grid.y)
			mob.Type = row
			mob.get_node("AnimatedSprite").play("type%d" % row)
			add_child(mob)
			mob.connect("AddScore", self, "_alien_destroy")
	AlienCount = AlienRow * AlienCol
	MoveTime = 1.0
	MoveDirection = 0.0
	$Player.initialize()
	$HUD/Message.visible = false
	$MoveTimer.start(MoveTime)
	$ShootTimer.start(0.5 + randf())

func create_block():
	var StartPt = $BlockStartPoint.global_position
	var Grid = 200.0
	for i in range(3):
		var block = Block.instance()
		block.position = Vector2(StartPt.x + Grid * float(i - 1), StartPt.y)
		add_child(block)

func mobs_move():
	var mobs = get_tree().get_nodes_in_group("Alien")
	var UTurn = false
	for m in mobs:
		if (MoveDirection == 0 and m.position.x >= 565) or (MoveDirection == PI and m.position.x <= 35):
				UTurn = true
				break
	if UTurn:
		MoveDirection = PI - MoveDirection
		get_tree().call_group("Alien", "move", PI / 2)
	else:
		get_tree().call_group("Alien", "move", MoveDirection)

func restart():
	$HUD.show_message("Clear!")
	yield(get_tree().create_timer(2), "timeout")
	game_start()

func gameover():
	$HUD.show_message("Game Over")
	print("Wait for timer")
	yield(get_tree().create_timer(2), "timeout")
	print("Restart game")
	game_start()
	create_block()
	Score = 0
	Level = 1
	Lives = 3
	$HUD.set_score(Score)
	$HUD.set_lives(Lives)

func mob_shoot():
	var mobs = get_tree().get_nodes_in_group("Alien")
	if len(mobs) == 0:
		return
	var mob = mobs[randi() % len(mobs)]
	var laser = Laser.instance()
	laser.setup("Alien", mob.get_node("LazerPosition").global_position)
	get_parent().add_child(laser)
	$ShootTimer.start(0.5 + randf() * 2)

func _alien_destroy(score):
	if Lives > 0:
		AlienCount -= 1
		Score += score
		$HUD.set_score(Score)
		if AlienCount == 0:
			restart()
			return
		MoveTime = float(AlienCount*AlienCount) / float(AlienRow*AlienRow * AlienCol*AlienCol)

func _on_MoveTimer_timeout():
	mobs_move()
	$MoveTimer.start(MoveTime)

func _on_Player_Damaged(damage):
	if AlienCount > 0:
#		print("Player damaged(%d)" % damage)
		Lives -= damage
		if Lives <= 0:
#			print("Game over")
			Lives = 0
			$Player/RecoverTimer.stop()
			$Player.visible = false
			gameover()
		else:
			$Player/AnimationPlayer.play("Damaged")
		$HUD.set_lives(Lives)

