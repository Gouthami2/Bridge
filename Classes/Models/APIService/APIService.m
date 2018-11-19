//
//  APIService.m
//  linphone
//
//  Created by Gouthami Reddy on 11/14/18.
//

#import "APIService.h"

@implementation APIService

#pragma mark - Instance
+ (id)shared {
	
	static id instance_ = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		instance_ = [[self alloc] init];
	});
	return instance_;
}

- (instancetype)init {
	
	self = [super init];
	if (self) {
	}
	return self;
}


#pragma mark - JSON
- (NSString *)getJSONString_fromObject:(id)Object {
	
	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:Object
													   options:kNilOptions
														 error:&error];
	if (!jsonData) {
		NSLog(@"Object -> String error: %@", error.localizedDescription);
		return @"";
	}
	else {
		NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
		return jsonString;
	}
}

- (id)getObject_fromJSONString:(NSString *)jsonString {
	
	NSError *error;
	id jsonObject = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
													options:kNilOptions
													  error:&error];
	if (!jsonObject) {
		NSLog(@"String -> Object error: %@", error.localizedDescription);
		return @"";
	}
	else {
		return jsonObject;
	}
}

#pragma mark - WebRequest With FormData
- (NSURLSession *)getURLSession {
	
	NSURLSessionConfiguration *defaultConfigur = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigur
																 delegate:nil
															delegateQueue:[NSOperationQueue mainQueue]];
	return defaultSession;
}

- (NSMutableURLRequest *)request_withFormData:(NSMutableDictionary *)paramDict withFile:(NSString *)filename requestType:(NSString *)requestType {
	
	
	// form data setup for each fileds(params)...
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	NSMutableData *body = [NSMutableData data];
	
	NSArray *keysArray = [paramDict allKeys];
	
	for (int i=0; i<[keysArray count]; i++) {
		
		NSString *keyString = [NSString stringWithFormat:@"%@", [keysArray objectAtIndex:i]];
		
		// element adding..
		NSString *firstName = [NSString stringWithFormat:@"%@", [paramDict objectForKey:keyString]];
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", keyString] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[firstName dataUsingEncoding:NSUTF8StringEncoding]];
		NSLog(@"%@ :: %@", keyString , firstName);
	}
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	NSString *urlstring = [NSString stringWithFormat:@"%@/%@", ServerPath, filename];
	NSLog(@"URL  %@ : %@", requestType, urlstring);
	
	
	// Url request...
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlstring]];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	[request setHTTPBody:body];
	[request setHTTPMethod:requestType];
    
    for (NSString *key_value in self.headers_dict.allKeys) {
        [request addValue:[NSString stringWithFormat:@"%@", [self.headers_dict objectForKey:key_value]] forHTTPHeaderField: key_value];
    }
	return request;
}

- (NSMutableURLRequest *)request_withFormData:(NSMutableDictionary *)paramDict images:(NSMutableDictionary *)imagesDict withFile:(NSString *)filename requestType:(NSString *)requestType {
	
	// form data setup for each fileds(params)...
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	NSMutableData *body = [NSMutableData data];
	
	NSArray *keysArray = [paramDict allKeys];
	for (int i=0; i<[keysArray count]; i++) {
		
		NSString *keyString = [NSString stringWithFormat:@"%@", [keysArray objectAtIndex:i]];
		// element adding..
		NSString *firstName = [NSString stringWithFormat:@"%@", [paramDict objectForKey:keyString]];
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", keyString] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[firstName dataUsingEncoding:NSUTF8StringEncoding]];
		NSLog(@"%@ :: %@", keyString , firstName);
	}
	
	
	NSArray *imageKeysArray = [imagesDict allKeys];
	for (int i=0; i<[imageKeysArray count]; i++) {
		
		NSString *keyString = [NSString stringWithFormat:@"%@", [imageKeysArray objectAtIndex:i]];
		// user_image ...
		UIImage *loImage = (UIImage *)[imagesDict objectForKey:keyString];
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n\r\n", keyString] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:UIImageJPEGRepresentation(loImage, 0.6)];
		NSLog(@"Image added");
	}
	
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	NSString *urlstring = [NSString stringWithFormat:@"%@/%@", ServerPath, filename];
	NSLog(@"URL  %@ : %@", requestType, urlstring);
	
	
	// Url request...
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlstring]];
	[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:body];
	[request setHTTPMethod:requestType];
    
    for (NSString *key_value in self.headers_dict.allKeys) {
        [request addValue:[NSString stringWithFormat:@"%@", [self.headers_dict objectForKey:key_value]] forHTTPHeaderField: key_value];
    }
	return request;
}

