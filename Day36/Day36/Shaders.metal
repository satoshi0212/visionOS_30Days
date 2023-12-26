#include <metal_stdlib>
using namespace metal;

vertex float4 vertexShader(unsigned int vid [[ vertex_id ]]) {
    const float4x4 vertices = float4x4(float4(-0.5, -0.5, 0.0, 0.5),
                                       float4( 0.5, -0.5, 0.0, 0.5),
                                       float4(-0.5,  0.5, 0.0, 0.5),
                                       float4( 0.5,  0.5, 0.0, 0.5));
    return vertices[vid];
}

// MARK: - Gear

// https://www.shadertoy.com/view/tt2XzG Gear

float smax(float a, float b, float k) {
    float h = max(k - abs(a - b), 0.0);
    return max(a, b) + h * h * 0.25 / k;
}

float sdSphere(float3 p, float r) {
    return length(p) - r;
}

float sdVerticalSemiCapsule(float3 p, float h, float r) {
    p.y = max(p.y - h, 0.0);
    return length(p) - r;
}

float sdCross(float2 p, float2 b, float r) {
    p = abs(p);
    p = (p.y > p.x) ? p.yx : p.xy;

    float2 q = p - b;
    float k = max(q.y, q.x);
    float2 w = (k > 0.0) ? q : float2(b.y - p.x, -k);

    return sign(k) * length(max(w, 0.0)) + r;
}

float dot2(float2 v) { return dot(v, v); }

float sdTrapezoid(float2 p, float r1, float r2, float he) {
    float2 k1 = float2(r2, he);
    float2 k2 = float2(r2 - r1, 2.0 * he);
    p.x = abs(p.x);
    float2 ca = float2(max(0.0, p.x - ((p.y < 0.0) ? r1 : r2)), abs(p.y) - he);
    float2 cb = p - k1 + k2 * clamp(dot(k1 - p, k2) / dot2(k2), 0.0, 1.0);
    float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return s * sqrt(min(dot2(ca), dot2(cb)));
}

float2 iSphere(float3 ro, float3 rd, float rad) {
    float b = dot( ro, rd );
    float c = dot( ro, ro ) - rad * rad;
    float h = b * b - c;
    if (h < 0.0) return float2(-1.0);
    h = sqrt(h);
    return float2(-b-h, -b+h);
}

float dents(float2 q, float tr, float y) {
    const float an = 6.283185/12.0;
    float fa = (atan2(q.y,q.x) + an * 0.5) / an;
    float sym = an * floor(fa);
    float2 r = float2x2(cos(sym), -sin(sym), sin(sym), cos(sym)) * q;
    float d = length(max(abs(r - float2(0.17, 0.0)) - tr * float2(0.042, 0.041 * y),0.0));
    return d - 0.005 * tr;
}

float4 gear(float3 q, float off, float time) {
    {
        float an = 2.0 * time * sign(q.y) + off * 6.283185 / 24.0;
        float co = cos(an), si = sin(an);
        q.xz = float2x2(co, -si, si, co) * q.xz;
    }

    q.y = abs(q.y);

    float an2 = 2.0 * min(1.0-2.0*abs(fract(0.5+time/10.0)-0.5),1.0/2.0);
    float3 tr = min(10.0 * an2 - float3(4.0, 6.0, 8.0), 1.0);

    // ring
    float d = abs(length(q.xz) - 0.155 * tr.y) - 0.018;

    // add dents
    float r = length(q);
    d = min(d, dents(q.xz,tr.z, r));

    // slice it
    float de = -0.0015 * clamp(600.0 * abs(dot(q.xz,q.xz) - 0.155 * 0.155), 0.0, 1.0);
    d = smax(d, abs(r - 0.5) - 0.03 + de, 0.005 * tr.z);

    // add cross
    float d3 = sdCross(q.xz, float2(0.15, 0.022) * tr.y, 0.02 * tr.y);
    float2 w = float2(d3, abs(q.y - 0.485) - 0.005 * tr.y);
    d3 = min(max(w.x, w.y),0.0) + length(max(w, 0.0)) - 0.003 * tr.y;
    d = min(d, d3);

    // add pivot
    d = min(d, sdVerticalSemiCapsule(q, 0.5 * tr.x, 0.01));

    // base
    d = min(d, sdSphere(q - float3(0.0, 0.12, 0.0), 0.025));

    return float4(d, q.xzy);
}

