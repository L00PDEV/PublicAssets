extends Node

@export var _object_center:Node3D

# Get cameraPivot. It's used to calculate the visible angle
@export var CameraPivot : Node3D

# Get the Item Title to show the Title
@export var item_title:Label
# Get the Item SubTitle to show the SubTitle
@export var item_subtitle:Label

# This contains all the loaded mesh of each item
var item_meshes: Dictionary = {}

# Import all i-2,i-1,i0,i1,i2 (instances)
var childs = []

func _ready() -> void:
	# Auto pre-import every mesh from ItemMeshes folder to item_meshes
	for file in DirAccess.get_files_at("res://Assets/item_meshes/"):
		if file.ends_with(".res"):
			item_meshes[file.get_basename()] = load("res://Assets/item_meshes/" + file)
	
	# All i-2,i-1,i0,i1,i2 imported
	childs = _object_center.get_children()


# Test: List of items inside the inventory in order #It's currently set only for testing purpose
var inventory_items = [
	"diamond",
	"box",
	"sphere",
	"box",
	"box",
	"sphere",
	"sphere",
	"diamond",
	"box",
	"box",
	"box",
	"box",
	"box",
]

# Item Index in selection
var selected_item_index:int = 0
var current_viewing_index : float = 0.0 # Used for animating slide
func _process(delta: float) -> void:
	# -- INPUT -- TEMEPORARY, must be organized --
	# Sliding instances Left
	if Input.is_action_just_pressed("move_left"):
		selected_item_index-=1
		selected_item_index = max(selected_item_index,0)
	# Sliding instances Right
	if Input.is_action_just_pressed("move_right"):
		selected_item_index+=1
		selected_item_index = min(selected_item_index,len(inventory_items)-1)
	
	# --- SET MESH TO INSTANCE CHILD ---
	# layout: i-2=-90, i-1=-45, i0=0, i1=45 i2=90 (Instances)
	
	# Starting point/Reset
	var i:int = -2 # for Instance Rotation
	var i_index : int = int(current_viewing_index)-2 # for Mesh Rotation (Visual purpose only)
	
	# Set CAMERA PIVOT rotation to range(0° to 45°) using Fractional part of current_viewing_index
	CameraPivot.rotation.y = (current_viewing_index-int(current_viewing_index))*deg_to_rad(45)
	
	# --- Directly replace the Mesh of Instances without changeing location
	for x:Node3D in childs:
		# Set the acctual starting position of all Instnaces: -90,-45,0,45,90
		x.rotation.y = i*deg_to_rad(45)
		
		var x_child:MeshInstance3D = x.get_child(0) # Get MeshInstance of the Instance
		x_child.rotation.y+=delta # Rotate all meshes separately Visual Purpose Only
		x.visible = true # Reset
		# Hide Instance if out of possible inventory index(x<0 or x>inventory)
		if i_index<0 or i_index>=len(inventory_items):
			x.visible = false
		
		# ONLY if it exists [0,1,2,3...,n]
		if x.visible:
			# Set Mesh: Of children
			x_child.mesh = item_meshes[inventory_items[i_index]]
		# Just counting
		i+=1
		i_index+=1
	
	# --- Rotate the camera range(0° to 45°) --- Looks like the Instances are sliding instead ---
	# update current_viewing_index
	current_viewing_index = lerpf(current_viewing_index,selected_item_index,delta*10)
	
	# Set Item Title to make it easier to know what item you're looking at
	item_title.text = inventory_items[selected_item_index]