- (NSMutableURLRequest *)request_withFormData:(NSMutableDictionary *)paramDict videos:(NSMutableDictionary *)videosDict withFile:(NSString *)filename requestType:(NSString *)requestType {
	
	// form data setup for each fileds(params)...
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	NSMutableData *body = [NSMutableData data];
	
	NSArray *keysArray = [paramDict allKeys];
	for (int i=0; i<[keysArray count]; i++) {
		
		NSString *keyString = [NSString stringWithFormat:@"%@", [keysArray objectAtIndex:i]];
		// element adding..
		NSString *firstName = [NSString stringWithFormat:@"%@", [paramDict objectForKey:keyString]];
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", keyString] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[firstName dataUsingEncoding:NSUTF8StringEncoding]];
		NSLog(@"%@ :: %@", keyString , firstName);
	}
	
	NSArray *videosKeysArray = [videosDict allKeys];
	for (int i=0; i<[videosKeysArray count]; i++) {
		
		NSString *keyString = [NSString stringWithFormat:@"%@", [videosKeysArray objectAtIndex:i]];
		
		// Video Data.....
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"Viedos.mp4\"\r\n", keyString] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"Content-Type: video/mp4\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:(NSData *) [videosDict objectForKey:keyString]];
		NSLog(@"%@ :: Video added", keyString);
	}
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	NSString *urlstring = [NSString stringWithFormat:@"%@/%@", ServerPath, filename];
	NSLog(@"URL  %@ : %@", requestType, urlstring);
	
	
	// Url request...
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlstring]];
	[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:body];
	[request setHTTPMethod:requestType];
    
    for (NSString *key_value in self.headers_dict.allKeys) {
        [request addValue:[NSString stringWithFormat:@"%@", [self.headers_dict objectForKey:key_value]] forHTTPHeaderField: key_value];
    }
	return request;
}

- (NSMutableURLRequest *)request_withFormData:(NSMutableDictionary *)paramDict audios:(NSMutableDictionary *)audiosDict withFile:(NSString *)filename requestType:(NSString *)requestType {
	
	// form data setup for each fileds(params)...
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	NSMutableData *body = [NSMutableData data];
	
	NSArray *keysArray = [paramDict allKeys];
	for (int i=0; i<[keysArray count]; i++) {
		
		NSString *keyString = [NSString stringWithFormat:@"%@", [keysArray objectAtIndex:i]];
		// element adding..
		NSString *firstName = [NSString stringWithFormat:@"%@", [paramDict objectForKey:keyString]];
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", keyString] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[firstName dataUsingEncoding:NSUTF8StringEncoding]];
		NSLog(@"%@ :: %@", keyString , firstName);
	}
	
	NSArray *audioKeysArray = [audiosDict allKeys];
	for (int i=0; i<[audioKeysArray count]; i++) {
		
		NSString *keyString = [NSString stringWithFormat:@"%@", [audioKeysArray objectAtIndex:i]];
		
		// audio Data.....
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"audio.m4a\"\r\n", keyString] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"Content-Type: audio/x-m4a\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:(NSData *) [audiosDict objectForKey:keyString]];
		NSLog(@"%@ :: audio added", keyString);
	}
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	NSString *urlstring = [NSString stringWithFormat:@"%@/%@", ServerPath, filename];
	NSLog(@"URL  %@ : %@", requestType, urlstring);
	
	// Url request...
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlstring]];
	[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:body];
	[request setHTTPMethod:requestType];
    
    for (NSString *key_value in self.headers_dict.allKeys) {
        [request addValue:[NSString stringWithFormat:@"%@", [self.headers_dict objectForKey:key_value]] forHTTPHeaderField: key_value];
    }
	return request;
}

#pragma mark - RawData
- (NSMutableURLRequest *)request_withRaw:(id)paramDict withFile:(NSString *)filename requestType:(NSString *)requestType {
	
	NSString *urlstring = [NSString stringWithFormat:@"%@/%@", ServerPath, filename];
	NSLog(@"URL  %@ : %@", requestType, urlstring);
	NSLog(@"Raw Elements : %@", paramDict);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlstring]];
	[request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setHTTPMethod:requestType];
    
    for (NSString *key_value in self.headers_dict.allKeys) {
        [request addValue:[NSString stringWithFormat:@"%@", [self.headers_dict objectForKey:key_value]] forHTTPHeaderField: key_value];
    }
	
	NSError *eleError = nil;
	NSData *postData = [NSJSONSerialization dataWithJSONObject:paramDict options:0 error:&eleError];
	[request setHTTPBody:postData];
	return request;
}

- (NSMutableURLRequest *)request_withDirect:(NSMutableDictionary *)paramDict withFile:(NSString *)filename requestType:(NSString *)requestType {
	
	// profile and param dictionary...
	NSMutableString *requestString = [[NSMutableString alloc] init];
	NSArray *keysArray = [paramDict allKeys];
	
	for (int i=0; i<[keysArray count]; i++) {
		
		NSString *keyString = [NSString stringWithFormat:@"%@", [keysArray objectAtIndex:i]];
		NSString *elementString = [NSString stringWithFormat:@"%@=%@&", keyString, [paramDict objectForKey:keyString]];
		if (i == (keysArray.count-1)) {
			elementString = [NSString stringWithFormat:@"%@=%@", keyString, [paramDict objectForKey:keyString]];
		}
		[requestString appendString:elementString];
	}
	
	NSString *urlstring = [NSString stringWithFormat:@"%@/%@?%@", ServerPath, filename, requestString];
	urlstring = [urlstring stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
	//urlstring = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"URL  %@ : %@", requestType, urlstring);
	
	// Url request...
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlstring]];
	[request setHTTPMethod:requestType];
    
    for (NSString *key_value in self.headers_dict.allKeys) {
        [request addValue:[NSString stringWithFormat:@"%@", [self.headers_dict objectForKey:key_value]] forHTTPHeaderField: key_value];
    }
	return request;
}
@end
