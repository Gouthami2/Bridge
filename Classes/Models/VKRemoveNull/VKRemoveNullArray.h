//
//  VKRemoveNullArray.h
//  linphone
//
//  Created by Gouthami Reddy on 2/1/18.
//

#import <Foundation/Foundation.h>

@interface VKRemoveNullArray : NSObject

// array filters methods...
- (NSMutableArray *)filterNullsArray:(NSArray *)loArr WithEmpty:(BOOL)sucess;

@end
