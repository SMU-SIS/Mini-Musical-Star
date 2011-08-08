#import "../KaraokeRecorderController.h"
#import <AVFoundation/AVFoundation.h>

@interface KaraokeRecorderControllerTest : GHTestCase { }
    KaraokeRecorderController *karaokeController;
@end


@implementation KaraokeRecorderControllerTest

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

- (void)setUpClass {
    // Run at start of all tests in the class
    NSString *audioSource = [[NSBundle mainBundle] pathForResource:@"Secrets" ofType:@"mp3"];
    //CFURLRef fileurl =  CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)audioSource, kCFURLPOSIXPathStyle, false);
    NSURL *audioSourceURL = [NSURL fileURLWithPath: audioSource isDirectory: NO];
    //NSLog(@"the string is %@", audioSource);
    //NSLog(@"the url is %@", audioSourceURL);
    karaokeController = [[KaraokeRecorderController alloc] initWithAudioFileAsCFURLRef:(CFURLRef)audioSourceURL];
    
}

- (void)tearDownClass {
    // Run at end of all tests in the class
    [karaokeController dealloc];
}

- (void)setUp {
    // Run before each test method
}

- (void)tearDown {
    // Run after each test method
}

- (NSString *) genRandStringLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%c", [letters characterAtIndex:rand()%[letters length]]];
         }
         
         return randomString;
}

- (void)testRecordingToFile
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *outputFile = [docDir stringByAppendingPathComponent:[self genRandStringLength: 10]];
    outputFile = [outputFile stringByAppendingString: @".caf"];
    
    CFURLRef outputFileURL = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)outputFile, kCFURLPOSIXPathStyle, false);
    [karaokeController enableRecordingWithPath:outputFileURL forBus:1];
                            [karaokeController startRecording];
                            sleep(2);
                            [karaokeController stopRecording];
                            
    //check playability of output file
    NSURL *myURL = [NSURL fileURLWithPath: outputFile isDirectory: NO];
    //NSLog (@"the output file url is %@", myURL);
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL: myURL options: nil];
    BOOL playable = asset.playable;
    
    
    //delete the file
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr removeItemAtPath:outputFile error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
    GHAssertTrue(playable, @"generated output file should be playable");
    

}


@end
