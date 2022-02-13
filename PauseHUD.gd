extends CanvasLayer

signal resume_game
signal surrender_game


func _ready() -> void:
    pass # Replace with function body.


func game_paused() -> void:
    $Control.show()


func _on_ResumeButton_pressed() -> void:
    $Control.hide()
    emit_signal("resume_game")


func _on_SurrenderButton_pressed() -> void:
    $Control.hide()
    emit_signal("surrender_game")


func _on_QuitButton_pressed() -> void:
    if OS.get_name() == "HTML5":
        JavaScript.eval("window.location.href='about:blank'")
    else:
        get_tree().quit()
