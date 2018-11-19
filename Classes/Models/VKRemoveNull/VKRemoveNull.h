//
//  VKRemoveNull.h
//  linphone
//
//  Created by Gouthami Reddy on 2/1/18.
//

#import <Foundation/Foundation.h>

@interface VKRemoveNull : NSObject

// initialization...
+ (id)shared;

// filters dictionary - empty bool yes send "" string otherwise "NA" string
- (NSMutableDictionary *)filterNullsDictionary:(NSDictionary *)sendDictionary WithEmpty:(BOOL)suces;
- (NSMutableArray *)filterNullsArray:(NSArray *)sendArray WithEmpty:(BOOL)sucess;
- (NSString *)filterNullsString:(NSString *)previousString;
- (NSString *)filterNullsString_Empty:(NSString *)previousString;

@end
