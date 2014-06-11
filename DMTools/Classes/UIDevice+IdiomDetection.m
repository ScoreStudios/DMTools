//
//  UIDevice+IdiomDetection.m
//  DM Tools
//
//  Created by hamouras on 05/08/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "UIDevice+IdiomDetection.h"
#ifndef MASTER
#	include <assert.h>
#	include <sys/types.h>
#	include <unistd.h>
#	include <sys/sysctl.h>
#endif


static UIUserInterfaceIdiom sCurrentDeviceIdiom = UIUserInterfaceIdiomPhone;
static BOOL sIdiomSet = NO;

@implementation UIDevice(IdiomDetection)

- (BOOL) isIPad
{
	if (__builtin_expect(sIdiomSet, YES) == NO)
	{
		sCurrentDeviceIdiom = UI_USER_INTERFACE_IDIOM();
		sIdiomSet = YES;
	}
	return sCurrentDeviceIdiom == UIUserInterfaceIdiomPad;
}

- (BOOL) isIPhone
{
	if (__builtin_expect(sIdiomSet, YES) == NO)
	{
		sCurrentDeviceIdiom = UI_USER_INTERFACE_IDIOM();
		sIdiomSet = YES;
	}
	return sCurrentDeviceIdiom == UIUserInterfaceIdiomPhone;
}


#ifndef MASTER
- (BOOL) hasDebuggerAttached
{
	int junk;
	int mib[4];
    struct kinfo_proc info;
    size_t size;
	
    // Initialize the flags so that, if sysctl fails for some bizarre 
    // reason, we get a predictable result.
	
    info.kp_proc.p_flag = 0;
	
    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.
	
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
	
    // Call sysctl.
	
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
	
    // We're being debugged if the P_TRACED flag is set.
	
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}
#endif
	
@end
