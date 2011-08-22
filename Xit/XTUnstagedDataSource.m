//
//  XTIndexDataSource.m
//  Xit
//
//  Created by German Laullon on 09/08/11.
//

#import "XTUnstagedDataSource.h"
#import "Xit.h"
#import "XTFileIndexInfo.h"

@implementation XTUnstagedDataSource

- (id) init {
    self = [super init];
    if (self) {
        items = [NSMutableArray array];
    }

    return self;
}

- (void) setRepo:(Xit *)newRepo {
    repo = newRepo;
//    [repo addObserver:self forKeyPath:@"reload" options:NSKeyValueObservingOptionNew context:nil];
//    [repo addObserver:self forKeyPath:@"selectedCommit" options:NSKeyValueObservingOptionNew context:nil];
    [self reload];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
}

- (NSImage *) iconForFile:(NSString *)file {
	 NSString *path = [[[repo repoURL] path] stringByAppendingPathComponent:file];
	 NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
	 
	 if (icon == nil) {
		NSString *type = (NSString*) UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[path pathExtension], NULL);
		icon = [[NSWorkspace sharedWorkspace] iconForFileType:type];
	 }
	 return icon;
}

- (void) reload {
    [items removeAllObjects];

    NSData *output = [repo exectuteGitWithArgs:[NSArray arrayWithObjects:@"diff-files", nil] error:nil];
    NSString *filesStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
    filesStr = [filesStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *files = [filesStr componentsSeparatedByString:@"\n"];

    [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
         NSString *file = (NSString *)obj;
         NSArray *info = [file componentsSeparatedByString:@"\t"];

         if (info.count > 1) {
             NSString *name = [info lastObject];
             NSString *status = [[[info objectAtIndex:0] componentsSeparatedByString:@" "] lastObject];
			 NSImage *icon = [self iconForFile:name];

             status = [status substringToIndex:1];
             XTFileIndexInfo *fileInfo = [[XTFileIndexInfo alloc] initWithName:name status:status icon:icon];
             [items addObject:fileInfo];
         }
     }];

    output = [repo exectuteGitWithArgs:[NSArray arrayWithObjects:@"ls-files", @"--others", @"--exclude-standard", nil] error:nil];
    filesStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
    filesStr = [filesStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    files = [filesStr componentsSeparatedByString:@"\n"];
    [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
         NSString *file = (NSString *)obj;
         if (file.length > 0) {
			 NSImage *icon = [self iconForFile:file];
             XTFileIndexInfo *fileInfo = [[XTFileIndexInfo alloc] initWithName:file status:@"?" icon:icon];
             [items addObject:fileInfo];
         }
     }];
}

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
