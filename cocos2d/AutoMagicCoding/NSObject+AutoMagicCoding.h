//
//  NSObject+AutoMagicCoding.h
//  AutoMagicCoding
//  ( https://github.com/psineur/NSObject-AutomagicCoding/ )
//
//  31.08.11.
//  Copyright 2011 Stepan Generalov.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "objc/runtime.h"

/** Key for object's class name dictionaryRepresentation. 
 * Value for this key from dictionary representation used to get Class
 * with NSClassFromString().
 */
#define kAMCDictionaryKeyClassName @"class"

/** Current version of AutoMagicCoding. */
extern NSString *const AMCVersion; // = @"1.1"

/** Custom AMC NSException name for errors while encoding. */
extern NSString *const AMCEncodeException;
/** Custom AMC NSException name for errors while decoding. */
extern NSString *const AMCDecodeException;
/** Custom AMC NSException name for detected KVC bugs/failures (see issue #19). */
extern NSString *const AMCKeyValueCodingFailureException;

/** Object's fields types recoginzed by AMC. */
typedef enum 
{
    /** Scalar value (primitive type or PLIST-compatible non-collection Objects, 
     * like NSString and NSNumber), that can be saved to NSDictionary without any
     * modification of special encoding.
     */
    kAMCFieldTypeScalar, 
    
    /** Custom Class objects, derived from NSObject, that returns YES in +AMCEnabled. */
    kAMCFieldTypeCustomObject,
    
    /** NSDictionary-like objects, that responds to all selectors in AMCHashProtocol */
    kAMCFieldTypeCollectionHash, 
    
    /** NSMutableDictionary-like objects, that responds to all selectors in AMCHashMutableProtocol */
    kAMCFieldTypeCollectionHashMutable,
    
    /** NSArray-like objects, that responds to all selectors in AMCArrayProtocol */
    kAMCFieldTypeCollectionArray,
    
    /** NSMutableArray-like objects, that responds to all selectors in AMCArrayMutableProtocol */
    kAMCFieldTypeCollectionArrayMutable,
    
    /** C structures.  */
    kAMCFieldTypeStructure,
} AMCFieldType;


#pragma mark Collection Protocols

/** Protocol that describes selectors, which object must respond to in order to
 * be detected by AMC as Ordered Collection. 
 * Note: object must not conform to this protocol, only respond to it's selectors.
 */
@protocol AMCArrayProtocol <NSObject>

- (NSUInteger)count;
- (id) objectAtIndex:(NSUInteger) index; 
- (id) initWithArray:(NSArray *) array;

@end

/** Protocol that describes selectors, which object must respond to in order to
 * be detected as Mutable Ordered Collection.
 * It simply adds new methods to AMCArrayProtocol. 
 * Note: object must not conform to this protocol, only respond to it's selectors.
 */
@protocol AMCArrayMutableProtocol <AMCArrayProtocol>

- (void) addObject: (id) anObject;

@end

/** Protocol that describes selectors, which object must respond to in order to
 * be detected as Hash(NSDictionary-Like Key-Value) Collection. 
 * Note: object must not conform to this protocol, only respond to it's selectors.
 */
@protocol AMCHashProtocol <NSObject>

- (NSUInteger)count;
- (NSArray *) allKeys;
- (id) initWithDictionary: (NSDictionary *) aDict;

@end

/** Protocol that describes selectors, which object must respond to in order to
 * be detected as Mutable Hash(NSMutableDictionary-Like Key-Value) Collection. 
 * It simply adds new methods to AMCArrayProtocol. 
 * Note: object must not conform to this protocol, only respond to it's selectors.
 */
@protocol AMCHashMutableProtocol <AMCHashProtocol>

- (void) setObject: (id) anObject forKey:(NSString *) aKey;

@end

#pragma mark - AutoMagicCoding Interface 

/** @category AutoMagicCoding AMC Public Interface. Describes new methods,
 * added to NSObject by AMC, which you will need to use and/or reimplement
 * to support & use serialize/deserialize in your instances of NSObject subclasses.
 * @version 1.1
 */
@interface NSObject (AutoMagicCoding)

