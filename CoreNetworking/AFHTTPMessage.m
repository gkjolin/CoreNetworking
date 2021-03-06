//
//  AFHTTPConstants.m
//  Amber
//
//  Created by Keith Duncan on 19/07/2009.
//  Copyright 2009. All rights reserved.
//

#import "AFHTTPMessage.h"

#import <objc/objc-auto.h>

#import "AFNetworkPacketWrite.h"
#import "AFNetworkPacketWriteFromReadStream.h"
#import "AFHTTPMessageMediaType.h"

#import "NSURLRequest+AFNetworkAdditions.h"

#import "AFNetwork-Constants.h"
#import "AFNetwork-Macros.h"

@interface _AFHTTPURLResponse : NSHTTPURLResponse {
 @private
	AFNETWORK_STRONG CFHTTPMessageRef _message;
}

- (id)initWithURL:(NSURL *)URL message:(CFHTTPMessageRef)message;

@property (assign, nonatomic) AFNETWORK_STRONG CFHTTPMessageRef message;

@end

@implementation _AFHTTPURLResponse

@synthesize message=_message;

- (id)initWithURL:(NSURL *)URL message:(CFHTTPMessageRef)message {
	NSString *MIMEType = nil; NSString *textEncodingName = nil;
	
	do {
		NSString *contentType = [NSMakeCollectable(CFHTTPMessageCopyHeaderFieldValue(message, (CFStringRef)AFHTTPMessageContentTypeHeader)) autorelease];
		AFHTTPMessageMediaType *mediaType = AFHTTPMessageParseContentTypeHeader(contentType);
		if (mediaType == nil) {
			break;
		}
		
		MIMEType = contentType;
		textEncodingName = [[mediaType parameters] objectForKey:@"charset"];
	} while (0);
	
	NSString *contentLength = [NSMakeCollectable(CFHTTPMessageCopyHeaderFieldValue(message, (CFStringRef)AFHTTPMessageContentLengthHeader)) autorelease];
	
	self = [self initWithURL:URL MIMEType:MIMEType expectedContentLength:(contentLength != nil ? [contentLength integerValue] : -1) textEncodingName:textEncodingName];
	if (self == nil) return nil;
	
	_message = (CFHTTPMessageRef)CFMakeCollectable(CFRetain(message));
	
	return self;
}

- (void)dealloc {
	CFRelease(_message);
	
	[super dealloc];
}

- (NSInteger)statusCode {
	return CFHTTPMessageGetResponseStatusCode([self message]);
}

- (NSDictionary *)allHeaderFields {
	return [NSMakeCollectable(CFHTTPMessageCopyAllHeaderFields([self message])) autorelease];
}

@end

CFHTTPMessageRef AFHTTPMessageCreateForRequest(NSURLRequest *request) {
	NSCParameterAssert([request HTTPBodyStream] == nil);
	NSCParameterAssert([request HTTPBodyFile] == nil);
	
	CFHTTPMessageRef message = CFHTTPMessageCreateRequest(kCFAllocatorDefault, (CFStringRef)[request HTTPMethod], (CFURLRef)[request URL], kCFHTTPVersion1_1);
	
	for (NSString *currentHeader in [request allHTTPHeaderFields]) {
		CFHTTPMessageSetHeaderFieldValue(message, (CFStringRef)currentHeader, (CFStringRef)[[request allHTTPHeaderFields] objectForKey:currentHeader]);
	}
	
	if ([request HTTPBody] != nil) {
		CFHTTPMessageSetBody(message, (CFDataRef)[request HTTPBody]);
	}
	
	return message;
}

NSURLRequest *AFHTTPURLRequestForHTTPMessage(CFHTTPMessageRef message) {
	NSURL *messageURL = [NSMakeCollectable(CFHTTPMessageCopyRequestURL(message)) autorelease];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:messageURL];
	[request setHTTPMethod:[NSMakeCollectable(CFHTTPMessageCopyRequestMethod(message)) autorelease]];
	[request setAllHTTPHeaderFields:[NSMakeCollectable(CFHTTPMessageCopyAllHeaderFields(message)) autorelease]];
	[request setHTTPBody:[NSMakeCollectable(CFHTTPMessageCopyBody(message)) autorelease]];
	
	return request;
}

