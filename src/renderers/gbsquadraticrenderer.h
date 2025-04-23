#ifndef GBSQUADRATICRENDERER_H
#define GBSQUADRATICRENDERER_H

#include "regularquadraticrenderer.h"
#include "surfacerenderer.h"

class GBSQuadraticRenderer : public SurfaceRenderer
{
public:
    GBSQuadraticRenderer(class RenderParameters* rp);
    ~GBSQuadraticRenderer();

    void initBuffers();
    void initShaders();
    void updateBuffers(class Model& model);
    void render(Model& model);

    void paintTessellation(int valency, int indexBufPointer, int numPatches, bool EV);

private:
    GLuint vaoEV, vboEV;
    GLuint vaoEF, vboEF;
    RegularQuadraticRenderer rr;
};

#endif // GBSQUADRATICRENDERER_H
