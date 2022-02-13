extends RigidBody2D


func _ready() -> void:
    pass # Replace with function body.


func _on_VisibilityNotifier2D_screen_exited() -> void:
    self.queue_free()
