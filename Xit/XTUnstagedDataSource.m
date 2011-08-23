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

@end
