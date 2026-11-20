class_name GameConfig
## Game-wide constants. NOT content: things true of the whole game live here.
## If a value would differ per character or per move, it belongs in a Resource instead.

# --- Simulation ---
const PHYSICS_TICK := 60                 # fixed timestep; ALL gameplay logic runs here
const ROUNDS_TO_WIN := 2
const ROUND_TIME_SECONDS := 99

# --- Camera (used by CameraController) ---
const CAMERA_MIN_ZOOM := 1.0
const CAMERA_MAX_ZOOM := 1.4
const CAMERA_Y_OFFSET := -120.0
const CAMERA_SMOOTHING := 8.0            # higher = snappier

# --- Stage ---
const STAGE_HALF_WIDTH := 900.0          # corner walls at +/- this x

# --- Debug ---
const DEBUG_DRAW_HITBOXES := true        # red = hitbox, blue = hurtbox, green = grab
const DEBUG_FRAME_STEP := false          # pause + advance one tick per keypress
