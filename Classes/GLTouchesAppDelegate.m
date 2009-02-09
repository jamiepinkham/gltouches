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


-(IBAction)showImagePicker
{
    if(imagePickerController == nil)
	{
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		imagePickerController = picker;
		[picker release];
	}
    
	[imagePickerController setDelegate:self];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentModalViewController:imagePickerController animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *filename = [documentsDirectory stringByAppendingPathComponent:@"SavedImage"];
    
    [imageData writeToFile:filename atomically:NO];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
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
