#ifndef ASSIGNMENT_RT_SCENE_H
#define ASSIGNMENT_RT_SCENE_H

#include <cg_common.h>
#include <cg_fwd.h>
#include <texture.h>
#include <shader.h>
#include "lib/shaders/rt_structure.h"

#include <cl.hpp>

#include <optional>

namespace cg {
struct BVH {
    std::vector<BVHNode> nodes;

    void buildFromTriangles(std::vector<Triangle> &triangles);
};

struct RayTracingScene {
    bool bufferNeedUpdate = true;

    BVH bvh;
    std::vector<Texture> usedTextures;
    std::vector<Triangle> triangles;
    std::vector<RayTracingMaterial> materials;
    std::vector<RayTracingLight> lights;

    void setFromScene(Scene &scene);
};

class RayTracingRenderer {
    typedef struct ShaderParams {
        Shader shader;
        GLuint vao{};
        GLuint vbo{};

        ShaderParams();

        void use() const;

        ~ShaderParams();
    } ShaderParams;
    inline static std::optional<ShaderParams> trivialShader;

    cl::Platform platform;
    cl::Device device;
    cl::Context context;
    cl::CommandQueue commandQueue;
    cg::Texture texture;

    bool clInited = false;

    bool initCL();

    bool programInited = false;

    cl::Program program;
    cl::Kernel testKernel;
    cl::Kernel rayGenerationKernel;
    cl::Kernel renderKernel;

    int _width{}, _height{};
    cl::Buffer rayBuffer;
    cl::Buffer outputBuffer;

    // scene related buffers
    cl::Buffer textureBuffer;
    cl::Buffer triangleBuffer;
    cl::Buffer materialBuffer;
    cl::Buffer bvhBuffer;
    cl::Buffer lightBuffer;

    std::vector<float> frameBuffer;

    size_t frameBufferSize() const {
        return frameBuffer.size() * sizeof(float);
    }

public:
    bool init(int width, int height);

    void render(RayTracingScene &scene, Camera &camera);
};
}

#endif //ASSIGNMENT_RT_SCENE_H
