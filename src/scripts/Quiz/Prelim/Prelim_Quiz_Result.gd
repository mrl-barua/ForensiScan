extends Node2D

@onready var score_label: Label = $ScoreLabel
@onready var history_label: RichTextLabel = $HistoryText

# Called when the node enters the scene tree for the first time.
func _ready():
	score_label.text = "Your Score: %d/10" % QuizManager.get_score()
	var answers = QuizManager.get_answer_history()
	var history_text = ""
	for entry in answers:
		history_text += "[b]Q:[/b] %s\n" % entry["question"]
		history_text += "[b]Your Answer:[/b] %s\n" % entry["selected"]
		history_text += "[b]Correct Answer:[/b] %s\n\n" % entry["correct"]
	history_label.text = history_text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
