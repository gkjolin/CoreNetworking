//
//  AFHTTPConstants.m
//  Amber
//
//  Created by Keith Duncan on 19/07/2009.
//  Copyright 2009 thirty-three. All rights reserved.
//

#import "AFHTTPMessage.h"

extern CFHTTPMessageRef AFHTTPMessageForRequest(NSURLRequest *request) {
	NSCParameterAssert([request HTTPBodyStream] == nil);
	
	CFHTTPMessageRef message = (CFHTTPMessageRef)[NSMakeCollectable(CFHTTPMessageCreateRequest(kCFAllocatorDefault, (CFStringRef)[request HTTPMethod], (CFURLRef)[request URL], kCFHTTPVersion1_1)) autorelease];
	
	for (NSString *currentHeader in [request allHTTPHeaderFields])
		CFHTTPMessageSetHeaderFieldValue(message, (CFStringRef)currentHeader, (CFStringRef)[[request allHTTPHeaderFields] objectForKey:currentHeader]);
	
	CFHTTPMessageSetBody(message, (CFDataRef)[request HTTPBody]);
	
	return message;
}

extern NSURLRequest *AFHTTPURLRequestForHTTPMessage(CFHTTPMessageRef message) {
	NSURL *messageURL = [NSMakeCollectable(CFHTTPMessageCopyRequestURL(message)) autorelease];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:messageURL];
	[request setHTTPMethod:[NSMakeCollectable(CFHTTPMessageCopyRequestMethod(message)) autorelease]];
	[request setAllHTTPHeaderFields:[NSMakeCollectable(CFHTTPMessageCopyAllHeaderFields(message)) autorelease]];
	[request setHTTPBody:[NSMakeCollectable(CFHTTPMessageCopyBody(message)) autorelease]];
	
	return request;
}

NSString *const AFHTTPMethodHEAD = @"HEAD";
NSString *const AFHTTPMethodTRACE = @"TRACE";
NSString *const AFHTTPMethodOPTIONS = @"OPTIONS";

NSString *const AFHTTPMethodGET = @"GET";
NSString *const AFHTTPMethodPOST = @"POST";
NSString *const AFHTTPMethodPUT = @"PUT";
NSString *const AFHTTPMethodDELETE = @"DELETE";

NSString *const AFNetworkSchemeHTTP = @"http";
NSString *const AFNetworkSchemeHTTPS = @"https";

NSString *const AFHTTPMessageUserAgentHeader = @"User-Agent";
NSString *const AFHTTPMessageContentLengthHeader = @"Content-Length";
NSString *const AFHTTPMessageHostHeader = @"Host";
NSString *const AFHTTPMessageConnectionHeader = @"Connection";
NSString *const AFHTTPMessageContentTypeHeader = @"Content-Type";

CFStringRef AFHTTPStatusCodeDescription(AFHTTPStatusCode code) {
	switch (code) {
		case AFHTTPStatusCodeOK:
			return CFSTR("OK");
		case AFHTTPStatusCodePartialContent:
			return CFSTR("Partial Content");
			
		case AFHTTPStatusCodeBadRequest:
			return CFSTR("Bad Request");
		case AFHTTPStatusCodeNotFound:
			return CFSTR("Not Found");
		case AFHTTPStatusCodeUpgradeRequired:
			return CFSTR("Upgrade Required");
			
		case AFHTTPStatusCodeServerError:
			return CFSTR("Server Error");
		case AFHTTPStatusCodeNotImplemented:
			return CFSTR("Not Implemented");
	}
	
	[NSException raise:NSInvalidArgumentException format:@"%s, (%ld) is not a known status code", __PRETTY_FUNCTION__, nil];
	return NULL;
}