#!/usr/bin/python
# ----------------------------------------------------------------------------
# Generates SpiderMonkey glue code after Objective-C code
#
# Author: Ricardo Quesada
# Copyright 2012 (C) Zynga, Inc
#
# Dual License: MIT or GPL v2.
# ----------------------------------------------------------------------------
'''
Generates SpiderMonkey glue code after Objective-C code
'''

__docformat__ = 'restructuredtext'


# python
import sys
import os
import re
import getopt
import glob
import ast
import xml.etree.ElementTree as ET
import itertools
import copy
import datetime
import ConfigParser
import string

class ParseException( Exception ):
    pass

class ParseOKException( Exception ):
    pass


# append sys argv0 to path, unless path is absolute
def get_path_for( path ):
    if not os.path.isabs( path ):
        return os.path.join( os.path.dirname( sys.argv[0] ), path )
    return path

#
# Globals
#
BINDINGS_PREFIX = 'js_bindings_'
PROXY_PREFIX = 'JSPROXY_'
METHOD_CONSTRUCTOR, METHOD_CLASS, METHOD_INIT, METHOD_REGULAR = xrange(4)


# xml2d recipe copied from here:
# http://code.activestate.com/recipes/577722-xml-to-python-dictionary-and-back/
def xml2d(e):
    """Convert an etree into a dict structure

    @type  e: etree.Element
    @param e: the root of the tree
    @return: The dictionary representation of the XML tree
    """
    def _xml2d(e):
        kids = dict(e.attrib)
        for k, g in itertools.groupby(e, lambda x: x.tag):
            g = [ _xml2d(x) for x in g ]
            kids[k]=  g
        return kids
    return { e.tag : _xml2d(e) }


