shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float alpha_hash_scale;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

uniform vec4 primary_color : source_color;
uniform vec4 secondary_color : source_color;

uniform float camNear = 0.25;
uniform float camFar = 0.75;


void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	vec4 color;
	if (albedo_tex.rgb == vec3(1.0))
		color = primary_color;
	else
		color = secondary_color;
		
	vec4 vertexWorld = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	vec4 vertexLocal = inverse(MODEL_MATRIX) * INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	ALBEDO = color.rgb;
	METALLIC = 0.0;
	ROUGHNESS = 0.0;
	SPECULAR = 0.0;
	
	float depthRaw = FRAGCOORD.z;
	
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depthRaw);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	
	float depthLinear = -view.z;
	float depthNorm = (depthLinear - camNear) / (camFar - camNear);
	
	ALPHA = clamp((pow(vertexLocal.y, 0.25) + 0.25) * depthNorm, 0.0, 1.0);
}
