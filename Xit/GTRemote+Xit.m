#import "GTRemote+Xit.h"

static int transfer_progress(
    const git_transfer_progress *progress, void *payload)
{
  if (payload == NULL)
    return 0;

  void (^block)(const git_transfer_progress *) = (__bridge id)payload;

  block(progress);
  return 0;
}

@implementation GTRemote (Xit)

- (BOOL)connectWithDirection:(git_direction)direction error:(NSError **)error
{
  int result = git_remote_connect(self.git_remote, direction);

  if (result != 0) {
    *error = [NSError git_errorFor:result];
    return NO;
  }
  return YES;
}

- (BOOL)fetchWithProgress:(void (^)(const git_transfer_progress *))progressBlock
                    error:(NSError **)error
{
  int result = git_remote_download(
      self.git_remote,
      transfer_progress,
      (__bridge void *)(progressBlock));

  return result == 0;
}

- (void)stop
{
  git_remote_stop(self.git_remote);
}

- (void)disconnect
{
  git_remote_disconnect(self.git_remote);
}

- (BOOL)isConnected
{
  return git_remote_connected(self.git_remote);
}

@end
