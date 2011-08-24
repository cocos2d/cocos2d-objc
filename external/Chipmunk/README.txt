ABOUT:
Chipmunk is a simple, lightweight, fast and portable 2D rigid body physics library written in C. It's licensed under the unrestrictive, OSI approved MIT license. My aim is to give 2D developers access the same quality of physics you find in newer 3D games. I hope you enjoy using Chipmunk, and please consider donating to help make it worth our time to continue to support Chipmunk with great new features.

CONTRACTING:
Howling Moon Software (my company) is available for contracting if you want to make the physics in your game really stand out. Given our unique experience with the library, we can help you use Chipmunk to it's fullest potential. Feel free to contact us through our webpage: http://howlingmoonsoftware.com/contracting.php

Chipmunk Pro: http://chipmunk-physics.net/chipmunkPro.php
We also make a bunch of extra for Chipmunk called Chipmunk Pro. Currently we have a nice Objective-C wrapper that should be of particular interest to Mac and iPhone developers. We are also working on auto-geometry features and multithreading/SIMD optimizations as well. Check out the link above for more information!

To try Objective-Chipmunk in your own projects see Objective-Chipmunk/Objective-Chipmunk/Readme.rtf.

BUILDING:
Mac OS X: There is an included XCode project file for building the static library and demo application. Alternatively you could use the CMake files. A Mac OS X version of Objective-Chipmunk is available for free upon request. We don't do regular builds as few people seem interested in it.

iPhone: If you want a native Objective-C API, check out the Objective-Chipmunk directory for the Objective-C binding and some sample code from shipping iPhone Apps. It is inexpensive to license and should save you a lot of time. Otherwise, the XCode project can build a static library with all the proper compiler settings. Alternatively, you can just run iphonestatic.command in the macosx/ directory.  It will build you a fat library compiled as release for the device and debug for the simulator. After running it, you can simply drop the Chipmunk-iPhone directory into your iPhone project!

UNIXes: A forum user was kind enough to make a set of CMake files for Chipmunk. This will require you to have CMake installed. To build run 'cmake .' then 'make'. This should build a dynamic library, a static library, and the demo application. A number of people have had build errors on Ubuntu due to not having GLUT or libxmu installed.

Windows: Visual Studio projects are included in the msvc/ directory. I do not maintain these personally, but a number of forum members have assisted with them.

Ruby: I've been using maintaining a Ruby extension for Chipmunk, but at this time is not up to date with all the latest changes. It has been tested and builds under Linux and OS X using CMake however 'cmake -D BUILD_RUBY_EXT=ON .; make'. A forum member has been working on an FFI based extention (http://github.com/erisdiscord/chipmunk-ffi), and that may be a better way to take advantage of Chipmunk from Ruby. Another forum user has offered to maintain the non-FFI version of the extension. Stay tuned.

GETTING STARTED:
First of all, you can find the C API documentation in the doc/ directory.

A good starting point is to take a look at the included Demo application. The demos all just set up a Chipmunk simulation space and the demo app draws the graphics directly out of that. This makes it easy to see how the Chipmunk API works without worrying about the graphics code. You are free to use the demo drawing routines in your own projects, though it is certainly not the recommended way of drawing Chipmunk objects as it pokes around at the undocumented parts of Chipmunk.

If you are looking at Objective-Chipmunk for the iPhone, we have a number of example projects and tutorials in the Objective-Chipmunk directory.

FORUM:
http://www.slembcke.net/forums

CONTACT:
slembcke@gmail.com (also on Google Talk)

CHANGES SINCE 6.0.0:
* MISC: Changed adding a static body to a space from a warning to a hard error.

CHANGES SINCE 6.0.0:
* BUG: Calling cpBodySetPos() on a sleeping body was delaying the Separate() handler callback if one existed.
* BUG: Fixed a bug where Separate() handler callbacks were not occuring when removing shapes.
* BUG: Calling cpBodyApplyForce() or cpBodyResetForces() was not activating sleeping bodies.
* API: Added cpSpaceEachConstraint().
* API: Added a "CurrentTimeStep" property to cpSpace to retrieve the current (or most recent) timestep.
* MISC: Got rid of anonymous unions so that it is C99 clean again.

CHANGES SINCE 5.x:
Chipmunk 6.x's API is not quite 100% compatible with 5.x. Make sure you read the list of changes carefully.
Keep in mind that this is a x.0.0 release and that it's likely there are still some bugs I don't know about yet. I've spent a lot of effort rewritting the collision detection, sleeping, and contact graph algorithms that have required large changes and cleanup to the 5.x codebase. I've ironed out all the bugs that I know of, and the beta test went well. So it's finally time for 6!

