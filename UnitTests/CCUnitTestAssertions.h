#define CCAssertEqualStrings(a1, a2, format...) XCTAssertEqualObjects(a1, a2, format)

// TODO had to replace this macro due to compile errors in calling _XCTRegisterFailure.

//#define CCAssertEqualStrings(a1, a2, format...) \
//do { \
//    @try { \
//        id a1value = (a1); \
//        id a2value = (a2); \
//        if (a1value == a2value) continue; \
//        if ([a1value isKindOfClass:[NSString class]] && \
//        [a2value isKindOfClass:[NSString class]] && \
//        [a1value compare:a2value options:0] == NSOrderedSame) continue; \
//        _XCTRegisterFailure(_XCTFailureDescription(_XCTAssertion_EqualObjects, 0, @#a1, @#a2, a1value, a2value),format); \
//    } \
//    @catch (id exception) { \
//        _XCTRegisterFailure(_XCTFailureDescription(_XCTAssertion_EqualObjects, 1, @#a1, @#a2, [exception reason]),format); \
//    } \
//} while(0)
