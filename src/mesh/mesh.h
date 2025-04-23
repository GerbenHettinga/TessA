#ifndef MESH_H
#define MESH_H

#include <vector>
#include <glm/glm.hpp>

#include "vertex.h"
#include "face.h"
#include "halfedge.h"


class Mesh {

public:
    Mesh() {}
    ~Mesh();

    Mesh(std::vector<glm::vec3> vs,
         std::vector<glm::vec3> ns, std::vector<std::vector<int>> nInds,
         std::vector<glm::vec2> uvs, std::vector<std::vector<int>> uvInds,
         std::vector<std::vector<int>> nextInds,
         std::vector<int> polyIndices, std::vector<int> faceValences);

    void init(std::vector<glm::vec3>& vs,
        std::vector<glm::vec3>& ns, std::vector<std::vector<int>>& nInds,
        std::vector<glm::vec2>& uvs, std::vector<std::vector<int>>& uvInds,
        std::vector<std::vector<int>>& nextInds,
        std::vector<int>& polyIndices, std::vector<int>& faceValences);

    Mesh(std::vector<Vertex>& vs, std::vector<HalfEdge>& hes, std::vector<Face>& fs);
    Mesh(std::vector<Vertex>& vs, std::vector<HalfEdge>& hes, std::vector<Face>& fs, bool calcAttributes);


    unsigned getValence(Vertex* Vert);
    bool subdivide(unsigned degree, Mesh& newMesh);
    bool catmullClark(Mesh& newMesh);
    bool dooSabin(Mesh& newMesh);
    bool oddDegree(unsigned degree, Mesh& newMesh);
    bool evenDegree(unsigned degree, Mesh& newMesh);
    bool linSubdivide();
    bool linSubdivide(Mesh& newMesh);

    bool dual();

    void evenSmooth();
    void oddSmooth();

    // For debugging
    void dispVertInfo(Vertex* dVert);
    void dispHalfEdgeInfo(HalfEdge* dHalfEdge);
    void dispFaceInfo(Face* dFace);

    std::vector<glm::vec3> setNormals();
    void meshMetrics();

    bool hasFacesOfValency(int v);
    int getNumberOfFaces(int v);
    bool hasEFsOfValency(int i);
    int getNumberOfEFs(int i);
    bool hasEVsOfValency(int i);
    int getNumberOfEVs(int i);
    bool hasRegularFaces();
    int getNumberOfRegularFaces();


    void setLimitPositionsAndTangents();

    void changeParamType(int p);
    void useTrueNormals(bool b);



    bool hasExtraordinaryVertices () { return hasEVs; }
    bool hasExtraordinaryFaces () { return hasEFs; }
    bool areEVsSurroundedByQuads() { return EVsSurroundedByQuads; }
    bool areEVsIsolated() { return EVsIsolated; }
    bool areEVsTwiceIsolated() { return EVsTwiceIsolated; }
    bool areEFsSurroundedByQuads() { return EFsSurroundedByQuads; }
    bool areEFsIsolated() { return EFsIsolated; }
    bool areEFsTwiceIsolated() { return EFsTwiceIsolated; }
    unsigned getEVisolationLevel() { return EVisolationLevel; }
    unsigned getEFisolationLevel() { return EFisolationLevel; }
    bool hasNormals() { return hasHENormals; }
    bool hasUVs() { return hasHEUVs; }

    Vertex* findClosest(glm::vec2 spos, glm::mat4x4 MVP);

    std::vector<Vertex>& getVertices() { return vertices; }
    std::vector<HalfEdge>& getHalfEdges() { return halfEdges; }
    std::vector<Face>& getFaces() { return faces; }

    std::vector<std::vector<Vertex*>>& getEVs() { return evs; }
    std::vector<Face*>& getRegularFaces() { return regFaces; }

    void update();
protected:

    void construct(std::vector<glm::vec3>& vs,
                   std::vector<glm::vec3>& ns,
                   std::vector<glm::vec2>& uvs, std::vector<int>& polyIndices, std::vector<int>& faceValences);

    void constructHalfEdges(std::vector<glm::vec3>& ns,
                            std::vector<glm::vec2>& uvs,
                            std::vector<std::vector<int>>& nInds,
                            std::vector<std::vector<int>>& uvInds,
                            std::vector<std::vector<int>>& nextInds);

    bool linSubdivide(std::vector<Vertex>& newVertices, std::vector<HalfEdge>& newHalfEdges, std::vector<Face>& newFaces);


private:
    //friend classes for easy access to topology data
    friend class NormalMesh;
    friend class CCMesh;
    friend class GenBSplineMesh;
    friend class GenQuadraticBSplineMesh;
    friend class GenQuarticBSplineMesh;
    friend class ControlMesh;

    int paramType;
    bool trueNormals;
    unsigned nOfTriangles;

    void findEVs();
    void findEFs();
    void findRegularFaces();

    bool hasEVs = false;
    bool hasEFs = false;
    bool EVsSurroundedByQuads = false;
    bool EVsIsolated = false;
    bool EVsTwiceIsolated = false;
    bool EFsSurroundedByQuads = false;
    bool EFsIsolated = false;
    bool EFsTwiceIsolated = false;
    bool hasHENormals = false;
    bool hasHEUVs = false;
    bool isDual = false;

    unsigned EVisolationLevel;
    unsigned EFisolationLevel;

    int polygons[8] = {0,0,0,0,0,0,0,0};

    unsigned numBoundary;

    std::vector<Vertex> vertices;
    std::vector<Face> faces;
    std::vector<HalfEdge> halfEdges;

    std::vector<std::vector<Vertex*>> evs;
    std::vector<std::vector<Face*>> efs;

    std::vector<Face*> bRegFaces;
    std::vector<Face*> regFaces;
    std::vector<Vertex*> regVertex;

    std::vector<unsigned> indices;
};

#endif // MESH_H
