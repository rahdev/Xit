//
//  XTHistoryItem.h
//  Xit
//
//  Created by German Laullon on 26/07/11.
//

#import <Foundation/Foundation.h>
#import "PBGraphCellInfo.h"

@class XTRepository;
@class GTCommit;

@interface XTHistoryItem : NSObject <NSCopying>
{
    @private
    XTRepository *repo;
    GTCommit *commit;
    PBGraphCellInfo *lineInfo;
    NSUInteger index;
}

@property (strong) XTRepository *repo;
@property (strong) GTCommit *commit;
@property (readonly) NSString *sha;
@property (strong) PBGraphCellInfo *lineInfo;
@property NSUInteger index;

+ (XTHistoryItem *)itemWithRepository:(XTRepository *)repo commit:(GTCommit *)commit;

@end

#if 0
@interface GTCommit (XTAdditions)

- (NSString *)sha;

@end
#endif
