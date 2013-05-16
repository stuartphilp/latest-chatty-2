//
//    LatestChatty2AppDelegate.m
//    LatestChatty2
//
//    Created by Alex Wayne on 3/16/09.
//    Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "LatestChatty2AppDelegate.h"
#import "StringTemplate.h"
#import "Mod.h"
#import "NoContentController.h"

@implementation LatestChatty2AppDelegate

@synthesize window,
            navigationController,
            contentNavigationController,
            slideOutViewController;

+ (LatestChatty2AppDelegate*)delegate {
    return (LatestChatty2AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (void)setupInterfaceForPhoneWithOptions:(NSDictionary *)launchOptions {
    if (![self reloadSavedState]) {
        // Add the root view controller
        RootViewController *viewController = [RootViewController controllerWithNib];
        [navigationController pushViewController:viewController animated:NO];
    }
    
//    if ([[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"message_id"]) {
//        // Tapped a messge push's view button
//        MessagesViewController *viewController = [MessagesViewController controllerWithNib];
//        [navigationController pushViewController:viewController animated:NO];
//    }
    
    // Style the navigation bar
    navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    // Configure and show the window
    window.backgroundColor = [UIColor blackColor];
    
    window.rootViewController = navigationController;
}

- (void)setupInterfaceForPadWithOptions:(NSDictionary *)launchOptions {
    self.contentNavigationController = [UINavigationController controllerWithRootController:[NoContentController controllerWithNib]];
    contentNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    contentNavigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    
    if (![self reloadSavedState]) {
        // Add the root view controller
        [navigationController pushViewController:[RootViewController controllerWithNib] animated:NO];
    }
    
//    if ([[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"message_id"]) {
//        // Tapped a messge push's view button
//        MessagesViewController *viewController = [MessagesViewController controllerWithNib];
//        [navigationController pushViewController:viewController animated:NO];
//    }
    
    self.slideOutViewController =  [SlideOutViewController controllerWithNib];
    [slideOutViewController addNavigationController:navigationController contentNavigationController:contentNavigationController];
    [slideOutViewController.view setFrame:CGRectMake(0, 20, 768, 1004)];
    
    window.rootViewController = slideOutViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self customizeAppearance];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *lastSaveDate = [defaults objectForKey:@"savedStateDate"];
    
//    // Register for Push
//    if ([defaults boolForKey:@"push.messages"]) {
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
//    }
    
    // If forget history is on or it's been 8 hours since the last opening, then we don't care about the saved state.
    if ([defaults boolForKey:@"forgetHistory"] || [lastSaveDate timeIntervalSinceNow] < -8*60*60) {
        [defaults removeObjectForKey:@"savedState"];
    }        
    
    if ([self isPadDevice]) {
        [self setupInterfaceForPadWithOptions:launchOptions];
    } else {
        [self setupInterfaceForPhoneWithOptions:launchOptions];
    }

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];    
    
    [window makeKeyAndVisible];

    // Settings defaults
    NSDictionary *defaultSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"",                           @"username",
                                     @"",                           @"password",
                                     @"shackapi.stonedonkey.com",   @"server",
                                     //[NSNumber numberWithBool:YES], @"landscape",
                                     [NSNumber numberWithBool:YES], @"embedYoutube",
                                     //[NSNumber numberWithBool:NO],  @"push.messages",
                                     [NSNumber numberWithBool:YES], @"picsResize",
                                     [NSNumber numberWithFloat:0.7],@"picsQuality",
                                     [NSNumber numberWithBool:YES], @"embedYoutube",
                                     [NSNumber numberWithBool:NO],  @"useSafari",
                                     [NSNumber numberWithBool:NO],  @"useChrome",
                                     [NSNumber numberWithBool:YES], @"postCategory.informative",
                                     [NSNumber numberWithBool:YES], @"postCategory.offtopic",
                                     [NSNumber numberWithBool:YES], @"postCategory.stupid",
                                     [NSNumber numberWithBool:YES], @"postCategory.political",
                                     [NSNumber numberWithBool:NO],  @"postCategory.nws",
                                     [NSNumber numberWithInt:0],    @"lastRefresh",
                                     [NSNumber numberWithInt:1],    @"grippyBarPosition",
                                     [NSMutableArray array],        @"pinnedPosts",
                                     nil];
    [defaults registerDefaults:defaultSettings];

    //Patch-E: modified requestBody and request URL for May 2013 Shacknews login changes
    if([defaults boolForKey:@"modTools"]==YES){
        //Mods need cookies
        NSString *usernameString = [[defaults stringForKey:@"username"] stringByEscapingURL];
        NSString *passwordString = [[defaults stringForKey:@"password"] stringByEscapingURL];
        //NSString *requestBody = [NSString stringWithFormat:@"email=%@&password=%@&login=login", usernameString, passwordString];
        NSString *requestBody = [NSString stringWithFormat:@"get_fields%%5B%%5D=result&user-identifier=%@&supplied-pass=%@&remember-login=1", usernameString, passwordString];        
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];

        //[request setURL:[NSURL URLWithString:@"http://www.shacknews.com"]];
        [request setURL:[NSURL URLWithString:@"https://www.shacknews.com/account/signin"]];
        [request setHTTPBody:[requestBody dataUsingEncoding:NSASCIIStringEncoding]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
        [NSURLConnection connectionWithRequest:request delegate:nil];
        
        // use for testing login above and to output current cookies for www.shacknews.com
//        NSString *responseBody = [NSString stringWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil]];
//        NSLog(@"%@", responseBody);
//        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"https://www.shacknews.com"]];
//        for (int i=0;i<cookies.count;i++) {
//            NSHTTPCookie *cookie = cookies[i];
//            NSLog(@"%@", cookie.description);
//        }
    }
    return YES;
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    if ([userInfo objectForKey:@"message_id"]) {
//        [UIAlertView showWithTitle:@"Incoming Message"
//                           message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
//                          delegate:self
//                 cancelButtonTitle:@"Dismiss"
//                 otherButtonTitles:@"View", nil];
//    }
//}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 1) {
//        MessagesViewController *viewController = [[MessagesViewController alloc] init];
//        [navigationController pushViewController:viewController animated:YES];
//        [viewController release];
//    }
//}

//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
//    [request setURL:[NSURL URLWithString:[[Model class] urlStringWithPath:@"/devices"]]];
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *pushToken = [[deviceToken description] stringByReplacingOccurrencesOfRegex:@"<|>" withString:@""];
//    NSString *usernameString = [[defaults stringForKey:@"username"] stringByEscapingURL];
//    NSString *passwordString = [[defaults stringForKey:@"password"] stringByEscapingURL];
//    NSString *requestBody = [NSString stringWithFormat:@"token=%@&username=%@&password=%@", pushToken, usernameString, passwordString];
//    [request setHTTPBody:[requestBody dataUsingEncoding:NSASCIIStringEncoding]];
//    [request setHTTPMethod:@"POST"];
//
//    [NSURLConnection connectionWithRequest:request delegate:nil];
//}
//
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    NSLog(@"Error in registration. Error: %@", error);
//}


- (NSURLCredential *)userCredential {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    return [NSURLCredential credentialWithUser:[defaults objectForKey:@"username"]
                                      password:[defaults objectForKey:@"password"]
                                   persistence:NSURLCredentialPersistenceNone];
}

//Patch-E: check the Embed YouTube user setting, if embedding is turned off open YouTube URL in either the YouTube app (if installed, either the Apple created pre-iOS 6 app or Google created app) or Safari if a YouTube app isn't installed. If embedding turned on, open YouTube URL in web view.
- (BOOL)isYoutubeURL:(NSURL *)url {
    if ([[url host] containsString:@"youtube.com"] || [[url host] containsString:@"youtu.be"]) {
        return YES;
    }
    return NO;
}

//Patch-E: if user has URLs set to open in Chrome, check to see if the app can open Chrome. If it can, construct the URL on the googlechrome:// URL scheme and return it.
- (id)urlAsChromeScheme:(NSURL *)url {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]]) {
        NSString *absoluteURLString = [url absoluteString];
        NSRange rangeForScheme = [absoluteURLString rangeOfString:@":"];
        NSString *urlWithNoScheme =  [absoluteURLString substringFromIndex:rangeForScheme.location];
        NSString *chromeURLString = [@"googlechrome" stringByAppendingString:urlWithNoScheme];
        NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
        
        absoluteURLString = nil;
        urlWithNoScheme = nil;
        chromeURLString = nil;
        
        return chromeURL;
    }
    return nil;
}

