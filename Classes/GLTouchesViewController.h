//
//  GLTouchesViewController.h
//  GLTouches
//
//  Created by Jamie Pinkham on 2/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MachTimer.h"
#import "EGLView.h"

@class EGLView;
@class MachTimer;

@interface GLTouchesViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UIButton *button;
    IBOutlet UIImagePickerController *imagePickerController;

    
@private
    MachTimer *precisionTimer;
    CGPoint beginPoint;
    CGPoint endPoint;   
    CGFloat initialDistance;

}

-(IBAction)showImagePicker;
-(CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;
-(void)clearTouches;

@end

