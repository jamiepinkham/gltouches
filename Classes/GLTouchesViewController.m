//
//  GLTouchesViewController.m
//  GLTouches
//
//  Created by Jamie Pinkham on 2/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "MachTimer.h"
#import "EGLView.h"
#import "GLTouchesViewController.h"

@implementation GLTouchesViewController

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count]) {
        case 1: { //Single touch
            
            //Get the first touch.
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
            
            switch ([touch tapCount])
            {
                case 1: //Single Tap.
                {
                    [precisionTimer start];
                    beginPoint = [touch locationInView:[self view]];
                    //Start a timer for 2 seconds.
                    //timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self 
                    //                                       selector:@selector(showAlertView:) userInfo:nil repeats:NO];
                    
                    //[timer retain];
                } break;
                case 2: {//Double tap. 
                    
                } break;
            }
        } break;
        case 2: { //Double Touch
            //Track the initial distance between two fingers.
            UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
            UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
            
            initialDistance = [self distanceBetweenTwoPoints:[touch1 locationInView:[self view]] 
                                                     toPoint:[touch2 locationInView:[self view]]];
			initialZoomFactor = [eglView zoomFactor];
            
        } break;
        default:
            break;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count])
    {
        case 1: {
            
        } break;
        case 2: {
            //The image is being zoomed in or out.
            
            UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
            UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
            
            //Calculate the distance between the two fingers.
            CGFloat finalDistance = [self distanceBetweenTwoPoints:[touch1 locationInView:[self view]]
                                                           toPoint:[touch2 locationInView:[self view]]];
            
            //Check if zoom in or zoom out.
			
			CGFloat dist = initialDistance - finalDistance;
            NSLog(@"%f = dist initial > final", dist);
            [eglView setZoomFactor: initialZoomFactor+(dist / 300) ];
        } break;
    }
    
}

- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
    
    float x = toPoint.x - fromPoint.x;
    float y = toPoint.y - fromPoint.y;
    
    return sqrt(x * x + y * y);
}

-(void)clearTouches{
    initialDistance = -1;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self clearTouches];
    NSSet *allTouches = [event allTouches];
    switch ([allTouches count]) {
        case 1:{
            NSLog(@"%f = [precisionTimer elapsedSeconds]", [precisionTimer elapsedSeconds]);
            UITouch *touch = [[event allTouches] anyObject];
            endPoint = [touch locationInView:[touch view]];
			CGFloat dx = endPoint.x - beginPoint.x;
			CGFloat dy = endPoint.y - beginPoint.y;
            if((abs(dx) > 10) || (abs(dy) > 10)){
                CGPoint vector = CGPointMake(dx, dy);
				float f = [precisionTimer elapsedSeconds] * 1000.0f;
				vector.x /= f;
				vector.y /= f;
                [eglView setCurrentSpinVector:vector];
            }
        }
            
            break;
        default:
            break;
    }
    NSLog(@"touches ended");
}



// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

-(IBAction) showImagePicker
{
    if(imagePickerController == nil)
	{
		imagePickerController = [[UIImagePickerController alloc] init];
	}
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentModalViewController:imagePickerController animated:YES];
}


//THIS IS THE METHOD CALLED WHEN SOMEONE IS DONE PICKING AN IMAGE
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	[eglView setCubeTexture:image];
    [picker dismissModalViewControllerAnimated:YES];
}
/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    precisionTimer = [[MachTimer alloc] init];
    [super viewDidLoad];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [eglView dealloc];
    [imagePickerController dealloc];
    [precisionTimer dealloc];
    [super dealloc];
}

@end
