#version 330
in vec3 position;
in vec3 normal;
in vec3 outColour;
in float[8] outWeights;

uniform vec3 Ka;
uniform vec3 Kd;
uniform vec3 Ks;
uniform float shininess;
uniform mat4 matrix;

uniform vec3 color;
uniform vec3 color2;
uniform vec4 lightPosition;
uniform vec3 lightIntensity;
uniform float surfaceAlpha;

uniform bool patchColours;

out vec4 fColor;
out vec3 pos;

void main()
{
    vec3 N = normalize(normal);
    vec3 L = normalize(lightPosition.xyz - position);
    vec3 E = normalize(-position);
    vec3 R = normalize(-reflect(L, N));


    vec3 C = color;
    if(patchColours) {
        C = outColour;
    }

    vec3 ambient = Ka*C;
    vec3 diff = Kd * max(dot(N, L), 0.0) * C * 1.1;
    vec3 specular = vec3(0.0);
    if(dot(N, L) > 0.0) {
        specular = Ks * pow(max(dot(R, E), 0.0), 0.3*shininess);
    }
    vec3 final = ambient + diff + specular;
    fColor = vec4(final, 1.0);
    pos = position;
}
