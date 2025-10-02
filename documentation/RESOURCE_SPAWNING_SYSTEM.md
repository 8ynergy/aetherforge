# Resource Spawning System

## Overview
The Resource Spawning System automatically spawns resources in the Mine scene based on cave level, using a grid-based approach to prevent overlapping and ensure proper spacing.

## Features
- **Grid-based spawning**: Resources spawn on a grid to prevent overlapping
- **Collision avoidance**: Resources won't spawn in the existing CollisionShape2D area
- **Viewable area constraints**: Resources only spawn within camera view + margin
- **Cave level system**: Different resource types and ratios per cave level
- **Timed spawning**: Initial spawn + periodic new spawns every 10 seconds
- **Memory management**: Grid positions are freed when resources are depleted

## Configuration

### Balance.gd Settings
```gdscript
# Resource spawning settings
const RESOURCE_SPAWN_SETTINGS = {
    "base_spawn_count": 20,    # Initial number of resources to spawn
    "spawn_interval": 10.0,    # Seconds between new resource spawns
    "grid_size": 64,           # Grid cell size in pixels
    "spawn_margin": 100        # Distance from screen edges
}

# Cave level resource configurations
const CAVE_LEVEL_RESOURCES = {
    1: {"stone": 5, "copper": 1},  # 5:1 ratio for level 1
    2: {"stone": 4, "copper": 2, "iron": 1},
    3: {"stone": 3, "copper": 3, "iron": 2, "silver": 1}
}
```

## Cave Level System

### Global.gd Methods
```gdscript
# Get current cave level
var level = Global.get_cave_level()

# Set cave level
Global.set_cave_level(2)

# Advance to next cave level
Global.advance_cave_level()
```

## Testing Controls

When in the Mine scene, you can use these keyboard shortcuts for testing:

- **Key 1**: Spawn a single resource
- **Key 2**: Clear all resources
- **Key 3**: Cycle through cave levels (1 → 2 → 3 → 1)

## How It Works

1. **Initialization**: When the Mine scene loads, the ResourceSpawner spawns 20 initial resources
2. **Grid System**: Each resource is placed on a 64x64 pixel grid to prevent overlapping
3. **Collision Detection**: The system checks against the existing CollisionShape2D area
4. **Viewable Area**: Resources only spawn within the camera view + 100px margin
5. **Periodic Spawning**: Every 10 seconds, a new resource spawns
6. **Resource Selection**: Resource type is selected based on cave level ratios
7. **Cleanup**: When a resource is depleted, its grid position is freed

## Resource Types

Currently supported resource types:
- **Stone** (NodeRock): Basic resource, 2 HP
- **Copper** (NodeCopper): Valuable resource, 8 HP

## File Structure

```
scripts/systems/ResourceSpawner.gd    # Main spawning logic
scripts/singletons/Balance.gd         # Configuration settings
scripts/singletons/Global.gd          # Cave level management
scenes/main/Mine.tscn                 # Scene with ResourceSpawner node
scenes/main/Mine.gd                   # Test controls
```

## Adding New Resource Types

1. Create the resource scene (e.g., NodeIron.tscn)
2. Add the resource type to `RESOURCE_SCENES` in ResourceSpawner.gd:
   ```gdscript
   const RESOURCE_SCENES = {
       "stone": "res://scenes/world/Resources/NodeRock/NodeRock.tscn",
       "copper": "res://scenes/world/Resources/NodeCopper/NodeCopper.tscn",
       "iron": "res://scenes/world/Resources/NodeIron/NodeIron.tscn"
   }
   ```
3. Add the resource to cave level configurations in Balance.gd
4. Ensure the resource extends ResourceNode class

## Troubleshooting

- **Resources not spawning**: Check that the ResourceSpawner node is properly added to Mine.tscn
- **Resources overlapping**: Verify grid_size is appropriate for resource sprite sizes
- **Resources spawning outside view**: Adjust spawn_margin in Balance.gd
- **Wrong resource types**: Check cave level configuration in Balance.gd

