#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <CoreGraphics/CoreGraphics.h>

#import "EGLView.h"

@interface EGLView (EGLViewPrivate)

- (bool)createBuffers;
- (void)destroyBuffers;

@end

@implementation EGLView

@synthesize currentSpinVector;
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
		zoomFactor = 0.5f;
		
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
	
	// 2 float => texture coordinate
	// 3 float => vertex position
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
	
	// Cube's faces (list of indexes)
	static const GLubyte elements[] =
	{
		0,1,2,3,
		4,5,6,7,
		8,9,10,11,
		12,13,14,15,
		16,17,18,19,
		20,21,22,23,
	};
	
	[EAGLContext setCurrentContext:context];
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glLoadIdentity();
	
	float m = sqrt((currentSpinRotation.x*currentSpinRotation.x)+(currentSpinRotation.y*currentSpinRotation.y));
	glRotatef(m,0,currentSpinRotation.x/m,currentSpinRotation.y/m);
	glScalef(zoomFactor,zoomFactor,zoomFactor);
    
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D,textureID);
	
	glTexCoordPointer(2, GL_FLOAT, 5*sizeof(GL_FLOAT), vertices);
	glVertexPointer(3, GL_FLOAT, 5*sizeof(GL_FLOAT), vertices + 2);
	
	glColor4f(1.0f,1.0f,1.0f,1.0f);
	for(unsigned int i = 0; i < 6; i++){
		glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_BYTE, elements + (i*4));
	}
	glFlush();
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
}

-(void)setCubeTexture:(UIImage *)image{
    CGImageRef textureImage = image.CGImage;
    size_t width = CGImageGetWidth(textureImage);
    size_t height = CGImageGetHeight(textureImage);
    if(textureImage){
        
		// TODO: have the texture size be powers of two and down(its a mobile device) sample the image to fit
		size_t newTextureWidth = width;
		size_t newTextureHeight = height;
		
		GLubyte* textureData = (GLubyte *) malloc(newTextureWidth * newTextureHeight * 4);
        CGContextRef textureContext = CGBitmapContextCreate(textureData, width, height, 8, width * 4, CGImageGetColorSpace(textureImage), kCGImageAlphaPremultipliedLast);
        
		
		CGContextDrawImage(textureContext, CGRectMake(0,0,(CGFloat)width,(CGFloat)height), textureImage);
        
		
		
        CGContextRelease(textureContext);
        
		glEnable(GL_TEXTURE_2D);
        // Use OpenGL ES to generate a name for the texture.
		glGenTextures(1, &textureID);
		// Bind the texture name. 
		glBindTexture(GL_TEXTURE_2D, textureID);
		// Speidfy a 2D texture image, provideing the a pointer to the image data in memory
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
		// Release the image data
		free(textureData);
		
		// Set the texture parameters to use a minifying filter and a linear filer (weighted average)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		
		// Enable use of the texture
		// Set a blending function to use
		//glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		// Enable blending
		//glEnable(GL_BLEND);
        
    }
}

-(void)addZoomFactor:(CGFloat)df{
    if(zoomFactor + df < 0)
        zoomFactor = 0.1f;
    else if(zoomFactor + df > 1.0f)
        zoomFactor = 1.0f;
    else
        zoomFactor+=df;
    NSLog(@"%f = df",df);
}
- (void)dealloc {
    [super dealloc];
}


@end
