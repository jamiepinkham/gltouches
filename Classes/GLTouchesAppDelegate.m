//
//  GLTouchesAppDelegate.m
//  GLTouches
//
//  Created by Jamie Pinkham on 2/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "GLTouchesAppDelegate.h"
#import "GLTouchesViewController.h"

@implementation GLTouchesAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    //comment to make this need to be commited to git.
    [application setStatusBarHidden:YES animated:YES];
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