- (id)viewControllerForURL:(NSURL *)url {
    NSString *uri = [url absoluteString];
    UIViewController *viewController = nil;
    
    if ([uri isMatchedByRegex:@"shacknews\\.com/laryn\\.x\\?id=\\d+"]) {
        NSUInteger targetThreadId = [[uri stringByMatching:@"shacknews\\.com/laryn\\.x\\?id=(\\d+)" capture:1] intValue];
        viewController = [[[ThreadViewController alloc] initWithThreadId:targetThreadId] autorelease];
    } else if ([uri isMatchedByRegex:@"shacknews\\.com/laryn\\.x\\?story=\\d+"]) {
        NSUInteger targetStoryId = [[uri stringByMatching:@"shacknews\\.com/laryn\\.x\\?story=(\\d+)" capture:1] intValue];
        viewController = [[[ChattyViewController alloc] initWithStoryId:targetStoryId] autorelease];
    }
    //Patch-E: added handling for profiles URLs to do a search of that users' post history through SearchResultsViewController with default search values. Profile links posted in a chatty thread or tapping a user's name in a ThreadViewController will launch the search. Can also pass in a search externally via the latestchatty:// protocol.
    else if ([uri isMatchedByRegex:@"shacknews\\.com/profile/.*"]) {
        NSString *profileName = [[uri stringByMatching:@"shacknews\\.com/profile/(.*)" capture:1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        viewController = [[[SearchResultsViewController alloc] initWithTerms:@"" author:profileName parentAuthor:@""] autorelease];
    } else if ([uri isMatchedByRegex:@"shacknews\\.com/chatty\\?id=\\d+"]) {
        NSUInteger targetThreadId = [[uri stringByMatching:@"shacknews\\.com/chatty\\?id=(\\d+)" capture:1] intValue];
        viewController = [[[ThreadViewController alloc] initWithThreadId:targetThreadId] autorelease];
    } else if ([uri isMatchedByRegex:@"shacknews\\.com/chatty\\?story=\\d+"]) {
        NSUInteger targetStoryId = [[uri stringByMatching:@"shacknews\\.com/chatty\\?story=(\\d+)" capture:1] intValue];
        viewController = [[[ChattyViewController alloc] initWithStoryId:targetStoryId] autorelease];
    } else if ([uri isMatchedByRegex:@"shacknews\\.com/onearticle.x/\\d+"]) {
        NSUInteger targetStoryId = [[uri stringByMatching:@"shacknews\\.com/onearticle.x/(\\d+)" capture:1] intValue];
        viewController = [[[StoryViewController alloc] initWithStoryId:targetStoryId] autorelease];
    } else if ([uri isMatchedByRegex:@"shacknews\\.com/article/\\d+"]) {
        NSUInteger targetStoryId = [[uri stringByMatching:@"shacknews\\.com/article/(\\d+)" capture:1] intValue];
        viewController = [[[StoryViewController alloc] initWithStoryId:targetStoryId] autorelease];
    }

    return viewController;
}

- (BOOL)reloadSavedState {
    @try {
        // Find saved state
        NSData *savedState = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedState"];
        
        if (savedState) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedState"];
            NSArray *controllerDictionaries = [NSKeyedUnarchiver unarchiveObjectWithData:savedState];
            
            // Create a dictionary to convert controller type strings to class objects
            NSMutableDictionary *controllerClassLookup = [NSMutableDictionary dictionary];
            [controllerClassLookup setObject:[RootViewController class]        forKey:@"Root"];
            [controllerClassLookup setObject:[StoriesViewController class] forKey:@"Stories"];
            [controllerClassLookup setObject:[StoryViewController class]     forKey:@"Story"];
            [controllerClassLookup setObject:[ChattyViewController class]    forKey:@"Chatty"];
            [controllerClassLookup setObject:[ThreadViewController class]    forKey:@"Thread"];
            [controllerClassLookup setObject:[BrowserViewController class] forKey:@"Browser"];
            
            for (NSDictionary *dictionary in controllerDictionaries) {
                // find the right controller class
                NSString *controllerName = [dictionary objectForKey:@"type"];
                Class class = [controllerClassLookup objectForKey:controllerName];
                
                if (class) {
                    id viewController = [[class alloc] initWithStateDictionary:dictionary];
                    [navigationController pushViewController:viewController animated:NO];
                    [viewController release];
                } else {
                    NSLog(@"No known view controller for the type: %@", controllerName);
                    return NO;
                }
            }
        } else {
            return NO;
        }
        
    }
    @catch (NSException *e) {
        // Something went wrong restoring state, so just start over.
        navigationController.viewControllers = nil;
        return NO;
    }
    
    return YES;
}

- (BOOL)isPadDevice {
    return CGRectGetMaxX([[UIScreen mainScreen] bounds]) > 480;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSMutableArray *savedControllers = [NSMutableArray array];
    for (id viewController in [navigationController viewControllers]) {
        BOOL hasState = [viewController respondsToSelector:@selector(stateDictionary)];
        BOOL hasLoading = [viewController respondsToSelector:@selector(loading)];
        BOOL isDoneLoading = hasLoading && ![viewController loading];
        
        if (hasState && (isDoneLoading || !hasLoading))
            [savedControllers addObject:[viewController stateDictionary]];
    }
    
    NSData *state = [NSKeyedArchiver archivedDataWithRootObject:savedControllers];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:state forKey:@"savedState"];
    [defaults setObject:[NSDate date] forKey:@"savedStateDate"];
    [defaults synchronize];
    
    //'logout' essentially
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* shackCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://www.shacknews.com"]];
    for (NSHTTPCookie* cookie in shackCookies) {
        NSLog(@"Name: %@ : Value: %@", cookie.name, cookie.value);
        [cookies deleteCookie:cookie];
    }
}

