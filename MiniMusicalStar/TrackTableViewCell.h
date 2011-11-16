//
//  TrackTableViewCell.h
//  MiniMusicalStar
//
//  Created by Tommi on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *trackNameLabel;
@property (nonatomic, retain) IBOutlet UIButton *recordOrTrashButton;
@property (nonatomic, retain) IBOutlet UIButton *muteOrUnmuteButton;
@property (nonatomic, retain) IBOutlet UIButton *showLyricsButton;
//@property (nonatomic, retain) IBOutlet UIButton *showCueButton;
@property (nonatomic, retain) IBOutlet UILabel *muteUnmuteLabel;
@property (nonatomic, retain) IBOutlet UILabel *recordRecordingLabel;
@property (nonatomic, retain) IBOutlet UILabel *showHideLyricsLabel;
//@property (nonatomic, retain) IBOutlet UILabel *showCuesLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
