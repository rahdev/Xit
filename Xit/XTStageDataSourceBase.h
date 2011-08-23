//
//  XTStageDataSourceBase.h
//  Xit
//
//  Created by David Catmull on 8/23/11.
//

#import <Foundation/Foundation.h>

@class Xit;

@interface XTStageDataSourceBase : NSObject
{
    @protected
    Xit *repo;
    NSMutableArray *items;
    NSTableView *table;
}

- (NSImage *) iconForFile:(NSString *)file;
- (NSArray *) items;
- (void) reload;
- (void) waitUntilReloadEnd;
- (void) setRepo:(Xit *)newRepo;

@end
