//
//  ThirdAttemptViewController.m
//  ThirdAttempt
//
//  Created by Jun Kit on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ThirdAttemptViewController.h"

@implementation ThirdAttemptViewController
@synthesize karaokeController, micVolumeSlider, musicVolumeSlider, mixPlayer, slideshowView, imagesArray;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [slideshowView release];
    [karaokeController release];
    [outputFile release];
    [mixPlayer release];
    [inputFileURLs release];
    [micVolumeSlider release];
    [musicVolumeSlider release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    isStarted = NO;
    
    NSString *source1 = [[NSBundle mainBundle] pathForResource:@"bass" ofType:@"mp3"];
    NSString *source2 = [[NSBundle mainBundle] pathForResource:@"drums" ofType:@"mp3"];
    NSString *source3 = [[NSBundle mainBundle] pathForResource:@"guitar" ofType:@"mp3"];
    NSString *source4 = [[NSBundle mainBundle] pathForResource:@"keys" ofType:@"mp3"];
    NSString *source5 = [[NSBundle mainBundle] pathForResource:@"vocals" ofType:@"mp3"];
    
    inputFileURLs = [[NSArray arrayWithObjects:[NSURL fileURLWithPath:source1],
                              [NSURL fileURLWithPath:source2],
                              [NSURL fileURLWithPath:source3],
                              [NSURL fileURLWithPath:source4],
                              [NSURL fileURLWithPath:source5], nil] retain];
                                                        
    karaokeController = [[KaraokeRecorderController alloc] initWithAudioFiles:inputFileURLs];
    
    //let's enable recording...
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    outputFile = [[docDir stringByAppendingPathComponent:@"beautiful.caf"] retain];
    
    [karaokeController enableRecordingWithPath:(CFURLRef)[NSURL fileURLWithPath:outputFile] forBus:1];
    

    
}

-(IBAction)volumeSliderChanged:(UISlider *)sender
{
    UInt32 inputBus = sender.tag;
    [karaokeController changeInputVolumeForBus:inputBus value:(AudioUnitParameterValue) sender.value];
}

-(IBAction)togglePlayback:(UIButton *)sender
{
    if (isStarted)
    {
        [karaokeController stopRecording];
        isStarted = NO;
        [sender setTitle:@"Live Your Mini Musical Star Dream!" forState:UIControlStateNormal];
    }
    
    else
    {
        [karaokeController startRecording];
        isStarted = YES;
        [sender setTitle:@"I've had enough!" forState:UIControlStateNormal];
    }
}

-(IBAction)toggleListenToRecording:(id)sender
{
    NSMutableArray *additionalArray = [NSMutableArray arrayWithArray:inputFileURLs];
    [additionalArray addObject:[NSURL fileURLWithPath:outputFile]];
    
    //remove the vocals (index 4) from the array
    [additionalArray removeObjectAtIndex:4];
    
    mixPlayer = [[MixPlayback alloc] initMixWithAudioFiles:additionalArray];
    //NSLog(@"hello i am here! and the value for the mixPlayer is %@", mixPlayer);
    
    //register to receive notifications from the MixPlayback
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeImage:) name:@"changeImage" object:nil];
    
    //set up the slideshow
    imagesArray = [[NSArray arrayWithObjects:[UIImage imageNamed:@"glee1.jpg"], [UIImage imageNamed:@"glee2.jpg"], [UIImage imageNamed:@"glee3.jpg"], nil] retain];
    
    [mixPlayer play];
    [slideshowView setImage:[imagesArray objectAtIndex:0]];
}

-(void)changeImage:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        imageCounter++;
        
        if (imageCounter >= imagesArray.count) {
            imageCounter = 0;
        }
        
        [slideshowView setImage:[imagesArray objectAtIndex:imageCounter]]; //set the 1st image

    });
}

- (void)viewDidUnload
{
    [mixPlayer release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
