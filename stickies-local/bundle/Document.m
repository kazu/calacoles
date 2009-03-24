/* ************************************************************************************************************
This code provides an interface to the ~/Library/StickiesDatabase file as of
OS X v10.3.8, Stickies v4.2, and is the same code used in StYNCies--a neat little utility that synchronizes 
your Stickies to your iPod and/or iDisk. See the "Inside StYNCies" articles on http://www.macdevcenter.com
for more details and example usage.

This class uses an NSAttributedString category addition for transforming RTF to HTML released by
Grayson Hansard and is maintained at http://www.fromconcentratesoftware.com


Copyright (C) 2004 Matthew Russell - http://russotle.com/styncies.html

Update: 7 July 05
This class appears to work just fine with the Stickies v5.0 release in Tiger. These files are bundled as part
of another macdevcenter tutorial on creating a Spotlight plugin for Stickies.

This program is free software; you can redistribute it and/or modify it under the terms of the 
GNU General Public License as published by the Free Software Foundation; either version 2 of the License, 
or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, 
write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
***********************************************************************************************************/
#import "Document.h"

/* Available from http://www.fromconcentratesoftware.com */
#import "NSAttributedString+FCSAdditions.h"

//window flags
int ST_OPEN =0;
int ST_CLOSED =1;

//window colors	
int ST_YELLOW =0;
int ST_BLUE =1;
int ST_GREEN =2;
int ST_PINK =3;
int ST_PURPLE =4;
int ST_GREY =5;

//versioning --1 is used by Stickies.app for 4.2
int ST_VERSION_4_2 = 1;
int ST_VERSION_5_0 = 1;

@implementation Document

//this did not appear in the output from class-dump, but
//is necessary or else Stickies will not read the notes
//written back to StickiesDatabase
+ (void)initialize {
	[self setVersion:ST_VERSION_5_0];
}

//this did not appear in the output from class-dump, but
//is a nice convenience to have around
- (id)initWithString:(NSString*)s {
	//NSLog(@"^^^initWithString:");
	//call designated initializer.
	//this is how to create/pass in the rtfd data
	NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
	[atts setValue:[NSFont fontWithName:@"Helvetica" size:0.0] forKey:NSFontAttributeName];
	NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:s attributes:atts];
	[self initWithData:[attStr RTFDFromRange:NSMakeRange(0, 11) documentAttributes:nil]];
	[attStr release];
	[atts release];
	return self;	
}

- (NSString*)stringValue {
	NSAttributedString *str = 
		[[NSAttributedString alloc] initWithRTFD:[self RTFDData] documentAttributes:NULL];
	
	[str autorelease];
	return [str string];
}

- (NSString*)documentTitleOfLength:(int)length {
	//the first "length" chars may contain control chars like newline. These don't 
	//look so good as filenames. Take either the first "length" chars
	//or chars until a control char is reached
	NSString *t;
	
	if ([[self stringValue] length] >= length)
	{
		t = [[self stringValue] substringToIndex:length];
	}
	else
	{
		t = [self stringValue];
	}
	
	NSRange controlRange = 
		[t rangeOfCharacterFromSet:[NSCharacterSet controlCharacterSet]];
	
	if (controlRange.location > length)
	{
		return t;
	}
	else
	{
		return [t substringToIndex:controlRange.location];
	
	}
}

-(NSString*)convertToHTMLsavingImagesToPath:(NSString*)imgPath {
	NSAttributedString *str = 
	[[NSAttributedString alloc] initWithRTFD:[self RTFDData] 
						  documentAttributes:NULL];
	[str autorelease];
	
	return [str convertToHTMLPreservingImages:YES 
						   savingImagesToPath:imgPath
									withTitle:[[self documentTitleOfLength:30] stringByAppendingString:@"..."]
			];
}

/**************************************************/
/* This point on is the interface from class-dump */
/**************************************************/

//probably sets some reasonable defaults
- (id)init {
	//call designated initializer.
	return [self initWithString:@""];
}
//probably the designated initializer
- (id)initWithData:(NSData*)fp8 {
	[super init];
	[self setWindowColor:ST_YELLOW];
	[self setWindowFlags:ST_OPEN];
	[self setCreationDate:[NSDate date]];
	[self setModificationDate:[NSDate date]];
	[self setWindowFrame:NSMakeRect(21.0, 678.0, 300.0, 200.0)];
	[self setRTFDData:fp8];
	return self;
}

- (void)dealloc {
	//NSLog(@"^^^dealloc:");
	[mRTFDData release];
	[mCreationDate release];
	[mModificationDate release];
	[super dealloc];
}

//unarchive
- (id)initWithCoder:(NSCoder*)fp8 {
	//NSLog(@"^^^initWithCoder:");
	[super init];
	mRTFDData = [[fp8 decodeObject] retain];
	[fp8 decodeValueOfObjCType:@encode(int) at:&mWindowFlags];
	[fp8 decodeValueOfObjCType:@encode(NSRect) at:&mWindowFrame];
	[fp8 decodeValueOfObjCType:@encode(int) at:&mWindowColor];
	mCreationDate = [[fp8 decodeObject] retain];
	mModificationDate = [[fp8 decodeObject] retain];
	return self;
}

//archive
- (void)encodeWithCoder:(NSCoder*)fp8 {
	[fp8 encodeObject:[self RTFDData]];
	[fp8 encodeValueOfObjCType:@encode(int) at:&mWindowFlags];	
	[fp8 encodeValueOfObjCType:@encode(NSRect) at:&mWindowFrame];
	[fp8 encodeValueOfObjCType:@encode(int) at:&mWindowColor];
	[fp8 encodeObject:[self creationDate]];
	[fp8 encodeObject:[self modificationDate]];
	
	//NSLog(@"encodeWithCoder: %d",[fp8 versionForClassName:@"Document"]);
}
- (NSDate*)creationDate {
	return mCreationDate;
}
- (void)setCreationDate:(NSDate*)fp8 {
	[fp8 retain];
	[mCreationDate release];
	mCreationDate = fp8;
}
- (NSDate*)modificationDate {
	return mModificationDate;
}
- (void)setModificationDate:(NSDate*)fp8 {
	[fp8 retain];
	[mModificationDate release];
	mModificationDate = fp8;
}
- (NSData*)RTFDData {
	return mRTFDData;
}
- (void)setRTFDData:(NSData*)fp8 {
	[fp8 retain];
	[mRTFDData release];
	mRTFDData = fp8;
	[self setModificationDate:[NSDate date]];
}
- (int)windowColor {
	return mWindowColor;
}
- (void)setWindowColor:(int)fp8 {
	mWindowColor = fp8;
	[self setModificationDate:[NSDate date]];
}
- (int)windowFlags {
	return mWindowFlags;
}
- (void)setWindowFlags:(int)fp8 {
	mWindowFlags =fp8;
	[self setModificationDate:[NSDate date]];
}
- (NSRect)windowFrame {
	return mWindowFrame;
}
- (void)setWindowFrame:(NSRect)fp8 {
	mWindowFrame = fp8;
	[self setModificationDate:[NSDate date]];
}
@end

void Init_document(){}