* API: Chipmunk now has hard runtime assertions that aren't disabled in release mode for many error conditions. Most people have been using release builds of Chipmunk during development and were missing out on very important error checking.
* API: Access to the private API has been disabled by default now and much of the private API has changed. I've added official APIs for all the uses of the private API I knew of.
* API: Added accessor functions for every property on every type. As Chipmunk's complexity has grown, it's become more difficult to ignore accessors. You are encouraged to use them, but are not required to.
* API: Added cpSpaceEachBody() and cpSpaceEachShape() to iterate bodies/shapes in a space.
* API: Added cpSpaceReindexShapesForBody() to reindex all the shapes attached to a particular body.
* API: Added a 'data' pointer to spaces now too.
* API: cpSpace.staticBody is a pointer to the static body instead of a static reference.
* API: The globals cp_bias_coef, cp_collision_slop, cp_contact_persistence have been moved to properties of a space. (collisionBias, collisionSlop, collisionPersistence respectively)
* API: Added cpBodyActivateStatic() to wake up bodies touching a static body with an optional shape filter parameter.
* API: Added cpBodyEachShape() and cpBodyEachConstraint() iterators to iterate the active shapes/constraints attached to a body.
* API: Added cpBodyEeachArbiter() to iterate the collision pairs a body is involved in. This makes it easy to perform grounding checks or find how much collision force is being applied to an object.
* API: The error correction applied by the collision bias and joint bias is now timestep independent and the units have completely changed.
* FIX: Units of damping for springs are correct regardless of the number of iterations. Previously they were only correct if you had 1 or 2 iterations.
* MISC: Numerous changes to help make Chipmunk work better with variable timesteps. Use of constant timesteps is still highly recommended, but it is now easier to change the time scale without introducing artifacts.
* MISC: Performance! Chipmunk 6 should be way faster than Chipmunk 5 for almost any game.
* MISC: Chipmunk supports multiple spatial indexes and uses a bounding box tree similar to the one found in the Bullet physics library by default. This should provide much better performance for scenes with objects of differening size and works without any tuning for any scale.


CHANGES SINCE 5.3.4
* FIX: Fixed spelling of cpArbiterGetDepth(). Was cpArbiteGetDepth() before. Apparently nobody ever used this function.
* FIX: Added defines for M_PI and M_E. Apparently these values were never part of the C standard math library. Who knew!?
* FIX: Added a guard to cpBodyActivate() so that it's a noop for rouge bodies.
* FIX: Shape queries now work with (and against) sensor shapes.
* FIX: Fixed an issue where removing a collision handler while a separate() callback was waiting to fire the next step would cause crashes.
* FIX: Fixed an issue where the default callback would not be called for sensor shapes.
* FIX: Resetting or applying forces or impulses on a body causes it to wake up now.
* MISC: Added a check that a space was not locked when adding or removing a callback.
* MISC: Removed cpmalloc from the API and replaced all occurences with cpcalloc
* MISC: Added a benchmarking mode to the demo app. -trial runs it in time trial mode and -bench makes it run some benchmarking demos.

CHANGES SINCE 5.3.3:
* FIX: cpBodyActivate() can now be called from collision and query callbacks. This way you can use the setter functions to change properties without indirectly calling cpBodyActivate() and causing an assertion.
* FIX: cpArbiterGetContactPointSet() was returning the collision points for the normals.
* FIX: cpSpaceEachBody() now includes sleeping bodies.
* FIX: Shapes attached to static rogue bodies created with cpBodyNewStatic() are added as static shapes.
* MISC: Applied a user patch to update the MSVC project and add a .def file.

CHANGES SINCE 5.3.2:
* API: Added cpArbiteGetCount() to return the number of contact points.
* API: Added helper functions for calculating areas of Chipmunk shapes as well as calculating polygon centroids and centering polygons on their centroid.
* API: Shape queries. Query a shape to test for collisions if it were to be inserted into a space.
* API: cpBodyInitStatic() and cpBodyNewStatic() for creating additional static (rogue) bodies.
* API: cpBodySleepWithGroup() to allow you to create groups of sleeping objects that are woken up together.
* API: Added overloaded *, +, - and == operators for C++ users.
* API: Added cpSpaceActivateShapesTouchingShape() to query for and activate any shapes touching a given shape. Useful if you ever need to move a static body.
* FIX: Fixed an extremely rare memory bug in the collision cache.
* FIX: Fixed a memory leak in Objective-Chipmunk that could cause ChipmunkSpace objects to be leaked.
* MISC: C struct fields and function that are considered private have been explicitly marked as such. Defining CP_ALLOW_PRIVATE_ACCESS to 0 in Chipmunk.h will let you test which parts of the private API that you are using and give me feedback about how to build proper APIs in Chipmunk 6 for what you are trying to do.
* MISC: Allow CGPoints to be used as cpVect on Mac OS X as well as iOS.


