#version 330
in vec3 position;
in vec3 normal;
in vec3 outColour;


uniform vec4 lightPosition;
uniform float frequency;
uniform float pvalue;
uniform bool patchColours;

out vec4 fColor;

void main()
{
    vec3 N = normalize(normal);
    vec3 L = normalize(lightPosition.xyz - position);
    vec3 E = normalize(-position);
    vec3 R = normalize(-reflect(L, N));


    vec3 c;
    if(sin(mod(gl_FragCoord.z * frequency*20.0, frequency*20.0)) > 0.0){
        c = patchColours ? outColour : vec3(1.0);
    } else {
        c = patchColours ? vec3(1.0) - outColour : vec3(0.0);
        //c = vec3(0.0);
    }

    vec3 oc = mix(max(dot(N, L), 0.0) * c, c, pvalue);

    fColor = vec4(oc, 1.0);
}
