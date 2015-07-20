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
	cc_FragColor = clamp(cc_Color, 0.0, 1.0);
	cc_FragTexCoord1 = cc_TexCoord1;
    gl_Position = cc_Position;
}

// ---------------------------------------------------------------------











