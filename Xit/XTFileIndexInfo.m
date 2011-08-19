//
//  XTFileIndexInfo.m
//  Xit
//
//  Created by German Laullon on 09/08/11.
//

#import "XTFileIndexInfo.h"

@implementation XTFileIndexInfo

@synthesize name;
@synthesize status;
@synthesize icon;

- (id) initWithName:(NSString *)theName status:(NSString *)theStatus icon:(NSImage *)theIcon {
    self = [super init];
    if (self) {
        self.name = theName;
        self.status = theStatus;
        self.icon = theIcon;
    }

    return self;
}

@end
