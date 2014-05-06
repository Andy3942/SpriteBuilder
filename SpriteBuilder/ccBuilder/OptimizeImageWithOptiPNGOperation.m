#import "OptimizeImageWithOptiPNGOperation.h"

#import "CCBWarnings.h"
#import "PublishingTaskStatusProgress.h"


@implementation OptimizeImageWithOptiPNGOperation

- (void)main
{
    NSLog(@"[%@] %@", [self class], [self description]);

    [self optimizeImageWithOptiPNG];

    [_publishingTaskStatusProgress taskFinished];
}

- (void)optimizeImageWithOptiPNG
{
    [_publishingTaskStatusProgress updateStatusText:[NSString stringWithFormat:@"Optimizing %@...", [_filePath lastPathComponent]]];

    self.task = [[NSTask alloc] init];
    [_task setLaunchPath:_optiPngPath];
    [_task setArguments:@[_filePath]];

    // NSPipe *pipe = [NSPipe pipe];
    NSPipe *pipeErr = [NSPipe pipe];
    [_task setStandardError:pipeErr];

    // [_task setStandardOutput:pipe];
    // NSFileHandle *file = [pipe fileHandleForReading];

    NSFileHandle *fileErr = [pipeErr fileHandleForReading];

    int status = 0;

    @try
    {
        [_task launch];
        [_task waitUntilExit];
        status = [_task terminationStatus];
    }
    @catch (NSException *ex)
    {
        NSLog(@"[%@] %@", [self class], ex);
        return;
    }

    if (status)
    {
        NSData *data = [fileErr readDataToEndOfFile];
        NSString *stdErrOutput = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *warningDescription = [NSString stringWithFormat:@"optipng error: %@", stdErrOutput];
        [_warnings addWarningWithDescription:warningDescription];
    }
}

- (void)cancel
{
    NSLog(@"[%@] CANCELLED %@", [self class], [self description]);
    @try
    {
        [super cancel];
        [_task terminate];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception: %@", exception);
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"file: %@, file full: %@, optipng: %@", [_filePath lastPathComponent], _filePath, _optiPngPath];
}

@end