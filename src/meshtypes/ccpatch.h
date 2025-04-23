#ifndef CCPATCH_H
#define CCPATCH_H

#include <vector>
#include <glm/glm.hpp>
#include "attributepatch.h"

class CCPatch : public AttributePatch
{
public:
    CCPatch() {}

    CCPatch(std::vector<glm::vec3> p, std::vector<glm::vec3> ep, std::vector<glm::vec3> em,
                     std::vector<glm::vec3> fp, std::vector<glm::vec3> fm, std::vector<glm::vec2> uvs, std::vector<glm::vec3> noise)
        :  AttributePatch(p, uvs, noise)
    {
        bs.resize(4);
        bs[0] = ep;
        bs[1] = em;
        bs[2] = fp;
        bs[3] = fm;
    }


    CCPatch(std::vector<glm::vec3> p, std::vector<glm::vec3> ep, std::vector<glm::vec3> em,
                     std::vector<glm::vec3> fp, std::vector<glm::vec3> fm, std::vector<glm::vec2> uvs)
        : AttributePatch(p, uvs)
    {
        bs.resize(4);
        bs[0] = ep;
        bs[1] = em;
        bs[2] = fp;
        bs[3] = fm;
    }

    CCPatch(std::vector<glm::vec3> p, std::vector<glm::vec3> ep, std::vector<glm::vec3> em,
                     std::vector<glm::vec3> fp, std::vector<glm::vec3> fm)
        : AttributePatch(p)
    {
        bs.resize(4);
        bs[0] = ep;
        bs[1] = em;
        bs[2] = fp;
        bs[3] = fm;
    }



};

#endif // CCPATCH_H
