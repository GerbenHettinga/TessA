#include "coordinatetexture.h"
#include <GL/glew.h>
#include <math.h>
#include <numbers>

float signedTriangleArea(glm::vec2 v1, glm::vec2 v2, glm::vec2 v3) {
    return v2.x*v3.y + v3.x*v1.y + v1.x*v2.y - v2.x*v1.y - v1.x*v3.y - v3.x*v2.y;
}

CoordinateTexture::CoordinateTexture(int n, int size, bool quad = false) : valency(n), size(size) {
    fsize = (float) size;
    points.clear();

    float phi = (2.0f * std::numbers::pi) / float(valency);
    //create regular polygon on circle with radius 1
    for(int i = 0; i < valency; i++) {
        float I = (float) i;
        points.push_back(glm::vec2(cos(phi*I), sin(phi*I)));
    }

    if(!quad) {
        createWeightMatrix();
    } else {
        createWeightMatrixQuad();
    }

    glGenTextures(1, &id);
    glBindTexture(GL_TEXTURE_3D, id);

    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glTexImage3D(GL_TEXTURE_3D, 0, GL_RGBA32F, 128, 128, 2, 0, GL_RGBA, GL_FLOAT, asSingle.data());

}


glm::vec3 barycentric(glm::vec2 p, glm::vec2 a, glm::vec2 b, glm::vec2 c) {
    glm::vec2 v0 = b - a;
    glm::vec2 v1 = c - a;
    glm::vec2 v2 = p - a;
    float d00 = glm::dot(v0, v0);
    float d01 = glm::dot(v0, v1);
    float d11 = glm::dot(v1, v1);
    float d20 = glm::dot(v2, v0);
    float d21 = glm::dot(v2, v1);
    float denom = d00 * d11 - d01 * d01;
    float v = (d11 * d20 - d01 * d21) / denom;
    float w = (d00 * d21 - d01 * d20) / denom;
    float u = 1.0f - v - w;
    return glm::vec3(u, v, w);
}

/* for every uv on size*size texture calculate position on parametric domain and then calculate
 * wachspress coordinates for this poisition. Extra care for linear positions of the texture
 */
void CoordinateTexture::createWeightMatrixQuad() {
    glm::vec2 currParamPos;
    asSingle = std::vector<float>(2*size*size*4);
    for(int i = 0; i < size-1; i++) {
        float u = (float) i / (fsize - 1.0);
        for(int j = 0; j < size-1; j++) {
            float v = (float) j / (fsize - 1.0);

            //bilinear interpolation except centre point omitted vec2(0.0, 0.0)
            currParamPos = u * (1.0f - v) * points[2] + u * v  * points[1] + (1.0f - u) * v * points[0];

            std::vector<float> w = wachspress(currParamPos);

            for(int l = 0; l < 4; l++) {
                asSingle[i * (size*4) + j*4 + l] = w[l];
                asSingle[(size*size*4) + i * (size*4) + j*4 + l] = w[4 + l];
            }
        }
    }

    //linear boundary conditions for edge u = 1, v = 1
    for(int i = 0; i < size; i++) {
        float u = (float) i/ (fsize - 1.0f);
        asSingle[(size - 1) * (size*4) + i*4 + 1] = u;
        asSingle[(size - 1) * (size*4) + i*4 + 2] = 1.0f - u;

        asSingle[i * (size*4) + (size-1)*4 + 1] = u;
        asSingle[i * (size*4) + (size-1)*4 ] = 1.0f - u;
    }

}


/* for every uv on size*size texture calculate position on parametric domain and then calculate
 * wachspress coordinates for this poisition. Extra care for linear positions of the texture
 */
void CoordinateTexture::createWeightMatrix() {
    glm::vec2 currTexturePos;
    glm::vec2 currParamPos;

    asSingle = std::vector<float>(2*size*size*4);
    for(int i = 0; i < size; i++) {
        float u = (float) i / (fsize - 1.0f);
        for(int j = 1; j < size; j++) {
            float v = (float) j / (fsize - 1.0f);

            //bilinear interpolation except centre point omitted vec2(0.0, 0.0)
            currTexturePos = u * (1.0f - v) * glm::vec2(1.0f, 0.0f) +
                             u * v * glm::vec2(1.0f, 1.0f) +
                             (1.0f - u) * v  * glm::vec2(0.0f, 1.0f);

            glm::vec3 uvw = barycentric(currTexturePos, glm::vec2(0.0f, 0.0f), glm::vec2(1.0f, 0.0f), glm::vec2(0.0f, 1.0f));
            currParamPos = uvw.x * points[0] + uvw.y * points[1];

            std::vector<float> w = wachspress(currParamPos);

            for(int l = 0; l < 4; l++) {
                asSingle[i * (size*4) + j*4 + l] = w[l];
                asSingle[(size*size*4) + i * (size*4) + j*4 + l] = w[4 + l];
            }
        }     
    }

    //linear boundary conditions
    for(int i = 0; i < size; i++) {
        float u = (float) i/ (fsize - 1.0f);
        asSingle[i * (size*4)] = 1.0f - u;
        asSingle[i * (size*4) + 1] = u;
    }
}

std::vector<float> CoordinateTexture::getData() {
    return asSingle;
}

unsigned int CoordinateTexture::getID() {
    return id;
}

std::vector<float> CoordinateTexture::wachspress(glm::vec2 p){
    float sumweights = 0.0;
    float A_i, A_iplus1;
    std::vector<float> weights = std::vector<float>(8);
    A_iplus1 = signedTriangleArea(points[valency-1], points[0], p);
    for(int i = 0; i < valency; i++) {
        A_i = A_iplus1;
        A_iplus1 = signedTriangleArea(points[i], points[(i+1) % valency], p);
        weights[i] = 1.0/(A_i*A_iplus1);
        sumweights += weights[i];
    }
    for(int i = 0; i < valency; i++) {
        weights[i] /= sumweights;
    }
    return weights;
}
