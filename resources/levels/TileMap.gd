extends TileMap


# Damage-Map -> Stores the remaining hardness of cells
var remaining_hardness_dict = {}

# The layers
var ground_layer := 0
var block_layer := 1
var mine_overlay_layer := 2

# The mine-overlay-atlas
var mine_overlay_atlas := 1
# The current's biomes atlassssss
var block_atlas := 0
var ground_atlas := 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Logic of damaging cells
func damage_cell(cell: Vector2i, damage: float) -> bool:
		var was_ore :bool
		
		if remaining_hardness_dict.has(cell):
			# We know the cell -> Further reduce damage
			remaining_hardness_dict[cell] = remaining_hardness_dict[cell] - damage
		else:
			# Unknown cell -> New Entry
			remaining_hardness_dict[cell] = self.get_cell_tile_data(block_layer, cell).get_custom_data("hardness") - damage
		self.mine_overlay(cell)
		
		var attached_cell = null
		# Gotta check if cell itself is a wall
		if self.get_cell_atlas_coords(block_layer,cell,false).y == 1:
			attached_cell = self.get_neighbor_cell(cell,TileSet.CELL_NEIGHBOR_TOP_SIDE)
		# Same goes for it being the top of a wall
		if self.get_cell_atlas_coords(block_layer,self.get_neighbor_cell(cell,TileSet.CELL_NEIGHBOR_BOTTOM_SIDE),false).y == 1:
			attached_cell = self.get_neighbor_cell(cell,TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
		if attached_cell != null:
			remaining_hardness_dict[attached_cell] = remaining_hardness_dict[cell]
			self.mine_overlay(attached_cell)
		
		# Remove the tile when it's destroyed
		if remaining_hardness_dict[cell] < 0:
			was_ore = self.get_cell_tile_data(block_layer, cell).get_custom_data("is_ore")
			self.clear_cell(cell, attached_cell)
		return was_ore


# Puts an overlay on the specified cell
func mine_overlay(cell: Vector2i) -> void:
	# Sometimes this function get's called out of sync...
	if(self.get_cell_tile_data(block_layer, cell) == null):
			return
	
	var percent = 1 - remaining_hardness_dict[cell] / self.get_cell_tile_data(block_layer, cell).get_custom_data("hardness")
	if percent < 0.25:
		self.set_cell(mine_overlay_layer,cell,mine_overlay_atlas, Vector2i(0,0), 0)
		return
	if percent < 0.5:
		self.set_cell(mine_overlay_layer,cell,mine_overlay_atlas, Vector2i(1,0), 0)
		return
	if percent < 0.75:
		self.set_cell(mine_overlay_layer,cell,mine_overlay_atlas, Vector2i(2,0), 0)
		return
	if percent < 1:
		self.set_cell(mine_overlay_layer,cell,mine_overlay_atlas, Vector2i(3,0), 0)
		return


# Clears the cell - TODO NAV-UPDATES
func clear_cell(cell: Vector2i, attached_cell) -> void:
	# If it's just a random Block
	# TODO Nav-updates!
	if(attached_cell == null):
		# Gotta check for layer ontop
		var top_cell = self.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_TOP_SIDE)
		if self.get_cell_source_id(block_layer, top_cell, false) != -1:
			# There's something on top of it -> let's see if it is a top or a wall
			if self.get_cell_atlas_coords(block_layer,top_cell,false).y == 0:
				# It's a top -> Gotta make a wall
				self.erase_cell(mine_overlay_layer, cell)
				remaining_hardness_dict.erase(cell)
				# Get the x-atlas-coords of the cell ABOVE the top_cell -> we need the correct wall
				var top_atlas_coords_x = self.get_cell_atlas_coords(block_layer,self.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_TOP_SIDE),false).x
				self.set_cell(block_layer, cell, block_atlas,Vector2i(top_atlas_coords_x,1), 0)
				self.set_cell(ground_layer, cell, ground_atlas,Vector2i(0,0), 0)
				return
		
		# Nothing on top of it/it's a wall -> delete it
		self.erase_cell(mine_overlay_layer, cell)
		remaining_hardness_dict.erase(cell)
		self.erase_cell(block_layer, cell)
		self.set_cell(ground_layer, cell, 2, Vector2i(0,0), 0)
		
		
	# We have a wall!
	else:
		var top_cell :Vector2i
		var wall_cell :Vector2i
		if attached_cell.y > cell.y:
			top_cell = cell
			wall_cell = attached_cell
		else:
			top_cell = attached_cell
			wall_cell = cell
		
		# Handle Wall-Cell
		self.erase_cell(mine_overlay_layer, wall_cell)
		remaining_hardness_dict.erase(wall_cell)
		self.erase_cell(block_layer, wall_cell)
		self.set_cell(ground_layer, wall_cell, ground_atlas,Vector2i(0,0), 0)
		
		# Handle Top-Cell aka make it a Wall IF there is another cell above it and it's NOT a wall
		var top_top_cell = self.get_neighbor_cell(top_cell, TileSet.CELL_NEIGHBOR_TOP_SIDE)
		if self.get_cell_source_id(block_layer, top_top_cell, false) != -1:
			# There's something on top of it -> let's see if it is a top or a wall
			if self.get_cell_atlas_coords(block_layer,top_top_cell,false).y == 0:
				# It's NOT a wall!
				self.erase_cell(mine_overlay_layer, top_cell)
				remaining_hardness_dict.erase(top_cell)
				# Get the x-atlas-coords of the cell ABOVE the top_cell -> we need the correct wall
				var top_atlas_coords_x = self.get_cell_atlas_coords(block_layer,self.get_neighbor_cell(top_cell, TileSet.CELL_NEIGHBOR_TOP_SIDE),false).x
				self.set_cell(block_layer, top_cell, block_atlas,Vector2i(top_atlas_coords_x,1), 0)
				self.set_cell(ground_layer, top_cell, ground_atlas,Vector2i(0,0), 0)
				return
		
		# Nothing/wall on top of it -> delete it
		self.erase_cell(mine_overlay_layer, top_cell)
		remaining_hardness_dict.erase(top_cell)
		self.erase_cell(block_layer, top_cell)
		self.set_cell(ground_layer, top_cell, ground_atlas,Vector2i(0,0), 0)
