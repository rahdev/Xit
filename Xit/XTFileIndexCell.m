//
//  XTFileIndexCell.m
//  Xit
//

#import "XTFileIndexCell.h"

@implementation XTFileIndexCell

@synthesize fileInfo;
@synthesize icon;

- (id) initWithCoder:(id)coder {
    self = [super initWithCoder:coder];
    textCell = [[NSTextFieldCell alloc] initWithCoder:coder];
    return self;
}

- (void) drawWithFrame:(NSRect)rect inView:(NSView *)view {
    NSRect txtRec = NSInsetRect(rect, rect.size.height, 0);
    NSRect badgeRec = NSMakeRect(rect.origin.x + rect.size.width - rect.size.height, rect.origin.y, rect.size.height, rect.size.height);

    [textCell setObjectValue:self.fileInfo.name];
    [textCell setHighlighted:[self isHighlighted]];
    [textCell drawWithFrame:txtRec inView:view];

    [fileInfo.status drawInRect:badgeRec withAttributes:nil];

    icon.size = NSMakeSize(rect.size.height, rect.size.height);
    [icon setFlipped:YES];
    [icon drawAtPoint:rect.origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}
@end
