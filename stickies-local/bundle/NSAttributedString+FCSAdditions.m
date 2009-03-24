//
//  NSAttributedString+FCSAdditions.m
//  FCSFramework
//
//  Created by Grayson Hansard on 12/2/04.
//  Copyright 2004 From Concentrate Software. All rights reserved.
//

#import "NSAttributedString+FCSAdditions.h"


@implementation NSAttributedString (FCSAdditions)

-(NSArray *)paragraphs
{
	NSString *s = [self string], *t = [NSString string];
	unsigned int pos;
	NSRange r = {0,0};
	NSArray *a = [s componentsSeparatedByString:@"\n"];
	NSMutableArray *p = [NSMutableArray array];
	NSEnumerator *e = [a objectEnumerator];
	while (t = [e nextObject])
	{ 
		r.location += r.length;
		r.length = [t length]; 
		if ([t length] > 0) 
		{
			[p addObject:[self attributedSubstringFromRange:r]];
			r.location +=1; 
		}
		else
			r.location += 1; 
	}
		
	return p;
}

-(NSString *)convertToHTML
{
	return [self convertToHTMLWithTitle:nil];
}

-(NSString *)convertToHTMLWithTitle:(NSString *)title
{
	return [self convertToHTMLPreservingImages:NO savingImagesToPath:nil withTitle:title];
}

-(NSString *)convertToHTMLPreservingImages:(BOOL)preserveIMG 
						savingImagesToPath:(NSString *)imgPath
								 withTitle:(NSString *)htmlTitle
{
	NSDictionary *attributes;
	NSRange r;
	unsigned int pos = 0;
	NSMutableString *html = [NSMutableString string];
	NSString *temp = nil;
	
	NSFont *font;
	NSColor *c;
	NSString *link = nil;
	NSMutableString *tag = [NSMutableString string];
	BOOL underline = NO, italic = NO, bold = NO;
	NSFontTraitMask fontMask;
	float size;
	NSFontManager *fm = [NSFontManager sharedFontManager];
	
	NSTextAttachment *ta;
	NSFileWrapper *imgWrapper;
	if (preserveIMG)
	{
		BOOL isFolder;
		if (![[NSFileManager defaultManager] fileExistsAtPath:imgPath isDirectory:&isFolder] || !isFolder)
			[[NSFileManager defaultManager] createDirectoryAtPath:imgPath attributes:nil];
	}
	
	NSArray *paragraphs = [self paragraphs];
	NSAttributedString *attString = nil;
	NSEnumerator *e = [paragraphs objectEnumerator];
	
	//Prepare for CSS stuff
	NSMutableDictionary *cssAttrs = [NSMutableDictionary dictionary];
	NSMutableString *css = [NSMutableString string];
	NSString *cssHash = nil;
	
	while (attString = [e nextObject])
	{
		[html appendString:@"<p>"];
		r = NSMakeRange(0,0);
		pos = 0;
		while ((pos < [attString length]) && (attributes = [attString attributesAtIndex:pos effectiveRange:&r]))
		{
			font = [attributes objectForKey:NSFontAttributeName];
			temp = [[attString attributedSubstringFromRange:r] string];
			c = [attributes objectForKey:NSForegroundColorAttributeName];
			link = [attributes objectForKey:NSLinkAttributeName];
			
			//Get attributes
			fontMask = [fm traitsOfFont:font];
			size = [font pointSize];
			bold = fontMask & NSBoldFontMask;
			italic = fontMask & NSItalicFontMask;
			underline = [[attributes objectForKey:NSUnderlineStyleAttributeName] boolValue];
			
			// Grab and save images...
			if (preserveIMG)
			{
				ta = [attributes objectForKey:NSAttachmentAttributeName];
				
				if (ta)
				{
					imgWrapper = [ta fileWrapper];
					[imgWrapper writeToFile:[imgPath stringByAppendingFormat:@"/%@", [imgWrapper filename]]
								 atomically:YES updateFilenames:NO];
					temp = [NSString stringWithFormat:@"<img src=\"%@\" alt=\"%@\" />", [imgWrapper filename], [imgWrapper filename]];
				}
			}
			
			if (link)
				temp = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", link, temp];
			
			/************************* CSS *****************************/
			[css setString:@""];
			if (bold)
				[css appendString:@"\tfont-weight: bold;\n"];
			if (italic)
				[css appendString:@"\tfont-style: italic;\n"];
			if (underline && !link)
				[css appendString:@"\ttext-decoration: underline;\n"];
			if (c)
				[css appendFormat:@"\tcolor: %@\n", [c hexidecimalRepresentation]];
			[css appendFormat:@"\tfont-size: %ipx;", (int)size*2];
			cssHash = [NSString stringWithFormat:@"[CSS:%d]", [css hash]];
			
			if (![cssAttrs objectForKey:cssHash])
				[cssAttrs setObject:[css copy] forKey:cssHash];
			
			temp = [NSString stringWithFormat:@"<span class=\"%@\">%@</span>", cssHash, temp];
			/************************* CSS *****************************/
			
			[html appendString:temp];
			pos += r.length;
		}
		[html appendString:@"</p>\n"];
	}
	[html replaceOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x201c] withString:@"&#8220;"
							 options:NSLiteralSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x201d] withString:@"&#8221;"
							 options:NSLiteralSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x2018] withString:@"&#8216;"
							 options:NSLiteralSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x2019] withString:@"&#8217;"
							 options:NSLiteralSearch range:NSMakeRange(0, [html length])];
	
	/************************* CSS *****************************/
	NSArray *keys = [cssAttrs allKeys];
	NSString *key = nil, *attr = nil;
	NSMutableString *style = [NSMutableString string];
	[style setString:@"<style type=\"text/css\">\n\n"];
	int i, j = [keys count];
	for (i=0; i < j; i++)
	{
		key = [keys objectAtIndex:i];
		attr = [cssAttrs objectForKey:key];
		[style appendFormat:@".a%i {\n%@\n}\n\n", i, attr];
		[html replaceOccurrencesOfString:key withString:[NSString stringWithFormat:@"a%i", i]
								 options:NSLiteralSearch range:NSMakeRange(0, [html length])];
	}
	[style appendString:@"</style>\n"];
	/************************* CSS *****************************/
	
	html = [NSMutableString stringWithFormat:@"<html>\n<head>\n<title>%@</title>\n"
		@"%@</head>\n<body>%@</body>\n</html>", htmlTitle, style, html];
	
	return html;	
}


-(BOOL)exportAsHTMLToPath:(NSString *)path withTitle:(NSString *)htmlTitle
{
	NSString *HTML = nil, *imgPath = [path stringByDeletingLastPathComponent];
	if ([self containsAttachments])
		HTML = [self convertToHTMLPreservingImages:YES savingImagesToPath:imgPath withTitle:htmlTitle];
	else
		HTML = [self convertToHTMLWithTitle:htmlTitle];
	
	return [HTML writeToFile:path atomically:YES];
}

@end