CFHTTPMessageRef AFHTTPMessageCreateForResponse(NSHTTPURLResponse *response) {
	CFHTTPMessageRef message = CFHTTPMessageCreateResponse(kCFAllocatorDefault, [response statusCode], (CFStringRef)[NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]], kCFHTTPVersion1_1);
	[[response allHeaderFields] enumerateKeysAndObjectsUsingBlock:^ (id key, id obj, BOOL *stop) {
		CFHTTPMessageSetHeaderFieldValue(message, (CFStringRef)key, (CFStringRef)obj);
	}];
	return message;
}

NSHTTPURLResponse *AFHTTPURLResponseForHTTPMessage(NSURL *URL, CFHTTPMessageRef message) {
	return [[[_AFHTTPURLResponse alloc] initWithURL:URL message:message] autorelease];
}

static void _AFHTTPPrintMessage(CFHTTPMessageRef message) {
	printf("%s", [[[[NSString alloc] initWithData:[NSMakeCollectable(CFHTTPMessageCopySerializedMessage(message)) autorelease] encoding:NSMacOSRomanStringEncoding] autorelease] UTF8String]);
}

static __attribute__((used)) void _AFHTTPPrintRequest(NSURLRequest *request) {
	_AFHTTPPrintMessage((CFHTTPMessageRef)[NSMakeCollectable(AFHTTPMessageCreateForRequest((id)request)) autorelease]);
}

static __attribute__((used)) void _AFHTTPPrintResponse(NSURLResponse *response) {
	_AFHTTPPrintMessage((CFHTTPMessageRef)[NSMakeCollectable(AFHTTPMessageCreateForResponse((id)response)) autorelease]);
}

CFHTTPMessageRef AFHTTPMessageMakeResponseWithCode(AFHTTPStatusCode responseCode) {
	return (CFHTTPMessageRef)[NSMakeCollectable(CFHTTPMessageCreateResponse(kCFAllocatorDefault, responseCode, AFHTTPStatusCodeGetDescription(responseCode), kCFHTTPVersion1_1)) autorelease];
}

