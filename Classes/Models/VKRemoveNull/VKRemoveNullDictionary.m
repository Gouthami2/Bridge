//
//  VKRemoveNullDictionary.m
//  linphone
//
//  Created by Gouthami Reddy on 2/1/18.
//

#import "VKRemoveNullDictionary.h"
#import "VKRemoveNullArray.h"

@implementation VKRemoveNullDictionary

// filters all nulls element from dictionary...
- (NSMutableDictionary *)filterNullsDictionary:(NSDictionary *)loDict WithEmpty:(BOOL)sucess {
    
    NSMutableDictionary *removeDict = [loDict mutableCopy];
    for (NSString * key in [removeDict allKeys]) {
        
        // if elements contains array...
        if ([[removeDict objectForKey:key] isKindOfClass:[NSArray class]] ||
            [[removeDict objectForKey:key] isKindOfClass:[NSMutableArray class]]) {
            
            // filtering child array...
            VKRemoveNullArray *nullArray = [[VKRemoveNullArray alloc] init];
            NSMutableArray *finalArray = [nullArray filterNullsArray:[removeDict objectForKey:key] WithEmpty:sucess];
            [removeDict setObject:finalArray forKey:key];
            
            //NSLog(@"Dictionary Class - Array...");
        }
        // if elements contains dictionary...
        else if ([[removeDict objectForKey:key] isKindOfClass:[NSDictionary class]] ||
                 [[removeDict objectForKey:key] isKindOfClass:[NSMutableDictionary class]]) {
            
            // filtering child dictionary...
            VKRemoveNullDictionary *nullDict = [[VKRemoveNullDictionary alloc] init];
            NSMutableDictionary *finalDict = [nullDict filterNullsDictionary:[removeDict objectForKey:key] WithEmpty:sucess];
            [removeDict setObject:finalDict forKey:key];
            
            //NSLog(@"Dictionary Class - Dictionary...");
        }
        // if elements contains number...
        else if ([[removeDict objectForKey:key] isKindOfClass:[NSNumber class]]) {
            //NSLog(@"Number....");
        }
        // if elements contains string...
        else {
            if (sucess)
                [removeDict setObject:[self filterNullsString_Empty:[removeDict objectForKey:key]] forKey:key];
            else
                [removeDict setObject:[self filterNullsString:[removeDict objectForKey:key]] forKey:key];
        }
    }
    return removeDict;
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
