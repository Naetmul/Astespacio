extends CanvasLayer

signal start_game

const license_scene = preload("res://License.tscn")


func show_message(text: String) -> void:
    $Control/Message.text = text
    $Control/Message.show()
    $MessageTimer.start()


func show_game_over() -> void:
    show_message("Game Over")
    
    yield($MessageTimer, "timeout")
    
    $Control/Message.text = "Astespacio"
    $Control/Message.show()
    
    yield(get_tree().create_timer(1), "timeout")
    $Control/HBoxContainer.show()
    $Control/LicenseButton.show()
    
    
func update_score(score: int) -> void:
    $Control/VBoxContainer/ScoreLabel.text = str(score)
    
    
func update_highscore(highscore: int, is_new: bool = false) -> void:
    if is_new:
        $Control/VBoxContainer/HighscoreLabel.text = "New Highscore: %s!" % highscore
    else:
        $Control/VBoxContainer/HighscoreLabel.text = "Best: %s" % highscore
    
    
func show_highscore() -> void:
    $Control/VBoxContainer/HighscoreLabel.show()
    
    
func hide_highscore() -> void:
    $Control/VBoxContainer/HighscoreLabel.hide()


func _on_StartButton_pressed() -> void:
    $Control/HBoxContainer.hide()
    $Control/LicenseButton.hide()
    emit_signal("start_game")


func _on_QuitButton_pressed() -> void:
    if OS.get_name() == "HTML5":
        JavaScript.eval("window.location.href='about:blank'")
    else:
        get_tree().quit()


func _on_MessageTimer_timeout() -> void:
    $Control/Message.hide()


func _on_LicenseButton_pressed() -> void:
    $Control.hide()
    var license = license_scene.instance()
    license.HUD_control_path = $Control.get_path()
    get_viewport().add_child(license)
