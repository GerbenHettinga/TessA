#ifndef ACC2RENDERER_H
#define ACC2RENDERER_H

#include "surfacerenderer.h"


class ACC2Renderer : public SurfaceRenderer {
public:
    ACC2Renderer(RenderParameters* rp);
    ~ACC2Renderer();

    void initBuffers();
    void initShaders();
    void updateBuffers(Model& model);
    void render(Model& model);

    void paintTessellation(int valency, int indexBufPointer, int numPatches);

private:
    GLuint vao;
    GLuint vbo[5];
    GLuint vboUV;

    std::vector<PolygonShader*> polyshaders;
};

#endif // ACC2RENDERER_H
