class_name Bitmask
extends Reference


static func clear(mask:int) -> int:
  mask = 0
  return mask


static func set_flag(mask:int, flag: int, state: bool) -> int:
  if state == true:
    mask |= flag
  else:
    mask &= (~flag)
  return mask


static func is_flag_set(mask:int, flag: int) -> bool:
  return bool(flag&mask)


static func are_flags_sets(mask:int, flags: int) -> bool:
  return is_flag_set(mask, flags)


static func toggle_flag(mask:int, flag: int) -> bool:
  var result = !is_flag_set(mask, flag)
  set_flag(mask, flag, result)
  return result

