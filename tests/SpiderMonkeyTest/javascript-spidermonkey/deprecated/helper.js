// From: http://stackoverflow.com/questions/332422/how-do-i-get-the-name-of-an-objects-type-in-javascript
function type(obj){
    return Object.prototype.toString.call(obj).match(/^\[object (.*)\]$/)[1]
}
/* Simple JavaScript Inheritance
 * By John Resig http://ejohn.org/
 * MIT Licensed.
 */
// Inspired by base2 and Prototype
// var cc = cc = cc || {};

function copy_properties( parent, child ) {
	for( name in parent ) {
		child[name] = parent[name];
	}
	child['_super'] = parent;
}

(function () {
 var initializing = false, fnTest = /xyz/.test(function () {
											   xyz;
											   }) ? /\b_super\b/ : /.*/;
 
 // Create a new Class that inherits from this Class
 Object.prototype.extend = function (prop) {
 var _super = this.prototype;
 
 // Instantiate a base Class (but only create the instance,
 // don't run the init constructor)
 initializing = true;
 var prototype = new this();
 
 var t = type(prototype);
 if( t == 'Object' ) {
 prototype['__nativeObject'] = _super;
 } else {
 prototype['__nativeObject'] = prototype;
 }
 initializing = false;
 
 // Copy the properties over onto the new prototype
 for (var name in prop) {
 // Check if we're overwriting an existing function
 prototype[name] = typeof prop[name] == "function" &&
 typeof _super[name] == "function" && fnTest.test(prop[name]) ?
 (function (name, fn) {
  return function () {
  var tmp = this._super;
  
  // Add a new ._super() method that is the same method
  // but on the super-Class
  this._super = _super[name];
  
  // The method only need to be bound temporarily, so we
  // remove it when we're done executing
  var ret = fn.apply(this, arguments);
  this._super = tmp;
  
  return ret;
  };
  })(name, prop[name]) :
 prop[name];
 }
 
 // The dummy Class constructor
 function Class() {
 // All construction is actually done in the init method
 if (!initializing && this.ctor) {
 this.ctor.apply(this, arguments);
 }
 }
 
 // Populate our constructed prototype object
 Class.prototype = prototype;
 
 // Enforce the constructor to be what we expect
 Class.prototype.constructor = Class;
 
 // And make this Class extendable
 Class.extend = arguments.callee;
 
 //add implementation method
 Class.implement = function (prop) {
 for (var name in prop) {
 prototype[name] = prop[name];
 }
 };
 
 return Class;
 };
 })();
