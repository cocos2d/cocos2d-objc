/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */


/// draws a point given x and y coordinate
void drawPoint( float x, float y );
/// draws a line given x1,y1 and x2,y2 coordinates
void drawLine( float x1, float x2, float y1, float y2);
/// draws a poligon given a pointer to float coordiantes and the number of vertices
void drawPoly( float *poli, int points );
/// draws a circle given the center, radius and number of segments
void drawCircle( float x, float y, float radius, int segments);
