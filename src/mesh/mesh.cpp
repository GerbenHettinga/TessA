#include "mesh.h"
#include "math.h"
#include <unordered_set>
#include <numbers> 
#include <iostream>

Mesh::Mesh(std::vector<glm::vec3> vs,
           std::vector<glm::vec3> ns, std::vector<std::vector<int>> nInds,
           std::vector<glm::vec2> uvs, std::vector<std::vector<int>> uvInds,
           std::vector<std::vector<int>> nextInds,
           std::vector<int> polyIndices, std::vector<int> faceValences)
{

    construct(vs, ns, uvs, polyIndices, faceValences);

    if(!nInds.empty()) {
        hasHENormals = true;
    }

    if(!uvInds.empty()) {
        hasHEUVs = true;
    }

    constructHalfEdges(ns, uvs, nInds, uvInds, nextInds);

    setLimitPositionsAndTangents();

    meshMetrics();
}

void Mesh::init(std::vector<glm::vec3>& vs,
    std::vector<glm::vec3>& ns, std::vector<std::vector<int>>& nInds,
    std::vector<glm::vec2>& uvs, std::vector<std::vector<int>>& uvInds,
    std::vector<std::vector<int>>& nextInds,
    std::vector<int>& polyIndices, std::vector<int>& faceValences)
{
    vertices.clear();
    halfEdges.clear();
    faces.clear();

    construct(vs, ns, uvs, polyIndices, faceValences);

    if (!nInds.empty()) {
        hasHENormals = true;
    }

    if (!uvInds.empty()) {
        hasHEUVs = true;
    }

    constructHalfEdges(ns, uvs, nInds, uvInds, nextInds);

    setLimitPositionsAndTangents();

    meshMetrics();
}

Mesh::~Mesh() {

}

Mesh::Mesh(std::vector<Vertex>& verts, std::vector<HalfEdge>& hes, std::vector<Face>& fs) :
    vertices(verts), faces(fs), halfEdges(hes)
{
    meshMetrics();

    size_t n = verts.size();

//    vs = std::vector<glm::vec3>(n);
//    vertexNormals = std::vector<glm::vec3>(n);
//    vertexUVs = std::vector<glm::vec2>(n);
//    for(size_t i = 0; i < n; i++) {
//       vs[i] = vertices[i].coords;
//       vertexNormals[i] = vertices[i].normal;
//       vertexUVs[i] = vertices[i].uv;
//    }
}



Mesh::Mesh(std::vector<Vertex>& verts, std::vector<HalfEdge>& hes, std::vector<Face>& fs, bool calcAttributes) :
    vertices(verts), faces(fs), halfEdges(hes)
{
    meshMetrics();

    size_t n = verts.size();

//    vs = std::vector<glm::vec3>(n);
//    vertexNormals = std::vector<glm::vec3>(n);
//    vertexUVs = std::vector<glm::vec2>(n);
//    for(size_t i = 0; i < n; i++) {
//       vs[i] = vertices[i].coords;
//       vertexNormals[i] = vertices[i].normal;
//       vertexUVs[i] = vertices[i].uv;
//    }

    //????
    polygons[1] = fs.size()*4;
}

void Mesh::update() {
    //meshMetrics();
    setLimitPositionsAndTangents();
}


bool Mesh::hasFacesOfValency(int v){
    return (polygons[v-3] > 0);
}

int Mesh::getNumberOfFaces(int v){
    return polygons[v-3];
}

bool Mesh::hasEFsOfValency(int i) {
    return !efs[i-3].empty();
}

int Mesh::getNumberOfEFs(int i) {
    return efs[i-3].size();
}

bool Mesh::hasEVsOfValency(int i) {
    return !evs[i-3].empty();
}

int Mesh::getNumberOfEVs(int i) {
    return evs[i-3].size();
}

bool Mesh::hasRegularFaces() {
    return !regFaces.empty() || !bRegFaces.empty();
}

int Mesh::getNumberOfRegularFaces() {
    return regFaces.size() + bRegFaces.size();
}

void Mesh::changeParamType(int p) {
    paramType = p;
}

void Mesh::useTrueNormals(bool b) {
    trueNormals = b;
}


