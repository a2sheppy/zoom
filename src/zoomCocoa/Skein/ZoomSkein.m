//
//  ZoomSkein.m
//  ZoomCocoa
//
//  Created by Andrew Hunter on Thu Jul 01 2004.
//  Copyright (c) 2004 Andrew Hunter. All rights reserved.
//

#import "ZoomSkein.h"


@implementation ZoomSkein

- (id) init {
	self = [super init];
	
	if (self) {
		rootItem = [[ZoomSkeinItem alloc] initWithCommand: @"- start -"];
		activeItem = rootItem;
		currentOutput = [[NSMutableString alloc] init];
	}
	
	return self;
}

- (ZoomSkeinItem*) rootItem {
	return rootItem;
}

// = Zoom output receiver =
- (void) inputCommand: (NSString*) command {
	// Create/set the item to the appropraite item in the skein
	ZoomSkeinItem* newItem = [activeItem addChild: [ZoomSkeinItem skeinItemWithCommand: command]];
	
	// Move the 'active' item
	activeItem = newItem;
	
	// No output for this item yet
	[activeItem setResult: nil];
	[activeItem increaseTemporaryScore];
	
	// Create a buffer for any new output
	if (currentOutput) [currentOutput release];
	currentOutput = [[NSMutableString alloc] init];
}

- (void) inputCharacter: (NSString*) character {
	// We treat these the same
	[self inputCommand: character];
}

- (void) outputText: (NSString*) outputText {
	// Append this text to the current outout
	[currentOutput appendString: outputText];
}

- (void) zoomWaitingForInput {
	// Send the current output to the active item
	if ([currentOutput length] > 0) {
		[activeItem setResult: currentOutput];

		[currentOutput release];
		currentOutput = [[NSMutableString alloc] init];
	}
}

- (void) zoomInterpreterRestart {
	[self zoomWaitingForInput];
	
	// Back to the top
	activeItem = rootItem;
}

@end
