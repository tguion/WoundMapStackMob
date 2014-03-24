//
//  NSObject+FFSerializerSugar.h
//  FF-IOS-Framework
//
//  Created by Gary on 22/03/2014.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (FFSerializerSugar)

/**
 Implement this method in a model class if you wish a property NOT to be serialized for saving to the server
 */
- (BOOL) ff_shouldSerialize:(NSString *)propertyName;

/**
 Implement this method in a model class if you wish a property to be serialized as a set of references
 */
- (BOOL) ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName;

@end
