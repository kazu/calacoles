//
//  NSAttributedString+FCSAdditions.h
//  FCSFramework
//
//  Created by Grayson Hansard on 12/2/04.
//  Copyright 2004 From Concentrate Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSColor+FCSAdditions.h"

@interface NSAttributedString (FCSAdditions)

-(NSArray *)paragraphs;

-(NSString *)convertToHTML;
-(NSString *)convertToHTMLWithTitle:(NSString *)title;
-(NSString *)convertToHTMLPreservingImages:(BOOL)preserveIMG 
						savingImagesToPath:(NSString *)imgPath
								 withTitle:(NSString *)htmlTitle;
-(BOOL)exportAsHTMLToPath:(NSString *)path withTitle:(NSString *)htmlTitle;

@end
