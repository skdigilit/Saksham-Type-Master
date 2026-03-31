class_name GameTheme
## Central repository for all visual constants and shader helpers.
## Uses static constants and methods — no Godot Theme editor.

# ──────────────────────────────────────────────
# Colors
# ──────────────────────────────────────────────

## The colour of the big background behind everything.
## This is the olive-green colour you see filling the whole screen.
const COLOR_BACKGROUND: Color = Color(0.545, 0.604, 0.345)

## The colour inside the big circle where the letters live.
## Slightly lighter than the background so the circle stands out.
const COLOR_CIRCLE_INTERIOR: Color = Color(0.62, 0.68, 0.42)

## The colour of the thick ring drawn around the circle.
## A very dark olive so it looks like a hand-drawn border.
const COLOR_CIRCLE_OUTLINE: Color = Color(0.176, 0.2, 0.098)

## The colour of the small dots around the edge of the circle that haven't been collected yet.
## Dark so they look "empty" or waiting.
const COLOR_CIRCLE_DOT_EMPTY: Color = Color(0.176, 0.2, 0.098)

## The colour of a dot around the circle edge once you have collected that letter.
## Bright yellow so you can easily see your progress.
const COLOR_CIRCLE_DOT_FILLED: Color = Color(0.83, 0.78, 0.29)

## The colour of every normal letter sitting in the circle grid.
## Dark so the letters are easy to read against the lighter circle interior.
const COLOR_LETTER_NORMAL: Color = Color(0.176, 0.2, 0.098)

## The thin stroke drawn around each letter to make it look hand-drawn.
## Same olive as the circle interior so the outline blends softly.
const COLOR_LETTER_OUTLINE: Color = Color(0.62, 0.68, 0.42)

## The semi-transparent highlight box drawn behind the letter you are currently standing on.
## Helps you quickly spot your position in the grid.
const COLOR_LETTER_HIGHLIGHT_BG: Color = Color(0.82, 0.84, 0.72, 0.7)

## The colour of the letter you are currently standing on (your position letter).
## Near-white so it pops out from the dark normal letters.
const COLOR_LETTER_HIGHLIGHT_TEXT: Color = Color(0.95, 0.95, 0.92)

## The colour of the special letter you need to collect (the gold target letter).
## Bright yellow-gold so it is easy to spot across the grid.
const COLOR_LETTER_COLLECTIBLE: Color = Color(0.83, 0.78, 0.29)

## The colour of the decorative letters floating in the background.
## Very faint (low alpha) so they don't distract from the game.
const COLOR_BG_LETTER: Color = Color(0.42, 0.48, 0.24, 0.35)

## The colour used for enemy sprites and the "GAME OVER" text.
## A strong red so enemies and danger are immediately obvious.
const COLOR_ENEMY: Color = Color(0.77, 0.31, 0.31)

## The colour of the soft circle drawn behind each enemy sprite.
## Same red as the enemy but more transparent, like a glow.
const COLOR_ENEMY_BG: Color = Color(0.77, 0.31, 0.31, 0.4)

## The colour used for all score and information text at the edges of the screen (HUD).
## Dark so it is readable against the light olive background.
const COLOR_HUD: Color = Color(0.176, 0.2, 0.098)

# ──────────────────────────────────────────────
# Font Sizes
# ──────────────────────────────────────────────

## How big the letters in the circle grid are (in pixels).
## Calculated automatically from the circle size — set to GRID_CELL_FONT_RATIO × cell height.
static var FONT_SIZE_GRID: int = 86

## How thick the stroke outline drawn around each grid letter is (in pixels).
## A larger number makes letters look bolder and more hand-drawn.
const FONT_SIZE_GRID_OUTLINE: int = 12

## Controls how much of a grid cell's height the letter fills.
## 0.8 means the letter uses 80% of the cell height.
## Lower = smaller letters with more space around them; higher = letters fill the cell more.
const GRID_CELL_FONT_RATIO: float = 0.8

## How big the score and collected-count text is at the edges of the screen (in pixels).
const FONT_SIZE_HUD: int = 48

## Thickness of the outline drawn around HUD text. 0 means no outline.
const FONT_SIZE_HUD_OUTLINE: int = 0

## How big the decorative letters floating in the background are (in pixels).
## Larger = background letters are more visible; smaller = more subtle.
const FONT_SIZE_BG: int = 100

## Legacy font size constant for the enemy symbol. Kept for reference.
const FONT_SIZE_ENEMY: int = 120

## The radius (half-width) of the enemy sprite in pixels.
## This controls how big the enemy looks on screen AND the size of its danger zone.
## Increase to make enemies bigger and easier to see (but also harder to dodge!).
const ENEMY_BG_RADIUS: float = 40.0

