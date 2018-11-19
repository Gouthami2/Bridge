//
//  VKRemoveNullArray.m
//  linphone
//
//  Created by Gouthami Reddy on 2/1/18.
//

#import "VKRemoveNullArray.h"
#import "VKRemoveNullDictionary.h"

@implementation VKRemoveNullArray

// filters all nulls element from Array...
- (NSMutableArray *)filterNullsArray:(NSArray *)loArr WithEmpty:(BOOL)sucess {
    
    NSMutableArray *removeArr = [loArr mutableCopy];
    for (int i=0; i<[removeArr count]; i++) {
        
        // if elements contains array...
        if ([[removeArr objectAtIndex:i] isKindOfClass:[NSArray class]] ||
            [[removeArr objectAtIndex:i] isKindOfClass:[NSMutableArray class]]) {
        
            // filtering child array...
            VKRemoveNullArray *nullArray = [[VKRemoveNullArray alloc] init];
            NSMutableArray *finalArray = [nullArray filterNullsArray:[removeArr objectAtIndex:i] WithEmpty:sucess];
            [removeArr replaceObjectAtIndex:i withObject:finalArray];
            
            //NSLog(@"Array Class - Array...");
        }
        // if elements contains dictionary...
        else if ([[removeArr objectAtIndex:i] isKindOfClass:[NSDictionary class]] ||
                 [[removeArr objectAtIndex:i] isKindOfClass:[NSMutableDictionary class]]) {
            
            // filtering child dictionary...
            VKRemoveNullDictionary *nullDict = [[VKRemoveNullDictionary alloc] init];
            NSMutableDictionary *finalDict = [nullDict filterNullsDictionary:[removeArr objectAtIndex:i] WithEmpty:sucess];
            [removeArr replaceObjectAtIndex:i withObject:finalDict];
            
            //NSLog(@"Array Class - Dictionary...");
        }
        // if elements contains number...
        else if ([[removeArr objectAtIndex:i] isKindOfClass:[NSNumber class]]) {
            //NSLog(@"Number....");
        }
        // if elements contains string...
        else {
            [removeArr replaceObjectAtIndex:i withObject:[self filterNullsString:[removeArr objectAtIndex:i]]];
        }
    }

    return removeArr;
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