class SpiderMonkey(object):

    @classmethod
    def parse_config_file( cls, config_file ):
        cp = ConfigParser.ConfigParser()
        cp.read(config_file)


        supported_options = {'obj_class_prefix_to_remove': '',
                             'classes_to_parse' : [],
                             'classes_to_ignore' : [],
                             'class_properties' : [],
                             'bridge_support_file' : [],
                             'hierarchy_protocol_file' : [],
                             'inherit_class_methods' : True,
                             'functions_to_parse' : [],
                             'functions_to_ignore' : [],
                             'method_properties' : [],
                             'js_properties' : [],
                             'struct_properties' : [],
                             'function_prefix_to_remove' : '',
                             'import_files' : [],
                             }



        for s in cp.sections():
            config = copy.copy( supported_options )

            # Section is the config namespace
            config['namespace'] = s

            for o in cp.options(s):
                if not o in config:
                    print 'Ignoring unrecognized option: %s' % o
                    continue

                t = type( config[o] )
                if t == type(True):
                    v = cp.getboolean(s, o)
                elif t == type(1):
                    v = cp.getint(s, o )
                elif t == type(''):
                    v = cp.get(s, o )
                elif t == type([]):
                    v = cp.get(s, o )
                    v = v.replace('\t','')
                    v = v.replace('\n','')
                    v = v.replace(' ','')
                    v = v.strip()
                    v = v.split(',')
                else:
                    raise Exception('Unsupported type' % str(t) )
                config[ o ] = v

            sp = SpiderMonkey( config )
            sp.parse()

    def __init__(self, config ):

        self.hierarchy_files = config['hierarchy_protocol_file']
        self.init_hierarchy_file()

        self.bridgesupport_files = config['bridge_support_file']
        self.init_bridgesupport_file()

        self.namespace = config['namespace']

        #
        # Classes related
        #
        self.class_prefix = config['obj_class_prefix_to_remove']
        self.inherit_class_methods = config['inherit_class_methods']
        self.import_files = config['import_files']

        # Add here manually generated classes
        self.init_class_properties( config['class_properties'] )
        self.init_classes_to_bind( config['classes_to_parse'] )
        self.init_classes_to_ignore( config['classes_to_ignore'] )

        # In order to prevent parsing a class many times
        self.parsed_classes = []

        #
        # Method related
        #
        self.init_method_properties( config['method_properties'] )

        self.init_callback_methods()
        # Current method that is being parsed
        self.current_method = None

        #
        # function related
        #
        self.function_prefix = config['function_prefix_to_remove']
        self.init_functions_to_bind( config['functions_to_parse'] )
        self.init_functions_to_ignore( config['functions_to_ignore'] )
        self.current_function = None
        self.callback_functions = []

        #
        # struct related
        #
        self.init_struct_properties( config['struct_properties'] )


    def init_hierarchy_file( self ):
        self.hierarchy = {}
        for f in self.hierarchy_files:
            # empty string ??
            if f:
                fd = open( get_path_for( f ) )
                self.hierarchy.update( ast.literal_eval( fd.read() ) )
                fd.close()

    def init_bridgesupport_file( self ):
        self.bs = {}
        self.bs['signatures'] = {}

        for f in self.bridgesupport_files:
            p = ET.parse( get_path_for( f ) )
            root = p.getroot()
            xml = xml2d( root )
            for key in xml['signatures']:
                # More than 1 file can be loaded
                # So, older keys should not be overwritten
                if not key in self.bs['signatures']:
                    self.bs['signatures'][key] = xml['signatures'][key]
                else:
                    l = self.bs['signatures'][key]
                    if type(l) == type([]):
                        self.bs['signatures'][key].extend( xml['signatures'][key] )

    def init_callback_methods( self ):
        self.callback_methods = {}

        for class_name in self.method_properties:
            methods = self.method_properties[ class_name ]
            for method in methods:
                if 'callback' in self.method_properties[ class_name ][ method ]:
                    if not self.callback_methods.has_key( class_name ):
                        self.callback_methods[ class_name ] = []
                    self.callback_methods[ class_name ].append( method )

    def process_method_properties( self, klass, method_name, props ):

        if not klass in self.method_properties:
            self.method_properties[klass] = {}
        if not method_name in self.method_properties[klass]:
            self.method_properties[klass][method_name] = {}
        self.method_properties[klass][method_name] = copy.copy( props )

        # Process "merge"
        if 'merge' in props:
            lm = props['merge'].split('|')

            # append self
            lm.append( method_name )

            methods = {}
            # needed to obtain the selector with greater number of args
            max_args = 0
            # needed for optional_args_since
            min_args = 1000

            for m in lm:
                m = m.strip()
                args = m.count(':')
                methods[ args ] = m
                if args > max_args:
                    max_args = args
                if args < min_args:
                    min_args = args

                # Automatically add "ignore" in the method_properties, but not in "self"
                if m != method_name:
                    self.set_method_property( klass, m, 'ignore', True )

            # Add max/min/calls rules
            self.set_method_property( klass, method_name, 'calls', methods )
            self.set_method_property( klass, method_name, 'min_args', min_args )
            self.set_method_property( klass, method_name, 'max_args', max_args )

            # safety check
            if method_name.count(':') != max_args:
                raise Exception("Merge methods should have less arguments that the main method. Check: %s # %s" % (klass, method_name ) )

        if 'name' in props:
            # If this name was previously used, the delete it. Only the newer one will be used
            # this scenario can happen when defining a name using a regexp, and then change it with a single line
            name = props['name']
            for m in self.method_properties[klass]:
                d = self.method_properties[klass][m]
                old_name = d.get('name', None )
                if m != method_name and old_name == name:
                    del( d['name'] )
                    print 'Deleted duplicated from %s (old:%s)  (new:%s)' % (klass, m, method_name)


        if 'manual' in props:
            if not klass in self.manual_methods:
                self.manual_methods[ klass ] = []
            self.manual_methods[ klass ].append( method_name )


    def init_method_properties( self, properties ):
        self.method_properties = {}
        self.manual_methods = {}
        for prop in properties:
            # key value
            if not prop or len(prop)==0:
                continue
            key,value = prop.split('=')

            # From Key get: Class # method
            klass,method = key.split('#')
            klass = klass.strip()
            method = method.strip()

            opts = {}
            # From value get options
            options = value.split(';')
            for o in options:
                # Options can have their own Key Value
                if ':' in o:
                    o = o.replace('"', '')
                    o = o.replace("'", "")

                    # o_value might also have some ':'
                    # So, it should split by the first ':'
                    o_list = o.split(':')
                    o_key = o_list[0]
                    o_val = ':'.join(o_list[1:])
                else:
                    o_key = o
                    o_val = True
                opts[ o_key ] = o_val

            expanded_klasses = self.expand_regexp_names( [klass], self.supported_classes )
            for k in expanded_klasses:
                self.process_method_properties( k, method, opts )

    def init_struct_properties( self, properties ):
        self.struct_properties = {}
        self.struct_opaque = []
        self.struct_manual = []
        for prop in properties:
            # key value
            if not prop or len(prop)==0:
                continue
            key,value = prop.split('=')

            opts = {}
            # From value get options
            options = value.split(';')
            for o in options:
                # Options can have their own Key Value
                if ':' in o:
                    o_key, o_val = o.split(':')
                    o_val = o_val.replace('"', '')    # remove possible "
                else:
                    o_key = o
                    o_val = None
                opts[ o_key ] = o_val

                # populate lists. easier to code
                if o_key == 'opaque':
                    # '*' is needed for opaque structs
                    self.struct_opaque.append( key + '*' )
                elif o_key == 'manual':
                    self.struct_manual.append( key )
            self.struct_properties[key] = opts

    def init_functions_to_bind( self, functions ):
        self._functions_to_bind = set( functions )
        ref_list = []

        if 'function' in self.bs['signatures']:
            for k in self.bs['signatures']['function']:
                ref_list.append( k['name'] )
            self.functions_to_bind = self.expand_regexp_names( self._functions_to_bind, ref_list )
        else:
            self.functions_to_bind = []
        self.functions_bound = []

    def init_functions_to_ignore( self, klasses ):
        self._functions_to_ignore = klasses
        self.functions_to_ignore = self.expand_regexp_names( self._functions_to_ignore, self.functions_to_bind )

        copy_set = copy.copy( self.functions_to_bind )
        for i in self.functions_to_bind:
            if i in self.functions_to_ignore:
                print 'Explicity removing %s from bindings...' % i
                copy_set.remove( i )

        self.functions_to_bind = copy_set

    def init_class_properties( self, properties ):
        self.supported_classes = set()
        self.class_manual = []
        self.class_properties = {}
        for prop in properties:
            # key value
            if not prop or len(prop)==0:
                continue
            key,value = prop.split('=')

            opts = {}
            # From value get options
            options = value.split(';')
            for o in options:
                # Options can have their own Key Value
                if ':' in o:
                    o_key, o_val = o.split(':')
                    o_val = o_val.replace('"', '')    # remove possible "
                else:
                    o_key = o
                    o_val = None
                opts[ o_key ] = o_val

                # populate lists. easier to code
                if o_key == 'manual':
                    # '*' is needed for opaque structs
                    self.supported_classes.add( key )
                    self.class_manual.append( key )

            self.class_properties[key] = opts

    def init_classes_to_bind( self, klasses ):
        self._classes_to_bind = set( klasses )
        ref_list = []
        if 'class' in self.bs['signatures']:
            for k in self.bs['signatures']['class']:
                ref_list.append( k['name'] )
        self.classes_to_bind = self.expand_regexp_names( self._classes_to_bind, ref_list )
        l = self.ancestors_of_classes_to_bind()
        s = set( self.classes_to_bind )
        self.classes_to_bind = s.union( set(l) )

    def init_classes_to_ignore( self, klasses ):
        self._classes_to_ignore = klasses
        self.classes_to_ignore = self.expand_regexp_names( self._classes_to_ignore, self.classes_to_bind )

        copy_set = copy.copy( self.classes_to_bind )
        for i in self.classes_to_bind:
            if i in self.classes_to_ignore:
                print 'Explicity removing %s from bindings...' % i
                copy_set.remove( i )

        self.classes_to_bind = copy_set
        self.supported_classes = self.supported_classes.union( copy_set )

    def ancestors_of_classes_to_bind ( self ):
        ancestors = []
        for klass in self.classes_to_bind:
            new_list = self.ancestors( klass, [klass] )
            ancestors.extend( new_list )
        return ancestors

    def ancestors( self, klass, list_of_ancestors ):
        if klass not in self.hierarchy:
            return list_of_ancestors

        info = self.hierarchy[ klass ]
        subclass =  info['subclass']
        if not subclass:
            return list_of_ancestors

        list_of_ancestors.append( subclass )

        return self.ancestors( subclass, list_of_ancestors )

    def expand_regexp_names( self, names_to_expand, list_of_names ):
        valid = []
        all_class_names = []
        for n in list_of_names:
            for regexp in names_to_expand:
                if not regexp or regexp=='':
                    continue
                # if last char is not a regexp modifier,
                # then append '$' to regexp
                last_char = regexp[-1]
                if last_char in string.letters or last_char in string.digits or last_char=='_':
                    result = re.match( regexp + '$', n )
                else:
                    result = re.match( regexp, n )
                if result:
                    valid.append( n )

        ret = list( set( valid ) )
        return ret

    #
    # Helpers
    #
    def get_callback_args_for_method( self, method ):
        method_name = method['selector']
        method_args = method_name.split(':')

        full_args = []
        args = []

        if 'arg' in method:
            for i,arg in enumerate( method['arg'] ):
                full_args.append( method_args[i] +':' )
                full_args.append( '(' + arg['declared_type'] + ')' )
                full_args.append( arg['name'] + ' ' )

                args.append( method_args[i] +':' )
                args.append( arg['name'] + ' ' )
            return [''.join(full_args), ''.join(args) ]
        return method_name, method_name

    def get_parent_class( self, class_name ):
        try:
            parent = self.hierarchy[class_name]['subclass']
        except KeyError, e:
            return None
        return parent

    def get_class_method( self, class_name ):
        class_methods = []

        klass = None
        list_of_classes = self.bs['signatures']['class']
        for k in list_of_classes:
            if k['name'] == class_name:
                klass = k

        if not klass:
            raise Exception("Base class not found: %s" % class_name )

        for m in klass['method']:
            if self.is_class_method( m ):
                class_methods.append( m )
        return class_methods

    def get_struct_type_and_num_of_elements( self, struct ):
        # PRECOND: Structure must be valid

        # BridgeSupport to TypedArray
        bs_to_type_array =  { 'c' : 'TYPE_INT8',
                              'C' : 'TYPE_UINT8',
                              's' : 'TYPE_INT16',
                              'S' : 'TYPE_UINT16',
                              'i' : 'TYPE_INT32',
                              'I' : 'TYPE_UINT32',
                              'f' : 'TYPE_FLOAT32',
                              'd' : 'TYPE_FLOAT64',
                              }

        inner = struct.replace('{', '')
        inner = inner.replace('{', '')
        inner = inner.replace('}','')
        key,value = inner.split('=')

        k = value[0]
        if not k in bs_to_type_array:
            raise Exception('Structure cannot be converted')

        # returns type of structure and len
        return (bs_to_type_array[k], len(value) )

    def get_name_for_manual_struct( self, struct_name ):
        value = self.get_struct_property( 'manual', struct_name )
        if not value:
            return struct_name
        return value

    def get_struct_property( self, property, struct_name ):
        try:
            return self.struct_properties[ struct_name ][ property ]
        except KeyError, e:
            return None


    def is_valid_structure( self, struct ):
        # Only support non-nested structures of only one type
        # valids:
        #   {xxx=CCC}
        #   {xxx=ff}
        # invalids:
        #   {xxx=CC{yyy=C}}
        #   {xxx=fC}

        if not struct:
            return False

        if struct[0] == '{' and struct[-1] == '}' and len( struct.split('{') ) == 2:
            inner = struct.replace('{', '')
            inner = inner.replace('{', '')
            inner = inner.replace('}', '')
            key,value = inner.split('=')
            # values should be of the same type
            previous = None
            for c in value:
                if previous != None:
                    if previous != c:
                        return False
                    previous = c
            return True
        return False

    # whether or not the method is a constructor
    def is_class_constructor( self, method ):
        if self.is_class_method( method ) and 'retval' in method:
            retval = method['retval']
            dt = retval[0]['declared_type']

            # Should also check the naming convention. eg: 'spriteWith...'
            if dt == 'id':
                return True
        return False

    # whether or not the method is an initializer
    def is_method_initializer( self, method ):
        # Is this is a method ?
        if not 'selector' in method:
            return False

        if 'retval' in method:
            retval = method['retval']
            dt = retval[0]['declared_type']

            if method['selector'].startswith('init') and dt == 'id':
                return True
        return False

    def get_method_property( self, class_name, method_name, prop ):
        try:
            return self.method_properties[ class_name ][ method_name ][ prop ]
        except KeyError, e:
            return None

    def set_method_property( self, class_name, method_name, prop, value=True ):

        if not class_name in self.method_properties:
            self.method_properties[ class_name ] = {}

        if not method_name in self.method_properties[ class_name ]:
            self.method_properties[ class_name ][ method_name ] = {}

        k = self.method_properties[class_name][method_name]
        k[ prop ] = value

    def is_class_method( self, method ):
        return 'class_method' in method and method['class_method'] == 'true'

    def get_method( self,class_name, method_name ):
        for klass in self.bs['signatures']['class']:
            if klass['name'] == class_name:
                for m in klass['method']:
                    if m['selector'] == method_name:
                        return m

        # Not found... search in protocols
        list_of_protocols = self.bs['signatures']['informal_protocol']
        if 'protocols' in self.hierarchy[ class_name ]:
            protocols = self.hierarchy[ class_name ]['protocols']
            for protocol in protocols:
                for ip in list_of_protocols:
                    # protocol match ?
                    if ip['name'] == protocol:
                        # traverse method then
                        for m in ip['method']:
                            if m['selector'] == method_name:
                                return m

        raise Exception("Method not found for %s # %s" % (class_name, method_name) )

    def get_method_type( self, method ):
        if self.is_class_constructor( method ):
            method_type = METHOD_CONSTRUCTOR
        elif self.is_class_method( method ):
            method_type = METHOD_CLASS
        elif self.is_method_initializer(method):
            method_type = METHOD_INIT
        else:
            method_type = METHOD_REGULAR

        return method_type

    def get_number_of_arguments( self, function ):
        ret = 0
        if 'arg' in function:
            return len( function['arg'] )
        return ret

    def convert_selector_name_to_native( self, name ):
        return name.replace(':','_')

    def convert_selector_name_to_js( self, class_name, selector ):
        # Does it have a rename rule ?
        try:
            return self.method_properties[ class_name ][ selector ][ 'name' ]
        except KeyError, e:
            pass

        # Is it a property ?
        try:
            if selector in self.hierarchy[ class_name ][ 'properties' ]:
                ret = 'get%s%s' % (selector[0].capitalize(), selector[1:] )
                return ret
        except KeyError, e:
            pass

        name = ''
        parts = selector.split(':')
        for i,arg in enumerate(parts):
            if i==0:
                name += arg
            elif arg:
                name += arg[0].capitalize() + arg[1:]

        return name

    def convert_function_name_to_js( self, function_name ):
        name = function_name
        if function_name.startswith( self.function_prefix ):
            name = name[ len(self.function_prefix) : ]
            name = name[0].lower() + name[1:]
        return name

    def convert_class_name_to_js( self, class_name ):

        # rename rule ?
        if class_name in self.class_properties and 'name' in self.class_properties[class_name]:
            name = self.class_properties[class_name]['name']
            name = name.replace('"', '')
            return name

        # Prefix rule ?
        if class_name.startswith( self.class_prefix ):
            class_name = class_name[len( self.class_prefix) : ]

        return class_name

    def generate_autogenerate_prefix( self, fd ):
        autogenerated_template = '''/*
* AUTOGENERATED FILE. DO NOT EDIT IT
* Generated by "%s -c %s" on %s
*/
'''
        fd.write( autogenerated_template % ( os.path.basename(sys.argv[0]), os.path.basename(sys.argv[2]), datetime.date.today() ) )

    #
    # "class" constructor and destructor
    #
    def generate_constructor( self, class_name ):

        # Global Variables
        # JSPROXY_CCNode
        # JSPROXY_CCNode
        constructor_globals = '''
JSClass* %s_class = NULL;
JSObject* %s_object = NULL;
'''

        # 1: JSPROXY_CCNode,
        # 2: JSPROXY_CCNode,
        # 8: possible callback code
        constructor_template = ''' // Constructor
JSBool %s_constructor(JSContext *cx, uint32_t argc, jsval *vp)
{
    JSObject *jsobj = [%s createJSObjectWithRealObject:nil context:cx];
    JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));

    return JS_TRUE;
}
'''
        proxy_class_name = '%s%s' % (PROXY_PREFIX, class_name )
        self.mm_file.write( constructor_globals % ( proxy_class_name, proxy_class_name ) )
        self.mm_file.write( constructor_template % ( proxy_class_name, proxy_class_name ) )

    def generate_destructor( self, class_name ):
        destructor_template = '''
// Destructor
void %s_finalize(JSContext *cx, JSObject *obj)
{
	CCLOGINFO(@"spidermonkey: finalizing JS object %%p (%s)", obj);
}
'''
        proxy_class_name = '%s%s' % (PROXY_PREFIX, class_name )
        self.mm_file.write( destructor_template % ( proxy_class_name,
                                                    class_name) )

    #
    # Method generator functions
    #
    def generate_method_call_to_real_object( self, selector_name, num_of_args, ret_js_type, args_declared_type, class_name, method_type ):

        args = selector_name.split(':')

        if method_type == METHOD_INIT:
            prefix = '\t%s *real = [(%s*)[proxy.klass alloc] ' % (class_name, class_name )
            suffix = '\n\t[proxy setRealObj: real];\n\t[real autorelease];\n'
            suffix += '\n\tobjc_setAssociatedObject(real, &JSPROXY_association_proxy_key, proxy, OBJC_ASSOCIATION_RETAIN);'
            suffix += '\n\t[proxy release];'
        elif method_type == METHOD_REGULAR:
            prefix = '\t%s *real = (%s*) [proxy realObj];\n\t' % (class_name, class_name)
            suffix = ''
            if ret_js_type:
                prefix = prefix + 'ret_val = '
            prefix = prefix + '[real '
        elif method_type == METHOD_CONSTRUCTOR:
            prefix = '\tret_val = [%s ' % (class_name )
            suffix = ''
        elif method_type == METHOD_CLASS:
            if not ret_js_type:
                prefix = '\t[%s ' % (class_name)
            else:
                prefix = '\tret_val = [%s ' % (class_name )
            suffix = ''
        else:
            raise Exception('Invalid method type')

        call = ''

        for i,arg in enumerate(args):
            if num_of_args == 0:
                call += arg
            elif i+1 > num_of_args:
                break
            elif arg:   # empty arg?
                # cast needed to prevent compiler errors
                call += '%s:(%s)arg%d ' % (arg, args_declared_type[i], i)

        call += ' ];';

        return '%s%s%s' % (prefix, call, suffix )

    # special case: returning Object
    def generate_retval_object( self, declared_type, js_type ):
        object_template = '''
	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
'''
        return object_template

    # special case: returning String
    def generate_retval_string( self, declared_type, js_type ):
        template = '''
	JSString *ret_obj = JS_NewStringCopyZ(cx, [ret_val UTF8String]);
	JS_SET_RVAL(cx, vp, STRING_TO_JSVAL(ret_obj) );
'''
        return template

    def generate_retval_array( self, declared_type, js_type ):
        template = '''
	jsval ret_jsval = NSArray_to_jsval( cx, (NSArray*) ret_val );
	JS_SET_RVAL(cx, vp, ret_jsval );
'''
        return template

    def generate_retval_set( self, declared_type, js_type ):
        template = '''
	jsval ret_jsval = NSSet_to_jsval( cx, (NSSet*) ret_val );
	JS_SET_RVAL(cx, vp, ret_jsval );
'''
        return template

    #
    # special case: manual bindings for these structs
    #  eg: CGRect, CGSize, CGPoint, cpVect
    #
    def generate_retval_struct_manual( self, declared_type, js_type ):
        new_name = self.get_name_for_manual_struct( declared_type )
        template = '''
	jsval ret_jsval = %s_to_jsval( cx, (%s)ret_val );
	JS_SET_RVAL(cx, vp, ret_jsval);
''' % (new_name, declared_type )
        return template

    #
    # Non manual bound structures
    #
    def generate_retval_struct_automatic( self, declared_type, js_type ):
        template = '''
	JSObject *typedArray = js_CreateTypedArray(cx, js::TypedArray::%s, %d );
	%s* buffer = (%s*)JS_GetTypedArrayData(typedArray);
	*buffer = ret_val;
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(typedArray));
	'''
        t, l = self.get_struct_type_and_num_of_elements( js_type )
        return template % (t, l,
                           declared_type, declared_type )

    #
    # Structures that should be treated as "opaque"
    #
    def generate_retval_opaque( self, declared_type, js_type ):
        template = '''
	jsval ret_jsval = opaque_to_jsval( cx, ret_val );
	JS_SET_RVAL(cx, vp, ret_jsval);
	'''
        return template

    def generate_retval( self, declared_type, js_type ):
        direct_convert = {
            'i' : 'INT_TO_JSVAL(ret_val)',
            'u' : 'INT_TO_JSVAL(ret_val)',
            'b' : 'BOOLEAN_TO_JSVAL(ret_val)',
            's' : 'STRING_TO_JSVAL(ret_val)',
            'd' : 'DOUBLE_TO_JSVAL(ret_val)',
            'c' : 'INT_TO_JSVAL(ret_val)',
            'long' : 'long_to_jsval(cx, ret_val)',                # long: not supoprted on JS 64-bit
            'longlong' : 'longlong_to_jsval(cx, ret_val)',        # long long: not supported on JS
            'void' : 'JSVAL_VOID',
            None : 'JSVAL_VOID',
        }
        special_convert = {
            'o' : self.generate_retval_object,
            'S' : self.generate_retval_string,
            'array': self.generate_retval_array,
            'set': self.generate_retval_set,
        }

        ret = ''
        if declared_type in self.struct_opaque:
            ret = self.generate_retval_opaque( declared_type, js_type )
        elif declared_type in self.struct_manual:
            ret =  self.generate_retval_struct_manual( declared_type, js_type )
        elif self.is_valid_structure( js_type ):
            ret = self.generate_retval_struct_automatic( declared_type, js_type )
        elif js_type in special_convert:
            ret = special_convert[js_type]( declared_type, js_type )
        elif js_type in direct_convert:
            s = direct_convert[ js_type ]
            ret = '\tJS_SET_RVAL(cx, vp, %s);' % s
        else:
            raise Exception("Invalid key: %s" % js_type )

        return ret

    def validate_retval( self, method, class_name = None ):
        # Left column: BridgeSupport types
        # Right column: JS types
        supported_declared_types = {
            'NSString*' : 'S',
            'NSArray*'  : 'array',
            'NSMutableArray*' : 'array',
            'CCArray*'  : 'array',
            'NSSet*'    : 'set',
        }

        supported_types = {
            'f' : 'd',  # float
            'd' : 'd',  # double
            'i' : 'i',  # integer
            'I' : 'u',  # unsigned integer
            'c' : 'c',  # char
            'C' : 'c',  # unsigned char
            'B' : 'b',  # BOOL
            'v' :  None,  # void (for retval)
            'L' : 'long',          # long (special conversion)
            'Q' : 'longlong',      # long long (special conversion)
        }