float2 rot(float2 v) {
    return float2(v.x - v.y, v.y + v.x) * 0.707107;
}

float4 map(float3 p, float time) {
    // center sphere
    float4 d = float4(sdSphere(p, 0.12), p);

    // gears. There are 18, but we only evaluate 4
    float3 qx = float3(rot(p.zy), p.x); if (abs(qx.x) > abs(qx.y)) qx = qx.zxy;
    float3 qy = float3(rot(p.xz), p.y); if (abs(qy.x) > abs(qy.y)) qy = qy.zxy;
    float3 qz = float3(rot(p.yx), p.z); if (abs(qz.x) > abs(qz.y)) qz = qz.zxy;
    float3 qa = abs(p);
    qa = (qa.x > qa.y && qa.x > qa.z) ? p.zxy :
    (qa.z>qa.y) ? p.yzx :
    p.xyz;
    float4 t;
    t = gear(qa, 0.0, time); if (t.x < d.x) d = t;
    t = gear(qx, 1.0, time); if (t.x < d.x) d = t;
    t = gear(qz, 1.0, time); if (t.x < d.x) d = t;
    t = gear(qy, 1.0, time); if (t.x < d.x) d = t;

    return d;
}

float3 calcNormal(float3 pos, float time) {
    float2 e = float2(1.0, -1.0) * 0.5773;
    const float eps = 0.00025;
    return normalize(e.xyy * map( pos + e.xyy*eps, time ).x +
                     e.yyx * map( pos + e.yyx*eps, time ).x +
                     e.yxy * map( pos + e.yxy*eps, time ).x +
                     e.xxx * map( pos + e.xxx*eps, time ).x );
}

float calcAO(float3 pos, float3 nor, float time) {
    float occ = 0.0;
    float sca = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = map(pos + h * nor, time).x;
        occ += (h - d) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 3.0 * occ, 0.0, 1.0);
}

float calcSoftshadow(float3 ro, float3 rd, float k, float time) {
    float res = 1.0;

    // bounding sphere
    float2 b = iSphere( ro, rd, 0.535 );
    if (b.y > 0.0) {
        // raymarch
        float tmax = b.y;
        float t = max(b.x,0.001);
        for (int i = 0; i < 64; i++) {
            float h = map(ro + rd * t, time).x;
            res = min(res, k * h / t);
            t += clamp(h, 0.012, 0.2);
            if (res < 0.001 || t > tmax) break;
        }
    }

    return clamp(res, 0.0, 1.0);
}

float4 intersect(float3 ro, float3 rd, float time) {
    float4 res = float4(-1.0);

    // bounding sphere
    float2 tminmax = iSphere(ro, rd, 0.535);
    if (tminmax.y > 0.0) {
        // raymarch
        float t = max(tminmax.x, 0.001);
        for (int i = 0; i < 128 && t < tminmax.y; i++) {
            float4 h = map(ro + t * rd, time);
            if (h.x < 0.001) { res = float4(t, h.yzw); break; }
            t += h.x;
        }
    }

    return res;
}

float3x3 setCamera(float3 ro, float3 ta, float cr) {
    float3 cw = normalize(ta - ro);
    float3 cp = float3(sin(cr), cos(cr), 0.0);
    float3 cu = normalize(cross(cw,cp));
    float3 cv =          (cross(cu,cw));
    return float3x3(cu, cv, cw);
}

