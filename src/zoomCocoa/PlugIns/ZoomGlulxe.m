//
//  ZoomGlulxe.m
//  ZoomCocoa
//
//  Created by Andrew Hunter on 18/12/2005.
//  Copyright 2005 Andrew Hunter. All rights reserved.
//

#import "ZoomGlulxe.h"
#import "ZoomBlorbFile.h"

@implementation ZoomGlulxe

+ (BOOL) canRunPath: (NSString*) path {
	NSString* extn = [[path pathExtension] lowercaseString];
	
	// We can run .ulx files
	if ([extn isEqualToString: @"ulx"]) return YES;
	
	// ... and we can run blorb files with a Glulx block in them
	if ([extn isEqualToString: @"blb"] || [extn isEqualToString: @"glb"] || [extn isEqualToString: @"gblorb"] || [extn isEqualToString: @"zblorb"] || [extn isEqualToString: @"blorb"]) {
		ZoomBlorbFile* blorb = [[ZoomBlorbFile alloc] initWithContentsOfFile: path];
		
		if (blorb != nil && [blorb dataForChunkWithType: @"GLUL"] != nil) {
			return YES;
		}
	}
	
	return [super canRunPath: path];
}

- (id) initWithFilename: (NSString*) gameFile {
	// Initialise as usual
	self = [super initWithFilename: gameFile];
	
	if (self) {
		// Set the client to be glulxe
		[self setClientPath: [[NSBundle bundleForClass: [self class]] pathForAuxiliaryExecutable: @"glulxe-client"]];
	}
	
	return self;
}

// = Metadata =

- (ZoomStoryID*) idForStory {
	// Generate an MD5-based ID
	return [[[ZoomStoryID alloc] initWithGlulxFile: [self gameFilename]] autorelease];
}

- (ZoomStory*) defaultMetadata {
	// Just use the default metadata-establishing routine
	return [ZoomStory defaultMetadataForFile: [self gameFilename]]; 
}

- (NSImage*) coverImage {
	// Try decoding the cover picture, if available
	ZoomBlorbFile* decodedFile = [[ZoomBlorbFile alloc] initWithContentsOfFile: [self gameFilename]];
	int coverPictureNumber = -1;
	
	// Try to retrieve the frontispiece tag (overrides metadata if present)
	NSData* front = [decodedFile dataForChunkWithType: @"Fspc"];
	if (front != nil && [front length] >= 4) {
		const unsigned char* fpc = [front bytes];
		
		coverPictureNumber = (((int)fpc[0])<<24)|(((int)fpc[1])<<16)|(((int)fpc[2])<<8)|(((int)fpc[3])<<0);
	}
	
	if (coverPictureNumber >= 0) {			
		// Attempt to retrieve the cover picture image
		if (decodedFile != nil) {
			NSData* coverPictureData = [decodedFile imageDataWithNumber: coverPictureNumber];
			
			if (coverPictureData) {
				NSImage* coverPicture = [[[NSImage alloc] initWithData: coverPictureData] autorelease];
				
				// Sometimes the image size and pixel size do not match up
				NSImageRep* coverRep = [[coverPicture representations] objectAtIndex: 0];
				NSSize pixSize = NSMakeSize([coverRep pixelsWide], [coverRep pixelsHigh]);
				
				if (!NSEqualSizes(pixSize, [coverPicture size])) {
					[coverPicture setScalesWhenResized: YES];
					[coverPicture setSize: pixSize];
				}
				
				if (coverPicture != nil) {
					[decodedFile release];
					return coverPicture;
				}
			}
		}
	}
	
	[decodedFile release];
	
	// Default to the Glulxe icon
	return [[[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"GlkClient"
																					 ofType: @"icns"]] 
		autorelease];
}

@end
