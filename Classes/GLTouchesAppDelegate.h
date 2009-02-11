//
//  GLTouchesAppDelegate.h
//  GLTouches
//
//  Created by Jamie Pinkham on 2/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLTouchesViewController;

@interface GLTouchesAppDelegate : NSObject <UIApplicationDelegate, UIImagePickerControllerDelegate> {
    UIWindow *window;
    GLTouchesViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GLTouchesViewController *viewController;

@end