//Patch-E: handling the registered latestchatty:// URL scheme
//  Uses the existing AppDelegate method viewControllerForURL to determine what kind of ViewController to instantiate and push onto the appropriate navigation controller stack.
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"Passed in URL: %@", url);
    if (!url) {
        return NO;
    }
    
    NSLog(@"Loading passed in URL.");
    UIViewController *viewController = [self viewControllerForURL:url];
    
    if (viewController == nil) {
        NSLog(@"URL passed in did not match any handlers.");
        return NO;
    }
    
    if ([self isPadDevice]) {
        [self.contentNavigationController pushViewController:viewController animated:YES];
    } else {
        [self.navigationController dismissModalViewControllerAnimated:YES];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    return YES;
}

#pragma mark - Customizations

- (void)customizeAppearance {
    //custom appearance settings for UIKit items
    UIImage *backgroundImage =
        [[UIImage imageNamed:@"navbar_bg"]
        resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
    [[UINavigationBar appearance] setBackgroundImage:backgroundImage
                                       forBarMetrics:UIBarMetricsDefault];
    [[UIToolbar appearance] setBackgroundImage:backgroundImage
                            forToolbarPosition:UIToolbarPositionAny
                                    barMetrics:UIBarMetricsDefault];
    
    UIImage *backButtonImage =
        [[UIImage imageNamed:@"button_back"]
        resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 6) resizingMode:UIImageResizingModeStretch];
    UIImage *backButtonHighlightImage =
        [[UIImage imageNamed:@"button_back_highlight"]
        resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 6) resizingMode:UIImageResizingModeStretch];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonHighlightImage
                                                      forState:UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsDefault];
    
    UIImage *barButtonDoneImage =
        [[UIImage imageNamed:@"button_done"]
         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6) resizingMode:UIImageResizingModeStretch];
    UIImage *barButtonDoneLandscapeImage =
        [[UIImage imageNamed:@"button_done_landscape"]
         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6) resizingMode:UIImageResizingModeStretch];
    UIImage *barButtonNormalImage =
        [[UIImage imageNamed:@"button_normal"]
         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6) resizingMode:UIImageResizingModeStretch];
    UIImage *barButtonNormalHighlightImage =
        [[UIImage imageNamed:@"button_normal_highlight"]
         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6) resizingMode:UIImageResizingModeStretch];
    UIImage *barButtonNormalLandscapeImage =
        [[UIImage imageNamed:@"button_normal_landscape"]
         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6) resizingMode:UIImageResizingModeStretch];
    UIImage *barButtonNormalHighlightLandscapeImage =
        [[UIImage imageNamed:@"button_normal_highlight_landscape"]
         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6) resizingMode:UIImageResizingModeStretch];
    //iOS 6 allows usage of appearance proxy to customize done and normal buttons independently
    //downside to the following is that iOS 5 will not have blue color done style buttons, do we care?
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        [[UIBarButtonItem appearance] setBackgroundImage:barButtonNormalImage
                                                forState:UIControlStateNormal
                                                   style:UIBarButtonItemStyleBordered
                                              barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:barButtonNormalLandscapeImage
                                                forState:UIControlStateNormal
                                                   style:UIBarButtonItemStyleBordered
                                              barMetrics:UIBarMetricsLandscapePhone];
        
        [[UIBarButtonItem appearance] setBackgroundImage:barButtonNormalHighlightImage
                                                forState:UIControlStateHighlighted
                                                   style:UIBarButtonItemStyleBordered
                                              barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:barButtonNormalHighlightLandscapeImage
                                                forState:UIControlStateHighlighted
                                                   style:UIBarButtonItemStyleBordered
                                              barMetrics:UIBarMetricsLandscapePhone];
        
        [[UIBarButtonItem appearance] setBackgroundImage:barButtonDoneImage
                                                forState:UIControlStateNormal
                                                   style:UIBarButtonItemStyleDone
                                              barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:barButtonDoneLandscapeImage
                                                forState:UIControlStateNormal
                                                   style:UIBarButtonItemStyleDone
                                              barMetrics:UIBarMetricsLandscapePhone];
    } else {
        [[UIBarButtonItem appearance] setBackgroundImage:barButtonNormalImage
                                                forState:UIControlStateNormal
                                              barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:barButtonNormalLandscapeImage
                                                forState:UIControlStateNormal
                                              barMetrics:UIBarMetricsLandscapePhone];
        
        [[UIBarButtonItem appearance] setBackgroundImage:barButtonNormalHighlightImage
                                                forState:UIControlStateHighlighted
                                              barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:barButtonNormalHighlightLandscapeImage
                                                forState:UIControlStateHighlighted
                                              barMetrics:UIBarMetricsLandscapePhone];
    }
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor colorWithRed:183.0/255.0 green:187.0/255.0 blue:194.0/255.0 alpha:1.0],UITextAttributeTextColor,
                                [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5],UITextAttributeTextShadowColor,
                                [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                UITextAttributeTextShadowOffset,
                                nil];
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes
                                                forState:UIControlStateNormal];
    
