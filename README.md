# LSBitlyClient

LSBitlyClient is simple object-c library for Bitly API.


## Requirements

- ARC
- [AFNetworking](https://github.com/AFNetworking/AFNetworking)


## Endpoints

LSBitlyClient supports two endpoints (for now): 

- OAuth Basic Authorization `/oauth/access_token`
- Shorten `/v3/shorten`


## Usage
	
### OAuth Basic Authorization
	
	LSBitlyClient *bitly = [[LSBitlyClient alloc] initWithClientID:CLIENT_ID secret:CLIENT_SECRET];
	
	[bitly authorizeWithUsername:username password:password success:^(id result) {
	
		NSDictionary *dict = (NSDictionary *)result;
		NSString *accessToken = [dict valueForKey:@"access_token"];
		NSLog(@"access token : %@", accessToken);
				
	} error:^(NSError *error) {
		NSLog(@"error : %@", error);
	}];

### Shorten
	
	NSString *bitlyAccessToken = ….; // previously obtained access token
	
	LSBitlyClient *bitly = [[LSBitlyClient alloc] initWithClientID:CLIENT_ID secret:CLIENT_SECRET];
	
	[bitly shorten:@"http://github.com" accessToken:bitlyAccessToken success:^(id result) {
		
		NSString *originalURL = [result valueForKey:@"originalURL"];
		NSString *shortURL = [result valueForKey:@"shortURL"];
		
		NSLog(@"%@ => %@", originalURL, shortURL);
	
	} error:^(NSError *error) {
		NSLog(@"error : %@", error);
	}];



## License

Available under the MIT license.
