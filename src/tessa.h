#ifndef TESSA_H
#define TESSA_H

#include "enums.h"
#include <string>

class Tessa 
{
public:
    Tessa();
    ~Tessa();

    std::string drawMode;
    std::string surfaceMode;
    std::string primitiveMode;
    std::string shadeMode;

    void updateWindowTitle();

private:

};

#endif // TESSA_H
