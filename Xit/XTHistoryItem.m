//
//  XTHistoryItem.m
//  Xit
//
//  Created by German Laullon on 26/07/11.
//

#import "XTHistoryItem.h"
#import <ObjectiveGit/ObjectiveGit.h>

@implementation XTHistoryItem

@synthesize repo;
@synthesize commit;
@synthesize lineInfo;
@synthesize index;

+ (XTHistoryItem *)itemWithRepository:(XTRepository *)repo commit:(GTCommit *)commit {
    XTHistoryItem *item = [[self alloc] init];

    item->repo = repo;
    item->commit = commit;
    return item;
}

- (NSString *)sha {
    return [commit sha];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end

@implementation GTCommit (XTAdditions)

- (NSString *)sha {
    return [NSString git_stringWithOid:git_commit_id([self git_commit])];
}

@end
