//
//  GLView.h
//  GLTouches
//
//  Created by Jamie Pinkham on 2/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "MachTimer.h"


@interface EGLView : UIView {
    
    CGPoint currentSpinVector;
	CGFloat zoomFactor;
@private
	
	EAGLContext* context;
	
	GLuint
    viewRenderbuffer,
    viewFramebuffer,
    depthRenderbuffer,
	textureID;
	
	NSTimer* viewUpdateTimer;
	NSTimeInterval viewUpdateTimerInterval;
    CGPoint currentSpinRotation;
    MachTimer* degradingTimer;
}

//@property(nonatomic) CGPoint currentSpinVector;
@property(nonatomic) CGFloat zoomFactor;

-(void)updateView;
-(void)setCubeTexture:(UIImage *)anImage;
-(void)renderEAGL;
-(int)nearestPowerOfTwo:(int)aNumber;
-(void)setCurrentSpinVector:(CGPoint)aVector;

@end

