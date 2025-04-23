#version 330
layout(location = 0) in vec3 vertex_position;
layout(location = 1) in vec3 vertex_normal;
//layout(location = 2) in vec2 vertex_uv;

uniform mat4 matrix;
uniform mat3 normal_matrix;

uniform bool captureGeometry;


out vec3 normal;
out vec3 position;
//out vec2  uv;

void main() {
    vec4 vp;
    if(!captureGeometry) {
        vp = matrix*vec4(vertex_position, 1.0);
    } else {
        vp = vec4(vertex_position, 1.0);
    }
    normal = normalize(normal_matrix * normalize(vertex_normal));
    gl_Position = vp;
    position = vec3(vp);
}
