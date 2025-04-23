#ifndef POLYGONRENDERER_H
#define POLYGONRENDERER_H

#include "surfacerenderer.h"

class PolygonRenderer : public SurfaceRenderer
{
public:
    PolygonRenderer(RenderParameters* rp);
    ~PolygonRenderer();

    void initBuffers();
    void initShaders();
    void updateBuffers(Model& model);
    void render(Model& model);

private:
    unsigned vao, vbo, nbo, uvbo, ibo;

    std::vector<PolygonShader*> polyFlat, polyFlatSquare;
    std::vector<PolygonShader*> polyImplicitPhong;
    std::vector<PolygonShader*> polyImplicitPN;
    std::vector<PolygonShader*> polyPhongExplicit;
    std::vector<PolygonShader*> polyPNExplicit;
    std::vector<PolygonShader*> polyGregExplicit;
    std::vector<PolygonShader*> polyTensorExplicit;
};


#endif // POLYGONRENDERER_H
