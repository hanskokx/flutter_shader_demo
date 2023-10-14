#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec4 uColor;
uniform float uTime;

out vec4 FragColor;

// cosine based palette, 4 vec3 params
vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
    return a + b*cos(6.28318*(c*t+d)) ;
}

void main()
{
    vec4 colorWithAlpha = vec4(uColor.rgb * uColor.a, uColor.a);
    vec2 uv = (FlutterFragCoord() * 2.0 - uSize.xy) / uSize.y;
    vec2 uv0 = uv;

    vec3 finalColor = colorWithAlpha.rgb;

    for (float i = 0.0; i < 4.0; i++) {
        // To make it repeating
        uv = fract(uv * 1.5) - 0.5;

        float d = length(uv) * exp(-length(uv0));

        vec3 color = palette(length(uv0) + i*0.4 + uTime * 0.4, vec3(0.5, 0.5, 0.5), vec3(0.5, 0.5, 0.5), vec3(1.0, 1.0, 1.0), vec3(0.263, 0.416, 0.557));


        d = sin(d * 8.0 + uTime)/8.0;
        d = abs(d);

        d = pow(0.01 / d, 1.2);

        finalColor += color * d;
    }

    FragColor = vec4(finalColor, 1.0);

}

