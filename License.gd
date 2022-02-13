extends CanvasLayer

export(NodePath) var HUD_control_path


func _on_LicenseLabel_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        get_node(HUD_control_path).show()
        self.queue_free()
