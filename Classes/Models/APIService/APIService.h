//
//  APIService.h
//  linphone
//
//  Created by Gouthami Reddy on 11/14/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define ServerPath @"https://qa.onescreen.kotter.net"

// class...
@interface APIService : NSObject

// headers...
@property(nonatomic, strong) NSMutableDictionary *headers_dict;

// methods...
+ (id)shared;
- (NSString *)getJSONString_fromObject:(id)Object;
- (id)getObject_fromJSONString:(NSString *)jsonString;


// formdata...
- (NSURLSession *)getURLSession;
- (NSMutableURLRequest *)request_withFormData:(NSMutableDictionary *)paramDict withFile:(NSString *)filename requestType:(NSString *)requestType;
- (NSMutableURLRequest *)request_withFormData:(NSMutableDictionary *)paramDict images:(NSMutableDictionary *)imagesDict withFile:(NSString *)filename requestType:(NSString *)requestType;
- (NSMutableURLRequest *)request_withFormData:(NSMutableDictionary *)paramDict videos:(NSMutableDictionary *)videosDict withFile:(NSString *)filename requestType:(NSString *)requestType;
- (NSMutableURLRequest *)request_withFormData:(NSMutableDictionary *)paramDict audios:(NSMutableDictionary *)audiosDict withFile:(NSString *)filename requestType:(NSString *)requestType;


// Raw data....
- (NSMutableURLRequest *)request_withRaw:(id)paramDict withFile:(NSString *)filename requestType:(NSString *)requestType;
- (NSMutableURLRequest *)request_withDirect:(NSMutableDictionary *)paramDict withFile:(NSString *)filename requestType:(NSString *)requestType;

@end
