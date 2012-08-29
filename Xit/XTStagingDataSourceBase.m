//
//  XTStagedDataSource.m
//  Xit
//
//  Created by David Catmull on 6/22/11.
//

#import "XTStagingDataSourceBase.h"
#import "XTRepository.h"
#import "XTFileIndexInfo.h"

@implementation XTStagingDataSourceBase

- (id)init {
    self = [super init];
    if (self) {
        items = [NSMutableArray array];
    }

    return self;
}

- (void)setRepo:(XTRepository *)newRepo {
    repo = newRepo;
    [repo addReloadObserver:self selector:@selector(repoChanged:)];
    [self reload];
}

- (void)repoChanged:(NSNotification *)note {
    // TODO: check if the paths really indicate a reload
    // Recursion can happen if reloading uses git calls that trigger the file
    // system notification.
    if (!reloading) {
        reloading = YES;
        [self reload];
        reloading = NO;
    }
}

- (void)reload {
    // For subclasses.
}

- (NSArray *)items {
    return items;
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    table = aTableView;
    return [items count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)rowIndex {
    if (rowIndex >= [items count])
        return nil;

    XTFileIndexInfo *item = [items objectAtIndex:rowIndex];

    return [item valueForKey:column.identifier];
}

@end