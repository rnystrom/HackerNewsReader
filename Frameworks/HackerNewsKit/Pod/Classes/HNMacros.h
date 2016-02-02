//
//  HNMacros.h
//  HackerNewsKit
//
//  Created by Ryan Nystrom on 1/18/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#define EQUAL_HELPER(comp, key) _EQUAL_HELPER(comp, key, isEqual)

#define EQUAL_STRING_HELPER(comp, key) _EQUAL_HELPER(comp, key, isEqualToString)

#define EQUAL_ARRAY_HELPER(comp, key) _EQUAL_HELPER(comp, key, isEqualToArray)

#define EQUAL_DICTIONARY_HELPER(comp, key) _EQUAL_HELPER(comp, key, isEqualToArray)

#define _EQUAL_HELPER(comp, key, sel) (BOOL)^{ \
id val1 = [self key]; \
id val2 = [comp key]; \
return (val1 == val2) || [val1 sel:val2]; \
}()
