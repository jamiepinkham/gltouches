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
    NSLog(@"touches began");
    [precisionTimer start];
    UITouch  *touch = [[event allTouches] anyObject];
    beginPoint = [touch locationInView:touch.view];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches ended");
    NSLog(@"%f = [precisionTimer elapsedSeconds]", [precisionTimer elapsedSeconds]);
    UITouch *touch = [[event allTouches] anyObject];
    endPoint = [touch locationInView:[touch view]];
    CGPoint vector = CGPointMake(endPoint.x - beginPoint.x, beginPoint.y - endPoint.y);
    
    NSLog(@"%f, %f = vector x, vector y", vector.x, vector.y);
    float speed = (sqrt((vector.x * vector.x) + (vector.y * vector.y)) / [precisionTimer elapsedSeconds]);
    NSLog(@"%f = acceleration", speed);
    float m = sqrt((vector.x * vector.x) + (vector.y * vector.y));
	if(0.0f != m){
		float f = (speed / 100.0f) / m;
		vector.x *= f;
		vector.y *= f;
	}
    [self.view setCurrentSpinVector:vector];
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
	[self.view setCubeTexture:image];
    //NSData *imageData = UIImagePNGRepresentation(image);
    
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
        
    //NSString *filename = [documentsDirectory stringByAppendingPathComponent:@"SavedImage"];
    //[imageData writeToFile:filename atomically:NO];
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



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [self.view dealloc];
    [imagePickerController dealloc];
    [precisionTimer dealloc];
    [super dealloc];
}

@end
