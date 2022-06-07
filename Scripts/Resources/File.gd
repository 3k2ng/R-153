extends Resource
class_name File

enum FileType {
	DIRECTORY,
	TEXT,
	EXECUTABLE
}

export(FileType) var fileType

export var location: String
