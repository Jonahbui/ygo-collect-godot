class_name Meta
extends Resource

enum {
  # Set when the meta file created, indicating first time usage of the app (or user deleted the file)
  DB_NEW = 1,
  # Set when the user has requested the DB file to be redownloaded
  DB_UPDATE_REQUESTED = 2,
  SETS_NEED_DOWNLOAD = 4,
  CARDS_NEED_DOWNLOAD = 8
  CARD_RESOURCES_NEED_UPDATE = 16,
  SET_RESOURCES_NEED_UPDATE = 32,
}

export var mask : int
export var last_db_version : String
export var last_set_created : String = ""
export var last_card_created : int = -1

func _init():
  self.mask = DB_NEW
