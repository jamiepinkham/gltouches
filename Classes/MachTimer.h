//
//  MachTimer.h
//  GLTouches
//
//  Created by Jamie Pinkham on 2/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include <assert.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <unistd.h>

@interface MachTimer : NSObject {
	uint64_t t0;
}

- (void)start;
- (float)elapsedSeconds;

@end
