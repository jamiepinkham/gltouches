#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EGLView.h"

@interface EGLView (EGLViewPrivate)

- (bool)createBuffers;
- (void)destroyBuffers;

@end




@implementation EGLView

@synthesize currentSpinVector;

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (void)layoutSubviews{
	[EAGLContext setCurrentContext:context];
	[self destroyBuffers];
	[self createBuffers];
}

- (bool)createBuffers
{
	
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return false;
	}
	
	return true;
}

- (void)destroyBuffers
{
	if(viewFramebuffer){
		glDeleteFramebuffersOES(1, &viewFramebuffer);
	}
	viewFramebuffer = 0;
	
	if(viewRenderbuffer){
		glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	}
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer) {
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
	}
	depthRenderbuffer = 0;
}

void Perspective (GLfloat fovy, GLfloat aspect, GLfloat zNear,  
				  GLfloat zFar) 
{ 
	GLfloat xmin, xmax, ymin, ymax;
	ymax = zNear * ((GLfloat)tan(fovy * 3.1415962f / 360.0f));   
	ymin = -ymax; 
	xmin = ymin * aspect; 
	xmax = ymax * aspect;   
}

- (void)setupView
{
	
	GLint backingWidth,backingHeight;
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	glViewport(0, 0, backingWidth, backingHeight);
	
	float ratio = (float)(backingWidth)/(backingHeight); 
	
	glMatrixMode(GL_PROJECTION); 
	glLoadIdentity();
	
	Perspective(45.0f,ratio, 1.0f, 40.0f);
	
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
}

- (id)initWithCoder:(NSCoder*)coder
{
	if(self = [super initWithCoder:coder]) {
		// Get the layer
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
		
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties =
		[NSDictionary dictionaryWithObjectsAndKeys:
		 [NSNumber numberWithBool:FALSE],
		 kEAGLDrawablePropertyRetainedBacking,
		 kEAGLColorFormatRGBA8,
		 kEAGLDrawablePropertyColorFormat,
		 nil
         ];
		
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if(!context || ![EAGLContext setCurrentContext:context] || ![self createBuffers]) {
			[self release];
			return nil;
		}
		
		currentSpinVector = CGPointMake(1.0f,0.25f);
		currentSpinRotation = CGPointMake(0.0f,0.0f);
		
		[self setupView];
		
		viewUpdateTimerInterval = 1.0 / 60.0; // 60fps
		viewUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:viewUpdateTimerInterval 
                                                           target:self 
                                                         selector:@selector(updateView) 
                                                         userInfo:nil 
                                                          repeats:YES];
		
	}
	return self;
}



- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    //[self renderEAGL];
}

- (void)updateView{
	float secondsElapsed = 1.0f;
	currentSpinRotation.x += currentSpinVector.x * secondsElapsed;
	currentSpinRotation.y += currentSpinVector.y * secondsElapsed;
    
	[self renderEAGL];
}

- (void)renderEAGL{
	
	// indicies or the faces

	static GLubyte faces[6][4] = {
		{2,1,3,0},
		{5,6,4,7},
		{6,2,7,3},
		{1,5,0,4},
		{3,0,7,4},
		{6,5,2,1}
	};
	
	// points for the box
	static GLfloat vertices[] = {
		-0.5f,-0.5f,-0.5f,
		0.5f,-0.5f,-0.5f,
		0.5f,0.5f,-0.5f,
		-0.5f,0.5f,-0.5f,
		-0.5f,-0.5f,0.5f,
		0.5f,-0.5f,0.5f,
		0.5f,0.5f,0.5f,
		-0.5f,0.5f,0.5f
	};
	
	[EAGLContext setCurrentContext:context];
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glLoadIdentity();
	
	//glTranslatef(currentSpinRotation.x,0,0);
	
	float m = sqrt((currentSpinRotation.x*currentSpinRotation.x)+(currentSpinRotation.y*currentSpinRotation.y));
	glRotatef(m,0,currentSpinRotation.x/m,currentSpinRotation.y/m);
    
	glEnableClientState(GL_VERTEX_ARRAY); 
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glColor4f(1.0f,1.0f,1.0f,1.0f);
	for(unsigned int i = 0; i < 6; i++){
		glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_BYTE, faces[i]);
	}
	glDisableClientState(GL_VERTEX_ARRAY);
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
}

-(void)setCubeTexture:(UIImage *)image{

}

- (void)dealloc {
    [super dealloc];
}


@end
