extends Node
class_name FileSystem

export(String) var system_name

export(String) var system_owner

export(Array, Resource) var files

# Returns specified file in directory
func get_file(dir):
	for file in files:
		if file.location + "/" + file.file_name == dir:
			return file

# Returns all files in directory
func get_files(dir):
	var ret = []
	if not dir == "~" and not get_file(dir):
		return null
	for file in files:
		if file.location == dir:
			ret.append(file)
	return ret

# Returns owner of the file
func is_owner(user_name):
	return user_name == system_owner
