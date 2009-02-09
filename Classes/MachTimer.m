//
//  MachTimer.m
//  GLTouches
//
//  Created by Jamie Pinkham on 2/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MachTimer.h"

static mach_timebase_info_data_t timebase;

@implementation MachTimer
+ (void)initialize
{
	(void) mach_timebase_info(&timebase);
}


- init
{
	if(self = [super init]) {
		t0 = mach_absolute_time();
	}
	return self;
}

- (void)start
{
	t0 = mach_absolute_time();
}

- (float)elapsedSeconds {
	return ((float)(mach_absolute_time() - t0)) * ((float)timebase.numer) / ((float)timebase.denom) / 1000000000.0f;
}
@end
