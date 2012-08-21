
director = cc.Director.getInstance();

cc.log("**** 1 ****");
__jsc__.dumpRoot();
__jsc__.garbageCollect();

scene = cc.Scene.create();
layer = cc.Node.create();
layer2 = cc.Node.create();


cc.log("**** 2 ****");
__jsc__.dumpRoot();
__jsc__.garbageCollect();

layer.onEnter = function() {
    cc.log("On Enter!!");

    cc.log("**** 3 ****");
    __jsc__.dumpRoot();
   __jsc__.garbageCollect();
};

scene.addChild( layer );
director.runWithScene( scene );

cc.log("**** 4 ****");
__jsc__.dumpRoot();
__jsc__.garbageCollect();

