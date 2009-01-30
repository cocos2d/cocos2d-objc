#INCLUDE_DIRECTORIES(${CHIPMUNK_SOURCE_DIR}/include)

SET(chipmunk_includes
	chipmunk.h
	cpArbiter.h
	cpArray.h
	cpBB.h
	cpBody.h
	cpCollision.h
	cpHashSet.h
	cpJoint.h
	cpPolyShape.h
	cpShape.h
	cpSpace.h
	cpSpaceHash.h
	cpVect.h
)


ADD_LIBRARY(chipmunk SHARED 
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

INSTALL(FILES ${chipmunk_includes} DESTINATION include/chipmunk)
SET_TARGET_PROPERTIES(chipmunk_static PROPERTIES OUTPUT_NAME chipmunk) #Sets chipmunk_static to output "libchipmunk.a" not "libchipmunk_static.a"
INSTALL(TARGETS chipmunk chipmunk_static
	LIBRARY DESTINATION lib
	ARCHIVE DESTINATION lib)
SET_TARGET_PROPERTIES(chipmunk PROPERTIES VERSION 4)

