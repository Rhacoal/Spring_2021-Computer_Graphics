#version 330 core
#include <bsdf.fsh>

// {headers}
#define RECIPROCAL_PI 0.3183098861837907

struct PointLight {
    vec3 direction;
    vec3 position;
    vec3 color;
};

struct DirectionalLight {
    vec3 direction;
    vec3 color;
};

#if POINT_LIGHT_COUNT
uniform PointLight pointLights[POINT_LIGHT_COUNT];
#endif

#if DIRECTIONAL
uniform DirectionalLight directionalLight;
#endif

uniform vec3 ambientLight;

uniform mat4 modelMatrix, mvpMatrix;
uniform vec3 cameraPosition;

uniform sampler2D albedo;
uniform sampler2D metallic;
uniform float metallicIntensity;
uniform sampler2D roughness;
uniform float roughnessIntensity;
uniform sampler2D ao;
uniform float aoIntensity;
uniform sampler2D normal;
uniform vec4 color;

in vec2 vUv;
in vec3 worldPosition;
in vec3 vNormal;

out vec4 fragColor;

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec3 result = vec3(0.0);

    vec4 diffuseColor = texture(diffuse, vUv);
    float opacity = diffuseColor.a;

    vec3 V = normalize(cameraPosition - worldPosition);
    vec3 N = normalize(vNormal);

    #if DIRECTIONAL
    {
        vec3 L = normalize(directionalLight.direction);
        vec3 H = normalize(L + V);
        float lambert = clamp(dot(N, L), 0.0, 1.0);

        float spec = pow(clamp(dot(N, H), 0.0, 1.0), shininess);
        vec3 lightColor = spec * directionalLight.color +
        RECIPROCAL_PI * diffuseColor.rgb * directionalLight.color;
        result += lightColor * lambert;
    }
        #endif
        #if POINT_LIGHT_COUNT
    for (int i = 0; i < POINT_LIGHT_COUNT; ++i) {
        vec3 lightVec = pointLights[i].position - worldPosition;
        vec3 L = normalize(lightVec);
        vec3 H = normalize(L + V);
        float lambert = clamp(dot(N, L), 0.0, 1.0);
        float spec = pow(clamp(dot(N, H), 0.0, 1.0), shininess) / dot(lightVec, lightVec);

        vec3 lightColor = spec * pointLights[i].color +
        RECIPROCAL_PI * diffuseColor.rgb * pointLights[i].color;
        result += (spec * pointLights[i].color.rgb * pointLights[i].color.a * power);
        result += lightColor * lambert;
    }
        #endif
    result.rgb += ambientLight;

    fragColor = vec4(result, opacity) * color;
}
