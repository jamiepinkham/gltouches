#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <CoreGraphics/CoreGraphics.h>

#import "EGLView.h"

@interface EGLView (EGLViewPrivate)

- (bool)createBuffers;
- (void)destroyBuffers;

@end

@implementation EGLView

//@synthesize currentSpinVector;
@synthesize zoomFactor;

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
	
	GLint backingWidth,backingHeight;
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	glGenRenderbuffersOES(1, &depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES,GL_DEPTH_COMPONENT16_OES,backingWidth,backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
	
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

- (void)setupView
{
	
	GLint backingWidth,backingHeight;
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);	
	
	glMatrixMode(GL_PROJECTION); 
	glLoadIdentity();
	
	// setup the view frustrum
	GLfloat fov = 0.785398163397f;
	GLfloat zNear = 0.05f;
	GLfloat zFar = 1000.0f;
	GLfloat aspect = (GLfloat)backingWidth / (GLfloat)backingHeight;
	GLfloat t = zNear * tan(fov * 0.5f);
	glFrustumf(
			   -t * aspect,
			   t * aspect,
			   -t,
			   t,
			   zNear,
			   zFar
	);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glViewport(0, 0, backingWidth, backingHeight);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
}

- (id)initWithCoder:(NSCoder*)coder
{
	if(self = [super initWithCoder:coder]) {
		// init values
		currentSpinVector = CGPointMake(1.0f,0.25f);
		currentSpinRotation = CGPointMake(0.0f,0.0f);
		zoomFactor = 0.5f;
		degradingTimer = [[MachTimer alloc] init];
        [degradingTimer start];
		// Get the layer
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
		// set it up
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties =
		[NSDictionary dictionaryWithObjectsAndKeys:
		 [NSNumber numberWithBool:FALSE],
		 kEAGLDrawablePropertyRetainedBacking,
		 kEAGLColorFormatRGBA8,
		 kEAGLDrawablePropertyColorFormat,
		 nil
         ];
		
		// create an opengl context for the view
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		// create the buffers
		if(!context || ![EAGLContext setCurrentContext:context] || ![self createBuffers]) {
			[self release];
			return nil;
		}
		// set the opengl states
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
}

- (void)updateView{
    float degradingFactor = [degradingTimer elapsedSeconds] / 5;

	currentSpinRotation.x += currentSpinVector.x / ([degradingTimer elapsedSeconds] / 5);
	currentSpinRotation.y += currentSpinVector.y / ([degradingTimer elapsedSeconds] / 5);  
	[self renderEAGL];
}

-(void)setCurrentSpinVector:(CGPoint)aVector{
    NSLog(@"%f new spin vector = ",aVector);
    currentSpinVector = aVector;
    [degradingTimer start];
}

- (void)renderEAGL{
	
	// standard cube vertex data from some forum
	static const GLfloat vertices[] =
	{
		0.0f,0.0f,1.0,-1.0,1.0,         // 2
		1.0f,0.0f,1.0,1.0,1.0,         // 6
		0.0f,1.0f,-1.0,-1.0,1.0,      // 3
		1.0f,1.0f,-1.0,1.0,1.0,         // 7
		
		0.0f,0.0f,-1.0,1.0,-1.0,      // 4
		1.0f,0.0f,1.0,1.0,-1.0,         // 5
		0.0f,1.0f,-1.0,-1.0,-1.0,      // 0
		1.0f,1.0f,1.0,-1.0,-1.0,      // 1
		
		0.0f,0.0f,-1.0,1.0,1.0,         // 7
		1.0f,0.0f,-1.0,1.0,-1.0,      // 4
		0.0f,1.0f,-1.0,-1.0,1.0,      // 3
		1.0f,1.0f,-1.0,-1.0,-1.0,      // 0
		
		0.0f,0.0f,1.0,-1.0,-1.0,      // 1
		1.0f,0.0f,1.0,1.0,-1.0,         // 5
		0.0f,1.0f,1.0,-1.0,1.0,         // 2
		1.0f,1.0f,1.0,1.0,1.0,         // 6
		
		0.0f,0.0f,-1.0,1.0,-1.0,      // 4
		1.0f,0.0f,-1.0,1.0,1.0,         // 7
		0.0f,1.0f,1.0,1.0,-1.0,         // 5
		1.0f,1.0f,1.0,1.0,1.0,         // 6
		
		0.0f,0.0f,-1.0,-1.0,1.0,      // 3
		1.0f,0.0f,-1.0,-1.0,-1.0,      // 0
		0.0f,1.0f,1.0,-1.0,1.0,         // 2
		1.0f,1.0f,1.0,-1.0,-1.0,      // 1
	};
	static const GLubyte elements[] =
	{
		0,1,2,3,
		4,5,6,7,
		8,9,10,11,
		12,13,14,15,
		16,17,18,19,
		20,21,22,23,
	};
	// this thread will use the view's current context
	[EAGLContext setCurrentContext:context];
	// choose the buffers and clear them
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	// set the modelview matrix
	glLoadIdentity();
	float m = sqrt((currentSpinRotation.x*currentSpinRotation.x)+(currentSpinRotation.y*currentSpinRotation.y));
	glTranslatef(0,0,-10.0f);
	glScalef(zoomFactor,zoomFactor,zoomFactor);
	glRotatef(m,currentSpinRotation.y/m,currentSpinRotation.x/m,0);
	// set the base color to white
	glColor4f(1.0f,1.0f,1.0f,1.0f);
	// turn depth testing on (z-buffer)
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	// enable and prepare texture info for cube faces
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindTexture(GL_TEXTURE_2D,textureID);	
	glTexCoordPointer(2, GL_FLOAT, 5*sizeof(GL_FLOAT), vertices);
	// enable and prepare vertex position info for cube faces
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, 5*sizeof(GL_FLOAT), vertices + 2);
	// render each of the 6 faces
	for(unsigned int i = 0; i < 6; i++){
		glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_BYTE, elements + (i*4));
	}
	// ensure all rendering commands have completed
	glFlush();
	// swap the render buffers (show what we made)
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
}
-(int)nearestPowerOfTwo:(int)n{
    int size = 0;
    
    while (n){
        size++;
        n >>= 1;
    }
    return 2 << ( size ? (size-1) : 0 );
	
}

