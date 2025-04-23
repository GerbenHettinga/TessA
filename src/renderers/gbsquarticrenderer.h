#ifndef GBSQUARTICRENDERER_H
#define GBSQUARTICRENDERER_H

#include "regularquarticrenderer.h"
#include "surfacerenderer.h"

class GBSQuarticRenderer : public SurfaceRenderer
{
public:
    GBSQuarticRenderer(RenderParameters* rp);
    ~GBSQuarticRenderer();

    void initBuffers();
    void initShaders();
    void updateBuffers(Model& model);
    void render(Model& model);

    void paintTessellation(int valency, int indexBufPointer, int numPatches, bool EV);

private:
    GLuint vaoEV, vboEV, vaoEF, vboEF;
    RegularQuarticRenderer rr;
};

#endif // GBSQUARTICRENDERER_H
