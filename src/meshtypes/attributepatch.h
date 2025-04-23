#ifndef ATTRIBUTEPATCH_H
#define ATTRIBUTEPATCH_H

#include <vector>
#include <glm/glm.hpp>

class AttributePatch
{
public:
    AttributePatch () {}
    AttributePatch (std::vector<glm::vec3> p) : ps(p) {  }
    AttributePatch (std::vector<glm::vec3> p, std::vector<glm::vec2> uvs) : ps(p), uvs(uvs) {  }
    AttributePatch (std::vector<glm::vec3> p, std::vector<glm::vec2> uvs, std::vector<glm::vec3> noise) : ps(p), uvs(uvs), noise(noise) {  }

    ~AttributePatch () {
        ps.clear();
        uvs.clear();
        bs.clear();
    }

    inline const std::vector<glm::vec3>& getVertices() const { return ps; }
    inline const std::vector<std::vector<glm::vec3>>& getBs() const {return bs; }
    inline const std::vector<glm::vec2>& getUVs() const { return uvs; }
    inline const std::vector<glm::vec3>& getNoise() const {return noise; }


protected:
    std::vector<glm::vec3> ps;
    std::vector<std::vector<glm::vec3>> bs;
    std::vector<glm::vec2> uvs;
    std::vector<glm::vec3> noise;
};


#endif // ATTRIBUTEPATCH_H
