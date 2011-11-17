//
//  TrackTableViewCell.m
//  MiniMusicalStar
//
//  Created by Tommi on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TrackTableViewCell.h"

@implementation TrackTableViewCell

@synthesize trackNameLabel;
@synthesize recordOrTrashButton;
@synthesize muteOrUnmuteButton;
@synthesize showLyricsButton;
@synthesize showCueButton;
@synthesize muteUnmuteLabel;
@synthesize recordRecordingLabel;
@synthesize showHideLyricsLabel;
@synthesize showCuesLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [trackNameLabel release];
    [recordOrTrashButton release];
    [muteOrUnmuteButton release];
    [showLyricsButton release];
    [showCueButton release];
    [muteUnmuteLabel release];
    [recordRecordingLabel release];
    [showHideLyricsLabel release];
    [showCuesLabel release];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
