#include "acc2renderer.h"
#include "../meshtypes/ccmesh.h"
#include "../mesh/mesh.h"
#include "../renderparameters.h"

ACC2Renderer::ACC2Renderer(RenderParameters* rp)
    : SurfaceRenderer(rp)
{
    getError();
    initBuffers();
    initShaders();
    getError();
}

ACC2Renderer::~ACC2Renderer() {
    glDeleteVertexArrays(1, &vao);
    glDeleteBuffers(6, vbo);
}

void ACC2Renderer::initBuffers() {
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);

    glGenBuffers(6, vbo);

    for(GLuint i = 0; i < 5; i++) {
        glBindBuffer(GL_ARRAY_BUFFER, vbo[i]);

        glEnableVertexAttribArray(i);
        glVertexAttribPointer(i, 3, GL_FLOAT, GL_FALSE, 0, nullptr);
    }

    glBindBuffer(GL_ARRAY_BUFFER, vbo[5]);

    glEnableVertexAttribArray(5);
    glVertexAttribPointer(5, 2, GL_FLOAT, GL_FALSE, 0, nullptr);
}

void ACC2Renderer::initShaders() {
    polyShaders.reserve(6);

    // for transform feedback
    const char* varyings[1] = {"pos"};

    for(size_t i = 3; i < 9; ++i) {
        polyShaders.push_back(new PolygonShader(i,
                                             std::string("../shaders/vert/vertshaderacc.glsl"),
                                             std::string("../shaders/acc/tcaccx.glsl"),
                                             std::string("../shaders/acc/teaccx.glsl") ));

        //glTransformFeedbackVaryings(polyShaders[i-3]->getFlatNormalShader()->getId(), 1, varyings, GL_SEPARATE_ATTRIBS);
    }
}



void ACC2Renderer::updateBuffers(Model& model) {
    CCMesh& m = model.getCCMesh();

    glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
    glBufferData(GL_ARRAY_BUFFER, m.getVertices().size() * sizeof(glm::vec3), m.getVertices().data(), GL_STATIC_DRAW);

    std::vector<std::vector<glm::vec3>>& bs = m.getBs();
    for(GLuint i = 1; i < 5; i++) {
        glBindBuffer(GL_ARRAY_BUFFER, vbo[i]);
        glBufferData(GL_ARRAY_BUFFER, bs[i-1].size() * sizeof(glm::vec3), bs[i-1].data(), GL_STATIC_DRAW);
    }

    glBindBuffer(GL_ARRAY_BUFFER, vbo[5]);
    glBufferData(GL_ARRAY_BUFFER, m.getUVs().size() * sizeof(glm::vec2), m.getUVs().data(), GL_STATIC_DRAW);

}


void ACC2Renderer::paintTessellation(int valency, int indexBufPointer, int numPatches) {
   Shader* shader = setShaderUniforms(polyShaders[valency-3]);

   getError();

   glPatchParameteri(GL_PATCH_VERTICES, (unsigned int) valency);

   getError();

   if(valency < 5) {
       glDrawArrays(GL_PATCHES, indexBufPointer, numPatches);

       getError();
   } else {
       if(settings->TriangulationMode == TriangulationModes::Minimal) {
           shader->setUniform("triangulation", 0);
           glDrawArraysInstanced(GL_PATCHES, indexBufPointer, numPatches, (unsigned int)(valency - 2));
       } else {
           shader->setUniform("triangulation", 1);
           glDrawArraysInstanced(GL_PATCHES, indexBufPointer, numPatches, (unsigned int)(valency));
       }
   }
}

void ACC2Renderer::render(Model& model) {
    glBindVertexArray(vao);

    int bIdx = 0;
    int numPatches;

    for(int i = 3; i < 9; ++i) {
        Mesh* currentMesh = model.getCCMesh().getMesh();

        bool a = currentMesh->hasFacesOfValency(i);
        if(!currentMesh->hasFacesOfValency(i)) {
            continue;
        }
        numPatches = currentMesh->getNumberOfFaces(i) * i;
        paintTessellation(i, bIdx, numPatches);
        bIdx += numPatches;
    }


    glBindVertexArray(0);
}
