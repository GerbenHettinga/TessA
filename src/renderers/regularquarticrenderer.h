#ifndef REGULARQUARTICRENDERER_H
#define REGULARQUARTICRENDERER_H

#include "surfacerenderer.h"

class RegularQuarticRenderer : public SurfaceRenderer
{
public:
    RegularQuarticRenderer(RenderParameters* rp);
    ~RegularQuarticRenderer();

    void initBuffers();
    void initShaders();
    void updateBuffers(Model& model);
    void render(Model& model);

    void paintTessellation(int valency, int indexBufPointer, int numPatches);

private:
    GLuint vao, vbo;
};

#endif // REGULARQUARTICRENDERER_H
