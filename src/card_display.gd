class_name CardSet
extends Control

onready var grid = $List/Scroll/Grid
onready var card_template = $List/Scroll/Grid/Card

var cards := []


func _ready() -> void:
  get_tree().connect("screen_resized", self, "window_size_changed")


func form_set(set:Set, cards:Array) -> void: 
  $List/SetName.text = set.set_name
  $List/Info/CardsInSet.text = str(set.num_of_cards)
  
  # Instance more cards for display if insufficient amount currently present
  if cards.size() > self.cards.size():
    for i in range (0, cards.size() - self.cards.size()):
      var new_card = card_template.duplicate()
      grid.call_deferred("add_child", new_card)
      self.cards.append(new_card)
  elif cards.size() < self.cards.size():
    for i in range(0, self.cards.size()):
      self.cards[i].hide()
  
  # Fill in cards with data
  var file := File.new()
  for i in range(0, cards.size()):
    var card_outline = self.cards[i]
    # TODO: actually pull numbers for the number of cards collected
    var total_quantity := 0
    
    # Display visually card status and its image
    var card_image : TextureButton = card_outline.get_node("Image")
    card_image.self_modulate = Color.white if total_quantity > 0 else Color.darkgray
    
    var texture = ImageTexture.new()
    texture.create_from_image(get_card_image(cards[i].id), 0)
    card_image.texture_normal = texture

    # Display name of card
    var card_name : RichTextLabel = card_outline.get_node("Name")
    card_name.text = cards[i].name
    
    card_outline.show()


func get_card_image(card_id) -> Image:
  var file := File.new()
  var image = Image.new()
  var image_path = "%s/%s.jpg" % [Externals.CARD_IMAGES_PATH, card_id]
  if not file.file_exists(image_path):
    var image_url = "%s/%s.jpg" % [Externals.IMAGE_DB_URL, card_id]
    $HTTPRequest.set_download_file(image_path)
    $HTTPRequest.request(image_url)
    var result = yield($HTTPRequest, "request_completed")
      
    if result[1] != OK:
      # TODO: return a default picture
      print("Error.")
      return null

  var error = image.load(image_path)
  if error != OK:
    # TODO: load a default picture
    print("Error loading image.")
    return null
  return image


func window_size_changed():
  var card_x = int(card_template.rect_size.x)
  var grid_pad_x = grid.get_constant("hseparation")
  var margin_x = get_constant("margin_left") + get_constant("margin_right")
  var window_x = OS.window_size.x - margin_x
  
  # NOTE: formula for the number of columns needed to fill in the grid
  # n = floor((z + y)/(x + y))
  # where
  # n : the number of columns needed to fill a grid
  # z : the x-size of the grid
  # y : the x-size of the padding between each elemennt in the grid
  # x : the x-size of the element in the grid
  grid.columns = int(floor((window_x + grid_pad_x) / (card_x + grid_pad_x)))
