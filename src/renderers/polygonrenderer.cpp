#include "polygonrenderer.h"

PolygonRenderer::PolygonRenderer(RenderParameters* rp)
    : SurfaceRenderer(rp)
{
    initBuffers();
    initShaders();
}

PolygonRenderer::~PolygonRenderer() {
    glDeleteVertexArrays(1, &vao);

    glDeleteBuffers(1, &vbo);
    glDeleteBuffers(1, &nbo);
    glDeleteBuffers(1, &uvbo);
    glDeleteBuffers(1, &ibo);
}

void PolygonRenderer::initBuffers() {
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);

    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);

    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, nullptr);

    glGenBuffers(1, &nbo);
    glBindBuffer(GL_ARRAY_BUFFER, nbo);

    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, nullptr);

    glGenBuffers(1, &uvbo);
    glBindBuffer(GL_ARRAY_BUFFER, uvbo);

    glEnableVertexAttribArray(2);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 0, nullptr);

    glGenBuffers(1, &ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);

    glBindVertexArray(0);
}


void PolygonRenderer::initShaders() {
    for(int i = 3; i < 9; i++) {
        //polyFlat.push_back(new PolygonShader(i, std::string("../shaders/flat/tcflatx.glsl"),
        //                                      std::string("../shaders/flat/tepolyflat.glsl")));

        //differentiate cases depending on i
        //polyFlatSquare.push_back(new PolygonShader(i, std::string("../shaders/flat/tcflatx.glsl"),
        //                                      ((i % 2) == 0) ? std::string("../shaders/flat/tepolyflatsq.glsl") :  std::string("../shaders/flat/tepolyflat.glsl")));

        const char* varyings[1] = {"pos"};

        /*if(i == 4) {
            polyImplicitPhong.push_back(new PolygonShader(std::string("../shaders/polyphong/tcphong" + std::string::number(i) + ".glsl"),
                                                  std::string("../shaders/polyphong/tepolyphongsq.glsl")));
            polyImplicitPN.push_back(new PolygonShader(std::string("../shaders/polyphong/tcphong" + std::string::number(i) + ".glsl"),
                                                  std::string("../shaders/polypn/tepolypnsq.glsl")));
        } else {
            polyImplicitPhong.push_back(new PolygonShader(std::string("../shaders/polyphong/tcphong" + std::string::number(i) + ".glsl"),
                                                  std::string("../shaders/polyphong/tepolyphong.glsl")));
            polyImplicitPN.push_back(new PolygonShader(std::string("../shaders/polyphong/tcphong" + std::string::number(i) + ".glsl"),
                                                  std::string("../shaders/polypn/tepolypn.glsl")));
        }*/
        //polyPhongExplicit.push_back(new PolygonShader(std::string("../shaders/phong/tcphong" + std::string::number(i) + "expl.glsl"),
        //                                       std::string("../shaders/phong/tephong" + std::string::number(i) + "expl.glsl" )));
        //polyPNExplicit.push_back(new PolygonShader(std::string("../shaders/pn/tcpn" + std::string::number(i) + "expl.glsl"),
        //                                       std::string("../shaders/pn/tepn" + std::string::number(i) + "expl.glsl") ));

        polyTensorExplicit.push_back(new PolygonShader(i, std::string("../shaders/GGB/tctensorx.glsl"),
                                           std::string("../shaders/GGB/tetensorx.glsl" )));
        polyGregExplicit.push_back(new PolygonShader(0, std::string("../shaders/GSP/tcgreg" + std::to_string(i) + "expl.glsl"),
                                               std::string("../shaders/GSP/tegreg"+ std::to_string(i) + "expl.glsl") ));

        //glTransformFeedbackVaryings(polyFlatSquare[i-3]->getFlatNormalShader()->programId(), 1, varyings, GL_SEPARATE_ATTRIBS);


        //glTransformFeedbackVaryings(polyFlat[i-3]->getFlatNormalShader()->programId(), 1, varyings, GL_SEPARATE_ATTRIBS);
        //polyFlat[i-3]->getFlatNormalShader()->link();
    }
}

void PolygonRenderer::updateBuffers(Model& model) {
    NormalMesh& nm = model.getNormalMesh();

    std::vector<glm::vec3>& verts = nm.getVertices();
    std::vector<glm::vec3>& norms = nm.getNormals();
    std::vector<glm::vec2>& uvs = nm.getUVs();
    std::vector<int>& indices = nm.getIndicesRing();

    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, verts.size() * sizeof(glm::vec3), verts.data(), GL_STATIC_DRAW);

    glBindBuffer(GL_ARRAY_BUFFER, nbo);
    glBufferData(GL_ARRAY_BUFFER, norms.size() * sizeof(glm::vec3), norms.data(), GL_STATIC_DRAW);

    glBindBuffer(GL_ARRAY_BUFFER, uvbo);
    glBufferData(GL_ARRAY_BUFFER, uvs.size() * sizeof(glm::vec2), uvs.data(), GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(unsigned), indices.data(), GL_STATIC_DRAW);
}

void PolygonRenderer::paintTessellation(int valency, int indexBufPointer, int numPatches) {
    glPatchParameteri(GL_PATCH_VERTICES, (unsigned int)valency);

    if (valency < 5) {
        glDrawArrays(GL_PATCHES, indexBufPointer, numPatches);
    }
    else {
        glDrawArraysInstanced(GL_PATCHES, indexBufPointer, numPatches, (unsigned int)(valency));
    }
}

void PolygonRenderer::render(Model& model) {
    PolygonShader* polyShader;

    int valency = 3;
    switch(settings->SurfaceMode) {
        case SurfaceModes::Flat     :
            if(valency == 4 || settings->TriangulationMode == TriangulationModes::SuperMinimal || settings->TriangulationMode == TriangulationModes::SuperPie) {
               polyShader = polyFlatSquare[valency - 3];
            } else {
               polyShader = polyFlat[valency - 3];
            }
            break;
        case SurfaceModes::PN       :
            polyShader = polyPNExplicit[valency-3];
            break;
        case SurfaceModes::Gregory  :
            polyShader = polyGregExplicit[valency-3];
            break;
        case SurfaceModes::Tensor   :
            polyShader = polyTensorExplicit[valency-3];
            break;
        case SurfaceModes::Mixed    :
            if(valency < 6) {
                polyShader = polyGregExplicit[valency-3];
            } else {
                polyShader = polyTensorExplicit[valency-3];
            }
            break;
        case SurfaceModes::PhongImplicit :
            polyShader = polyImplicitPhong[valency-3];
            break;
        case SurfaceModes::PNImplicit  :
            polyShader = polyImplicitPN[valency-3];
            break;
        default                     :
            polyShader = polyPhongExplicit[valency-3];
            break;
    }

    setShaderUniforms(polyShader);

    glBindVertexArray(vao);

    int bIdx = 0;
    int numPatches;

    for (int i = 3; i < 9; ++i) {
        Mesh* currentMesh = model.getMesh();

        bool a = currentMesh->hasFacesOfValency(i);
        if (!currentMesh->hasFacesOfValency(i)) {
            continue;
        }
        numPatches = currentMesh->getNumberOfFaces(i) * i;
        paintTessellation(i, bIdx, numPatches);
        bIdx += numPatches;
    }

    glBindVertexArray(0);
}
