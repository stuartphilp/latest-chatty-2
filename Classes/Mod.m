//
//  Mod.m
//  LatestChatty2
//
//  Created by jason on 2/7/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "Mod.h"

@implementation Mod
+ (void)modParentId:(NSUInteger)parentId modPostId:(NSUInteger)postId mod:(ModType)modType {
	NSString *url = nil;
	url = [NSString stringWithFormat:@"http://www.shacknews.com/mod_laryn.x?root=%d&id=%d&mod=", parentId, postId];
	
	switch (modType) {
		case ModTypeStupid:
			url = [url stringByAppendingString:@"stupid"];
			break;
			
		case ModTypeOfftopic:
			url = [url stringByAppendingString:@"offtopic"];
			break;
			
		case ModTypeNWS:
			url = [url stringByAppendingString:@"nws"];
			break;
			
		case ModTypePolitical:
			url = [url stringByAppendingString:@"political"];
			break;
			
		case ModTypeNuked:
			url = [url stringByAppendingString:@"nuked"];
			break;
			
		case ModTypeInformative:
			url = [url stringByAppendingString:@"informative"];
			break;			
			
		case ModTypeOntopic:
			url = [url stringByAppendingString:@"ontopic"];
			break;
	}
	
	if (url) {
		NSHTTPURLResponse * response;
		NSError * error;
		NSData *data;
		NSMutableURLRequest *request;
		
		//NSLog(@"Moderating post with URL: %@", url);
		request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
												cachePolicy:NSURLRequestReloadIgnoringCacheData 
											timeoutInterval:60] autorelease];
		data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];	

		NSString *modResult = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
		if([modResult rangeOfString:@"post already modded"].location != NSNotFound){
			NSLog(@"Post already modded.");
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Change"
															message:@"Either post already modded that way or you do not have access."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}


@end