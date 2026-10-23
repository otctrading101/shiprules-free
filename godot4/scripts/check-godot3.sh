#!/usr/bin/env bash
# Fails if any .gd file contains Godot 3 syntax. Usage: ./check-godot3.sh [dir]
set -u
dir="${1:-.}"
patterns=(
  '^[[:space:]]*export[[:space:]]*(\(|var[[:space:]])'   # export var  -> @export var
  '^[[:space:]]*onready[[:space:]]+var'                   # onready     -> @onready
  '^tool[[:space:]]*$'                                    # tool        -> @tool
  '\byield[[:space:]]*\('                                 # yield(...)  -> await
  '\bsetget\b'                                            # setget      -> set/get blocks
  '^[[:space:]]*(puppet|remote|master|remotesync|puppetsync|mastersync)[[:space:]]+func'
  'connect\([[:space:]]*"[^"]+"[[:space:]]*,[[:space:]]*self[[:space:]]*,'  # connect("sig", self, "m")
  '\.instance\(\)'                                        # instance()  -> instantiate()
  '\bchange_scene\('                                      # -> change_scene_to_file()
  'move_and_slide\([[:space:]]*[^)[:space:]]'             # move_and_slide(velocity, ...) -> no args
  '\bPool(Byte|Int|Real|String|Vector2|Vector3|Color)Array\b'
  '(\b(extends|is|as)[[:space:]]+|:[[:space:]]*)(KinematicBody2D|KinematicBody|Spatial|Sprite|Position2D|Particles2D)\b'  # renamed classes
  '\bfuncref\('
  '\bOS\.get_(screen_size|window_size)\('                 # -> DisplayServer
  '\bFile\.new\(\)|\bDirectory\.new\(\)'                  # -> FileAccess / DirAccess
)
status=0
for p in "${patterns[@]}"; do
  if out=$(grep -rnE --include='*.gd' -e "$p" "$dir" 2>/dev/null); then
    printf 'Godot 3 syntax (%s):\n%s\n\n' "$p" "$out"
    status=1
  fi
done
[ "$status" -eq 0 ] && echo "No Godot 3 syntax found."
exit "$status"
