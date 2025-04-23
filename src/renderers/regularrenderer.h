#ifndef REGULARRENDERER_H
#define REGULARRENDERER_H

#include "GL/glew.h"
#include "surfacerenderer.h"

class RegularRenderer : public SurfaceRenderer
{
public:
    RegularRenderer(RenderParameters* rp);
    ~RegularRenderer();

    void initBuffers();
    void initShaders();
    void updateBuffers(Model& model);
    void render(Model& model);

    void paintTessellation(int valency, int indexBufPointer, int numPatches);

private:
    GLuint vao, vbo;
};

#endif // REGULARRENDERER_H