void Mesh::constructHalfEdges(std::vector<glm::vec3>& ns,
                              std::vector<glm::vec2>& uvs,
                              std::vector<std::vector<int>>& nInds,
                              std::vector<std::vector<int>>& uvInds,
                              std::vector<std::vector<int>>& nextInds) {

    //for each vertex set its halfedges data
    for(int i = 0; i < vertices.size(); i++) {
        //int n = vertices[i].onBoundary ? vertices[i].val - 1 : vertices[i].val;

        int n = nextInds[i].size();
        for(int j = 0; j < n; j++) {
            int adjIdx = nextInds[i][j];
            //iterate over adjacent vertices to find correct one
            //then assign tangent to the halfedge
            HalfEdge* he = vertices[i].out;

            size_t cnt = 0;
            while(he->target->index != adjIdx && cnt < vertices[i].val) {
                he = he->twin->next;
                cnt++;
            }

            if(cnt <= vertices[i].val) {
                if(hasHEUVs) {
                    int tuv = uvInds[i][j];
                    he->uv = uvs[tuv];
                } else {
                    he->uv = glm::vec2(0.5, 0.5);
                }

                if(hasHENormals) {
                    int tns = nInds[i][j];
                    he->normal = ns[tns];
                } else {
                    he->normal = vertices[i].normal;
                }
            }
        }

    }

//    for(HalfEdge& he : halfEdges) {
//        if(he.twin->next->uv != he.uv) {
//            he.seam = true;
//        }
//    }

}

void Mesh::construct(std::vector<glm::vec3>& vs,
                     std::vector<glm::vec3>& ns,
                     std::vector<glm::vec2>& uvs,
                     std::vector<int>& polyIndices, std::vector<int>& faceValences) {

    size_t numVertices = unsigned(vs.size());
    size_t numHalfEdges = unsigned(polyIndices.size());
    size_t numFaces = unsigned(faceValences.size());

    // Note - resize() invokes the Vertex() constructor, reserve() does not.
    vertices.reserve(numVertices);
    halfEdges.reserve(2*numHalfEdges);
    faces.reserve(numFaces);

    //lVertices = *vs;

    // Add Vertices
    for (size_t i = 0; i < numVertices; i++) {
        vertices.push_back(Vertex(vs[i], nullptr, 0, i));
    }

    unsigned indexH = 0;
    unsigned currentIndex = 0;
    std::vector<std::vector<HalfEdge*>> potentialTwins(numVertices);
    // Add Faces
    for (int m = 0; m < numFaces; m++) {
        int faceValency = faceValences[m];
        faces.push_back(Face(nullptr, faceValency, m));

        for (int i = 0; i < faceValency; i++) {
            halfEdges.push_back(HalfEdge(nullptr, nullptr, nullptr, nullptr, nullptr, indexH + i));
        }

        for (int i = faceValency - 1; i >= 0; i--) {
            auto& currentEdge = halfEdges[indexH + i];

            int p1 = (i + 1) % faceValency;
            int m1 = (i - 1 + faceValency) % faceValency;

            int targetIndex = polyIndices[currentIndex + i];

            currentEdge = 
                HalfEdge(&vertices[targetIndex],
                        &halfEdges[indexH + p1], //next
                        &halfEdges[indexH + m1], //prev
                        nullptr,                                                  //twin      
                        &faces[m], 
                        indexH + i);

            // Append index of HalfEdge to list of OutgoingHalfEdges of its TailVertex.
            potentialTwins[targetIndex].push_back(&halfEdges[indexH + p1]);
        }

        faces[m].side = &halfEdges[indexH];

        indexH += faceValency;
        currentIndex += faceValency;

        polygons[faceValency - 3]++;
    }

    //qDebug() << "Faces" << faces.capacity() << faces.size();

    // Outs and Valences of vertices
    for (int k = 0; k < numVertices; k++) {
        //assign a random halfedge to start
        if(!potentialTwins[k].empty()) {
            vertices[k].out = potentialTwins[k][0];
            size_t len = potentialTwins[k].size();
            vertices[k].val = len;
        }
    }

    std::unordered_set<size_t> twinless;
    for (int m = 0; m < numHalfEdges; m++) {
        auto& currentEdge = halfEdges[m];

        if (!currentEdge.twin) {
            const Vertex* hTail = currentEdge.prev->target;
            const Vertex* hHead = currentEdge.target;
            const size_t len = currentEdge.target->val;

            auto& outgoing = potentialTwins[hHead->index];
            for (int i = 0; i < len; i++) {
                if (outgoing[i]->target == hTail) {

                    currentEdge.twin = outgoing[i];
                    outgoing[i]->twin = &currentEdge;
                    break;
                }

                if (i == (len - 1)) {
                    twinless.insert(m);
                }
            }            
        }

    }

    //qDebug() << "missing twins: " << twinless.size();

    if(!twinless.empty()) {
        HalfEdge* initial;
        HalfEdge* current;
        size_t start;

        while(twinless.size() > 0) {
            initial = &halfEdges[*twinless.begin()];
            twinless.erase(initial->index);

            halfEdges.push_back(HalfEdge(initial->prev->target, 0, 0, initial, 0, indexH));
            start = indexH;
            indexH++;

            current = initial->prev;
            while(current->twin != nullptr) {
                current = current->twin->prev;
            }

            // Trace the current boundary loop
            while (current != initial) {
                twinless.erase(current->index);

                // Target, Next, Prev, Twin, Poly, Index
                halfEdges.push_back(HalfEdge( current->prev->target,
                                           nullptr,
                                           &halfEdges[indexH-1],
                                 current,
                                 nullptr,
                                 indexH ));
                halfEdges[indexH-1].next = &halfEdges[indexH];

                current->target->val += 1;
                current->twin = &halfEdges[indexH];
                indexH++;

                current = current->prev;
                while (current->twin != nullptr) {
                    current = current->twin->prev;
                }
            }

            halfEdges[start].prev = &halfEdges[indexH-1];
            halfEdges[indexH-1].next = &halfEdges[start];

            initial->target->val += 1;
            initial->twin = &halfEdges[start];

        }
    }

    //for(size_t i = 0; i < halfEdges.size(); ++i) {
    //    if(!halfEdges[i].target)
            //qDebug() << "no target";
    //}
}

