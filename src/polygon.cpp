#include "polygon.h"
#include "math.h"
#include <glm/glm.hpp>
#include <random>
#include <numbers>

#include <iostream>
#include <fstream>

Polygon::Polygon(){
    polygonVertices.clear();
    polygonNormals.clear();
}

Polygon::Polygon(int valency){
    polygonVertices.clear();
    polygonNormals.clear();
    polygonVertices.reserve(valency);
    polygonNormals.reserve(valency);
    size = valency;

    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<float> dis(-0.5, 0.5);
    std::uniform_real_distribution<float> dis2(0.0, 1.0);

    float phi = (2.0*std::numbers::pi)/float(valency);
    glm::vec3 temp;

    glm::vec2 centr = glm::vec2(0.5, 0.5);

    for(int i = 0; i < valency; i++){
        temp = glm::vec3(cos(phi*i), sin(phi*i), dis(gen));
        //temp = glm::vec3(cos(phi*i), sin(phi*i), 0.0);
        polygonVertices.push_back(temp);
        temp.z = temp.z + dis2(gen);
        polygonNormals.push_back(glm::normalize(temp));
        polygonUVs.push_back(centr + 0.3f*glm::vec2(cos(phi*i), sin(phi*i)));
    }
    calculate();
}

Polygon::Polygon(std::vector<glm::vec3> vs, std::vector<glm::vec3> ns, std::vector<glm::vec2> uvs) :
    polygonVertices(vs),
    polygonNormals(ns),
    polygonUVs(uvs),
    size(vs.size())
{
    calculate();
}

Polygon::Polygon(std::vector<glm::vec3> vs, std::vector<glm::vec2> uvs) :
    polygonVertices(vs),
    polygonUVs(uvs),
    size(vs.size())
{
    for(size_t i = 0; i < vs.size(); i++) {
        polygonNormals.push_back(glm::vec3(1.0, 0.0, 0.0));
    }
    calculate();
}


Polygon::Polygon(std::vector<glm::vec3> vs, std::vector<glm::vec3> ns) :
    polygonVertices(vs),
    polygonNormals(ns),
    size(vs.size())
{
    for(size_t i = 0; i < vs.size(); i++) {
        glm::vec3 vn = glm::normalize(vs[i]);
        polygonUVs.push_back(
                    glm::vec2(0.5 + atan2(vn.z, vn.x),
                              0.5 - asin(vn.y) / std::numbers::pi));
    }
    calculate();
}

Polygon::Polygon(std::vector<glm::vec3> vs) :
    polygonVertices(vs),
    size(vs.size())
{
    for(size_t i = 0; i < vs.size(); i++) {
        glm::vec3 vn = glm::normalize(vs[i]);
        polygonUVs.push_back(
                    glm::vec2(0.5 + atan2(vn.z, vn.x),
                              0.5 - asin(vn.y) / std::numbers::pi));
    }
    polygonNormals.clear();
    calculate();
}

Polygon::~Polygon(){
    //
}

std::vector<glm::vec3> Polygon::getPolygonVertices(){
    return polygonVertices;
}

std::vector<glm::vec3> Polygon::getPolygonNormals(){
    return polygonNormals;
}

std::vector<glm::vec2> Polygon::getPolygonUVs(){
    return polygonUVs;
}


/* function that constructs the indexing for the correct tessellation
 * takes sub-triangle indices and appends remaining indices
 * by use of a usage mask
 * and does this for every sub-triangle */
std::vector<int> Polygon::getIndices(){
    std::vector<int> a;
    std::vector<int> inds; inds.clear(); inds.reserve(size);
    //create mask
    for(int i = 0; i < size; i++){
        inds.push_back(1);
    }
    for(int i = 0; i < size-2; i++){
        std::vector<int> mask = inds;
        a.push_back(indices[(i*3)]);
        mask[indices[(i*3)]] = 0;
        a.push_back(indices[(i*3)+1]);
        mask[indices[(i*3)+1]] = 0;
        a.push_back(indices[(i*3)+2]);
        mask[indices[(i*3)+2]] = 0;

        for(int j = 0; j < size; j++){
            if(mask[j]) a.push_back(j);
        }
    }
    return a;
}

std::vector<int> Polygon::getIndicesExplicit(){
    std::vector<int> a;
    for(int i = 0; i < size-2; i++){
        for(int j = 0; j < size; j++){
            a.push_back(j);
        }
    }
    return a;
}

