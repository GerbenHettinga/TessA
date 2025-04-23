#version 330
in vec3 pos;
flat in vec3 norm;
in vec3 oColour;

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

out vec4 fColor;

void main()
{
    vec3 N = normalize(norm);
    vec3 L = normalize(lightPosition.xyz - pos);
    vec3 E = normalize(-pos);
    vec3 R = normalize(-reflect(L, N));

    vec3 ambient = Ka*oColour;
    vec3 diff = Kd * max(dot(N, L), 0.0) * oColour * 1.1;
    vec3 specular = vec3(0.0);
    if(dot(N, L) > 0.0) {
        specular = Ks * pow(max(dot(R, E), 0.0), 0.3*shininess);
    }
    vec3 final = ambient + diff + specular;
    fColor = vec4(final, 1.0);
}
