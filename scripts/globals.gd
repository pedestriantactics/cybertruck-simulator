# this is where the archive code (version number) is stored

extends Node

var archive_code = "PT-G3-0"

# Determines the lowest decibel value that can be used for volume.
const MIN_DB = -80

# Determines the highest decibel value that can be used for volume.
const MAX_DB = 0

# Master volume as a linear value between 0 and 1. Automatically
# converts to/from decibels when setting/getting the value.
var master_volume: float:
	get:
		var volume_db = AudioServer.get_bus_volume_db(0)
		return db_to_linear(volume_db)
	set(value):
		value = linear_to_db(clamp(value, 0, 1))
		AudioServer.set_bus_volume_db(0, value)