std::vector<int> Polygon::getIndicesRing() {
    std::vector<int> a(size);

    for(int j = 0; j < size; j++){
        a[j] = j;
    }

    return a;
}

std::vector<int> Polygon::getIndicesTriangular() {
    std::vector<int> a((size - 2) * 3);
    for(int i = 0; i < size-2; i++){
            a[i*3] = 0;
            a[i*3 + 1] =i+1;
            a[i*3 + 2] = i+2;
    }

    return a;
}

int Polygon::getSize(){
    return size;
}

void Polygon::setVertex(int index, glm::vec3 v){
    polygonVertices[index] = v;
}

void Polygon::changeNormal(int vert, glm::vec3 change){
    polygonNormals[vert] = glm::normalize(polygonNormals[vert] + change);
}


std::vector<glm::vec2> Polygon::getParametrization(){
    std::vector<glm::vec2> param; param.clear();
    float phi = (2.0*std::numbers::pi)/float(size);
    for(int i = 0; i < size; i++){
        param.push_back(glm::vec2(cos(phi*i), sin(phi*i)));
    }
    return param;
}

std::vector<glm::vec2> Polygon::getParametrizationBilinear() {
    std::vector<glm::vec2> param; param.clear();
    float phi = (2.0*std::numbers::pi)/size;
    for(int i = 0; i < size; i++){
        param.push_back((0.5f - 0.005f) * glm::vec2(cos(phi*i), sin(phi*i)) + glm::vec2(0.5, 0.5));
    }
    return param;
}

/* positive modulo function for GBC coordinates */
int modulo_pos(int i, int n){
    return (i % n + n) % n;
}

/* calculates signed triangle area, assuming CCW orientation*/
float triangleArea(std::vector<glm::vec3> triangle){
    glm::vec3 v = (triangle[0]-triangle[1]);
    glm::vec3 u = (triangle[2]-triangle[1]);

    float ux = u.x; float uy = u.y; float uz = u.z;
    float vx = v.x; float vy = v.y; float vz = v.z;
    return 0.5*(uy*vz - uz*vy + uz*vx - ux*vz + ux*vy - uy*vx);
}

/*checks if point lies in triangle */
bool inTriangle (glm::vec3 pt, std::vector<glm::vec3> triangle)
{
    float areaABC = triangleArea(triangle);
    float alpha = glm::cross((pt-triangle[1]), (pt-triangle[2])).length() / (2.0*areaABC);
    float beta = glm::cross((pt-triangle[0]), (pt-triangle[2])).length() / (2.0*areaABC);
    float gamma = 1.0f - alpha - beta;

    if(alpha <= 0.0 || alpha >= 1.0){
        return false;
    }
    if(beta <= 0.0 || beta >= 1.0){
        return false;
    }
    if(gamma <= 0.0 || gamma >= 1.0){
        return false;
    }

    return true;
}

/* simple function with debug statement */
bool isNegativeTriangleArea(std::vector<glm::vec3> triangle){;
    return triangleArea(triangle) <= 0.0;
}

/* implementation of the ear clip algorithm for triangulating polygons
 * from polygonal boundaries. Assumes CCW binding */
std::vector<glm::vec3> Polygon::triangulateEarClip(){
    std::vector<glm::vec3> polygon;
    polygon.clear();
    polygon.insert(polygon.end(), polygonVertices.begin(), polygonVertices.end());

    std::vector<glm::vec3> triangle;
    triangle.clear();

    std::vector<glm::vec3> triangles;
    triangles.clear();
    bool ok;

    int i = 0;
    while(polygon.size() > 3 ){
        triangle.push_back(polygon[modulo_pos(i-1, polygon.size())]);
        triangle.push_back(polygon[i % polygon.size()]);
        triangle.push_back(polygon[(i+1) % polygon.size()]);
        ok = true;
        if(!isNegativeTriangleArea(triangle)){
            int j = (i+2) % polygon.size();
            while(j != modulo_pos(i-1, polygon.size())){
                if(inTriangle(polygon[j], triangle)) {
                    ok = false;
                    break;
                }
                j = (j+1) % polygon.size();
            }
        } else {
            ok = false;
        }
        if(ok){
            triangles.insert(triangles.end(), triangle.begin(), triangle.end());
            //todo: polygon.erase(i);
            i = i % polygon.size();

        } else {
            i = (i+1) % polygon.size();
        }
        triangle.clear();
    }
    //only one triangle left
    triangles.insert(triangles.end(), polygon.begin(), polygon.end());

    return triangles;
}