/** Used to choose how instances of that class should be treated when encoding/decoding
 * and should serialize/deserialize methods work or not.
 * Reimplement this method in your classes and return YES if you want to enable 
 * AutoMagicCoding for your class and it's subclasses.
 * Returns NO by default. 
 */
+ (BOOL) AMCEnabled;

#pragma mark Decode/Create/Init

/** Creates autoreleased object with given dictionary representation.
 * Returns nil, if aDict is nil or there's no class in your programm with name
 * provided in dict for key kAMCDictionaryKeyClassName.
 *
 * ATTENTION: Can throw exceptions - see README.md "Exceptions" part for details.
 * Define AMC_NO_THROW to disable throwing exceptions by this method and make
 * it return nil instead.
 *
 * @param aDict Dictionary that contains name of class NSString for
 * kAMCDictionaryKeyClassName key & all other values for keys in the saved object.
 */
+ (id) objectWithDictionaryRepresentation: (NSDictionary *) aDict;

/** Designated initializer for AMC. Treat it as something like -initWithCoder:
 * Inits object with key values from given dictionary.
 * Doesn't test objectForKey: kAMCDictionaryKeyClassName in aDict to be equal 
 * with [self className].
 *
 * ATTENTION: Can throw exceptions - see README.md "Exceptions" part for details.
 * Define AMC_NO_THROW to disable throwing exceptions by this method and make
 * it return nil instead.
 *
 * @param aDict Dictionary that contains name of class NSString for
 * kAMCDictionaryKeyClassName key & all other values for keys in the saved object.
 */
- (id) initWithDictionaryRepresentation: (NSDictionary *) aDict;

/** Works similar to -initWithDictionary: but sets only one value, loaded from
 * dictionary representation for given key.
 *
 * Can be very handy to load only some of values from dictionary representation
 * to pass them to existing class init methods.
 *
 * Uses KVC setValue:forKey: method to set value.
 *
 * ATTENTION: Can throw exceptions - see README.md "Exceptions" part for details.
 * Define AMC_NO_THROW to disable throwing exceptions by this method.
 *
 * @since v1.1
 */
- (void) loadValueForKey:(NSString *)key fromDictionaryRepresentation: (NSDictionary *) aDict;


#pragma mark Encode/Save

/** Encodes object and returns it's dictionary representation. 
 * If all encoded object's fields properly supports AMC - returned dictionary
 * can be writed to PLIST.
 * 
 * If you can't save returned dictionary to PLIST - it contains
 * non-PLIST-compatible objects, probably because some fields doesn't support AMC
 * and was treated as kAMCFieldTypeScalar.
 * Use "print description" to determine which objects was saved as scalar & add
 * AMC support for them.
 *
 * ATTENTION: Can throw exceptions - see README.md "Exceptions" part for details.
 * Define AMC_NO_THROW to disable throwing exceptions by this method and make
 * it return nil instead.
 */
- (NSDictionary *) dictionaryRepresentation;

#pragma mark Structure Support

/** Returns NSString representation of structure given in NSValue.
 *
 * Reimplement this method to support your own custom structs.
 * When reimplementing - use structName to detect your custom struct type & 
 * return [super AMCEncodeStructWithValue: value withName: structName] for 
 * all other struct names.
 * (See "Custom Struct Support" part in README.md for details).
 *
 * Default implementation encodes NS/CG Point, Size & Rect & returns nil if
 * structName is not equal to @"NSPoint", @"NSSize", @"NSRect", @"CGPoint", 
 * @"CGSize" or @"CGRect".
 *
 * @param structValue NSValue that holds structure to encode.
 *
 * @param structName Name of structure type to encode. 
 * In order to receive valid structName - your struct must be encoded/decoded
 * with name of it's property - not iVar name. (Issue #10)
 *
 * ATTENTION: Can throw exceptions - see README.md "Exceptions" part for details.
 * Even if AMC_NO_THROW is defined - this method can throw exceptions, that will 
 * be caught in -dictionaryRepresentation.
 *
 * You don't need to call this method directly, so don't add @try & @catch blocks to it.
 */
- (NSString *) AMCEncodeStructWithValue: (NSValue *) structValue withName: (NSString *) structName;

