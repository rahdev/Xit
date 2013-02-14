//
//  XTHistoryDataSource.m
//  Xit
//
//  Created by German Laullon on 26/07/11.
//

#import "XTHistoryDataSource.h"
#import "XTRepository.h"
#import "XTHistoryItem.h"
#import "XTStatusView.h"
#import "PBGitGrapher.h"
#import "PBGitHistoryGrapher.h"
#import "NSDate+Extensions.h"
#import <ObjectiveGit/ObjectiveGit.h>

@interface GTEnumerator (XTAdditions)

- (BOOL)pushAllRefsWithError:(NSError *__autoreleasing *)error;

@end

@implementation XTHistoryDataSource

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
        NSDate *startTime = [NSDate date];
        NSArray *args = [NSArray arrayWithObjects:@"--pretty=format:%H%n%P%n%cD%n%ce%n%s", @"--reverse", @"--tags", @"--all", @"--topo-order", nil];
        NSMutableArray *newItems = [NSMutableArray array];
        NSError *error = nil;

        [XTStatusView updateStatus:@"Loading..." command:[args componentsJoinedByString:@" "] output:nil forRepository:repo];

        GTEnumerator *enumerator = repo.objgitRepo.enumerator;
        GTCommit *commit = nil;

        [enumerator reset];
        enumerator.options = GTEnumeratorOptionsTopologicalSort;
        [enumerator pushAllRefsWithError:&error];
        if (error != nil) {
            // TODO: error
        }
        while ((commit = [enumerator nextObjectWithError:&error]) != nil) {
            [newItems addObject:[XTHistoryItem itemWithRepository:repo commit:commit]];
        }
        if (error != nil) {
            // TODO: error
        }

        PBGitGrapher *grapher = [[PBGitGrapher alloc] init];
        [newItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            XTHistoryItem *item = (XTHistoryItem *)obj;
            [grapher decorateCommit:item];
            item.index = idx;
        }];

        [XTStatusView updateStatus:[NSString stringWithFormat:@"%d commits loaded", (int)[newItems count]] command:nil output:@"" forRepository:repo];
        NSLog (@"-> %lu", [newItems count]);
        items = newItems;
        [table reloadData];
        NSLog(@">>> Reload time: %f", [startTime timeIntervalSinceDate:[NSDate date]]);
    });
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [items count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    XTHistoryItem *item = [items objectAtIndex:rowIndex];
    NSString *key = aTableColumn.identifier;
    
    if ([key isEqualToString:@"subject"])
        return item.commit.message;
    if ([key isEqualToString:@"email"])
        return item.commit.author.email;
    if ([key isEqualToString:@"date"])
        return item.commit.author.time;

    return [item.commit valueForKey:aTableColumn.identifier];
}

@end

static int StashIterator(size_t index, const char *message, const git_oid *stash_oid, void *payload) {
    return git_revwalk_push((git_revwalk*)payload, stash_oid);
}

@implementation GTEnumerator (XTAdditions)

- (BOOL)pushAllRefsWithError:(NSError *__autoreleasing *)error {
    // walk is a private property
    git_revwalk *walk = (__bridge git_revwalk *)[self performSelector:@selector(walk)];
    int gitError = 0;

    do {
        if ((gitError = git_revwalk_push_glob(walk, "refs/heads/*")) < GIT_OK) break;
        if ((gitError = git_revwalk_push_glob(walk, "refs/remotes/*")) < GIT_OK) break;
        if ((gitError = git_revwalk_push_glob(walk, "refs/tags/*")) < GIT_OK) break;
        if ((gitError = git_stash_foreach(self.repository.git_repository, StashIterator, walk)) < GIT_OK) break;
    } while (false);
	if(gitError < GIT_OK) {
		if (error != NULL)
			*error = [NSError git_errorFor:gitError withAdditionalDescription:@"Failed to push refs onto rev walker."];
		return NO;
	}
	
	return YES;
}

@end