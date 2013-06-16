#import <ObjectiveGit/ObjectiveGit.h>

@interface GTRemote (Xit)

- (BOOL)connectWithDirection:(git_direction)direction error:(NSError **)error;
- (BOOL)fetchWithProgress:(void (^)(const git_transfer_progress *))progressBlock
                    error:(NSError **)error;
- (void)stop;
- (void)disconnect;
- (BOOL)isConnected;

@end
