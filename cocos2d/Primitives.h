/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


/** draws a point given x and y coordinate
 * @warning This function needs optimizations. Try not to use it.
 */
void drawPoint( float x, float y );

/** draws a line given x1,y1 and x2,y2 coordinates
 * @warning This function needs optimizations. Try not to use it.
 */
void drawLine(float x1, float y1, float x2, float y2);

/** draws a poligon given a pointer to float coordiantes and the number of vertices
 * @warning This function needs optimizations. Try not to use it.
 */
void drawPoly( float *poli, int points );

/** draws a circle given the center, radius and number of segments
 * @warning This function needs optimizations. Try not to use it.
 */
void drawCircle( float x, float y, float radius, float angle, int segs);
