//
//  ZoomScrollView.m
//  ZoomCocoa
//
//  Created by Andrew Hunter on Fri Oct 10 2003.
//  Copyright (c) 2003 Andrew Hunter. All rights reserved.
//

#import "ZoomScrollView.h"


@implementation ZoomScrollView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        zoomView = nil;

        upperDivider = [[NSBox allocWithZone: [self zone]] initWithFrame:
            NSMakeRect(0,0,2,2)];
        [upperDivider setBoxType: NSBoxSeparator];
    }
    return self;
}

- (id) initWithFrame: (NSRect) frame
            zoomView: (ZoomView*) zView {
    self = [self initWithFrame:frame];
    if (self) {
        zoomView = zView; // Not retained, as this is a component of a ZoomView
		scaleFactor = 1.0;
        
        upperView = [[ZoomUpperWindowView allocWithZone: [self zone]] initWithFrame: frame
                                                                           zoomView: zView];
    }
    return self;
}

- (void) dealloc {
    [upperDivider release];
    [upperView release];
    [super dealloc];
}

- (void) tile {
    [super tile];

    int upperHeight  = [zoomView upperWindowSize];
    NSSize fixedSize = [@"M" sizeWithAttributes:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [zoomView fontWithStyle:ZFixedStyle], NSFontAttributeName, nil]];

    double upperMargin = (upperHeight * fixedSize.height) / scaleFactor;

    // Resize the content frame so that it doesn't cover the upper window
    NSClipView* contentView = [self contentView];
    NSRect contentFrame = [contentView frame];
    NSRect upperFrame, sepFrame;
	
	contentFrame.size = [self contentSize];

    contentFrame.size.height -= upperMargin;
    contentFrame.origin.y    += upperMargin;

    upperFrame.origin.x = contentFrame.origin.x;
    upperFrame.origin.y = contentFrame.origin.y - upperMargin;
    upperFrame.size.width = contentFrame.size.width;
    upperFrame.size.height = upperMargin;

    double sepHeight = [upperDivider frame].size.height;

    // Actually resize the contentView
    contentFrame.origin.y    += sepHeight;
    contentFrame.size.height -= sepHeight;
        
	// Content view scaling
	/* -- BLECH, darn cocoa. This doesn't work, as Cocoa is too thick to deal with a scaled NSClipView.
	NSRect contentBounds;
	contentBounds.origin = NSMakePoint(0,0);
	contentBounds.size   = NSMakeSize(floor(contentFrame.size.width * scaleFactor),
									  floor(contentFrame.size.height * scaleFactor));
	
	 [contentView setBounds: contentBounds];
	*/
    [contentView setFrame: contentFrame];

    // The upper/lower view seperator
    sepFrame = [upperDivider frame];
    sepFrame = contentFrame;
    sepFrame.origin.y -= sepHeight;
    sepFrame.size.height = sepHeight;
    [upperDivider setFrame: sepFrame];
    if ([upperDivider superview] == nil) [self addSubview: upperDivider];
    [upperDivider setNeedsDisplay: YES];

    // The upper window view
    [zoomView setUpperBuffer: (upperMargin*scaleFactor) + sepHeight];
    
    if (upperMargin > 0) {
        // Resize the upper window
        [upperView setFrame: upperFrame];
		
		// Scale it
		NSRect upperBounds;
		upperBounds.origin = NSMakePoint(0,0);
		upperBounds.size = NSMakeSize(floor(upperFrame.size.width * scaleFactor),
									  floor(upperFrame.size.height * scaleFactor));
		[upperView setBounds: upperBounds];
		
		// Add it to our view
        if ([upperView superview] == nil) {
            [self addSubview: upperView];
            [upperView setNeedsDisplay: YES];
        }
    } else {
        [upperView removeFromSuperview];
    }
}

- (void) updateUpperWindows {
    // Force a refresh of the upper window views
    [upperView setNeedsDisplay: YES];
}

- (void) setScaleFactor: (float) factor {
	scaleFactor = factor;
	[self tile];
}

@end
