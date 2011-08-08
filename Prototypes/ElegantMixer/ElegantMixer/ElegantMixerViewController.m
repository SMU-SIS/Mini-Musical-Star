//
//  ElegantMixerViewController.m
//  ElegantMixer
//
//  Created by Jun Kit on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ElegantMixerViewController.h"

@implementation ElegantMixerViewController

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

}

- (IBAction) showMediaPicker
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
    
    [picker setDelegate: self];                                         // 2
    [picker setAllowsPickingMultipleItems: YES];                        // 3
    picker.prompt = NSLocalizedString (@"Add songs to play",
                                       "Prompt in media item picker");
    
    [self presentModalViewController: picker animated: YES];    // 4
    [picker release];
}


- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
   didPickMediaItems: (MPMediaItemCollection *) collection {
    
    [self dismissModalViewControllerAnimated: YES];
    //[self updatePlayerQueueWithMediaCollection: collection];
    
    NSArray *items = collection.items;
    NSMutableArray *itemURLs = [NSMutableArray arrayWithCapacity:items.count];
    
    [items enumerateObjectsUsingBlock:^(id item, NSUInteger i, BOOL *stop) {
        NSLog(@"song number %i is at %@", i, [item valueForProperty:MPMediaItemPropertyAssetURL]);
        [itemURLs addObject:[item valueForProperty:MPMediaItemPropertyAssetURL]];
    }];
    
    //pass the array to the method in KaraokeRecorderController
    karaoke = [[KaraokeRecorderController alloc] initWithAudioFileArray:itemURLs];
    [karaoke startRecording];
    
}

- (IBAction) stopRecording
{
    [karaoke stopRecording];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    
    [self dismissModalViewControllerAnimated: YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
