#include <metal_stdlib>
using namespace metal;

struct ColorInOut
{
    float4 position [[position]];
};

vertex ColorInOut vertexShader(uint vertexID [[ vertex_id ]],
                               const device float4 *position [[ buffer(0) ]]) {
    ColorInOut out;
    out.position = position[vertexID];
    return out;
}

fragment float4 fragmentShader(ColorInOut in [[ stage_in ]]) {
    return float4(1.0, 0.0, 0.0, 1.0);
}
