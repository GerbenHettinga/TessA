#version 330
in vec2 pos;

uniform vec2[8] positions;
float[8] weights;
uniform mat4 matrix;
uniform int selectedVertex;
uniform int polygonSize;
uniform int GBCType;
uniform float pvalue;

float signedTriangleArea(vec2 v1, vec2 v2, vec2 v3) {
    //            e    i  +   f   g   +  d    h   -   e   g   -   d   i   -   f   h
    float det = v2.x*v3.y + v3.x*v1.y + v1.x*v2.y - v2.x*v1.y - v1.x*v3.y - v3.x*v2.y;
    return det*0.5;
}

int wrapper(int i, int n) {
    int a;
    if(i < 0){
        a = n-1;
    } else if(i == n){
        a = 0;
    } else {
        a = i;
    }
    return a;
}


void wachspress(vec2 p){
    vec2 vi, vi_min1, vi_plus1;
    float sumweights = 0.0;
    float B, A_i, A_iplus1;
    for(int i = 0; i < polygonSize; i++) {
        vi = positions[i];
        vi_min1 = positions[wrapper(i-1, polygonSize)];
        vi_plus1 = positions[wrapper(i+1, polygonSize)];
        B = signedTriangleArea(vi_min1, vi, vi_plus1);
        A_i = signedTriangleArea(vi_min1, vi,  p);
        A_iplus1 = signedTriangleArea(vi, vi_plus1, p);
        weights[i] = B/(A_i*A_iplus1);
        sumweights += weights[i];
    }
    for(int i = 0; i < polygonSize; i++) {
        weights[i] = weights[i]/sumweights;
    }
}

void meanValue(vec2 p) {
    vec2 vi;
    vec2 vi_min1;
    vec2 vi_plus1;
    float sumweights = 0.0;
    float ang1, ang2;
    vec2 vi_p;
    for(int i = 0; i < polygonSize; i++){
        vi = positions[i];
        vi_min1 = positions[wrapper((i-1), polygonSize)];
        vi_plus1 = positions[wrapper((i+1), polygonSize)];
        vi_p = normalize(vi-p);
        ang1 = acos(dot(normalize(vi_min1-p), vi_p));
        ang2 = acos(dot(normalize(vi_plus1-p), vi_p));
        weights[i] = (tan(ang1*0.5) + tan(ang2*0.5)) / distance(vi,p);
        sumweights += weights[i];
    }
    for(int i = 0; i < polygonSize; i++){
        weights[i] = weights[i]/sumweights;
    }
}

void harmonic(vec2 p) {
    vec2 vi, vi_min1, vi_plus1;
    float sumweights = 0.0;
    for(int i = 0; i < polygonSize; i++) {
        vi = positions[i];
        vi_min1 = positions[wrapper(i-1, polygonSize)];
        vi_plus1 = positions[wrapper(i+1, polygonSize)];
        float gamma_i = acos(dot(normalize(p-vi_plus1), normalize(vi-vi_plus1)));
        float beta_imin1 = acos(dot(normalize(vi-vi_min1), normalize(p-vi_min1)));
        weights[i] = 2.0*(1.0/tan(gamma_i) + 1.0/tan(beta_imin1));
        sumweights += weights[i];
    }

    for(int i = 0; i < polygonSize; i++) {
        weights[i] = weights[i]/sumweights;
    }
}

void threepoint(vec2 p) {
    vec2 vi, vi_min1, vi_plus1;
    float sumweights = 0.0;
    float B, A_i, A_iplus1, A_imin1;
    float r_i, r_imin1, r_iplus1;
    float C;
    for(int i = 0; i < polygonSize; i++){
        vi = positions[i];
        vi_min1 = positions[wrapper((i-1),  polygonSize)];
        vi_plus1 = positions[wrapper((i+1), polygonSize)];
        r_i = pow(distance(vi, p), pvalue);
        r_imin1 = pow(distance(vi_min1, p), pvalue);
        r_iplus1 = pow(distance(vi_plus1, p), pvalue);
        B = signedTriangleArea(p, vi_min1, vi_plus1);
        C = signedTriangleArea(vi_min1, vi, vi_plus1);
        A_i = signedTriangleArea(p, vi,  vi_plus1);
        A_imin1 = signedTriangleArea(p, vi_min1, vi);
        weights[i] = ((r_iplus1*A_imin1)-(B*r_i)+(r_imin1*A_i))/(A_imin1*A_i);
        sumweights += weights[i];
    }
    for(int i = 0; i < polygonSize; i++){
        weights[i] = weights[i]/sumweights;
    }
}


vec3 rainbow(float value) {
    float NLEVELS = 12.0;
    value *= NLEVELS; value = ceil(value);
    value /= NLEVELS;

    float dx=0.8;
    if (value<0.0) value=0.0;
    if (value>1.0) value=1.0;
    value = (6.0-2.0*dx)*value+dx;
    float R = max(0.0,(3.0-abs(value-4.0)-abs(value-5.0))/2.0);
    float G = max(0.0,(4.0-abs(value-2.0)-abs(value-4.0))/2.0);
    float B = max(0.0,(3.0-abs(value-1.0)-abs(value-2.0))/2.0);
    return vec3(R, G, B);
}

out vec4 fColor;

void main()
{
    if(GBCType == 0) wachspress(pos);
    if(GBCType == 1) meanValue(pos);
    if(GBCType == 2) harmonic(pos);
    if(GBCType == 3) threepoint(pos);
    fColor = vec4(rainbow(weights[selectedVertex]), 1.0);
}