## How much extra space around the enemy counts as a hit, as a fraction of one grid cell width.
## 0.4 means the danger zone extends 40% of a cell beyond the enemy's visible edge.
## Increase (e.g. 0.6) for a harder game where near-misses still count as hits.
## Decrease (e.g. 0.1) for a more forgiving game where you have to almost touch the enemy.
## Set to 0.0 to make the hit zone match exactly the enemy's visible circle — pixel-perfect.
const ENEMY_HIT_PADDING: float = 0.4

## How many enemies can be crossing the circle at the same time when the game starts.
## For example, 2 means two enemies can be inside the circle at once before a new one appears.
## Higher numbers = harder game right from the start.
const ENEMY_MAX_COUNT_INITIAL: int = 2

## How many seconds pass before the game adds one more enemy to the maximum allowed.
## For example, 30.0 means every 30 seconds the game gets one enemy harder.
## Lower numbers = difficulty ramps up faster; higher = longer breathing room.
const ENEMY_ESCALATION_INTERVAL: float = 30.0

# ──────────────────────────────────────────────
# Layout
# ──────────────────────────────────────────────

## How big the main circle is, measured from its centre to its edge (in pixels).
## Calculated automatically from the screen size at startup — do not set manually here.
## To change how big the circle is relative to the window, adjust CIRCLE_RADIUS_FRACTION below.
static var CIRCLE_RADIUS: float = 400.0

## The pixel position of the circle's centre on screen (x, y).
## Set automatically to the middle of the screen at startup — do not set manually.
static var CIRCLE_CENTER: Vector2 = Vector2(800, 600)

## Controls how much of the smaller screen dimension the circle fills (0.0 to 1.0).
## 0.40 means the circle radius is 40% of whichever is smaller — the screen width or height.
## Increase (e.g. 0.48) to make the circle bigger; decrease (e.g. 0.30) for a smaller circle.
const CIRCLE_RADIUS_FRACTION: float = 0.40

## How many small dots appear around the edge of the circle.
## Each dot represents one gold letter you need to collect to finish the round.
const CIRCLE_DOT_COUNT: int = 12

## How big each small dot around the circle edge is (in pixels radius).
## Bigger = easier to see your progress; smaller = more subtle.
const CIRCLE_DOT_RADIUS: float = 10.0

## How thick the ring drawn around the circle is (in pixels).
## Thicker = bolder, more visible border.
const CIRCLE_OUTLINE_WIDTH: float = 5.0

## How many rows and columns the invisible letter grid has.
## Think of it like a spreadsheet overlaid on the circle — letters fill the cells that land inside the circle.
## More rows/cols = more letters (but they get smaller); fewer = fewer, bigger letters.
const GRID_ROWS: int = 6
const GRID_COLS: int = 5

## How much empty space to leave between the circle edge and the outermost letters, as a fraction of the diameter.
## 0.0 = letters go right to the circle edge; 0.1 = leave a 10% gap around the inside of the circle.
## Increase to push letters further inward so they don't feel cramped against the border.
const LETTER_GRID_PADDING: float = 0.1

## The width and height of a single cell in the letter grid (in pixels).
## Calculated automatically from the circle size and GRID_ROWS/GRID_COLS — do not set manually.
static var GRID_CELL_SIZE: Vector2 = Vector2(108, 108)

## How fast enemies travel across the circle (pixels per second).
## Higher = enemies move faster and are harder to avoid; lower = more time to react.
const ENEMY_SPEED: float = 70.0

## Legacy constant for enemy collision size. Kept for reference.
const ENEMY_COLLISION_RADIUS: float = 30.0

## Set to false to silence all sound effects. Set to true to turn them back on.
const SOUND_ENABLED: bool = true

## Set to true to draw collision circles on enemies and cell outlines on letters.
## Great for understanding how the game decides when an enemy hits you!
## Turn it back to false when you are done experimenting.
const DEBUG_COLLISION: bool = false

# ──────────────────────────────────────────────
# Squiggle Shader Parameters
# ──────────────────────────────────────────────

## The squiggle shader makes everything look hand-drawn and wobbly, like it was sketched with a pen.
## All "STRENGTH" values control how much the wobble distorts the image.
##   0.0 = perfectly still / no squiggle; 0.1 = gentle wobble; 1.0 = very strong distortion.

## Wobble strength for the game circle letters and enemies.
## A light wobble so letters feel alive but are still easy to read.
const SQUIGGLE_STRENGTH_NORMAL: float = 0.1

