/* ************************************************************************************************************
This class provides an interface to the ~/Library/StickiesDatabase file as of
OS X v10.3.8, Stickies v4.2, and is the same code used in StYNCies--a neat little utility that synchronizes 
your Stickies to your iPod and/or iDisk. See the "Inside StYNCies" articles on http://www.macdevcenter.com
for more details and example usage.

This class uses an NSAttributedString category addition for transforming RTF to HTML released by
Grayson Hansard under and is maintained at http://www.fromconcentratesoftware.com


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
#import <Cocoa/Cocoa.h>

//window flags
extern int ST_CLOSED;
extern int ST_OPEN;

//window colors	
extern int ST_YELLOW;
extern int ST_BLUE;
extern int ST_GREEN;
extern int ST_PINK;
extern int ST_PURPLE;
extern int ST_GREY;

//versioning
extern int ST_VERSION_4_2;
extern int ST_VERSION_5_0;

@interface Document : NSObject <NSCoding> {
    int mWindowColor;
    int mWindowFlags;
	NSRect mWindowFrame;
    NSData *mRTFDData;
    NSDate *mCreationDate;
    NSDate *mModificationDate;
}

/**********************************************************
Methods not from class-dump: conveniences
**********************************************************/

//for ease of writing a note when the rtf
//details aren't relevant
- (id)initWithString:(NSString*)s;

//the first "length" characters of the document,
//breaking early if control chars are reached.
- (NSString*)documentTitleOfLength:(int)length;

//just the plain text on the note
- (NSString*)stringValue;

//the rtf text converted to html, with images
-(NSString*)convertToHTMLsavingImagesToPath:(NSString *)imgPath;

/**********************************************************
Methods from the interface generated from class-dump 
**********************************************************/

//Calls designated initializer
- (id)init;

//Designated initializer
- (id)initWithData:(NSData*)fp8;

//Clean up
- (void)dealloc;

//For reading/writing to disk using NSArchiver 
- (id)initWithCoder:(NSCoder*)fp8;
- (void)encodeWithCoder:(NSCoder*)fp8;

//Key Value Coding (KVC) methods
- (NSDate*)creationDate;
- (void)setCreationDate:(NSDate*)fp8;
- (NSDate*)modificationDate;
- (void)setModificationDate:(NSDate*)fp8;
- (NSData*)RTFDData;
- (void)setRTFDData:(NSData*)fp8;
- (int)windowColor;
- (void)setWindowColor:(int)fp8;
- (int)windowFlags;
- (void)setWindowFlags:(int)fp8;
- (NSRect)windowFrame;
- (void)setWindowFrame:(NSRect)fp8;

@end
