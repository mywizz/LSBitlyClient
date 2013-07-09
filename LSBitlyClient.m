//
// LSBitlyClient.m
//
// Copyright (c) 2013 Yunseok Kim (http://mywizz.me/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


NSString * const BITLY_API_ENDPOINT = @"https://api-ssl.bitly.com";
NSString * const BITLY_ERROR_DOMAIN = @"com.bitly.API";


#import "LSBitlyClient.h"
#import "AFNetworking.h"


@implementation LSBitlyClient

@synthesize clientID = _clientID;
@synthesize clientSecret = _clientSecret;

- (id)initWithClientID:(NSString *)clientID secret:(NSString *)clientSecret
{
	self = [self init];
	if (self)
	{
		_clientID = clientID;
		_clientSecret = clientSecret;
	}
	return self;
}

// ---------------------------------------------------------------------
#pragma mark -
#pragma mark Authorization

- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password success:(void(^)(id result))successBlock error:(void(^)(NSError *error))errorBlock
{
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
								self.clientID, @"client_id",
								self.clientSecret, @"client_secret",
								@"json", @"format",
								nil];
	
	AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:BITLY_API_ENDPOINT]];
	[client setAuthorizationHeaderWithUsername:username password:password];
	
	NSURLRequest *request = [client requestWithMethod:@"POST" path:@"/oauth/access_token" parameters:parameters];
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
								username, @"username",
								operation.responseString, @"access_token",
								nil];
		successBlock(result);
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
		errorBlock(error);
		
	}];
	
	[operation start];
}

// ---------------------------------------------------------------------
#pragma mark -
#pragma mark Shorten URL

- (void)shorten:(NSString *)url accessToken:(NSString *)accessToken success:(void(^)(id result))successBlock error:(void(^)(NSError *error))errorBlock
{
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
								accessToken, @"access_token",
								url, @"longUrl",
								nil];
	
	AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:BITLY_API_ENDPOINT]];
	NSURLRequest *request = [client requestWithMethod:@"POST" path:@"/v3/shorten" parameters:parameters];
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		
		int code = [[JSON valueForKey:@"status_code"] intValue];
		if (code >= 200 && code < 300)
		{
			NSDictionary *data = [JSON valueForKey:@"data"];
			NSString *shortURL = [data valueForKey:@"url"];
			
			NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
									url, @"originalURL",
									shortURL, @"shortURL",
									nil];
			
			successBlock(result);
			return;
		}
		
		errorBlock([NSError errorWithDomain:BITLY_ERROR_DOMAIN code:0 userInfo:nil]);
		
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
		
		errorBlock(error);
		
	}];
	
	[operation start];
}

@end
