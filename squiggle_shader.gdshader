shader_type canvas_item;
render_mode world_vertex_coords;

group_uniforms Squiggle;

/**
 * Noise texture scale
 * By default, the noise texture's size in world coordinates is set by its resolution
 * Higher values = smaller noise pattern (more detailed squiggles)
 * Lower values = larger noise pattern (smoother squiggles)
*/
uniform vec2 scale = vec2(1.0);

/**
 * Strength of the squiggle effect
 * Controls how far pixels are displaced from their original position
 * 0.0 = no squiggle (perfectly still)
 * 0.2 = moderate squiggle (good for text/UI)
 * 1.0+ = very strong squiggle (may look distorted)
*/
uniform float strength : hint_range(0.0, 2.0, 0.1) = 0.2;

/**
 * Number of squiggle frames per second
 * Controls animation speed
 * 6.0 = 6 different squiggle patterns per second
 * Higher = faster animation, more chaotic
 * Lower = slower animation, more subtle
*/
uniform float fps = 6.0;

/**
 * Noise texture that drives the squiggle pattern
 * Should be a seamless noise texture (like Perlin or Simplex noise)
 * filter_linear = smooth interpolation between pixels
 * repeat_enable = texture tiles seamlessly
*/
uniform sampler2D noise : filter_linear, repeat_enable;

group_uniforms;

// These variables pass data from vertex() to fragment() function
varying vec4 modulate;      // Color tint from the node
varying vec2 noise_uv;      // UV coordinates for sampling the noise texture

void vertex() {
	// Store the node's color for use in fragment shader
	modulate = COLOR;
	
	/**
	 * Calculate noise UV coordinates that stay attached to the object
	 * 
	 * VERTEX: Current vertex position in world coordinates
	 * MODEL_MATRIX[3].xy: Object's position in world space (translation)
	 * 
	 * Why subtract object position?
	 * - Makes the noise pattern move WITH the object
	 * - Prevents the pattern from "sliding" when object moves
	 * - Ensures consistent squiggle regardless of object position
	 * 
	 * Why divide by texture size and scale?
	 * - textureSize(noise, 0): Gets the actual pixel dimensions of noise texture
	 * - scale: Allows us to make the noise pattern larger or smaller
	 * - Division normalizes coordinates to 0-1 range for proper texture sampling
	 * 
	 * Result: noise_uv coordinates that are local to the object but scale-independent
	*/
	noise_uv = (VERTEX - MODEL_MATRIX[3].xy) / (vec2(textureSize(noise, 0)) * scale);
}

/**
 * Use irrational constants for unique squiggles every frame
 * 
 * PI (3.14159...) and E (2.71828...) are irrational numbers
 * When multiplied with frame numbers, they create non-repeating patterns
 * This ensures the squiggle never looks exactly the same twice
 * 
 * vec2(PI, E) gives us different offsets for X and Y axes
*/
#define offset_multiplier vec2(PI, E)

void fragment() {
	/**
	 * Calculate noise offset based on time
	 * 
	 * TIME: Engine time in seconds (automatically provided by Godot)
	 * fps: Frames per second we want
	 * floor(): Rounds down to integer, creating discrete frame steps
	 * 
	 * Example: if fps = 6 and TIME = 2.5 seconds
	 * floor(2.5 * 6) = floor(15.0) = 15 (we're on frame 15)
	 * 
	 * Multiplying by offset_multiplier (PI, E) gives us unique UV offsets
	*/
	vec2 noise_offset = vec2(floor(TIME * fps)) * offset_multiplier;
	
	/**
	 * Sample the noise texture
	 * 
	 * noise_uv + noise_offset: Shifts our noise sampling position
	 * .r: Takes only the red channel (noise textures are usually grayscale)
	 * * 4.0 * PI: Amplifies the noise value to create more variation
	 * 
	 * The result is a single float value that will determine distortion direction
	*/
	float noise_sample = texture(noise, noise_uv + noise_offset).r * 4.0 * PI;
	
	/**
	 * Convert noise value to a 2D direction
	 * 
	 * This is a clever trick: treat the noise value as an angle
	 * cos(angle) gives us X direction component
	 * sin(angle) gives us Y direction component
	 * 
	 * Result: a unit vector pointing in the direction determined by noise
	*/
	vec2 direction = vec2(cos(noise_sample), sin(noise_sample));
	
	/**
	 * Calculate the distorted UV coordinates
	 * 
	 * UV: Original texture coordinates for this pixel
	 * direction * strength * 0.005: Offset in the noise direction
	 * 
	 * Why * 0.005?
	 * - This is a magic number that scales the effect appropriately
	 * - Without it, the distortion would be way too strong
	 * - Adjust this value if you want different base strength
	 * 
	 * Result: UV coordinates that are "wiggled" based on the noise pattern
	*/
	vec2 squiggle_uv = UV + direction * strength * 0.005;
	
	/**
	 * Sample the main texture at the distorted coordinates
	 * 
	 * TEXTURE: The main texture of the object (sprite, text, etc.)
	 * squiggle_uv: Our wiggled UV coordinates
	 * * modulate: Apply the node's color tint
	 * 
	 * This is where the magic happens: we're reading pixels from slightly
	 * wrong positions, creating the squiggle/distortion effect
	*/
	COLOR = texture(TEXTURE, squiggle_uv) * modulate;
	
	// DEBUG LINE: Uncomment to see the shader as pure red
	// Useful for testing if the shader is working at all
	// COLOR = vec4(1.0,0.0,0.0,1.0);
}