class_name RecipeData
extends Resource
## Receta de combinación A + B → resultado. Los ingredientes se comparan
## por ID estable, no por el nombre visible.

@export var id: String = ""
@export var ingredient_a: ItemData
@export var ingredient_b: ItemData
@export var result_item: ItemData
@export_range(1, 99, 1) var result_count: int = 1


func is_valid() -> bool:
    return not id.strip_edges().is_empty() and ingredient_a != null and ingredient_b != null \
        and result_item != null and result_count > 0 \
        and result_item.id != ingredient_a.id and result_item.id != ingredient_b.id


func matches(first: ItemData, second: ItemData) -> bool:
    if not is_valid() or first == null or second == null:
        return false
    var direct := first.id == ingredient_a.id and second.id == ingredient_b.id
    var reverse := first.id == ingredient_b.id and second.id == ingredient_a.id
    return direct or reverse


func partner_for(item: ItemData) -> ItemData:
    if not is_valid() or item == null:
        return null
    if item.id == ingredient_a.id:
        return ingredient_b
    if item.id == ingredient_b.id:
        return ingredient_a
    return null


static func all_recipes() -> Array[RecipeData]:
    var recipes: Array[RecipeData] = []
    var directory := DirAccess.open("res://data/recipes")
    if directory == null:
        return recipes
    var files := directory.get_files()
    files.sort()
    for file_name: String in files:
        if file_name.get_extension().to_lower() != "tres":
            continue
        var recipe := load("res://data/recipes/" + file_name) as RecipeData
        if recipe != null and recipe.is_valid():
            recipes.append(recipe)
    return recipes


static func find_recipe(first: ItemData, second: ItemData) -> RecipeData:
    for recipe: RecipeData in all_recipes():
        if recipe.matches(first, second):
            return recipe
    return null