void Mesh::setLimitPositionsAndTangents() {
    // obtain face points
    for(int i = 0; i < faces.size(); i++) {
        Face* f = &faces[i];

        glm::vec3 c(0.0, 0.0, 0.0);
        HalfEdge* he = f->side;

        for(int j = 0; j < f->val; j++) {
            c += he->target->coords;
            he = he->next;
        }

        f->c = c / (float) f->val;
    }

    //compute limit positions of vertices and tangents at vertices
    for(int i = 0; i < vertices.size(); i++) {
        Vertex* v = &vertices[i];
        unsigned n = v->val;

        std::vector<glm::vec3> qis(n);

        if(v->val == 2) {
            v->p = v->coords;
            HalfEdge* he = v->out;
            for(size_t j = 0; j < 2; ++j) {
                he->e = 2.0f/3.0f * v->coords + 1.0f/3.0f * he->target->coords;
                qis[j] = he->e - v->coords;
                he = he->prev->twin;
            }
        } else if(v->val == 3 && v->onBoundary) {
            HalfEdge* he = v->out;
            glm::vec3 p;

            //find boundary edge
            for(size_t j =0; j < 3; ++j) {
                if(!he->polygon) {
                    break;
                }
                he = he->prev->twin;
            }

            p = (he->target->coords + 4.0f * v->coords + he->prev->twin->target->coords) / 6.0f;

            v->p = p;
            he = v->out;
            for(size_t j = 0; j < 3; ++j) {
                if(he->polygon && he->twin->polygon) {
                    glm::vec3 a = (he->next->target->coords + 2.0f*he->next->next->target->coords)/3.0f;
                    glm::vec3 b = (2.0f*he->twin->target->coords + he->target->coords)/3.0f;
                    glm::vec3 c = (2.0f*he->twin->next->target->coords + he->twin->next->next->target->coords)/3.0f;

                    he->e = (a + 4.0f*b + c)/6.0f;
                } else {
                    he->e = 2.0f/3.0f * v->coords + 1.0f/3.0f * he->target->coords;
                }
                qis[j] = he->e - v->p;
                he = he->prev->twin;
            }
        } else {
            float fn = (float) n;
            v->c = cos((2.0f*std::numbers::pi)/fn);

            float cospifn = cos(std::numbers::pi / fn);
            float cos2pifn = cos(2.0f * std::numbers::pi / fn);
            float lambda = (5.0f + cos2pifn + cospifn * sqrt(18.0f + 2.0f * cos2pifn)) / 16.0f;
            float sigma = 1.0f / sqrt(4.0f + cospifn * cospifn);

            ////qDebug() << "n: " << n << " lambda " << lambda <<" sigma " << sigma;


            glm::vec3 micis = glm::vec3();
            glm::vec3 mi, ci;

            HalfEdge* he = v->out;
            //calculate all attributes for this vertex
            for(unsigned j = 0; j < n; j++) {
                HalfEdge* cHe = he;
                //calculation for limit tangents
                for(unsigned k = 0; k < n; k++) {
                    float fk = (float) k;
                    mi = 0.5f * (cHe->target->coords + v->coords);

                    if(!cHe->polygon) {

                    } else {
                        ci = cHe->polygon->c;

                        qis[j] += (float)(1.0f - sigma*cos(std::numbers::pi /fn)) * (float)(cos((2.0f* std::numbers::pi *fk)/fn)) * mi;
                        qis[j] += 2.0f * sigma * (float)cos((2.0f* std::numbers::pi *fk + std::numbers::pi) / fn) * ci;

                    }

                    cHe = cHe->prev->twin;
                }

                if(he->twin->polygon) {
                    micis += 0.5f * (v->coords + he->target->coords) + he->twin->polygon->c;
                }
                he = he->prev->twin;
            }


            v->p = ((float)(n-3.0f)/(float)(n+5.0f)) * v->coords  + (4.0f/(float)(n*(n+5))) * micis;


            he = v->out;
            for(unsigned j = 0; j < n; j++) {
                he->e = v->p + (2.0f / 3.0f) * lambda * (2.0f/fn *  qis[j]);
                he = he->prev->twin;
            }
        }
        v->n = glm::cross(glm::normalize(qis[0]), glm::normalize(qis[1]));
    }

    //now everything should be ready to determine the fs;
    for(unsigned i = 0; i < vertices.size(); i++) {
        Vertex* v = &vertices[i];
        unsigned n = v->val;
        float c0 = cos((2.0f*std::numbers::pi)/(float)(v->val));
        HalfEdge* he = v->out;
        for(unsigned j = 0; j < n; j++) {
            if(he->polygon) {
                float d = he->polygon->val > 3 ? 3.0 : 4.0;

                float c1 = cos((2.0f*std::numbers::pi)/(float)(he->target->val));

                if(he->polygon && he->twin->polygon) {
                    glm::vec3 r = (he->prev->twin->target->coords - he->twin->next->target->coords)/6.0f
                           + 2.0f*(he->polygon->c - he->twin->polygon->c)/3.0f;


                    he->fp = (c1 * v->p + (d - 2.0f*c0 - c1) * he->e + (2.0f*c0) * he->twin->e + r) / d;
                    he->fm = (c1 * v->p + (d - 2.0f*c0 - c1) * he->e + (2.0f*c0) * he->twin->e - r) / d;
                } else {
                    he->fp = (2.0f * he->target->coords +
                             4.0f * he->twin->target->coords +
                             2.0f * he->prev->twin->target->coords +
                             he->next->target->coords)/9.0f;
                    he->fm = v->p - ((he->e - v->p) + (he->prev->twin->e - v->p));
                }
            }

            he = he->prev->twin;
         }

    }
}

