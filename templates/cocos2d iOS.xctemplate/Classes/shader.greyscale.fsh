//
//  ___FILENAME___
//
//  Created by : ___FULLUSERNAME___
//  Project    : ___PROJECTNAME___
//  Date       : ___DATE___
//
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___.
//  All rights reserved.
//
// -----------------------------------------------------------------
//
// This is a custom shader created for Credits
// It will read up the screen, and make it greyscale
// The pixel read from the screen, is unique to iOS devices
//
// All the default attributes and uniforms of the shaders, are automatically inserted
// See top of CCShader.m, for which attributs and uniforms are defined

void main()
{
    // Normally this should be 1.0 / textureSize, but we do not know that one
    // For that we would have to set up a uniform, and pass it to the shader
    // For now we just use a value which will give "most sprites" a slight blurr
    vec2 pixelSize = vec2(0.010, 0.010);
    
    vec4 color = texture2D(cc_MainTexture, cc_FragTexCoord1);

    vec4 color1 = texture2D(cc_MainTexture, cc_FragTexCoord1 + pixelSize);
    vec4 color2 = texture2D(cc_MainTexture, cc_FragTexCoord1 - pixelSize);
    pixelSize.x = -pixelSize.x;
    vec4 color3 = texture2D(cc_MainTexture, cc_FragTexCoord1 + pixelSize);
    vec4 color4 = texture2D(cc_MainTexture, cc_FragTexCoord1 - pixelSize);

    color = (color + color1 + color2 + color3 + color4) / 5.0 * cc_FragColor;

    float grey = (0.299 * color.r) + (0.587 * color.g) + (0.114 * color.b);
    gl_FragColor = vec4(grey, grey, grey, color.a);
}

// ---------------------------------------------------------------------












