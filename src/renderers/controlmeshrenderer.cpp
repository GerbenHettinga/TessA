#include "controlmeshrenderer.h"
#include "../mesh/mesh.h"


ControlMeshRenderer::ControlMeshRenderer(RenderParameters* rp)
    : SurfaceRenderer(rp)
{
    initBuffers();
    initShaders();
}


ControlMeshRenderer::~ControlMeshRenderer() {
    delete shader;
}

void ControlMeshRenderer::initBuffers() {
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);

    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);

    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, nullptr);

    glGenBuffers(1, &ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
}

void ControlMeshRenderer::initShaders() {

    shader = new Shader();

    shader->addShaderFromSourceFile(ShaderType::VertexS, "../shaders/vert/vertcontrolshader.glsl");

    shader->addShaderFromSourceFile(ShaderType::Fragment, "../shaders/frag/fragcontrolshader.glsl");

    shader->link();
}

void ControlMeshRenderer::updateBuffers(Model &model) {
    ControlMesh& m = model.getControlMesh();

    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, m.getVertices().size() * sizeof(glm::vec3), m.getVertices().data(), GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, m.getIndices().size() * sizeof(unsigned), m.getIndices().data(), GL_STATIC_DRAW);
}

void ControlMeshRenderer::render(Model& model) {
    glBindVertexArray(vao);

    shader->use();
    shader->setUniform("matrix", settings->MVP);

    //render the wireframe
    glEnable(GL_PRIMITIVE_RESTART);
    glPrimitiveRestartIndex(0xFFFFFFFF);
    glDrawElements(GL_LINE_LOOP, model.getControlMesh().getIndices().size(), GL_UNSIGNED_INT, (void *) 0);

    glDisable(GL_PRIMITIVE_RESTART);
    glBindVertexArray(0);
}

