class_name ColorButton
extends ColorRect

signal pressed()

export(Color) var color_hover = Color.white
export(Color) var color_pressed = Color.white
export(Color) var color_selected = Color.white
export(Color) var color_disabled = Color.white

export(bool) var modulate_children = true


func _ready() -> void:
  connect("mouse_entered", self, "on_mouse_entered")
  connect("mouse_exited", self, "on_mouse_exited")
  connect("gui_input", self, "on_gui_input")


func on_mouse_entered() -> void:
  pass # Replace with function body.


func on_mouse_exited() -> void:
  pass


func on_gui_input(event:InputEvent) -> void:
  if event is InputEventMouseButton:
    if event.get_button_index() == 1:
      if event.pressed:
        emit_signal("pressed")