//    UIImage *segmentSelected =
//        [[UIImage imageNamed:@"segcontrol_sel.png"]
//        resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
//    UIImage *segmentUnselected =
//        [[UIImage imageNamed:@"segcontrol_uns.png"]
//        resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
//    UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"segcontrol_sel-uns.png"];
//    UIImage *segUnselectedSelected = [UIImage imageNamed:@"segcontrol_uns-sel.png"];
//    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"segcontrol_uns-uns.png"];
//    
//    [[UISegmentedControl appearance] setBackgroundImage:segmentUnselected
//                                               forState:UIControlStateNormal
//                                             barMetrics:UIBarMetricsDefault];
//    [[UISegmentedControl appearance] setBackgroundImage:segmentSelected
//                                               forState:UIControlStateSelected
//                                             barMetrics:UIBarMetricsDefault];
//    
//    [[UISegmentedControl appearance] setDividerImage:segmentUnselectedUnselected
//                                 forLeftSegmentState:UIControlStateNormal
//                                   rightSegmentState:UIControlStateNormal
//                                          barMetrics:UIBarMetricsDefault];
//    [[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected
//                                 forLeftSegmentState:UIControlStateSelected
//                                   rightSegmentState:UIControlStateNormal
//                                          barMetrics:UIBarMetricsDefault];
//    [[UISegmentedControl appearance] setDividerImage:segUnselectedSelected
//                                 forLeftSegmentState:UIControlStateNormal
//                                   rightSegmentState:UIControlStateSelected
//                                          barMetrics:UIBarMetricsDefault];
    
//    [[UISwitch appearance] setTintColor:[UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:58.0/255.0 alpha:1.0]];
//    [[UISwitch appearance] setOnTintColor:[UIColor colorWithRed:119.0/255.0 green:197.0/255.0 blue:254.0/255.0 alpha:1.0]];
}

- (void)dealloc {
    self.navigationController = nil;
    self.window = nil;
    self.contentNavigationController = nil;
    self.slideOutViewController = nil;
    [super dealloc];
}

@end
