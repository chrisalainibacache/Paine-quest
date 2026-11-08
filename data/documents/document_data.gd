class_name DocumentData
extends Resource
## Nota o documento legible. Se guarda en la sección NOTAS de la mochila.

@export var id: String = ""
@export var title: String = ""
## Una entrada por página.
@export_multiline var pages: PackedStringArray = []
