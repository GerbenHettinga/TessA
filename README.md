# TessA

This repository includes nearly all of the code that was used to generate the results in the following papers:

- [Phong Tessellation and PN Polygons for Polygonal Models](https://scholar.google.nl/citations?view_op=view_citation&hl=en&user=-t8scrEAAAAJ&citation_for_view=-t8scrEAAAAJ:u5HHmVD_uO8C)
- [Multisided generalisations of Gregory patches](https://scholar.google.nl/citations?view_op=view_citation&hl=en&user=-t8scrEAAAAJ&citation_for_view=-t8scrEAAAAJ:u-x6o8ySG0sC)
- [A Comparison of GPU Tessellation Strategies for Multisided Patches](https://scholar.google.nl/citations?view_op=view_citation&hl=en&user=-t8scrEAAAAJ&citation_for_view=-t8scrEAAAAJ:d1gkVwhDpl0C)
- [A multisided C2 B-spline patch over extraordinary vertices in quadrilateral meshes](https://scholar.google.nl/citations?view_op=view_citation&hl=en&user=-t8scrEAAAAJ&citation_for_view=-t8scrEAAAAJ:zYLM7Y9cAGgC)
- [Multisided B-spline patches over extraordinary regions](https://scholar.google.nl/citations?view_op=view_citation&hl=en&user=-t8scrEAAAAJ&citation_for_view=-t8scrEAAAAJ:Tyk-4Ss8FVUC)

The code was written during my time as a Master and PhD student at the University of Groningen. The original source (Qt 5 and QMake) was converted to C++20, and CMake with dependencies ImGUI, SDL2, GLEW, glm and CMake. The code requires OpenGL version 4+ and windows. Contains also pieces of code written by Pieter Barendrecht and Rowan van Beckhoven.

### Building

First pull the dependencies.
``
git clone --recurse-submodules
``

Then build the solution with CMake.

``
mkdir build
cd build
cmake ../
``

### Structure

Most techniques have a corresponding meshtype and renderer. All techniques make use of tessellation shaders to evaluate the surfaces. The meshtypes perform extraction of control points from the current mesh. The meshtypes may perform [general degree subdivision](https://www.dgp.toronto.edu/public_user/stam/reality/Research/pdf/cagd01.pdf) to separate extraordinary vertices and faces.

### Todo:
Most of the code is there but not accesible because of bugs and other issues. The code is mostly there if you want to take a look at it.

The following techniques are currently not accesible from the UI:

- Generalised Gregory patches,
- Generalised Gregory S-patches,
- PN-polygons,
- Phong polygons,
- CPU evaluation.
- Multi OS support.

### Citations:

@incollection{hettinga2017phong,
  title={Phong tessellation and PN polygons for polygonal models},
  author={Hettinga, GJ and Kosinka, J},
  booktitle={Proceedings of the European Association for Computer Graphics: Short Papers},
  pages={49--52},
  year={2017}
}

@article{hettinga2018multisided,
  title={Multisided generalisations of Gregory patches},
  author={Hettinga, Gerben J and Kosinka, Ji{\v{r}}{\'\i}},
  journal={Computer Aided Geometric Design},
  volume={62},
  pages={166--180},
  year={2018},
  publisher={Elsevier}
}

@inproceedings{hettinga2018comparison,
  title={A comparison of GPU tessellation strategies for multisided patches},
  author={Hettinga, GJ and Barendrecht, PJ and Kosinka, J},
  booktitle={Proceedings of the 39th Annual European Association for Computer Graphics Conference: Short Papers},
  pages={45--48},
  year={2018}
}

@article{hettinga2020multisided,
  title={A multisided C2 B-spline patch over extraordinary vertices in quadrilateral meshes},
  author={Hettinga, Gerben J and Kosinka, Ji{\v{r}}{\'\i}},
  journal={Computer-Aided Design},
  volume={127},
  pages={102855},
  year={2020},
  publisher={Elsevier}
}

@article{hettinga2020multisided,
  title={Multisided B-spline Patches Over Extraordinary Regions},
  author={Hettinga, Gerben J and Kosinka, Jiri},
  year={2020},
  publisher={The Eurographics Association}
}
