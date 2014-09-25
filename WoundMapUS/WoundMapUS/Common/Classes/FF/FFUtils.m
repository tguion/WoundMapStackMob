//
//  FFUtils.m
//  FatFractal
//
//  Copyright (c) 2012 FatFractal, Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "FFUtils.h"

@implementation FFUtils

static NSMutableDictionary * _ffClassPropsDict;

+ (void)addPropsToDict:(NSDictionary *)dict forClass:(Class) class {
    NSString *className = [NSString stringWithCString:class_getName(class) encoding:NSUTF8StringEncoding];
    
    if (! class || [className isEqualToString:@"NSObject"])
        return;
    
    // do superclass
    [self addPropsToDict:dict forClass:class_getSuperclass(class)];
    
    unsigned int numProps;
    objc_property_t *props = class_copyPropertyList(class, &numProps);
    for (int i = 0; i < numProps; i++) {
        NSString *propName = [[NSString alloc] initWithCString:property_getName(props[i]) encoding:NSUTF8StringEncoding];
        const char * targAttr = property_getAttributes(class_getProperty(class, [propName UTF8String]));
        NSString *propAttributes = [[NSString alloc] initWithFormat:@"%s", targAttr];
        [dict setValue:propAttributes forKey:propName];
    }
    free(props);
}

+ (NSDictionary *) propertiesForClass:(Class)class {
    if (! _ffClassPropsDict)
        _ffClassPropsDict = [[NSMutableDictionary alloc] init];
    
    NSString *className = [NSString stringWithCString:class_getName(class) encoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict = [_ffClassPropsDict valueForKey:className];
    if (dict)
        return dict;
    else {
        dict = [[NSMutableDictionary alloc] init];
        [_ffClassPropsDict setValue:dict forKey:className];
        [self addPropsToDict:dict forClass:class];
        //        NSLog(@"propertiesForClass created properties cache for class %@ - %d properties found",
        //              className, [dict count]);
        return dict;
    }
}

+ (id) valueOf:(id)o forKey:(id)key {
    id v = [o valueForKey:key];
    
    if ([v isKindOfClass:[NSDate class]])
        v = [NSNumber numberWithLongLong:(long long)([(NSDate *)v timeIntervalSince1970] * 1000.0)];
    
    if ([v isKindOfClass:[NSNumber class]])
        return [[NSDecimalNumber alloc] initWithString:[v stringValue]];
    
    return v;
}

+ (BOOL) value1:(id)v1 isEqualTo:(id)v2 {
    if ([v1 class] == [v2 class])
        return [v1 isEqual:v2];
    
    if ([v1 isKindOfClass:[NSNumber class]]) {
        NSLog(@"Comparing as NSNumbers");
        return [v1 isEqualToNumber:v2];
    }
    
    return [v1 isEqual:v2];
}

+ (BOOL) object:(id)o1 hasEqualValuesTo:(id)o2 notEqualReason:(NSString **)reason {
    NSDictionary *p1 = [self propertiesForClass:[o1 class]];
    NSDictionary *p2 = [self propertiesForClass:[o2 class]];
    if (! [[p1 allKeys] isEqualToArray:[p2 allKeys]])
        return false;
    if (! [[p1 allValues] isEqualToArray:[p2 allValues]])
        return false;
    id key;
    for (key in [p1 allKeys]) {
        id val1 = [self valueOf:o1 forKey:key];
        id val2 = [self valueOf:o2 forKey:key];
        if ([val1 isKindOfClass:[NSNull class]] || val1 == nil) {
            if ([val2 isKindOfClass:[NSNull class]] || val2 == nil)
                continue;
            else
                return false;
        }
        
        if (! [self value1:val1 isEqualTo:val2]) {
            *reason = [[NSString alloc] initWithFormat:@"Key [%@] : val1(%@) [%@] val2(%@) [%@]", key, [val1 class], val1, [val2 class], val2];
            return false;
        }
    }
    return true;
}

@end
