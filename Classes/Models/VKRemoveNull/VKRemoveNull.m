//
//  VKRemoveNull.m
//  linphone
//
//  Created by Gouthami Reddy on 2/1/18.
//

#import "VKRemoveNull.h"
#import "VKRemoveNullArray.h"
#import "VKRemoveNullDictionary.h"

@implementation VKRemoveNull

// initialization of object...
+ (id)shared {
    
    static id instance_ = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance_ = [[self alloc] init];
    });
    return instance_;
}

// filters all nulls element from dictionary...
- (NSMutableDictionary *)filterNullsDictionary:(NSDictionary *)sendDictionary WithEmpty:(BOOL)sucess {
    
    // getting single dictionary elements...
    VKRemoveNullDictionary *nullDictObj = [[VKRemoveNullDictionary alloc] init];
    return [nullDictObj filterNullsDictionary:sendDictionary WithEmpty:sucess];
}

// filters all nulls element from array...
- (NSMutableArray *)filterNullsArray:(NSArray *)sendArray WithEmpty:(BOOL)sucess {
    
    // getting single array elements...
    VKRemoveNullArray *nullArrayObj = [[VKRemoveNullArray alloc] init];
    return [nullArrayObj filterNullsArray:sendArray WithEmpty:sucess];
}

// filters string if its contains null replace by the NA.
- (NSString *)filterNullsString:(NSString *)previousString {
    
    NSString *returnString = @"NA";
    
    @try {
        if (!previousString)
            return returnString;
        
        if ([previousString isKindOfClass:[NSNull class]])
            return returnString;
        
        if ([previousString isEqualToString:@"<nil>"])
            return returnString;
        
        if ([previousString isEqualToString:@"<null>"])
            return returnString;
        
        if ([previousString isEqualToString:@"NULL"])
            return returnString;
        
        if ([previousString isEqualToString:@"nil"])
            return returnString;
        
        if ([previousString isEqualToString:@"(null)"])
            return returnString;
        
        return previousString;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception :%@",exception);
        return returnString;
    }
}

// filters string if its contains null replace by the ""/empty.
- (NSString *)filterNullsString_Empty:(NSString *)previousString {
    
    NSString *returnString = @"";
    
    @try {
        if (!previousString)
            return returnString;
        
        if ([previousString isKindOfClass:[NSNull class]])
            return returnString;
        
        if ([previousString isEqualToString:@"<nil>"])
            return returnString;
        
        if ([previousString isEqualToString:@"<null>"])
            return returnString;
        
        if ([previousString isEqualToString:@"NULL"])
            return returnString;
        
        if ([previousString isEqualToString:@"nil"])
            return returnString;
        
        if ([previousString isEqualToString:@"(null)"])
            return returnString;
        
        return previousString;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception :%@",exception);
        return returnString;
    }
}

@end
