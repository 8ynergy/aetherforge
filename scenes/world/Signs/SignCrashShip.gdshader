shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform bool OnHoverShader = false;
uniform float glow_size = 5.0;
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 0.8);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

if (OnHoverShader) {
	// Create glow effect by sampling a slightly larger version
	vec2 ts = 1.0 / vec2(textureSize(TEXTURE, 0));
	float glow_alpha = 0.0;

	// Sample in a circle around the current pixel for glow
	for (float angle = 0.0; angle < 6.28; angle += 0.5) {
		vec2 offset = vec2(cos(angle), sin(angle)) * glow_size * ts;
		glow_alpha = max(glow_alpha, texture(TEXTURE, UV + offset).a);
	}

	// Draw original sprite first, then glow behind it
	if (tex.a > 0.0) {
		COLOR = tex; // Draw original sprite
	} else if (glow_alpha > 0.0) {
		COLOR = vec4(glow_color.rgb, glow_alpha * glow_color.a); // Draw glow behind
	} else {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0); // Transparent
	}
} else {
	COLOR = tex; // Normal rendering when not hovered
}
}
