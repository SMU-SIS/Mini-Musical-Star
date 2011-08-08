//
//  NGMoviePlayerUpperControlsView.h
//  bobcat
//
//  Created by Brent Simmons on 8/15/10.
//  Copyright 2010 NewsGator Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NGMoviePlayerUpperControlsView : UIView {
@private
	UIButton *doneButton;
	UILabel *timeElapsed;
	UILabel *timeRemaining;
	UISlider *slider;
	UIActivityIndicatorView *activityIndicator;
	UILabel *loadingMovieLabel;
	BOOL loadingMovie;
	UIView *loadingMovieContainerView;
	UIView *showingMovieContainerView;
}


@property (nonatomic, retain) IBOutlet UIView *loadingMovieContainerView;
@property (nonatomic, retain) IBOutlet UIView *showingMovieContainerView;

@property (nonatomic, retain) IBOutlet UIButton *doneButton;
@property (nonatomic, retain) IBOutlet UISlider *slider;
@property (nonatomic, retain) IBOutlet UILabel *timeElapsed;
@property (nonatomic, retain) IBOutlet UILabel *timeRemaining;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UILabel *loadingMovieLabel;
@property (nonatomic, assign) BOOL loadingMovie;

@end
