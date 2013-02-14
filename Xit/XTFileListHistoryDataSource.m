//
//  XTFileListHistoryDataSource.m
//  Xit
//
//  Created by German Laullon on 15/09/11.
//

#import "XTFileListHistoryDataSource.h"
#import "XTRepository.h"
#import "XTHistoryItem.h"
#import <ObjectiveGit/ObjectiveGit.h>


@implementation XTFileListHistoryDataSource
@synthesize items;

- (id)init {
    self = [super init];
    if (self) {
        items = [NSMutableArray array];
        index = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [repo removeObserver:self forKeyPath:@"selectedCommit"];
}

- (void)setRepo:(XTRepository *)newRepo {
    repo = newRepo;
    [repo addReloadObserver:self selector:@selector(repoChanged:)];
    [repo addObserver:self forKeyPath:@"selectedCommit" options:NSKeyValueObservingOptionNew context:nil];
    [self reload];
}

- (void)repoChanged:(NSNotification *)note {
    NSArray *paths = [[note userInfo] objectForKey:XTPathsKey];

    for (NSString *path in paths) {
        if ([path hasPrefix:@".git/logs/"]) {
            [self reload];
            break;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selectedCommit"]) {
        NSString *newSelectedCommit = [change objectForKey:NSKeyValueChangeNewKey];
        XTHistoryItem *item = [index objectForKey:newSelectedCommit];
        if (item != nil) {
            [table selectRowIndexes:[NSIndexSet indexSetWithIndex:item.index] byExtendingSelection:NO];
            [table scrollRowToVisible:item.index];
        } else {
            NSLog(@"commit '%@' not found!!", newSelectedCommit);
        }
    }
}

- (void)reload {
    if (repo == nil)
        return;
    dispatch_async(repo.queue, ^{
                       NSMutableArray *newItems = [NSMutableArray array];
                       //__block int idx = 0;

                       // TODO

                       NSLog (@"-> %lu", [newItems count]);
                       items = newItems;
                       [table reloadData];
                   });
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [items count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    XTHistoryItem *item = [items objectAtIndex:rowIndex];

    return [[item.commit sha] substringToIndex:6];
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSLog(@"%@", aNotification);
    XTHistoryItem *item = [items objectAtIndex:table.selectedRow];
    repo.selectedCommit = item.sha;
}

@end