-(void)setCubeTexture:(UIImage *)anImage{
    
    CGImageRef textureImage = anImage.CGImage;
    size_t width = CGImageGetWidth(textureImage);
    size_t height = CGImageGetHeight(textureImage);
    if(textureImage){
        // texture width and height need to be powers of two, so we resize the image
		size_t newTextureWidth = [self nearestPowerOfTwo:(int)width];
		size_t newTextureHeight = [self nearestPowerOfTwo:(int)height];
        
		GLubyte* textureData = (GLubyte *) malloc(newTextureWidth * newTextureHeight * 4);
        CGContextRef textureContext = CGBitmapContextCreate(textureData, 
                                                            newTextureWidth, 
                                                            newTextureHeight, 8, 
                                                            newTextureWidth * 4, 
                                                            CGImageGetColorSpace(textureImage), 
                                                            kCGImageAlphaPremultipliedLast);
        
		
		CGContextDrawImage(textureContext, CGRectMake(0,0,(CGFloat)newTextureWidth,(CGFloat)newTextureHeight), textureImage);
        
        CGContextRelease(textureContext);
        
		glEnable(GL_TEXTURE_2D);
        // Use OpenGL ES to generate a name for the texture.
		glGenTextures(1, &textureID);
		// Bind the texture name. 
		glBindTexture(GL_TEXTURE_2D, textureID);
		// Speidfy a 2D texture image, provideing the a pointer to the image data in memory
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, newTextureWidth, newTextureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
		// Release the image data
		free(textureData);
		
		// Set the texture parameters to use a minifying filter and a linear filer (weighted average)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        
    }
}

- (void)dealloc {
    [super dealloc];
}


@end