fragment float4 fragmentShader(float4 pixPos [[position]],
                               constant float2& res [[buffer(0)]],
                               constant float& time [[buffer(1)]],
                               texture2d<float, access::sample> rustyMetalTexture [[texture(0)]]) {

    constexpr sampler s(address::clamp_to_edge, filter::linear);

    float3 tot = float3(0.0);
    float2 p = (2.0 * pixPos.xy - res.xy) / res.y;
    p.y *= -1.0;

    // camera
    float an = 6.2831 * time / 40.0;
    float3 ta = float3(0.0, 0.0, 0.0);
    float3 ro = ta + float3(1.3 * cos(an), 0.5, 1.2 * sin(an));

    ro += 0.005 * sin(92.0 * time / 40.0 + float3(0.0, 1.0, 3.0));
    ta += 0.009 * sin(68.0 * time / 40.0 + float3(2.0, 4.0, 6.0));

    // camera-to-world transformation
    float3x3 ca = setCamera(ro, ta, 0.0);

    // ray direction
    float fl = 2.0;
    float3 rd = ca * normalize(float3(p, fl));

    // background
    //float3 col = float3(1.0 + rd.y) * 0.03;
    float3 col = float3(0.0);

    // raymarch geometry
    float4 tuvw = intersect(ro, rd, time);
    if (tuvw.x > 0.0) {
        // shading/lighting
        float3 pos = ro + tuvw.x * rd;
        float3 nor = calcNormal(pos, time);

        float3 te = 1.0 * rustyMetalTexture.sample(s, tuvw.yz * 2.0).xyz + 1.0 * rustyMetalTexture.sample(s, tuvw.yw * 1.0).xyz;

        float3 mate = 0.22 * te;
        float len = length(pos);

        mate *= 1.0 + float3(2.0, 0.5, 0.0) * (1.0 - smoothstep(0.121, 0.122,len));

        float focc = 0.1 + 0.9 * clamp(0.5 + 0.5 * dot(nor, pos / len), 0.0, 1.0);
        focc *= 0.1 + 0.9 * clamp(len * 2.0, 0.0, 1.0);
        float ks = clamp(te.x * 1.5, 0.0, 1.0);
        float3  f0 = mate;
        float kd = (1.0 - ks) * 0.125;

        float occ = calcAO( pos, nor, time ) * focc;

        col = float3(0.0);

        // top
        {
            float3 lig = normalize(float3(0.8, 0.2, 0.6));
            float dif = clamp(dot(nor, lig), 0.0, 1.0);
            float3 hal = normalize(lig - rd);
            float sha = 1.0; if (dif > 0.001) sha = calcSoftshadow(pos + 0.001 * nor, lig, 20.0, time);
            float3 spe = pow(clamp(dot(nor, hal), 0.0, 1.0), 16.0) * (f0 + (1.0 - f0) * pow(clamp(1.0 + dot(hal, rd), 0.0, 1.0), 5.0));
            col += kd * mate * 2.0 * float3(1.00, 0.70, 0.50) * dif * sha;
            col += ks *        2.0 * float3(1.00, 0.80, 0.70) * dif * sha * spe * 3.14;
        }

        // side
        {
            float3  ref = reflect(rd,nor);
            float fre = clamp(1.0+dot(nor,rd),0.0,1.0);
            float sha = occ;
            col += kd * mate * 25.0 * float3(0.19, 0.22, 0.24) * (0.6 + 0.4 * nor.y) * sha;
            col += ks * 25.0 * float3(0.19, 0.22, 0.24) * sha * smoothstep(-1.0 + 1.5 * focc, 1.0 - 0.4 * focc, ref.y) * (f0 + (1.0 - f0) * pow(fre, 5.0));
        }

        // bottom
        {
            float dif = clamp(0.4 - 0.6 * nor.y, 0.0, 1.0);
            col += kd * mate * 5.0 * float3(0.25, 0.20, 0.15) * dif * occ;
        }
    }

    if (col.x == 0) {
        discard_fragment();
    }

    // vignetting
    col *= 1.0 - 0.1 * dot(p, p);

    // gamma
    tot += pow(col, float3(0.45));

    // s-curve
    tot = min(tot, 1.0);
    tot = tot * tot * (3.0 - 2.0 * tot);

    // cheap dithering
    tot += sin(pixPos.x * 114.0) * sin(pixPos.y * 211.1) / 512.0;

    return float4(tot, 1.0);
}
