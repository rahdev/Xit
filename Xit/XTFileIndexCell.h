//
//  XTFileIndexCell.h
//  Xit
//

#import <AppKit/AppKit.h>
#import "XTFileIndexInfo.h"

@interface XTFileIndexCell : NSTextFieldCell
{
    NSTextFieldCell *textCell;
    XTFileIndexInfo *fileInfo;
    NSImage *icon;
}

@property (assign) XTFileIndexInfo *fileInfo;
@property (assign) NSImage *icon;

@end