//function that creates a fanning index from the first vertex
std::vector<int> Polygon::triangulateFanIndex() {
    std::vector<int> triangles; triangles.clear();

    for(int i = 0; i < size-2; i++){
        triangles.push_back(0);
        triangles.push_back((i+1) % size);
        triangles.push_back((i+2) % size);
    }
    return triangles;
}

void Polygon::setNormals(std::vector<glm::vec3> ns) {
    polygonNormals.clear();
    polygonNormals.insert(polygonNormals.end(), ns.begin(), ns.end());
}

/* implementation of the ear clip algorithm for triangulating polygons
 * from polygonal boundaries. Assumes CCW binding
 * by index!*/
std::vector<int> Polygon::triangulateEarClipIndex(){
    std::vector<int> polygon;
    polygon.clear();
    for(int i=0; i< size; i++){ polygon.push_back(i);};

    std::vector<glm::vec3> triangle;
    triangle.clear();

    std::vector<int> triangles;
    triangles.clear();
    bool ok;


    int i = 0;
    int iters = 0;

    while(polygon.size() > 3 && iters < 2*polygonVertices.size()){
        triangle.push_back(polygonVertices[polygon[modulo_pos(i-1, polygon.size())]]);
        triangle.push_back(polygonVertices[polygon[i % polygon.size()]]);
        triangle.push_back(polygonVertices[polygon[(i+1) % polygon.size()]]);
        ok = true;
        if(!isNegativeTriangleArea(triangle)){
            int j = (i+2) % polygon.size();
            while(j != modulo_pos(i-1, polygon.size())){
                if(inTriangle(polygonVertices[polygon[j]], triangle)) {
                    ok = false;
                    break;
                };
                j = (j+1) % polygon.size();
            }
        } else {
            ok = false;
        }
        if(ok){
            triangles.push_back(polygon[modulo_pos(i-1, polygon.size())]);
            triangles.push_back(polygon[i % polygon.size()]);
            triangles.push_back(polygon[(i+1) % polygon.size()]);
            //todo: polygon.remove(i);
            i = i % polygon.size();
        } else {
            i = (i+1) % polygon.size();
        }
        triangle.clear();
        iters++;

    }
    //only one triangle left
    triangles.insert(triangles.end(), polygon.begin(), polygon.end());
    return triangles;
}

void Polygon::calculate() {
    indices = triangulateFanIndex();
    //calculatePlane();
}


/* saves all your favourite polygons to file! */
void Polygon::savePolygon(std::string filename) {
    std::ofstream myfile;
    myfile.open (filename);
    for(int i = 0; i < size; i++) {
        myfile << "v " << polygonVertices[i].x << " " << polygonVertices[i].y << " " << polygonVertices[i].z << std::endl;
    }
    for(int i = 0; i < size; i++) {
        myfile << "vn " << polygonNormals[i].x << " " <<  polygonNormals[i].y << " " << polygonNormals[i].z << std::endl;
    }
    myfile << "f ";
    for(int i = 0; i < size; i++){
        myfile << i + 1  << " ";
    }
    myfile << std::endl;
    myfile.close();
}


/* uses Eigen library to find normal of best fitting
 * plane using SVD
 */
/*void Polygon::calculatePlane(){
    //first calculate mean
    glm::vec3 sum = glm::vec3(0.0, 0.0, 0.0);
    for(int i=0; i < size; i++){
        sum += polygonVertices[i];
    }
    glm::vec3 mean = sum/size;


    //then translate the polygon that it centered on the origin
    std::vector<glm::vec3> zeroMeanPoly;
    zeroMeanPoly.clear();

    for(int i=0; i< size; i++){
        zeroMeanPoly.push_back(polygonVertices[i] - mean);
    }

    //fill data matrix A
    MatrixXf A(3, size);

    for(int i = 0; i < size; i++){
        A(0, i) = zeroMeanPoly[i].x();
        A(1, i) = zeroMeanPoly[i].y();
        A(2, i) = zeroMeanPoly[i].z();
    }

    //calculate SVD of A
    JacobiSVD<MatrixXf> svd(A, ComputeThinU | ComputeThinV);

    //the third column of U matrix is normal of plane
    glm::vec3 planeNormal = glm::vec3(svd.matrixU()(0, 2), svd.matrixU()(1, 2), svd.matrixU()(2, 2));

    //qDebug() << planeNormal;
    //plane = Plane(planeNormal.normalized(), mean, 3.0);
}*/
