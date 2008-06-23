#INCLUDE_DIRECTORIES(${CHIPMUNK_SOURCE_DIR}/include)

ADD_LIBRARY(chipmunk SHARED 
	CMakeLists.txt
	chipmunk.c
	cpArbiter.c
	cpArray.c
	cpBB.c
	cpBody.c
	cpCollision.c
	cpHashSet.c
	cpJoint.c
	cpPolyShape.c
	cpShape.c
	cpSpace.c
	cpSpaceHash.c
	cpVect.c
)

ADD_LIBRARY(chipmunk_static STATIC 
	CMakeLists.txt
	chipmunk.c
	cpArbiter.c
	cpArray.c
	cpBB.c
	cpBody.c
	cpCollision.c
	cpHashSet.c
	cpJoint.c
	cpPolyShape.c
	cpShape.c
	cpSpace.c
	cpSpaceHash.c
	cpVect.c
)

INSTALL_TARGETS(/usr/local/lib chipmunk)

