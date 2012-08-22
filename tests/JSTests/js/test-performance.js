//
//
// Performance tests
//
//

// force garbage collect before running
__jsc__.garbageCollect();

// dump config info
cc.log('----------------');
cc.log('Config info:');
for( i in cc.config )
    cc.log( i + " = " + cc.config[i] );
cc.log('----------------');

//
// Testing creating Points in Native
//
var node=null;
var x=0;
var y=0;
var p=null;
var i=0;
var startMSec = Date.now();
var n=50000;
for( i=0; i < n; i++ )
    p = cc._native_p(i, i);

var endMSec = Date.now();
var elapsed = (endMSec - startMSec) / 1000;

cc.log("It took " + elapsed + " seconds to create " + n + " points in Native using cc._native_p(10,10)" );

//
// Testing creating Points in JS
//
startMSec = Date.now();
n=50000;
for( i=0; i < n; i++ )
    p = {x:i,y:i};

endMSec = Date.now();
elapsed = (endMSec - startMSec) / 1000;

cc.log("It took " + elapsed + " seconds to create " + n + " points in JS using {x:10, y:10}" );

//
// Testing creating Points in JS Using Typed Arrays
//
startMSec = Date.now();
n=50000;
for( i=0; i < n; i++ ) {
	p = new Float32Array(2);
	p[0] = i;
	p[1] = i;
}

endMSec = Date.now();
elapsed = (endMSec - startMSec) / 1000;

cc.log("It took " + elapsed + " seconds to create " + n + " points in JS using new Float32Array()" );


//
// Testing querying properties
// Valid only when using Typed Arrays for Point
//
n=50000;
p = new Float32Array(2);
p[0] = 10;
p[1] = 20;
startMSec = Date.now();
for( i=0; i < n; i++ ) {
    x = p[0];
    y = p[1];
}
endMSec = Date.now();
elapsed = (endMSec - startMSec) / 1000;
cc.log("It took " + elapsed + " seconds to parse " + n + " points using p[0], p[1]" );

//
// Testing querying properties
// Valid only when using Object for Point
//
n=50000;
p = {x:10,y:20};
startMSec = Date.now();
for( i=0; i < n; i++ ) {
    x = p.x;
    y = p.y;
}
endMSec = Date.now();
elapsed = (endMSec - startMSec) / 1000;
cc.log("It took " + elapsed + " seconds to parse " + n + " points using p.x, p.y" );


//
// Testing native calls
//
node = cc.Node.create();
node.setPosition( cc.p(1,1) );

n=50000;
p = node.getPosition();
startMSec = Date.now();
for( i=0; i < n; i++ ) {
    node.cleanup();
}
endMSec = Date.now();
elapsed = (endMSec - startMSec) / 1000;
cc.log("It took " + elapsed + " seconds to send " + n + " calls using node.cleanup()" );

//
// Testing creating nodes
//
n=1000;
startMSec = Date.now();
for( i=0; i < n; i++ ) {
    node = cc.Node.create();
}
endMSec = Date.now();
elapsed = (endMSec - startMSec) / 1000;
cc.log("It took " + elapsed + " seconds to create " + n + " cc.Node objects" );


cc.log('----------------');
