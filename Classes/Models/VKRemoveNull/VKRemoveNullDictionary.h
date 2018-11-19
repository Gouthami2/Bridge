//
//  VKRemoveNullDictionary.h
//  linphone
//
//  Created by Gouthami Reddy on 2/1/18.
//

#import <Foundation/Foundation.h>

@interface VKRemoveNullDictionary : NSObject

// method filters methods...
- (NSMutableDictionary *)filterNullsDictionary:(NSDictionary *)loDict WithEmpty:(BOOL)sucess;

@end
