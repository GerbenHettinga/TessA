#version 400 core
in vec3[] position;
in vec3[] a;
in vec3[] b;
in vec3[] c;
in vec3[] d;
in vec2[] uv;
in vec3[] noise;
flat in int[] instance;

/*DEFINE N FLAG*/

uniform float tessInnerLevel;
uniform float tessOuterLevel;
uniform bool adaptive;
uniform mat4 matrix;

layout(vertices = N) out;
out vec3[] tc_p;
out vec3[] tc_ep;
out vec3[] tc_em;
out vec3[] tc_fp;
out vec3[] tc_fm;
out vec3[] tc_n;
out vec2[] tc_uv;
out vec3[] tc_noise;

patch out int inst;


void main()
{


    // set inner outer tess level
    if (gl_InvocationID == 0) {


        //if(!adaptive) {
            gl_TessLevelInner[0] = tessInnerLevel;
            gl_TessLevelInner[1] = tessInnerLevel;

            gl_TessLevelOuter[0] = tessOuterLevel;
            gl_TessLevelOuter[1] = tessOuterLevel;
            gl_TessLevelOuter[2] = tessOuterLevel;
            gl_TessLevelOuter[3] = tessOuterLevel;

		/*
        } else {
            //vec3 C = (c[0] + c[1] + c[2] + c[3] + c[4])*0.2;
            vec3 C = (c[0] + c[1] + c[2] + c[3] + c[4]) * 0.2;
            vec3 C2 = (d[0] + d[1] + d[2] + d[3] + d[4]) * 0.2;
            C = vec3(matrix * vec4(0.5*(C + C2),1.0));
            vec3 p0 = vec3(matrix * vec4(position[(instance[0]+1) % 5], 1.0));
            vec3 p1 = vec3(matrix * vec4(position[(instance[0]+2) % 5], 1.0));

            float a = length(C - p0);
            float b = length(p0 - p1);
            float c = length(C - p1);

            gl_TessLevelOuter[2] = a*tessOuterLevel;
            gl_TessLevelOuter[0] = b*tessOuterLevel;
            gl_TessLevelOuter[1] = c*tessOuterLevel;

            gl_TessLevelInner[0] = max(a,max(b,c))*tessInnerLevel;
            gl_TessLevelInner[0] = min(a,min(b,c))*tessInnerLevel;
        }
		*/
        inst = instance[0];
    }

    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
    tc_p[gl_InvocationID] = position[gl_InvocationID];
    tc_ep[gl_InvocationID] = a[gl_InvocationID];
    tc_em[gl_InvocationID] = b[gl_InvocationID];
    tc_fp[gl_InvocationID] = c[gl_InvocationID];
    tc_fm[gl_InvocationID] = d[gl_InvocationID];
    tc_uv[gl_InvocationID] = uv[gl_InvocationID];
    tc_noise[gl_InvocationID] = noise[gl_InvocationID];

    tc_n[gl_InvocationID] = normalize(cross(normalize(tc_ep[gl_InvocationID] - tc_p[gl_InvocationID]), normalize(tc_em[gl_InvocationID] - tc_p[gl_InvocationID])));
}