AFNetworkPacket <AFNetworkPacketWriting> *AFHTTPConnectionPacketForMessage(CFHTTPMessageRef message) {
	NSData *messageData = [NSMakeCollectable(CFHTTPMessageCopySerializedMessage(message)) autorelease];
	return [[[AFNetworkPacketWrite alloc] initWithData:messageData] autorelease];
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


NSString *const AFHTTPMessageServerHeader = @"Server";
NSString *const AFHTTPMessageUserAgentHeader = @"User-Agent";

NSString *const AFHTTPMessageHostHeader = @"Host";
NSString *const AFHTTPMessageConnectionHeader = @"Connection";

NSString *const AFHTTPMessageContentLengthHeader = @"Content-Length";
NSString *const AFHTTPMessageContentTypeHeader = @"Content-Type";
NSString *const AFHTTPMessageContentRangeHeader = @"Content-Range";
NSString *const AFHTTPMessageContentMD5Header = @"Content-MD5";

NSString *const AFHTTPMessageETagHeader = @"ETag";
NSString *const AFHTTPMessageIfMatchHeader = @"If-Match";
NSString *const AFHTTPMessageIfNoneMatchHeader = @"If-None-Match";

NSString *const AFHTTPMessageTransferEncodingHeader = @"Transfer-Encoding";

NSString *const AFHTTPMessageAllowHeader = @"Allow";
NSString *const AFHTTPMessageAcceptHeader = @"Accept";
NSString *const AFHTTPMessageLocationHeader = @"Location";
NSString *const AFHTTPMessageRangeHeader = @"Range";
NSString *const AFHTTPMessageExpectHeader = @"Expect";

NSString *const AFHTTPMessageWWWAuthenticateHeader = @"WWW-Authenticate";
NSString *const AFHTTPMessageAuthorizationHeader = @"Authorization";
NSString *const AFHTTPMessageProxyAuthorizationHeader = @"Proxy-Authorization";


CFStringRef AFHTTPStatusCodeGetDescription(AFHTTPStatusCode code) {
	switch (code) {
		case AFHTTPStatusCodeContinue:
			return CFSTR("Continue");
		case AFHTTPStatusCodeSwitchingProtocols:
			return CFSTR("Switching Protocols");
			
		case AFHTTPStatusCodeOK:
			return CFSTR("OK");
		case AFHTTPStatusCodeCreated:
			return CFSTR("Created");
		case AFHTTPStatusCodePartialContent:
			return CFSTR("Partial Content");
			
		case AFHTTPStatusCodeMultipleChoices:
			return CFSTR("Multiple Choices");
		case AFHTTPStatusCodeMovedPermanently:
			return CFSTR("Moved Permanently");
		case AFHTTPStatusCodeFound:
			return CFSTR("Found");
		case AFHTTPStatusCodeSeeOther:
			return CFSTR("See Other");
		case AFHTTPStatusCodeNotModified:
			return CFSTR("Not Modified");
		case AFHTTPStatusCodeTemporaryRedirect:
			return CFSTR("Temporary Redirect");
			
		case AFHTTPStatusCodeBadRequest:
			return CFSTR("Bad Request");
		case AFHTTPStatusCodeUnauthorized:
			return CFSTR("Unauthorized");
		case AFHTTPStatusCodeNotFound:
			return CFSTR("Not Found");
		case AFHTTPStatusCodeNotAllowed:
			return CFSTR("Not Allowed");
		case AFHTTPStatusCodeNotAcceptable:
			return CFSTR("Not Acceptable");
		case AFHTTPStatusCodeUnsupportedMediaType:
			return CFSTR("Unsupported Media Type");
		case AFHTTPStatusCodeProxyAuthenticationRequired:
			return CFSTR("Proxy Authentication Required");
		case AFHTTPStatusCodeConflict:
			return CFSTR("Conflict");
		case AFHTTPStatusCodeExpectationFailed:
			return CFSTR("Expectation Failed");
		case AFHTTPStatusCodeUpgradeRequired:
			return CFSTR("Upgrade Required");
			
		case AFHTTPStatusCodeServerError:
			return CFSTR("Server Error");
		case AFHTTPStatusCodeNotImplemented:
			return CFSTR("Not Implemented");
	}
	
	@throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%s, (%ld) is not a known status code", __PRETTY_FUNCTION__, (NSInteger)code] userInfo:nil];
	return NULL;
}

NSString *AFHTTPAgentStringForBundle(NSBundle *bundle) {
	if (bundle == nil) {
		return nil;
	}
	return [NSString stringWithFormat:@"%@/%@", [[bundle objectForInfoDictionaryKey:(id)@"CFBundleDisplayName"] stringByReplacingOccurrencesOfString:@" " withString:@"-"], [[bundle objectForInfoDictionaryKey:(id)kCFBundleVersionKey] stringByReplacingOccurrencesOfString:@" " withString:@"-"]];
}

NSString *AFHTTPAgentString(void) {
	static NSString *agentString = nil;
	if (agentString == nil) {
		NSMutableArray *components = [NSMutableArray array];
		[components addObjectsFromArray:[NSArray arrayWithObjects:AFHTTPAgentStringForBundle([NSBundle mainBundle]), nil]];
		NSBundle *coreNetworkingBundle = [NSBundle bundleWithIdentifier:AFCoreNetworkingBundleIdentifier];
		if (coreNetworkingBundle != nil) {
			[components addObjectsFromArray:[NSArray arrayWithObjects:AFHTTPAgentStringForBundle(coreNetworkingBundle), nil]];
		}
		NSString *newAgentString = [([components count] > 0 ? [components componentsJoinedByString:@" "] : @"") copy];
		
		if (!objc_atomicCompareAndSwapGlobalBarrier(nil, newAgentString, &agentString)) {
			[newAgentString release];
		}
	}
	return agentString;
}