CHANGES SINCE 5.3.1:
* FIX: Collision begin callbacks were being called continuously for sensors or collisions rejected from the pre-solve callback.
* FIX: Plugged a nasty memory leak when adding post-step callbacks.
* FIX: Shapes were being added to the spatial hash using an uninitialized bounding box in some cases.
* FIX: Perfectly aligned circle shapes now push each other apart.
* FIX: cpBody setter functions now call cpBodyActivate().
* FIX: Collision handler targets are released in Objective-Chipmunk when they are no longer needed instead of waiting for the space to be deallocated.
* API: cpSpaceSegmentQuery() no longer returns a boolean. Use cpSpaceSegmentQueryFirst() instead as it's more efficient.
* NEW: cpSpaceRehashShape() Rehash an individual shape, active or static.
* NEW: cpBodySleep() Force a body to fall asleep immediately.
* NEW: cpConstraintGetImpulse() Return the most recent impulse applied by a constraint.
* NEW: Added setter functions for the groove joint endpoints.
* MISC: A number of other minor optimizations and fixes.

CHANGES SINCE 5.3.0:
 * NEW: Added a brand new tutorial for Objective-Chipmunk: SimpleObjectiveChipmunk that can be found in the Objective-Chipmunk folder.
 * NEW: Proper API docs for Objective-Chipmunk.
 * NEW: Updated the included Objective-Chipmunk library.
 * FIX: Fixed a rare memory crash in the sensor demo.
 * FIX: Fixed some warnings that users submitted.

CHANGES SINCE 5.2.0:
 * FIX: Fixed the source so it can compile as C, C++, Objective-C, and Objective-C++.
 * FIX: Fixed cp_contact_persistence. It was broken so that it would forget collision solutions after 1 frame instead of respecting the value set.
 * OPTIMIZATION: Several minor optimizations have been added. Though performance should only differ by a few percent.
 * OPTIMIZATION: Chipmunk now supports putting bodies to sleep when they become inactive.
 * API: Elastic iterations are now deprecated as they should no longer be necessary.
 * API: Added API elements to support body sleeping.
 * API: Added a statically allocated static body to each space for attaching static shapes to.
 * API: Static shapes attached to the space's static body can simply be added to the space using cpSpaceAddShape().
 * NEW: New MSVC projects.
 * NEW: Added boolean and time stamp types for clarity.

CHANGES SINCE 5.1.0:
 * OPTIMIZATION: Chipmunk structs used within the solver are now allocated linearly in large blocks. This is much more CPU cache friendly. Programs have seen up to 50% performance improvements though 15-20% should be expected.
 * API: Shape references in cpArbiter structs changed to private_a and private_b to discourage accessing the fields directly and getting them out of order. You should be using cpArbiterGetShapes() or CP_ARBITER_GET_SHAPES() to access the shapes in the correct order.
 * API: Added assertion error messages as well as warnings and covered many new assertion cases.
 * FIX: separate() callbacks are called before shapes are removed from the space to prevent dangling pointers.
 * NEW: Added convenience functions for creating box shapes and calculating moments.
 

CHANGES SINCE 5.0.0:
 * FIX: fixed a NaN issue that was causing raycasts for horizontal or vertical lines to end up in an infinite loop
 * FIX: fixed a number of memory leaks
 * FIX: fixed warnings for various compiler/OS combinations
 * API: Rejecting a collision from a begin() callback permanently rejects the collision until separation
 * API: Erroneous collision type parameterns removed from cpSpaceDefaulteCollisionHandler()
 * MOVE: FFI declarations of inlined functions into their own header
 * MOVE: Rearranged the project structure to separate out the header files into a separate include/ directory.
 * NEW: Added a static library target for the iPhone.
 * NEW: Type changes when building on the iPhone to make it friendlier to other iPhone APIs
 * NEW: Added an AABB query to complement point and segment queries
 * NEW: CP_NO_GROUP and CP_ALL_LAYERS constants

CHANGES SINCE 4.x:
 * Brand new Joint/Constraint API: New constraints can be added easily and are much more flexible than the old joint system
 * Efficient Segment Queries - Like raycasting, but with line segments.
 * Brand new collision callback API: Collision begin/separate events, API for removal of objects within callbacks, more programable control over collision handling.