#include "regularquadraticrenderer.h"

RegularQuadraticRenderer::RegularQuadraticRenderer(RenderParameters* rp)
    : SurfaceRenderer(rp)
{
    initBuffers();
    initShaders();
}

RegularQuadraticRenderer::~RegularQuadraticRenderer() {

}

void RegularQuadraticRenderer::initBuffers() {
    //regular buffers for regular patches
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);

    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);

    for(GLuint i = 0; i < 3; ++i) {
        glEnableVertexAttribArray(i);
        glVertexAttribPointer(i, 3, GL_FLOAT, GL_FALSE, 3*sizeof(glm::vec3), (void*) (i*sizeof(glm::vec3)));
    }

    glBindVertexArray(0);
}

void RegularQuadraticRenderer::initShaders() {
    polyShaders.push_back(new PolygonShader(4,
                                         std::string("../shaders/qacc1/vertshaderqacc1.glsl"),
                                         std::string("../shaders/qacc1/tcqacc1.glsl"),
                                         std::string("../shaders/qacc1/teqacc1.glsl") ));
}


void RegularQuadraticRenderer::updateBuffers(Model& model) {
    GenQuadraticBSplineMesh& m = model.getQuadraticGBSMesh();

    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, m.getRegularBs().size() * sizeof(glm::vec3), m.getRegularBs().data(), GL_STATIC_DRAW);
    //qDebug() << e << "buffers";
}

void RegularQuadraticRenderer::render(Model& model) {
    glBindVertexArray(vao);

    if(model.getQuadraticGBSMesh().getNumberOfFaces(4) > 0) {
        Shader* shader = setShaderUniforms(polyShaders[0]);

        int numPatches = model.getQuadraticGBSMesh().getNumberOfFaces(4) * 4;

        glPatchParameteri(GL_PATCH_VERTICES, 4);
        glDrawArrays(GL_PATCHES, 0, numPatches);
    }

    glBindVertexArray(0);
}
