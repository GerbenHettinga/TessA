#ifndef GBSBEZIERRENDERER_H
#define GBSBEZIERRENDERER_H

#include "surfacerenderer.h"
#include "regularrenderer.h"

class GBSBezierRenderer : public SurfaceRenderer
{
public:
    GBSBezierRenderer(RenderParameters* rp);
    ~GBSBezierRenderer();

    void initBuffers();
    void initShaders();
    void updateBuffers(Model& model);
    void render(Model& model);

    void paintTessellation(int valency, int indexBufPointer, int numPatches);

private:
    GLuint vao, vbo;

    RegularRenderer rr;
};

#endif // GBSBEZIERRENDERER_H
