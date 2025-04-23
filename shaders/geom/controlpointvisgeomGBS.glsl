#version 330
layout(points) in;
in vec3[] b0;
in vec3[] b1;
in vec3[] b2;

in vec3[] b3;
in vec3[] b4;
in vec3[] b5;

in vec3[] b6;
in vec3[] b7;
in vec3[] b8;


uniform mat4 matrix;
uniform float alpha;

layout(points, max_vertices = 32) out;
out vec3 normal;
out vec3 position;



int wrap(int i, int n) {
    return (i + n) % n;
}

void main()
{
    gl_Position = matrix * vec4(b0[gl_PrimitiveIDIn], 1.0);
    position = b0[gl_PrimitiveIDIn];
    normal = vec3(1.0, 0.0, 0.0);
    EmitVertex();

    gl_Position = matrix * vec4(b1[gl_PrimitiveIDIn], 1.0);
    position = b1[gl_PrimitiveIDIn];
    normal = vec3(0.0, 0.0, 1.0);
    EmitVertex();

    gl_Position = matrix * vec4(b2[gl_PrimitiveIDIn], 1.0);
    position = b2[gl_PrimitiveIDIn];
    normal = vec3(0.0, 1.0, 0.0);
    EmitVertex();

    gl_Position = matrix * vec4(b3[gl_PrimitiveIDIn], 1.0);
    position = b3[gl_PrimitiveIDIn];
    normal = vec3(0.0, 0.0, 1.0);
    EmitVertex();

    gl_Position = matrix * vec4(b4[gl_PrimitiveIDIn], 1.0);
    position = b4[gl_PrimitiveIDIn];
    normal = vec3(0.0, 1.0, 0.0);
    EmitVertex();

    gl_Position = matrix * vec4(b5[gl_PrimitiveIDIn], 1.0);
    position = b5[gl_PrimitiveIDIn];
    normal = vec3(0.0, 0.0, 1.0);
    EmitVertex();

    gl_Position = matrix * vec4(b6[gl_PrimitiveIDIn], 1.0);
    position = b6[gl_PrimitiveIDIn];
    normal = vec3(0.0, 1.0, 0.0);
    EmitVertex();

    gl_Position = matrix * vec4(b7[gl_PrimitiveIDIn], 1.0);
    position = b7[gl_PrimitiveIDIn];
    normal = vec3(0.0, 0.0, 1.0);
    EmitVertex();

    gl_Position = matrix * vec4(b8[gl_PrimitiveIDIn], 1.0);
    position = b8[gl_PrimitiveIDIn];
    normal = vec3(0.0, 1.0, 0.0);
    EmitVertex();

    EndPrimitive();
}