void Mesh::findEFs() {
    efs.clear();
    efs.resize(10);

    EFsSurroundedByQuads = true;
    EFsIsolated = true;
    EFsTwiceIsolated = true;


    for(Face& f : faces) {
        if(f.val != 4) {
            hasEFs = true;

            EFsSurroundedByQuads = EFsSurroundedByQuads && f.isSurroundedByQuads();
            EFsIsolated = EFsIsolated && f.isIsolated();
            EFsTwiceIsolated = EFsTwiceIsolated && f.isIsolated(1);

            efs[f.val - 3].push_back(&f);
        }
    }
}

void Mesh::findEVs() {
    evs.clear();
    evs.resize(10);

    regVertex.clear();

    EVsIsolated = true;
    EVsTwiceIsolated = true;
    EVsSurroundedByQuads = true;

    for(Vertex& v : vertices) {
        if(v.isOnBoundary()) {
           v.onBoundary = true;

            if(v.val >= 4) { //valency 2 and three are only correct on boundary
                hasEVs = true;
                EVsSurroundedByQuads = EVsSurroundedByQuads && v.isSurroundedByQuads();
                EVsIsolated = EVsIsolated && v.isIsolated();
                EVsTwiceIsolated = EVsTwiceIsolated && v.isIsolated(1);
                evs[v.val - 3].push_back(&v);
           }
        } else {
            if(v.val != 4) {
                hasEVs = true;
                EVsSurroundedByQuads = EVsSurroundedByQuads && v.isSurroundedByQuads();
                EVsIsolated = EVsIsolated && v.isIsolated();
                EVsTwiceIsolated = EVsTwiceIsolated && v.isIsolated(1);
                if(v.val >= 3) //only up to valency 8 is supported
                    evs[v.val - 3].push_back(&v);
            }
        }

        if(v.isRegular() && v.isSurroundedByQuads() && !v.isOnBoundary()) {
            regVertex.push_back(&v);
        }
    }
}

