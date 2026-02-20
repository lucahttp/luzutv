## Pre-PR Validation

All steps must pass before submitting to ensure project stability:

```bash
# 1. Headless Syntax Check
# Verifies all GDScript files for syntax errors without opening the editor
godot --headless --check-only

# 2. Main Scene Smoke Test
# Ensures the main scene can load and initialize without immediate crashes
godot --headless --main-scene res://scenes/main.tscn --quit

# 3. Export Validation (Optional but recommended)
# Verifies that the project can be exported for the primary target
# godot --headless --export-debug "Windows Desktop" exports/validation_build.exe
```

### Checklist
- [ ] No syntax errors in GDScript (`--check-only` passes)
- [ ] Main scene loads and quits successfully
- [ ] No "Red" errors in the Godot Output console on startup
- [ ] README updated (if adding new features or dependencies)
- [ ] Assets are correctly imported and `.import` files are tracked