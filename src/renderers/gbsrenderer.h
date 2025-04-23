#ifndef GBSRENDERER_H
#define GBSRENDERER_H

#include "regularrenderer.h"
#include "surfacerenderer.h"

class GBSRenderer : public SurfaceRenderer
{
public:
    GBSRenderer(RenderParameters* rp);
    ~GBSRenderer();

    void initBuffers();
    void initShaders();
    void updateBuffers(Model& model);
    void render(Model& model);

    void paintTessellation(int valency, int indexBufPointer, int numPatches, bool EV);

private:
    GLuint vaoEV, vboEV, vaoEF, vboEF;
    RegularRenderer rr;
};

#endif // GBSRENDERER_H