void Mesh::findRegularFaces() {
    //only append faces with valency 4 and no EVs
    regFaces.clear();
    for(size_t k = 0; k < faces.size(); k++) {
        if(faces[k].isRegular()) {
            if(faces[k].isOnBoundary()) {
                bRegFaces.push_back(&faces[k]);
            } else {
                regFaces.push_back(&faces[k]);
            }
        }
    }
}


bool Mesh::subdivide(unsigned degree, Mesh& newMesh) {
    if(degree != 3) {
        return evenDegree(degree, newMesh);
    } else {
        return catmullClark(newMesh);
    }
}

//process EVs and faces
void Mesh::meshMetrics() {
    findEVs();
    findEFs();
    findRegularFaces();

    for (int i = 0; i < 8; ++i) {
        polygons[i] = 0;
    }

    for (Face& f : faces) {
        polygons[f.val - 3]++;
    }
}


Vertex* Mesh::findClosest(glm::vec2 spos, glm::mat4x4 MVP) {
    Vertex* closest = nullptr;
    float dist, minDist = 1000.0;
    for(size_t i = 0; i < vertices.size(); i++) {
        glm::vec3 worldPos = glm::vec3(MVP * glm::vec4(vertices[i].coords, 1.0));

        glm::vec2 screenPos_nds = glm::vec2(worldPos.x, worldPos.y);
        dist = glm::distance(screenPos_nds, spos);

        if(dist < minDist) {
            closest = &vertices[i];
            minDist = dist;
        }
    }

    return closest;
}


// Example to illustrate the half-edge structure
unsigned Mesh::getValence(Vertex* Vert) {
    unsigned val;
    HalfEdge* startH;
    HalfEdge* nextH;

    startH = Vert->out;
    val = 1;
    nextH = startH->twin->next;

    while ((nextH != startH) && (val < 40)) {
        val++;
        nextH = nextH->twin->next;
    }

    return val;
}

void Mesh::dispVertInfo(Vertex* dVert) {
    //qDebug() << "Vertex at Index =" << dVert->index << "Coords =" << dVert->coords << "Out =" << dVert->out << "Val =" << dVert->val;
}

void Mesh::dispHalfEdgeInfo(HalfEdge* dHalfEdge) {
    //qDebug() << "HalfEdge at Index =" << dHalfEdge->index << "Target =" << dHalfEdge->target << "Next =" << dHalfEdge->next << "Prev =" << dHalfEdge->prev << "Twin =" << dHalfEdge->twin << "Poly =" << dHalfEdge->polygon;
}

void Mesh::dispFaceInfo(Face* dFace){
    //qDebug() << "Face at Index =" << dFace->index << "Side =" << dFace->side << "Val =" << dFace->val;
}

std::vector<glm::vec3> Mesh::setNormals() {
    std::vector<glm::vec3> ns;

    for (int k = 0; k < vertices.size(); k++) {
        ns.push_back(vertices[k].normal);
    }

    return ns;
}


