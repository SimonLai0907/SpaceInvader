extends CanvasLayer

func show_message(message):
	$Message.visible = true
	$Message.text = message

func set_score(score):
	$Score.text = "Score: %d" % score

func set_lives(lives):
	if lives < 0:
		lives == 0
	$Lives.text = "Lives: %d" % lives
