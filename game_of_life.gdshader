/*
 * A simple Conway's Game of Life shader with no loops.
 *
 * The goal of this shader was to implement Conway's Game of Life with no loops of any kind and
 * to keep it as simple as possible.
 *
 * In the spirit of simplicity, this works purely with black and white. No shades, no alpha. A
 * live pixel is solid white and a dead pixel is solid black. Anything in-between won't register.
 */
shader_type canvas_item;

/*
 * These uniforms need to be controlled from GDScript. A simple _input() override
 * that gets MouseInputEvents and updates these uniforms with mouse position, and
 * whether the mouse is clicked or not will work.
 */
uniform bool mouse_pressed = false;
uniform vec2 mouse_position = vec2(0.0, 0.0);
uniform float brush_width: hint_range(1.0, 1000.0, 0.1) = 10.0;

vec4 get_neighbor(sampler2D sample_texture, vec2 uv, vec2 uv_offset, vec2 pixel_size) {
    // Get the neighbor pixel at the provided offset from our current position
    // taking pixel size into account in case it's not 1,1
    vec4 ret = texture(sample_texture, uv + uv_offset * pixel_size);
    return ret;
}

int is_neighbor_alive(vec4 neighbor) {
    // If our neighbor is alive (solid white pixel) then return 1 otherwise 0.
    if (neighbor.rgb == vec3(1.0)) {
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

    if (mouse_pressed && length(distance_to_mouse) < brush_width) {
        COLOR = vec4(1.0);
    } else {
        //
        // Now we implement the rules
        //
        if (COLOR.rgb == vec3(1.0) && (neighbors == 2 || neighbors == 3)) {
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
