/*
 * A simple Conway's Game of Life shader with no loops.
 *
 * The goal of this shader was to implement Conway's Game of Life with no loops of any kind and
 * to keep it as simple as possible.
 *
 * To use this shader, refer to the viewport_technique.tscn in this folder. You need to create 2 viewports
 * each with a child sprite and they each need to have the other as their texture as a viewport texture.
 */
shader_type canvas_item;

/*
 * Set mouse_pressed and mouse_position from an _input callback in gdscript
 * to draw on the shader.
 */
uniform bool mouse_pressed = false;
uniform vec2 mouse_position = vec2(0.0, 0.0);

// This determines the brush diameter
uniform float brush_width: hint_range(1.0, 1000.0, 0.1) = 10.0;

// Pause the shader when true
uniform bool paused = false;

// Clear the shader when true (all pixels black)
uniform bool clear = false;

vec4 get_neighbor(sampler2D sample_texture, vec2 uv, vec2 uv_offset, vec2 pixel_size) {
    // Get the neighbor pixel at the provided offset from our current position
    // taking pixel size into account in case it's not 1,1
    vec4 ret = texture(sample_texture, uv + uv_offset * pixel_size);
    return ret;
}

bool is_alive(vec4 col) {
    // Is this color "alive"
    float val = max(col.r, max(col.g, col.b));
    if (val > 0.0) {
        return true;
    }
    return false;
}

int is_neighbor_alive(vec4 neighbor) {
    if (is_alive(neighbor)) {
        return 1;
    }
    return 0;
}

void fragment() {
    // Get all 8 neighbors. This could be a loop, but the goal is a "no loops at all"
    // version of Conway's Game of Life.
    vec4 pxl_color_top_left = get_neighbor(TEXTURE, UV, vec2(-1, -1), TEXTURE_PIXEL_SIZE);
    vec4 pxl_color_top = get_neighbor(TEXTURE, UV, vec2(0, -1), TEXTURE_PIXEL_SIZE);
    vec4 pxl_color_top_right = get_neighbor(TEXTURE, UV, vec2(1, -1), TEXTURE_PIXEL_SIZE);
    vec4 pxl_color_left = get_neighbor(TEXTURE, UV, vec2(-1, 0), TEXTURE_PIXEL_SIZE);
    vec4 pxl_color_right = get_neighbor(TEXTURE, UV, vec2(1, 0), TEXTURE_PIXEL_SIZE);
    vec4 pxl_color_bottom_left = get_neighbor(TEXTURE, UV, vec2(-1, 1), TEXTURE_PIXEL_SIZE);
    vec4 pxl_color_bottom = get_neighbor(TEXTURE, UV, vec2(0, 1), TEXTURE_PIXEL_SIZE);
    vec4 pxl_color_bottom_right = get_neighbor(TEXTURE, UV, vec2(1, 1), TEXTURE_PIXEL_SIZE);

    // Now we need a count of all our living neighbors
    int neighbors = 0;
    neighbors += is_neighbor_alive(pxl_color_top_left);
    neighbors += is_neighbor_alive(pxl_color_top);
    neighbors += is_neighbor_alive(pxl_color_top_right);
    neighbors += is_neighbor_alive(pxl_color_left);
    neighbors += is_neighbor_alive(pxl_color_right);
    neighbors += is_neighbor_alive(pxl_color_bottom_left);
    neighbors += is_neighbor_alive(pxl_color_bottom);
    neighbors += is_neighbor_alive(pxl_color_bottom_right);

    vec2 distance_to_mouse = (UV / TEXTURE_PIXEL_SIZE) - mouse_position;

    if (clear) {
        COLOR = vec4(vec3(0.0), 1.0);
    } else if ((mouse_pressed && length(distance_to_mouse) < brush_width) || paused) {
        if (mouse_pressed && length(distance_to_mouse) < brush_width) {
            COLOR = vec4(1.0);
        } else {
            COLOR = COLOR;
        }
    } else {
        //
        // Now we implement the rules
        //
        if (is_alive(COLOR) && (neighbors == 2 || neighbors == 3)) {
            // 1. If we are alive and we have 2 or 3 living neighbors we stay alive
            COLOR = COLOR;
        } else if (neighbors == 3) {
            // 2. If we are not alive and we have exactly 3 living neighbors we become alive
            COLOR = vec4(1.0);
        } else {
            // 3. Otherwise, we die or stay dead if we're already dead
            COLOR = vec4(vec3(0.0), 1.0);
        }
    }
}
