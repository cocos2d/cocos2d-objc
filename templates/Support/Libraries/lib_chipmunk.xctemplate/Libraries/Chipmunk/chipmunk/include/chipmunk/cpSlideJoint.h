/* Copyright (c) 2013 Scott Lembcke and Howling Moon Software
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/// @defgroup cpSlideJoint cpSlideJoint
/// @{

/// Check if a constraint is a slide joint.
cpBool cpConstraintIsSlideJoint(const cpConstraint *constraint);

/// Allocate a slide joint.
cpSlideJoint* cpSlideJointAlloc(void);
/// Initialize a slide joint.
cpSlideJoint* cpSlideJointInit(cpSlideJoint *joint, cpBody *a, cpBody *b, cpVect anchorA, cpVect anchorB, cpFloat min, cpFloat max);
/// Allocate and initialize a slide joint.
cpConstraint* cpSlideJointNew(cpBody *a, cpBody *b, cpVect anchorA, cpVect anchorB, cpFloat min, cpFloat max);

/// Get the location of the first anchor relative to the first body.
cpVect cpSlideJointGetAnchorA(const cpConstraint *constraint);
/// Set the location of the first anchor relative to the first body.
void cpSlideJointSetAnchorA(cpConstraint *constraint, cpVect anchorA);

/// Get the location of the second anchor relative to the second body.
cpVect cpSlideJointGetAnchorB(const cpConstraint *constraint);
/// Set the location of the second anchor relative to the second body.
void cpSlideJointSetAnchorB(cpConstraint *constraint, cpVect anchorB);

/// Get the minimum distance the joint will maintain between the two anchors.
cpFloat cpSlideJointGetMin(const cpConstraint *constraint);
/// Set the minimum distance the joint will maintain between the two anchors.
void cpSlideJointSetMin(cpConstraint *constraint, cpFloat min);

/// Get the maximum distance the joint will maintain between the two anchors.
cpFloat cpSlideJointGetMax(const cpConstraint *constraint);
/// Set the maximum distance the joint will maintain between the two anchors.
void cpSlideJointSetMax(cpConstraint *constraint, cpFloat max);

/// @}