#        s = method['selector']

        ret_js_type = None
        ret_declared_type = None

        # parse ret value
        if 'retval' in method:
            retval = method['retval']
            t = retval[0]['type']
            dt = retval[0]['declared_type']
            dt_class_name = dt.replace('*','')

            # Special case for initializer methods
            if self.is_method_initializer(method ):
                ret_js_type = None
                ret_declared_type = None

            # Special case for class constructors
            elif self.is_class_constructor( method ):
                ret_js_type = 'o'
                ret_declared_type = class_name + '*'

            # Part of supported declared types ?
            elif dt in supported_declared_types:
                ret_js_type = supported_declared_types[dt]
                ret_declared_type = dt

            # Part of supported types ?
            elif t in supported_types:
                if supported_types[t] == None:  # void type
                    ret_js_type = None
                    ret_declared_type = 'void'
                else:
                    ret_js_type = supported_types[t]
                    ret_declared_type = retval[0]['declared_type']

            # special case for Objects
            elif t == '@' and dt_class_name in self.supported_classes:
                ret_js_type = 'o'
                ret_declared_type = dt

            # valid automatic struct ?
            elif self.is_valid_structure( t ):
                ret_js_type = t
                ret_declared_type =  dt

            # valid opaque struct ?
            elif dt in self.struct_opaque:
                ret_js_type = 'N/A'
                ret_declared_type = dt

            # valid manual struct ?
            elif dt in self.struct_manual:
                ret_js_type = 'N/A'
                ret_declared_type = dt

            else:
                raise ParseException('Unsupported return value %s' % dt)

        return (ret_js_type, ret_declared_type )

    def validate_arguments( self, method ):
        # Left column: BridgeSupport types
        # Right column: JS types
        supported_declared_types = {
            'NSString*' : 'S',
            'NSArray*'  : 'array',
            'CCArray*'  : 'array',
            'NSMutableArray*' : 'array',
            'NSSet*' : 'set',
            'void (^)(id)' : 'f',
            'void (^)(CCNode *)' : 'f',
        }

        supported_types = {
            'f' : 'd',  # float
            'd' : 'd',  # double
            'i' : 'i',  # integer
            'I' : 'u',  # unsigned integer
            'c' : 'c',  # char
            'C' : 'c',  # unsigned char
            'B' : 'b',  # BOOL
            's' : 'c',  # short
            'L' : 'long',       # long (custom conversion)
            'Q' : 'longlong',   # long long (custom conversion)
        }

        args_js_type = []
        args_declared_type = []

        # parse arguments
        if 'arg' in method:
            args = method['arg']
            for arg in args:
                t = arg['type']
                dt = arg['declared_type']

                # Treat 'id' as NSObject*
                if dt=='id':
                    dt='NSObject*'

                dt_class_name = dt.replace('*','')

                # IMPORTANT: 1st search on declared types.
                # NSString should be treated as a special case, not as a generic object
                if dt in supported_declared_types:
                    args_js_type.append( supported_declared_types[dt] )
                    args_declared_type.append( dt )
                elif t in supported_types:
                    args_js_type.append( supported_types[t] )
                    args_declared_type.append( dt )
                # special case for Objects
                elif t == '@' and dt_class_name in self.supported_classes:
                    args_js_type.append( 'o' )
                    args_declared_type.append( dt )

                # valid 'opaque' struct ?
                elif dt in self.struct_opaque:
                    args_js_type.append('N/A')
                    args_declared_type.append( dt )

                # valid manual struct ?
                elif dt in self.struct_manual:
                    args_js_type.append('N/A')
                    args_declared_type.append( dt )

                # valid automatic struct ?
                elif self.is_valid_structure( t ):
                    args_js_type.append( t )
                    args_declared_type.append( dt )

                else:
                    raise ParseException("Unsupported argument: %s" % dt)

        return (args_js_type, args_declared_type)

    def generate_argument_variadic_2_nsarray( self ):
        template = '\tok &= jsvals_variadic_to_nsarray( cx, argvp, argc, &arg0 );\n'
        self.mm_file.write( template )

    # Special case for string to NSString generator
    def generate_argument_string( self, i, arg_js_type, arg_declared_type ):
        template = '\tok &= jsval_to_nsstring( cx, *argvp++, &arg%d );\n'
        self.mm_file.write( template % i )

    # Special case for objects
    def generate_argument_object( self, i, arg_js_type, arg_declared_type ):
        object_template = '\tok &= jsval_to_nsobject( cx, *argvp++, &arg%d);\n'
        self.mm_file.write( object_template % (i ) )

    # Manual conversion for struct
    def generate_argument_struct_manual( self, i, arg_js_type, arg_declared_type ):
        new_name = self.get_name_for_manual_struct( arg_declared_type )
        template = '\tok &= jsval_to_%s( cx, *argvp++, (%s*) &arg%d );\n' % (new_name, new_name, i )
        self.mm_file.write( template )

    def generate_argument_struct_automatic( self, i, arg_js_type, arg_declared_type ):
        # This template assumes that the types will be the same on all platforms (eg: 64 and 32-bit platforms)
        template = '''
	JSObject *tmp_arg%d;
	ok &= JS_ValueToObject( cx, *argvp++, &tmp_arg%d );
	arg%d = *(%s*)JS_GetTypedArrayData( tmp_arg%d);
'''
        proxy_class_name = PROXY_PREFIX + arg_declared_type

        self.mm_file.write( template % (i,
                                        i,
                                        i, arg_declared_type, i ) )


    def generate_argument_array( self, i, arg_js_type, arg_declared_type ):
        template = '\tok &= jsval_to_nsarray( cx, *argvp++, &arg%d );\n'
        self.mm_file.write( template % (i) )

    def generate_argument_set( self, i, arg_js_type, arg_declared_type ):
        template = '\tok &= jsval_to_nsset( cx, *argvp++, &arg%d );\n'
        self.mm_file.write( template % (i) )

    def generate_argument_function( self, i, arg_js_type, arg_declared_type ):
        template = '\tok &= jsval_to_block_1( cx, *argvp++, JS_THIS_OBJECT(cx, vp), &arg%d );\n'
        self.mm_file.write( template % (i) )

    def generate_argument_opaque( self, i, arg_js_type, arg_declared_type ):
        template = '\tok &= jsval_to_opaque( cx, *argvp++, (void**)&arg%d );\n'
        self.mm_file.write( template % (i) )

    def generate_argument_long( self, i, arg_js_type, arg_declared_type ):
        template = '\tok &= jsval_to_long( cx, *argvp++, &arg%d );\n'
        self.mm_file.write( template % (i) )

    def generate_argument_longlong( self, i, arg_js_type, arg_declared_type ):
        template = '\tok &= jsval_to_longlong( cx, *argvp++, &arg%d );\n'
        self.mm_file.write( template % (i) )

    def generate_arguments( self, args_declared_type, args_js_type, properties = {} ):
        # b      JSBool          Boolean
        # c      uint16_t/jschar ECMA uint16_t, Unicode char
        # i      int32_t         ECMA int32_t
        # u      uint32_t        ECMA uint32_t
        # j      int32_t         Rounded int32_t (coordinate)
        # d      double          IEEE double
        # I      double          Integral IEEE double
        # S      JSString *      Unicode string, accessed by a JSString pointer
        # W      jschar *        Unicode character vector, 0-terminated (W for wide)
        # o      JSObject *      Object reference
        # f      JSFunction *    Function private
        # v      jsval           Argument value (no conversion)
        # *      N/A             Skip this argument (no vararg)
        # /      N/A             End of required arguments
        # More info:
        # https://developer.mozilla.org/en/SpiderMonkey/JSAPI_Reference/JS_ConvertArguments
        js_types_conversions = {
            'b' : ['JSBool',    'JS_ValueToBoolean'],
            'd' : ['double',    'JS_ValueToNumber'],
            'I' : ['double',    'JS_ValueToNumber'],    # double converted to string
            'i' : ['int32_t',   'JS_ValueToECMAInt32'],
            'j' : ['int32_t',   'JS_ValueToECMAInt32'],
            'u' : ['uint32_t',  'JS_ValueToECMAUint32'],
            'c' : ['uint16_t',  'JS_ValueToUint16'],
        }

        js_special_type_conversions =  {
            'S' : [self.generate_argument_string, 'NSString*'],
            'o' : [self.generate_argument_object, 'id'],
            'array': [self.generate_argument_array, 'NSArray*'],
            'set': [self.generate_argument_set, 'NSSet*'],
            'f' : [self.generate_argument_function, 'js_block'],
            'long' :     [self.generate_argument_long, 'long'],
            'longlong' : [self.generate_argument_longlong, 'long long'],
        }

        # First  time
        self.mm_file.write('\tjsval *argvp = JS_ARGV(cx,vp);\n')
        self.mm_file.write('\tJSBool ok = JS_TRUE;\n');

        # Declare variables
        declared_vars = '\t'
        for i,arg in enumerate(args_js_type):
            if args_declared_type[i] in self.struct_opaque:
                declared_vars += '%s arg%d;' % ( args_declared_type[i], i )
            elif args_declared_type[i] in self.struct_manual:
                declared_vars += '%s arg%d;' % ( args_declared_type[i], i )
            elif self.is_valid_structure( arg ):
                declared_vars += '%s arg%d;' % ( args_declared_type[i], i )
            elif arg in js_types_conversions:
                declared_vars += '%s arg%d;' % (js_types_conversions[arg][0], i)
            elif arg in js_special_type_conversions:
                declared_vars += '%s arg%d;' % ( js_special_type_conversions[arg][1], i )
            declared_vars += ' '
        self.mm_file.write( '%s\n\n' % declared_vars )


        # Optional Arguments ?
        min_args = properties.get('min_args', None)
        max_args = properties.get('max_args', None)
        if min_args != max_args:
            optional_args = min_args
        else:
            optional_args = None

        # Use variables

        # Special case for variadic_2_nsarray
        if 'variadic_2_array' in properties:
            self.generate_argument_variadic_2_nsarray()

        else:
            for i,arg in enumerate(args_js_type):

                if optional_args!=None and i >= optional_args:
                    self.mm_file.write('\tif (argc >= %d) {\n\t' % (i+1) )

                if args_declared_type[i] in self.struct_opaque:
                    self.generate_argument_opaque( i, arg, args_declared_type[i] )
                elif args_declared_type[i] in self.struct_manual:
                    self.generate_argument_struct_manual( i, arg, args_declared_type[i] )
                elif self.is_valid_structure( arg ):
                    self.generate_argument_struct_automatic( i, arg, args_declared_type[i] )
                elif arg in js_types_conversions:
                    t = js_types_conversions[arg]
                    self.mm_file.write( '\tok &= %s( cx, *argvp++, &arg%d );\n' % ( t[1], i ) )
                elif arg in js_special_type_conversions:
                    js_special_type_conversions[arg][0]( i, arg, args_declared_type[i] )
                else:
                    raise ParseException('Unsupported argument type: %s' % arg )

                if optional_args!=None and i >= optional_args:
                    self.mm_file.write('\t}\n' )

        self.mm_file.write('\tif( ! ok ) return JS_FALSE;\n');


    def generate_method_prefix( self, class_name, method, num_of_args, method_type ):
        # JSPROXY_CCNode, setPosition
        # "!" or ""
        # proxy.initialized = YES (or nothing)
        template_methodname = '''
JSBool %s_%s%s(JSContext *cx, uint32_t argc, jsval *vp) {
'''
        template_init = '''
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);

	NSCAssert( proxy && %s[proxy realObj], @"Invalid Proxy object");
'''

        selector = method['selector']
        converted_name = self.convert_selector_name_to_native( selector )

        # method name
        class_method = '_static' if self.is_class_method(self.current_method) else ''
        self.mm_file.write( template_methodname % ( PROXY_PREFIX+class_name, converted_name, class_method ) )

        # method asserts for instance methods
        if method_type == METHOD_INIT or method_type == METHOD_REGULAR:
            assert_init = '!' if method_type == METHOD_INIT else ''
            self.mm_file.write( template_init % assert_init )

        try:
            # Does it have optional arguments ?
            properties = self.method_properties[class_name][selector]
            min_args = properties.get('min_args', None)
            max_args = properties.get('max_args', None)
            if min_args != max_args:
                method_assert_on_arguments = '\tJSB_PRECONDITION( argc >= %d && argc <= %d , @"Invalid number of arguments" );\n' % (min_args, max_args)
            elif 'variadic_2_array' in properties:
                method_assert_on_arguments = '\tJSB_PRECONDITION( argc >= 0, @"Invalid number of arguments" );\n'
            else:
                # default
                method_assert_on_arguments = '\tJSB_PRECONDITION( argc == %d, @"Invalid number of arguments" );\n' % num_of_args
        except KeyError, e:
            # No, it only has required arguments
            method_assert_on_arguments = '\tJSB_PRECONDITION( argc == %d, @"Invalid number of arguments" );\n' % num_of_args
        self.mm_file.write( method_assert_on_arguments )


    def generate_method_suffix( self ):
        end_template = '''
	return JS_TRUE;
}
'''
        self.mm_file.write( end_template )


    def generate_method( self, class_name, method ):

        s = method['selector']

        if self.get_method_property( class_name, s, 'manual' ):
            sys.stderr.write('Ignoring method %s # %s. It should be manually generated' % (class_name, s ) )
            return True

        # Variadic methods are not supported
        if 'variadic' in method and method['variadic'] == 'true':
            raise ParseException('variadic arguemnts not supported.')

        # Skip 'callback' and 'ignore' methods
        try:
            if 'callback' in self.method_properties[class_name][s]:
                raise ParseException( 'Method defined as callback. Ignoring.' )
            if 'ignore' in self.method_properties[class_name][s]:
                raise ParseException( 'Explicity ignoring method' )
        except KeyError, e:
            pass

        args_js_type, args_declared_type = self.validate_arguments( method )
        ret_js_type, ret_declared_type = self.validate_retval( method, class_name )

        method_type = self.get_method_type( method )

        num_of_args = len( args_declared_type )

        # writes method description
        self.mm_file.write( '\n// Arguments: %s\n// Ret value: %s (%s)' % ( ', '.join(args_declared_type), ret_declared_type, ret_js_type ) )

        self.generate_method_prefix( class_name, method, num_of_args, method_type )

        try:
            properties = self.method_properties[class_name][method['selector']]
        except KeyError, e:
            properties = {}

        # Optional Args ?
        min_args = properties.get('min_args', None)
        max_args = properties.get('max_args', None)
        if min_args != max_args:
            optional_args = min_args
        else:
            optional_args = None

        total_args = self.get_number_of_arguments( method )
        if total_args > 0:
            self.generate_arguments( args_declared_type, args_js_type, properties )

        if ret_js_type:
            self.mm_file.write( '\t%s ret_val;\n' % (ret_declared_type ) )

        if optional_args != None:
            else_str = ''
            for i in xrange(max_args+1):
                if i in properties['calls']:
                    call_real = self.generate_method_call_to_real_object( properties['calls'][i], i, ret_js_type, args_declared_type, class_name, method_type )
                    self.mm_file.write( '\n\t%sif( argc == %d ) {\n\t%s\n\t}' % ( else_str, i, call_real) )
                    else_str = 'else '
            self.mm_file.write( '\n\telse\n\t\treturn JS_FALSE;\n\n' )
        else:
            call_real = self.generate_method_call_to_real_object( s, num_of_args, ret_js_type, args_declared_type, class_name, method_type )
            self.mm_file.write( '\n%s\n' % call_real )

        ret_string = self.generate_retval( ret_declared_type, ret_js_type )
        if not ret_string:
            raise ParseException('invalid return string')

        self.mm_file.write( ret_string )

        self.generate_method_suffix()

        return True

    def generate_methods( self, class_name, klass ):
        ok_methods = []
        ok_method_name = []

        # Parse methods defined in the Class
        self.is_a_protocol = False
        for m in klass['method']:
            self.current_method = m

            try:
                self.generate_method( class_name, m )
                ok_methods.append( m )
                ok_method_name.append( m['selector'] )
            except ParseException, e:
                sys.stderr.write( 'NOT OK: "%s#%s" Error: %s\n' % ( class_name, m['selector'], str(e) ) )

        self.current_method = None

        self.is_a_protocol = True

        # Parse methods defined in the Protocol
        if class_name in self.hierarchy:
            list_of_protocols = self.bs['signatures']['informal_protocol']
            protocols = self.hierarchy[ class_name ]['protocols']
            for protocol in protocols:
                for p in list_of_protocols:
                    # XXX Super slow
                    if p['name'] == protocol:

                        # Get the method object
                        for m in p['method']:
                            method_name = m['selector']

                            # avoid possible duplicates between Protocols and Classes
                            if not method_name in ok_method_name:
                                self.current_method = m
                                try:
                                    ok = self.generate_method( class_name, m )
                                    ok_methods.append( m )
                                    ok_method_name.append( m['selector'] )
                                except ParseException, e:
                                    sys.stderr.write( 'NOT OK: "%s#%s" Error: %s\n' % ( class_name, m['selector'], str(e) ) )

        # Parse class methods from base classes
        if self.inherit_class_methods:
            parent = self.get_parent_class( class_name )
            while (parent != None) and (not parent in self.classes_to_ignore):
                class_methods = self.get_class_method( parent )
                for cm in class_methods:
                    if not cm['selector'] in ok_method_name:
                        self.current_method = cm
                        try:
                            ok = self.generate_method( class_name, cm )
                            ok_methods.append( cm )
                            ok_method_name.append( cm['selector'] )
                        except ParseException, e:
                            sys.stderr.write( 'NOT OK: "%s#%s" Error: %s\n' % ( class_name, cm['selector'], str(e) ) )
                parent = self.get_parent_class( parent )

        self.current_method = None
        self.is_a_protocol = False

        return ok_methods

    def generate_class_mm_prefix( self ):
        import_template = '''
// needed for callbacks from objective-c to JS
#import <objc/runtime.h>
#import "JRSwizzle.h"

#import "jstypedarray.h"
#import "js_bindings_config.h"
#import "ScriptingCore.h"

#import "%s%s_classes.h"

'''
        self.generate_autogenerate_prefix( self.mm_file )
        self.mm_file.write( import_template % (BINDINGS_PREFIX, self.namespace) )

    def generate_pragma_mark( self, class_name, fd ):
        pragm_mark = '''
/*
 * %s
 */
#pragma mark - %s
'''
        fd.write( pragm_mark % (class_name, class_name) )

    def generate_class_header_prefix( self ):
        self.generate_autogenerate_prefix( self.h_file )
        for i in self.import_files:
            if i and i != '':
                self.h_file.write('#import "%s"\n' % i )

    def generate_class_header( self, class_name, parent_name ):
        # JSPROXXY_CCNode
        # manual_methods
        # JSPROXXY_CCNode
        # JSPROXY_CCNode, JSPROXY_NSObject
        header_template = '''

#ifdef __cplusplus
extern "C" {
#endif

void %s_createClass(JSContext *cx, JSObject* globalObj, const char* name );

%s

extern JSObject *%s_object;
extern JSClass *%s_class;

#ifdef __cplusplus
}
#endif


/* Proxy class */
@interface %s : %s
{
}
'''
        header_template_end = '''
@end
'''
        proxy_class_name = '%s%s' % (PROXY_PREFIX, class_name )

        self.generate_pragma_mark( class_name, self.h_file )

        manual = ''
        if class_name in self.manual_methods:
            manual += '// Manually generated methods\n'
            tmp = 'JSBool %s_%s%s(JSContext *cx, uint32_t argc, jsval *vp);\n'

            for method_name in self.manual_methods[class_name]:
                method = self.get_method( class_name, method_name )
                class_method = '_static' if self.is_class_method(method) else ''
                n = self.convert_selector_name_to_native( method_name )
                manual += tmp % (proxy_class_name, n, class_method )


        self.h_file.write( header_template % (  proxy_class_name,
                                                manual,
                                                proxy_class_name,
                                                proxy_class_name,
                                                proxy_class_name, PROXY_PREFIX + parent_name  ) )
        # callback code should be added here
        self.h_file.write( header_template_end )

    def generate_callback_args( self, method ):
        no_args ='jsval *argv = NULL; unsigned argc=0;\n'
        with_args = '''unsigned argc=%d;
			jsval argv[%d];
'''

        convert = {
            'i' : 'INT_TO_JSVAL(%s);',
            'c' : 'INT_TO_JSVAL(%s);',
            'b' : 'BOOLEAN_TO_JSVAL(%s);',
            'f' : 'DOUBLE_TO_JSVAL(%s);',
            'd' : 'DOUBLE_TO_JSVAL(%s);',
        }

        #
        # XXX Only supports a limited amount of parameters
        # XXX generate_retval should be reused
        #
        if 'arg' in method:
            args_len = self.get_number_of_arguments( method )
            for i,arg in enumerate( method['arg'] ):
                t = arg['type'].lower()
                dt = arg['declared_type']

                if dt[-1] == '*':
                    dt = dt[:-1]

                if t in convert:
                    tmp = convert[t] % arg['name']
                    with_args += "			argv[%d] = %s\n" % (i,tmp)
                elif dt == 'NSSet':
                    with_args += "			argv[%d] = NSSet_to_jsval( cx, %s );\n" % (i, arg['name'] )
                elif t == '@' and (dt in self.supported_classes or dt in self.class_manual):
                    with_args += "			argv[%d] = OBJECT_TO_JSVAL( get_or_create_jsobject_from_realobj( cx, %s ) );\n" % (i, arg['name'] )
                else:
                    with_args += '			argv[%d] = JSVAL_VOID; // XXX TODO Value not supported (%s) \n' % (i, dt)

            return with_args % (args_len, args_len)
        return no_args


    def generate_implementation_callback( self, class_name ):
        # BOOL ccMouseUp NSEvent*
        # ccMouseUp
        # ccMouseUp
        template = '''
-(%s) %s
{
	if (_jsObj) {
		JSContext* cx = [[ScriptingCore sharedInstance] globalContext];
		JSBool found;
		JS_HasProperty(cx, _jsObj, "%s", &found);
		if (found == JS_TRUE) {
			jsval rval, fval;
			%s
			JS_GetProperty(cx, _jsObj, "%s", &fval);
			JS_CallFunctionValue(cx, _jsObj, fval, argc, argv, &rval);
		}
	}
}
'''
        if class_name in self.callback_methods:
            for m in self.callback_methods[ class_name ]:

                method = self.get_method( class_name, m )
                full_args, args = self.get_callback_args_for_method( method )
                js_retval, dt_retval = self.validate_retval( method, class_name )

                converted_args = self.generate_callback_args( method )

                js_name = self.convert_selector_name_to_js( class_name, m )
                self.mm_file.write( template % ( dt_retval, full_args,
                                                 js_name,
                                                 converted_args,
                                                 js_name ) )

    def generate_implementation_swizzle( self, class_name ):
        # CCNode
        # CCNode
        template_prefix = '''
+(void) swizzleMethods
{
	[super swizzleMethods];

	static BOOL %s_already_swizzled = NO;
	if( ! %s_already_swizzled ) {
		NSError *error;
'''
        # CCNode, onEnter, onEnter
        template_middle = '''
		if( ! [%s jr_swizzleMethod:@selector(%s) withMethod:@selector(JSHook_%s) error:&error] )
			NSLog(@"Error swizzling %%@", error);
'''
        # CCNode
        template_suffix = '''
		%s_already_swizzled = YES;
	}
}
'''

        if class_name in self.callback_methods:
            self.mm_file.write(  template_prefix % ( class_name, class_name ) )
            for m in self.callback_methods[ class_name ]:

                if not self.get_method_property( class_name, m, 'no_swizzle' ):
                    self.mm_file.write( template_middle % ( class_name, m, m ) )

            self.mm_file.write(  template_suffix % ( class_name ) )

    def generate_implementation( self, class_name ):

        create_object_template_prefix = '''
+(JSObject*) createJSObjectWithRealObject:(id)realObj context:(JSContext*)cx
{
	JSObject *jsobj = JS_NewObject(cx, %s_class, %s_object, NULL);
	%s *proxy = [[%s alloc] initWithJSObject:jsobj class:[%s class]];
	[proxy setRealObj:realObj];

	if( realObj ) {
		objc_setAssociatedObject(realObj, &JSPROXY_association_proxy_key, proxy, OBJC_ASSOCIATION_RETAIN);
		[proxy release];
	}

	[self swizzleMethods];
'''

        create_object_template_suffix = '''
	return jsobj;
}
'''
        proxy_class_name = '%s%s' % (PROXY_PREFIX, class_name )

        self.mm_file.write( '\n@implementation %s\n' % proxy_class_name )

        self.mm_file.write( create_object_template_prefix % (proxy_class_name, proxy_class_name,
                                                             proxy_class_name, proxy_class_name,
                                                             class_name
                                                             ) )

        self.mm_file.write( create_object_template_suffix )

        self.generate_implementation_swizzle( class_name )

        self.generate_implementation_callback( class_name )

        self.mm_file.write( '\n@end\n' )

    def generate_createClass_function( self, class_name, parent_name, ok_methods ):
        # 1-12: JSPROXY_CCNode
        implementation_template = '''
void %s_createClass(JSContext *cx, JSObject* globalObj, const char* name )
{
	%s_class = (JSClass *)calloc(1, sizeof(JSClass));
	%s_class->name = name;
	%s_class->addProperty = JS_PropertyStub;
	%s_class->delProperty = JS_PropertyStub;
	%s_class->getProperty = JS_PropertyStub;
	%s_class->setProperty = JS_StrictPropertyStub;
	%s_class->enumerate = JS_EnumerateStub;
	%s_class->resolve = JS_ResolveStub;
	%s_class->convert = JS_ConvertStub;
	%s_class->finalize = %s_finalize;
//	%s_class->flags = JSCLASS_HAS_PRIVATE;
'''

        # Properties
        properties_template = '''
	static JSPropertySpec properties[] = {
		{0, 0, 0, 0, 0}
	};
'''
        functions_template_start = '\tstatic JSFunctionSpec funcs[] = {\n'
        functions_template_end = '\t\tJS_FS_END\n\t};\n'

        static_functions_template_start = '\tstatic JSFunctionSpec st_funcs[] = {\n'
        static_functions_template_end = '\t\tJS_FS_END\n\t};\n'

        # 1: JSPROXY_CCNode
        # 2: JSPROXY_NSObject
        # 3-4: JSPROXY_CCNode
        init_class_template = '''
	%s_object = JS_InitClass(cx, globalObj, %s_object, %s_class, %s_constructor,0,properties,funcs,NULL,st_funcs);
}
'''
        proxy_class_name = '%s%s' % (PROXY_PREFIX, class_name )
        proxy_parent_name = '%s%s' % (PROXY_PREFIX, parent_name )

        self.mm_file.write( implementation_template % ( proxy_class_name,
                                                        proxy_class_name, proxy_class_name, proxy_class_name,
                                                        proxy_class_name, proxy_class_name, proxy_class_name,
                                                        proxy_class_name, proxy_class_name, proxy_class_name,
                                                        proxy_class_name, proxy_class_name, proxy_class_name ) )

        self.mm_file.write( properties_template )

        js_fn = '\t\tJS_FN("%s", %s, %d, JSPROP_PERMANENT | JSPROP_SHARED %s),\n'

        instance_method_buffer = ''
        class_method_buffer = ''
        for method in ok_methods:

            num_args = self.get_number_of_arguments( method )

            class_method = '_static' if self.is_class_method(method) else ''

            js_name = self.convert_selector_name_to_js( class_name, method['selector'] )
            cb_name = self.convert_selector_name_to_native( method['selector'] )

            if self.is_class_constructor( method ):
                entry = js_fn % (js_name, proxy_class_name + '_' + cb_name + class_method, num_args, '| JSPROP_ENUMERATE' ) # | JSFUN_CONSTRUCTOR
            else:
                entry = js_fn % (js_name, proxy_class_name + '_' + cb_name + class_method, num_args, '| JSPROP_ENUMERATE' )

            if self.is_class_method( method ):
                class_method_buffer += entry
            else:
                instance_method_buffer += entry

        # instance methods entry point
        self.mm_file.write( functions_template_start )
        self.mm_file.write( instance_method_buffer )
        self.mm_file.write( functions_template_end )

        # class methods entry point
        self.mm_file.write( static_functions_template_start )
        self.mm_file.write( class_method_buffer )
        self.mm_file.write( static_functions_template_end )

        self.mm_file.write( init_class_template % ( proxy_class_name, proxy_parent_name, proxy_class_name, proxy_class_name ) )

    def generate_callback_code( self, class_name ):
        # CCNode
        template_prefix = '@implementation %s (SpiderMonkey)\n'

        # BOOL - ccMouseUp:(NSEvent*)
        # PROXYJS_CCNode
        template = '''
-(%s) %s%s
{
%s
	%s *proxy = objc_getAssociatedObject(self, &JSPROXY_association_proxy_key);
	if( proxy )
		[proxy %s];
}
'''
        template_suffix = '@end\n'

        proxy_class_name = PROXY_PREFIX + class_name

        if class_name in self.callback_methods:

            self.mm_file.write( template_prefix % class_name )
            for m in self.callback_methods[ class_name ]:

                real_method = self.get_method( class_name,m )
                fullargs, args = self.get_callback_args_for_method( real_method )
                js_ret_val, dt_ret_val = self.validate_retval(  real_method, class_name )

                if not self.get_method_property( class_name, m, 'no_swizzle' ):
                    swizzle_prefix = 'JSHook_'
                    call_native ='\t//1st call native, then JS. Order is important\n\t[self JSHook_%s];'% (args)
                else:
                    swizzle_prefix = ''
                    call_native = ''
                self.mm_file.write( template % ( dt_ret_val, swizzle_prefix, fullargs,
                                                 call_native,
                                                 proxy_class_name,
                                                 args
                                                 ) )

            self.mm_file.write( template_suffix )

    def generate_class_mm( self, klass, class_name, parent_name ):

        self.generate_pragma_mark( class_name, self.mm_file )
        self.generate_constructor( class_name )
        self.generate_destructor( class_name )

        ok_methods = self.generate_methods( class_name, klass )

        self.generate_createClass_function( class_name, parent_name, ok_methods )
        self.generate_implementation( class_name )

        self.generate_callback_code( class_name )

    def generate_class_binding( self, class_name ):

        # Ignore NSObject. Already registerd
        if not class_name or class_name in self.classes_to_ignore or class_name in self.parsed_classes:
            return

        parent = self.hierarchy[class_name]['subclass']
        self.generate_class_binding( parent )

        self.parsed_classes.append( class_name )

        signatures = self.bs['signatures']
        classes = signatures['class']
        klass = None

        parent_name = self.hierarchy[ class_name ]['subclass']

        # XXX: Super slow. Add them into a dictionary
        for c in classes:
            if c['name'] == class_name:
                klass = c
                break

        if not klass:
            raise Exception("Class not found: '%s'. Check file: '%s'" % (class_name, self.bridgesupport_files ) )

        methods = klass['method']

        proxy_class_name = '%s%s' % (PROXY_PREFIX, class_name )

        self.generate_class_mm( klass, class_name, parent_name )
        self.generate_class_header( class_name, parent_name )

    def generate_class_registration( self, klass ):
        # only supported classes
        if not klass or klass in self.classes_to_ignore or klass in self.class_manual:
            return

        if not klass in self.classes_registered:
            parent = self.hierarchy[klass]['subclass']
            self.generate_class_registration( parent )

            class_name = self.convert_class_name_to_js( klass )

            self.class_registration_file.write('%s%s_createClass(_cx, %s, "%s");\n' % ( PROXY_PREFIX, klass, self.namespace, class_name ) )
            self.classes_registered.append( klass )

    def generate_classes_registration( self ):

        self.classes_registered = []

        self.class_registration_file = open( '%s%s_classes_registration.h' % (BINDINGS_PREFIX, self.namespace), 'w' )
        self.generate_autogenerate_prefix( self.class_registration_file )

        for klass in self.supported_classes:
            self.generate_class_registration( klass )

        self.class_registration_file.close()

    def generate_function_mm_prefix( self ):
        import_template = '''
#import "jstypedarray.h"
#import "ScriptingCore.h"
#import "js_manual_conversions.h"
#import "js_bindings_config.h"
#import "%s%s_functions.h"
'''
        self.generate_autogenerate_prefix( self.mm_file )
        self.mm_file.write( import_template % (BINDINGS_PREFIX, self.namespace) )

    def generate_function_header_prefix( self ):
        self.generate_autogenerate_prefix( self.h_file )
        self.h_file.write('''
#ifdef __cplusplus
extern "C" {
#endif
''')

    def generate_function_header_suffix( self ):
        self.h_file.write('''
#ifdef __cplusplus
}
#endif
''')

    def generate_function_declaration( self, func_name ):
        # JSPROXY_ccDrawPoint
        template_funcname = 'JSBool %s%s(JSContext *cx, uint32_t argc, jsval *vp);\n'
        self.h_file.write( template_funcname % ( PROXY_PREFIX, func_name ) )

    def generate_function_call_to_real_object( self, func_name, num_of_args, ret_js_type, args_declared_type ):

        if ret_js_type:
            prefix = '\tret_val = %s(' % func_name
        else:
            prefix = '\t%s(' % func_name

        call = ''

        for i,dt in enumerate(args_declared_type):
            # cast needed to prevent compiler errors
            if i >0:
                call += ', '
            call += '(%s)arg%d ' % (dt, i)

        call += ' );';

        return '%s%s' % (prefix, call )

    def generate_function_prefix( self, func_name, num_of_args ):
        # JSPROXY_ccDrawPoint
        template_funcname = '''
JSBool %s%s(JSContext *cx, uint32_t argc, jsval *vp) {
'''
        self.mm_file.write( template_funcname % ( PROXY_PREFIX, func_name ) )

        # Number of arguments
        self.mm_file.write( '\tJSB_PRECONDITION( argc == %d, @"Invalid number of arguments" );\n' % num_of_args )

    def generate_function_suffix( self ):
        end_template = '''
	return JS_TRUE;
}
'''
        self.mm_file.write( end_template )

    def generate_function_binding( self, function ):

        func_name = function['name']

        # Don't generate functions that are defined as callbacks
        if func_name in self.callback_functions:
            raise ParseException('Function defined as callback. Ignoring %s' % func_name)

        args_js_type, args_declared_type = self.validate_arguments( function )
        ret_js_type, ret_declared_type = self.validate_retval( function )

        num_of_args = len( args_declared_type )

        # writes method description
        self.mm_file.write( '\n// Arguments: %s\n// Ret value: %s' % ( ', '.join(args_declared_type), ret_declared_type ) )

        self.generate_function_prefix( func_name, num_of_args )

        if len(args_js_type) > 0:
            self.generate_arguments( args_declared_type, args_js_type );

        if ret_js_type:
            self.mm_file.write( '\t%s ret_val;\n' % ret_declared_type )

        call_real = self.generate_function_call_to_real_object( func_name, num_of_args, ret_js_type, args_declared_type )
        self.mm_file.write( '\n%s\n' % call_real )

        ret_string = self.generate_retval( ret_declared_type, ret_js_type )
        if not ret_string:
            raise ParseException('invalid return string')

        self.mm_file.write( ret_string )

        self.generate_function_suffix()

        return True

    def generate_function_registration( self, func_name ):

        function = None
        for func in self.bs['signatures']['function']:
            if func['name'] == func_name:
                function = func
                break

        num_args = self.get_number_of_arguments( function )
        template = 'JS_DefineFunction(_cx, %s, "%s", %s, %d, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );\n' % \
                 ( self.namespace,
                   self.convert_function_name_to_js( func_name),
                   PROXY_PREFIX + func_name,
                   num_args )

        self.function_registration_file.write( template )

    def generate_functions_registration( self ):

        self.function_registration_file = open( '%s%s_functions_registration.h' % (BINDINGS_PREFIX, self.namespace), 'w' )
        self.generate_autogenerate_prefix( self.function_registration_file )

        for func in self.functions_bound:
            self.generate_function_registration( func )

        self.function_registration_file.close()


    def generate_bindings( self ):

        #
        # Classes
        #

        # is there any class to register
        if 'class' in self.bs['signatures']:

            self.h_file = open( '%s%s_classes.h' % ( BINDINGS_PREFIX, self.namespace), 'w' )
            self.generate_class_header_prefix()
            self.mm_file = open( '%s%s_classes.mm' % (BINDINGS_PREFIX, self.namespace), 'w' )
            self.generate_class_mm_prefix()

            for klass in self.classes_to_bind:
                self.generate_class_binding( klass )

            self.h_file.close()
            self.mm_file.close()

            self.generate_classes_registration()


        #
        # Free Functions
        #

        # Is there any function to register:
        if 'function' in self.bs['signatures']:

            self.h_file = open( '%s%s_functions.h' % ( BINDINGS_PREFIX, self.namespace), 'w' )
            self.generate_function_header_prefix()
            self.mm_file = open( '%s%s_functions.mm' % (BINDINGS_PREFIX, self.namespace), 'w' )
            self.generate_function_mm_prefix()

            for f in self.bs['signatures']['function']:
                if f['name'] in self.functions_to_bind:
                    try:
                        self.generate_function_binding( f )
                        self.generate_function_declaration( f['name'] )
                        self.functions_bound.append( f['name'] )
                    except ParseException, e:
                        sys.stderr.write( 'NOT OK: "%s" Error: %s\n' % (  f['name'], str(e) ) )

            self.generate_function_header_suffix()
            self.h_file.close()
            self.mm_file.close()

            self.generate_functions_registration()

    def parse( self ):
        self.generate_bindings()

def help():
    print "%s v0.1 - Script that generates glue code between Objective-C and Javascript (Spidermonkey)" % sys.argv[0]
    print "Usage:"
    print "\t-c --config-file\tConfiguration file needed to generate the glue code."
    print "\nExample:"
    print "\t%s -c cocos2d-config.ini" % sys.argv[0]
    sys.exit(-1)

if __name__ == "__main__":
    if len( sys.argv ) == 1:
        help()

    configfile = None

    argv = sys.argv[1:]
    try:
        opts, args = getopt.getopt(argv, "c:", ["config-file="])

        for opt, arg in opts:
            if opt in ("-c", "--config-file"):
                configfile = arg
    except getopt.GetoptError,e:
        print e
        opts, args = getopt.getopt(argv, "", [])

    if args == None:
        help()

    SpiderMonkey.parse_config_file( configfile )