## Wobble strength for the decorative background letters.
## Slightly less than normal so the background doesn't compete with the game.
const SQUIGGLE_STRENGTH_BG: float = 0.08

## Wobble strength for the score and HUD text at the screen edges.
## Very subtle so numbers are easy to read.
const SQUIGGLE_STRENGTH_HUD: float = 0.05

## How many times per second the squiggle animation updates (frames per second).
## Lower = slower, lazier wobble; higher = faster, more energetic jitter.
const SQUIGGLE_FPS: float = 6.0

## How large the noise pattern used by the squiggle shader is.
## Smaller values = fine, high-frequency wiggles; larger = big, sweeping bends.
const SQUIGGLE_SCALE: Vector2 = Vector2(1.0, 1.0)

## Dedicated squiggle parameters for the game circle boundary.
## Stronger wobble + slower update = more exaggerated hand-drawn feel on the circle outline.

## How strongly the circle outline wobbles. Much higher than normal for a dramatic sketched look.
const SQUIGGLE_CIRCLE_STRENGTH: float = 0.55

## How many times per second the circle outline wobble updates.
## Slower than normal so the circle deformation feels heavy and deliberate.
const SQUIGGLE_CIRCLE_FPS: float = 4.0

## Noise pattern size for the circle outline wobble.
## Smaller than 1.0 so the circle bends in big smooth curves rather than tiny jitters.
const SQUIGGLE_CIRCLE_SCALE: Vector2 = Vector2(0.6, 0.6)

# ──────────────────────────────────────────────
# Screen Layout Initialisation
# ──────────────────────────────────────────────

## Call this once at the very start of game_main._ready(), before any other node is created.
## It works out CIRCLE_RADIUS and CIRCLE_CENTER from the real screen size so everything
## scales correctly no matter what resolution the window is.
static func initialize_screen_layout(viewport_size: Vector2) -> void:
	CIRCLE_CENTER = viewport_size * 0.5
	CIRCLE_RADIUS = min(viewport_size.x, viewport_size.y) * CIRCLE_RADIUS_FRACTION

# ──────────────────────────────────────────────
# Cached Resources (lazy-loaded)
# ──────────────────────────────────────────────

static var _noise_texture: NoiseTexture2D = null
static var _shader: Shader = null
static var _font: FontFile = null

## Path to the Action Man Bold font
# const FONT_PATH: String = "res://Fonts/Action_Man_Bold.ttf"
const FONT_PATH: String = "res://Fonts/CCWildWords Roman.ttf"
# const FONT_PATH: String = "res://Fonts/CherryBombOne-Regular.ttf"


## Creates and caches a seamless noise texture for the squiggle shader.
static func get_noise_texture() -> NoiseTexture2D:
	if _noise_texture == null:
		var noise := FastNoiseLite.new()
		noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		noise.frequency = 0.03
		noise.seed = randi()
		var tex := NoiseTexture2D.new()
		tex.noise = noise
		tex.seamless = true
		tex.width = 256
		tex.height = 256
		_noise_texture = tex
	return _noise_texture


## Loads and caches the squiggle shader resource.
static func get_shader() -> Shader:
	if _shader == null:
		_shader = load("res://squiggle_shader.gdshader") as Shader
	return _shader


## Loads and caches the Action Man Bold font.
static func get_font() -> FontFile:
	if _font == null:
		_font = load(FONT_PATH) as FontFile
	return _font


## Applies the squiggle shader to any CanvasItem node.
## strength: distortion amount. fps: animation speed. scale: noise pattern scale.
static func apply_squiggle_shader(
	node: CanvasItem,
	strength: float = SQUIGGLE_STRENGTH_NORMAL,
	fps: float = SQUIGGLE_FPS,
	scale: Vector2 = SQUIGGLE_SCALE
) -> void:
	var mat := ShaderMaterial.new()
	mat.shader = get_shader()
	mat.set_shader_parameter("strength", strength)
	mat.set_shader_parameter("fps", fps)
	mat.set_shader_parameter("scale", scale)
	mat.set_shader_parameter("noise", get_noise_texture())
	node.material = mat


## Creates a LabelSettings resource with the specified visual properties.
static func create_label_settings(
	font_color: Color,
	font_size: int,
	outline_color: Color = COLOR_LETTER_OUTLINE,
	outline_size: int = FONT_SIZE_GRID_OUTLINE
) -> LabelSettings:
	var settings := LabelSettings.new()
	settings.font = get_font()
	settings.font_color = font_color
	settings.font_size = font_size
	settings.outline_color = outline_color
	settings.outline_size = outline_size
	return settings
