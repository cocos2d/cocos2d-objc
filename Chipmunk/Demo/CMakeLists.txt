INCLUDE_DIRECTORIES(${CHIPMUNK_SOURCE_DIR}/src)

INCLUDE(FindOpenGL)
INCLUDE(FindGLUT)

Find_Package ( OpenGL REQUIRED )
Find_Package ( GLUT REQUIRED )

#Declare any external dependencies that your project may have here.
#examples include: ITK, VTK, JPEG, PNG, OpenGL, ZLIB, Perl, Java
#If you're not sure what name to use, look in the Modules directory of your
#cmake install and check that a file named Find(Package).cmake exists
SET(Required_Packages
#list packages here
OpenGL GLUT
)

IF(GLUT_FOUND)
    MESSAGE("libglut found. ${GLUT_INCLUDE_DIR} ${GLUT_LIBRARIES}")
    LINK_DIRECTORIES(${GLUT_LIBRARIES})
ELSE(GLUT_FOUND)
    MESSAGE(FATAL_ERROR "libglut requested but not found. Please install freeglut")
ENDIF(GLUT_FOUND)


IF(OPENGL_FOUND)
    MESSAGE("libGL found. ${OPENGL_INCLUDE_DIR} ${OPENGL_LIBRARIES}")
    LINK_DIRECTORIES(${OPENGL_LIBRARIES})
ELSE(OPENGL_FOUND)
    MESSAGE(FATAL_ERROR "libGL requested but not found. Please install OpenGL libraries")
ENDIF(OPENGL_FOUND)

#Set any libraries that your project depends on.
#examples: ITKCommon, VTKRendering, etc
SET(Libraries
#list libraries here
GL glut
)

#LINK_DIRECTORIES(${CHIPMUNK_SOURCE_DIR}/build/source)

#the following block of code is an example of how to build an executable in
#cmake.  Unmodified, it will add an executable called "MyExe" to the project.
#MyExe will be built using the files MyClass.h and MyClass.cxx, and it will
#be linked to all the libraries you specified above. 
#You can build more than one executable per project
SET(CurrentExe "../chipmunk_demos")
ADD_EXECUTABLE(${CurrentExe}  Demo1.c  Demo2.c  Demo3.c  Demo4.c  Demo5.c  Demo6.c  Demo7.c  main.c)

TARGET_LINK_LIBRARIES(${CurrentExe} ${Libraries} chipmunk_static)

#the following line is an example of how to add a test to your project.
#Testname is the title for this particular test.  ExecutableToRun is the
#program which will be running this test.  It can either be a part of this
#project or an external executable.  After that list any args that are needed
#for this test.  Include as many tests as you like.  If your project doesn't have
#any tests you can comment out or delete the following line.
#ADD_TEST(Testname ExecutableToRun arg1 arg2 arg3)
	
#Once you're done modifying this template, you should rename it to "CMakeLists.txt"
SET (CMAKE_BUILD_TYPE Release)


