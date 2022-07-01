tool
class_name ColorButton
extends Panel

signal pressed()

export(Color) var color_hover = Color.black
export(Color) var color_pressed = Color.gray
export(Color) var color_selected = Color.lightgray
export(Color) var color_disabled = Color.black
export(Color) var color_default = Color.white setget set_color_default
var color_current : Color setget set_color_current

func _ready() -> void:
  set_color_current(color_default)
  connect("mouse_entered", self, "on_mouse_entered")
  connect("mouse_exited", self, "on_mouse_exited")
  connect("gui_input", self, "on_gui_input")


func on_mouse_entered() -> void:
  set_color_current(color_hover)


func on_mouse_exited() -> void:
  set_color_current(color_default)


func on_gui_input(event:InputEvent) -> void:
  if Engine.editor_hint:
    return
  if event is InputEventMouseButton:
    if event.get_button_index() == 1:
      if event.pressed:
        set_color_current(color_pressed)
      else:
        emit_signal("pressed")
        set_color_current(color_selected if has_focus() else color_default)


func set_color_default(color:Color) -> void:
  color_default = color
  if get_stylebox("panel") == null:
    add_stylebox_override("panel", StyleBoxFlat.new())
  
  if Engine.editor_hint:
    var stylebox : StyleBoxFlat = self.get_stylebox("panel")
    stylebox.bg_color = color_default


func set_color_current(color:Color) -> void:
  color_current = color
  if get_stylebox("panel") == null:
    add_stylebox_override("panel", StyleBoxFlat.new())
  var stylebox : StyleBoxFlat = self.get_stylebox("panel")
  stylebox.bg_color = color_current
