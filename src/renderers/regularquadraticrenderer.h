#ifndef REGULARQUADRATICRENDERER_H
#define REGULARQUADRATICRENDERER_H

#include "surfacerenderer.h"

class RegularQuadraticRenderer : public SurfaceRenderer
{
public:
    RegularQuadraticRenderer(RenderParameters* rp);
    ~RegularQuadraticRenderer();

    void initBuffers();
    void initShaders();
    void updateBuffers(Model& model);
    void render(Model& model);

    void paintTessellation(int valency, int indexBufPointer, int numPatches);

private:
    GLuint vao, vbo;
};
#endif // REGULARQUADRATICRENDERER_H
