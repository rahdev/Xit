//
//  XTStageDataSourceBase.m
//  Xit
//
//  Created by David Catmull on 8/23/11.
//

#import "XTStageDataSourceBase.h"
#import "Xit.h"
#import "XTFileIndexInfo.h"

@implementation XTStageDataSourceBase

- (id) init {
    self = [super init];
    if (self) {
        items = [NSMutableArray array];
    }

    return self;
}

- (NSImage *) iconForFile:(NSString *)file {
    NSString *path = [[[repo repoURL] path] stringByAppendingPathComponent:file];
    NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];

    if (icon == nil) {
        NSString *type = (NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[path pathExtension], NULL);
        icon = [[NSWorkspace sharedWorkspace] iconForFileType:type];
    }
    [icon setSize:NSMakeSize(16, 16)];
    return icon;
}

- (void) setRepo:(Xit *)newRepo {
    repo = newRepo;
    [self reload];
}

- (void) reload {
}

// just for tests
- (NSArray *) items {
    return items;
}

// only for unit test
- (void) waitUntilReloadEnd {
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
         XTFileIndexInfo *item = (XTFileIndexInfo *)obj;
         NSLog (@"%lu - file:'%@' - status:'%@'", idx, item.name, item.status);
     }];
}

#pragma mark - NSTableViewDataSource

- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView {
    table = aTableView;
    //    [table setDelegate:self];
    return [items count];
}

- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    XTFileIndexInfo *item = [items objectAtIndex:rowIndex];

    return [item valueForKey:aTableColumn.identifier];
}

@end
