//
//  NSColor+FCSAdditions.m
//  FCSFramework
//
//  Created by Grayson Hansard on 12/4/04.
//  Copyright 2004 From Concentrate Software. All rights reserved.
//

#import "NSColor+FCSAdditions.h"


@implementation NSColor (FCSAdditions)

-(NSString *)hexidecimalRepresentation
{
	int r, g, b;
	r = [self redComponent] * 255.0;
	g = [self greenComponent] * 255.0;
	b = [self blueComponent] * 255.0;
	
	return [NSString stringWithFormat:@"#%02x%02x%02x",r,g,b];
}

@end
