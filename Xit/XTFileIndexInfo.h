//
//  XTFileIndexInfo.h
//  Xit
//
//  Created by German Laullon on 09/08/11.
//

#import <Foundation/Foundation.h>

@interface XTFileIndexInfo : NSObject
{
    @private
    NSString *name;
    NSString *status;
    NSImage *icon;
}

@property (assign) NSString *name;
@property (assign) NSString *status;
@property (assign) NSImage *icon;

- (id) initWithName:(NSString *)theName status:(NSString *)theStatus icon:(NSImage *)theIcon;

@end
