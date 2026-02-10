 QUICKSTART: Building a 3D Game with AI Tools

> A practical guide on how to build a 3D action game using **Godot 4**, **AI coding assistants**, **Mixamo**, and **AI 3D model generators** — with zero prior game dev experience.

---

## The Stack

| Tool | Purpose | Cost |
|------|---------|------|
| [Godot 4](https://godotengine.org) | Game engine | Free & open source |
| AI Coding Assistant | Write scripts, debug, architecture | Varies |
| [Mixamo](https://mixamo.com) | Character animations | Free (Adobe account) |
| [Hunyuan 3D](https://hunyuan3d.tencent.com) | AI-generated 3D models | Free |
| [Blender](https://blender.org) | Model tweaking (optional) | Free |

---

## Phase 1: Design & Planning (AI Assistant)

### What to tell your AI assistant:

```
I want to build a [GENRE] game in Godot 4.
- The player should be able to [CORE MECHANICS].
- The setting is [ENVIRONMENT].
- The camera should be [CAMERA STYLE].
- Enemies should [ENEMY BEHAVIOR].
```

### What the AI generates for you:
- ✅ `project.godot` with input mappings
- ✅ State machine system (reusable for any game)
- ✅ Player controller with physics
- ✅ Camera system
- ✅ NPC/Enemy AI
- ✅ HUD/UI
- ✅ Scene files (.tscn)

### Pro tip:
> Be specific about the "feel" you want. Say things like "arcade physics like GTA" 
> or "tight controls like Celeste" — the AI understands game design references.

---

## Phase 2: Generate 3D Models (Hunyuan 3D)

Go to [hunyuan3d.tencent.com](https://hunyuan3d.tencent.com) and generate models.

### Effective prompts:

**Characters:**
```
Low poly [DESCRIPTION] character, cartoon style, 
simple geometry, vibrant colors, T-pose, game-ready
```

**Vehicles:**
```
Low poly [VEHICLE TYPE], simple geometry, 
cartoon proportions, clean topology
```

**Buildings/Props:**
```
Low poly [BUILDING TYPE], [STYLE] architecture, 
simple geometry, game asset, clean UV
```

### Export settings:
- Format: **FBX** or **GLB**
- Keep it low poly (AI tends to over-detail)

---

## Phase 3: Animate with Mixamo

### Step-by-step:
1. Go to [mixamo.com](https://mixamo.com)
2. **Upload** your character model (FBX from Hunyuan)
3. Mixamo auto-rigs it (places a skeleton inside)
4. **Search** for animations and download each one:
   - Format: **FBX for Unity** (works with Godot)
   - Check **"Without Skin"** for animation-only files (smaller)
   - Keep **"With Skin"** for the first one (this becomes your base model)

### Essential animations for an action game:
| Animation | Mixamo Search Term |
|-----------|-------------------|
| Idle | "Breathing Idle" |
| Walk | "Walking" |
| Run | "Running" |
| Jump | "Jump" |
| Punch | "Cross Punch" |
| Kick | "Roundhouse Kick" |
| Hit reaction | "Hit Reaction" |
| Death | "Falling Dead" |

### For other genres:
- **Shooter:** "Rifle Idle", "Rifle Walk", "Reload"
- **RPG:** "Sword Slash", "Cast Spell", "Pick Up"
- **Platformer:** "Double Jump", "Wall Climb", "Slide"

---

## Phase 4: Import into Godot

### 4.1 Import the base model
1. Place all FBX files in `assets/models/characters/[name]/`
2. Open Godot → files appear in FileSystem panel
3. The base model FBX imports as a **Scene** (default)

### 4.2 Import animations
For **each animation FBX** (NOT the base model):
1. Select the FBX in the FileSystem panel
2. Go to the **Import** dock (top left)
3. Change **Import As** → **Animation Library**
4. Click **Reimport**

### 4.3 Connect animations to your character
1. Open your character scene
2. Select the **AnimationPlayer** node
3. Click **Animation → Manage Animations → Load Library**
4. Select each reimported animation FBX
5. Set AnimationPlayer's **Root Node** to point to the node containing `Armature`

### 4.4 Common gotcha: "Couldn't resolve track"
This means the AnimationPlayer can't find the skeleton. Fix:
- Select AnimationPlayer → Inspector → **Root Node**
- Point it to the parent of your `Armature` node

---

## Phase 5: Iterate with AI

This is where AI coding assistants shine. You can ask for:

### Gameplay tweaks:
```
"Make the punch animation play at 2x speed"
"Add looping to walk and idle animations"
"Add a deadzone to prevent animation flickering"
```

### New features:
```
"Add a combo system: punch → punch → kick"
"Make enemies patrol between waypoints"
"Add a health bar that follows enemies"
```

### Bug fixes:
Just paste the error from Godot's console:
```
"I'm getting this error: [paste error]"
```

### Pro tips:
- **Share screenshots** of the Godot editor when stuck
- **Paste the full error** from the debug console
- **Describe the feel**, not just the code: "it feels floaty" > "change gravity to 20"
- **Iterate fast**: get it working, then polish

---

## Project Structure (Template)

```
your-game/
├── project.godot              # Godot config + input mappings
├── assets/
│   └── models/
│       └── characters/        # FBX models + animations
├── scripts/
│   ├── core/
│   │   ├── state_machine.gd   # Reusable state machine
│   │   └── state.gd           # Base state class
│   ├── player/
│   │   ├── player_controller.gd
│   │   └── states/            # Idle, Walk, Run, Jump, Attack...
│   ├── npc/
│   │   ├── npc_controller.gd
│   │   └── states/            # Patrol, Chase, Attack, Dead...
│   ├── vehicle/               # Optional: bikes, cars, etc.
│   ├── camera/
│   │   └── orbit_camera.gd    # Third-person camera
│   ├── managers/
│   │   └── transition_manager.gd
│   └── ui/
│       └── hud.gd
└── scenes/
    ├── main.tscn              # Main game scene
    ├── player/
    ├── npcs/
    └── ui/
```

---

## Animation Integration Pattern

The key pattern that makes AI-generated animations work in Godot:

```gdscript
# In your player controller, create a mapping dictionary:
@export var anim_map: Dictionary = {
    "idle": "idle/mixamo_com",
    "walk": "walking/mixamo_com",
    "run": "running/mixamo_com",
    "punch": "Cross Punch/mixamo_com",
    # ... etc
}

# Play animations by logical name, not file name:
func play_animation(name: String, loop: bool = false, speed: float = 1.0):
    var real_name = anim_map.get(name, name)
    var anim = animation_player.get_animation(real_name)
    if anim:
        anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
    animation_player.speed_scale = speed
    animation_player.play(real_name, 0.2)  # 0.2s crossfade
```

This decouples your game logic from Mixamo's naming convention.

---

## Common Issues & Solutions

| Problem | Solution |
|---------|----------|
| Model is huge/tiny | Scale the root node (try 0.01 or 100) |
| Animation doesn't play | Check AnimationPlayer's Root Node property |
| "Couldn't resolve track" | Root Node points to wrong node |
| Animation blips/flickers | Add crossfade blend time (0.2s) |
| States flicker rapidly | Add input deadzone (0.1 threshold) |
| Attack animation too slow | Use speed_scale parameter |
| Type inference errors | Use explicit types: `var x: float = clampf(...)` |
| FBX won't load as animation | Change Import As → Animation Library, Reimport |

---

## Workflow Summary

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  AI Assistant│────▶│  Hunyuan 3D │────▶│   Mixamo    │
│  (code +     │     │  (3D models)│     │ (animations)│
│   architecture)    └──────┬──────┘     └──────┬──────┘
└──────┬──────┘             │                   │
       │              ┌─────▼───────────────────▼─────┐
       └─────────────▶│         Godot 4               │
                      │   (assemble + iterate)        │
                      └───────────────────────────────┘
```

**Total cost: $0** (all tools are free or have free tiers)
**Time to first playable: ~2 hours**

---

## Next Level

Once your base game works:
- 🎵 **Audio**: [freesound.org](https://freesound.org) for SFX, [pixabay.com/music](https://pixabay.com/music) for BGM
- 🗣️ **Voice**: [ElevenLabs](https://elevenlabs.io) for NPC voices
- 🏗️ **Level Design**: Use Godot's CSG tools or Blender for custom geometry
- 🌐 **Textures**: Generate seamless textures with AI image generators
- 📦 **Export**: Godot exports to Windows, Linux, macOS, Android, iOS, and Web

---

*Built with ❤️ and AI. No game dev experience required.*