/** Decodes structure from given string & returns NSValue that is ready to be set 
 * with setValue:forKey:.
 *
 * Reimplement this method to support your own custom structs.
 * When reimplementing - use structName to detect you custom struct type & 
 * return [super AMCDecodeStructFromString: value withName: structName] for 
 * all other struct names.
 * (See "Custom Struct Support" part in README.md for details).
 *
 * @param value NSString representation of structure.
 *
 * @param structName Name of structure type to decode.
 * In order to receive valid structName - your struct must be encoded/decoded
 * with name of it's property - not iVar name. (Issue #10)
 *
 * ATTENTION: Can throw exceptions - see README.md "Exceptions" part for details.
 * Even if AMC_NO_THROW is defined - this method can throw exceptions, that will 
 * be caught in -initWithDictionaryRepresentation.
 *
 * You don't need to call this method directly, so don't add @try & @catch blocks to it.
 */
- (NSValue *) AMCDecodeStructFromString: (NSString *)value withName: (NSString *) structName;


#pragma mark Info for Serialization

/** Returns array of keys, that will be used to create dictionary representation.
 *
 * By default - uses list of all available properties in the object 
 * provided by Objective-C Runtime methods.
 * All properties declared by superclasses are included.
 * Keys order: from superClasses properties first, our object's properties last.
 * Inside of each class order: exactly how they was declared - from top
 * to bottom.
 * NSObject's properties are not included.
 * 
 * You can expand it with your custom non-property ivars, by appending your own
 * keys to keys that were returned by [super AMCKeysForDictionaryRepresentation]
 * or completely reimplement this method without any call to super - to return
 * only keys, that you want to encode/decode.
 */
- (NSArray *) AMCKeysForDictionaryRepresentation;

/** Returns field type for given key to save/load it in dictionaryRepresentation
 * as Scalar, CustomObject, Collection, etc...
 * Reimplement this method to add your custom ivar without properties. 
 *
 * ATTENTION: If you've added keys to -AMCKeysForDictionaryRepresentation for
 * iVars without properties - you must reimplement this method, or your iVars 
 * will be treated as kAMCFieldTypeScalar.
 *
 * Structs always must be used as properties in AMC (Issue #10) - do not
 * reimplement this method to support struct iVars - they will be treated
 * as structs, but AMC will fail to detect structName, which is needed to
 * encode/decode them as NSStrings properly.
 */
- (AMCFieldType) AMCFieldTypeForValueWithKey: (NSString *) aKey;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

/** Returns class name. Declared by AMC for iOS, on Mac declared in Foundation framework */
- (NSString *) className;
/** Returns class name. Declared by AMC for iOS, on Mac declared in Foundation framework. */
+ (NSString *) className;

#endif

@end

#pragma mark Encode/Decode Helper Functions

/** Returns value, prepared for -setValue:forKey: based on it's fieldType 
 * Recursively uses itself for objects in collections. 
 * You don't need to call this function directly.
 */
id AMCDecodeObject (id value, AMCFieldType fieldType, id collectionClass);

/** Returns object that can be added to dictionary for dictionaryRepresentation. 
 * You don't need to call this function directly.
 */
id AMCEncodeObject (id value, AMCFieldType fieldType);

#pragma mark Property Info Helper Functions

/** Returns Class of given property if it is a Objective-C object.
 * Otherwise returns nil.
 * You don't need to call this function directly.
 */
id AMCPropertyClass (objc_property_t property);

/** Returns name of struct, if given property type is struct.
 * Otherwise returns nil.
 * You don't need to call this function directly.
 */
NSString *AMCPropertyStructName(objc_property_t property);

#pragma mark Field Type Info Helper Functions

/** Tries to guess fieldType for given encoded object. Used in collections 
 * decoding to create objects in collections. 
 * You don't need to call this function directly.
 */
AMCFieldType AMCFieldTypeForEncodedObject(id object);

/** Returns fieldType for given not yet encoded object. 
 * You don't need to call this function directly.
 */
AMCFieldType AMCFieldTypeForObjectToEncode(id object);

/** Returns YES, if instances of given class respond to all required instance methods listed
 * in protocol p.
 * Otherwise returns NO;
 * You don't need to call this function directly.
 */
BOOL classInstancesRespondsToAllSelectorsInProtocol(id class, Protocol *p );


