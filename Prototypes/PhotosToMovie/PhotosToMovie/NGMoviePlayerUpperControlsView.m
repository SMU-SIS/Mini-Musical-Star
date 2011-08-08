//
//  NGMoviePlayerUpperControlsView.m
//  bobcat
//
//  Created by Brent Simmons on 8/15/10.
//  Copyright 2010 NewsGator Technologies, Inc. All rights reserved.
//

#import "NGMoviePlayerUpperControlsView.h"


#define NG_MOVIEPLAYER_DONE NSLocalizedString(@"Done", @"Done button")
#define NG_MOVIEPLAYER_LOADING_MOVIE NSLocalizedString(@"Loading Movie…", @"Loading movie message")


@implementation NGMoviePlayerUpperControlsView

@synthesize doneButton;
@synthesize timeElapsed;
@synthesize timeRemaining;
@synthesize slider;
@synthesize activityIndicator;
@synthesize loadingMovieLabel;
@synthesize loadingMovie;
@synthesize loadingMovieContainerView;
@synthesize showingMovieContainerView;


#pragma mark Init

- (void)commonInit {
	loadingMovie = YES;
	self.backgroundColor = [[UIColor colorWithRed:0.7f green:0.8f blue:0.9f alpha:0.3] retain];
}


- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self == nil)
		return nil;
	[self commonInit];
	return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self == nil)
		return nil;
	[self commonInit];
	return self;
}


#pragma mark Dealloc

- (void)dealloc {
	[doneButton release];
	[slider release];
	[timeElapsed release];
	[timeRemaining release];
	[activityIndicator release];
	[loadingMovieLabel release];
	[loadingMovieContainerView release];
	[showingMovieContainerView release];
	[super dealloc];
}


#pragma mark Accessors

- (void)ensureViewIsShowingAndOtherIsHidden:(UIView *)viewToShow viewToHide:(UIView *)viewToHide {
	/*Either loading-movie or showing-movie view.*/
	if (![viewToShow isDescendantOfView:self]) {
		[self addSubview:viewToShow];
		CGRect rView = viewToShow.frame;
		rView.origin.y = 0;
		viewToShow.frame = rView;
	}
	viewToShow.hidden = NO;
	viewToHide.hidden = YES;
}


- (void)updateUI {
	if (self.loadingMovie) {
		[self ensureViewIsShowingAndOtherIsHidden:self.loadingMovieContainerView viewToHide:self.showingMovieContainerView];
		if (![self.activityIndicator isAnimating])
			[self.activityIndicator startAnimating];
		self.loadingMovieLabel.text = NG_MOVIEPLAYER_LOADING_MOVIE;	
	}
	else {
		[self ensureViewIsShowingAndOtherIsHidden:self.showingMovieContainerView viewToHide:self.loadingMovieContainerView];
		if ([self.activityIndicator isAnimating])
			[self.activityIndicator stopAnimating];
	}
}


- (void)setLoadingMovie:(BOOL)flag {
	loadingMovie = flag;
	[self updateUI];
	[self setNeedsLayout];
}


#pragma mark Layout

- (void)layoutSubviews {
	
	/*Resize Done button if needed to accommodate localized string.*/ 
	static CGFloat doneButtonTextWidth = 0.0f;
	if (doneButtonTextWidth < 0.1f) {
		[self.doneButton setTitle:NG_MOVIEPLAYER_DONE forState:UIControlStateNormal];
		CGSize doneButtonTextSize = [NG_MOVIEPLAYER_DONE sizeWithFont:self.doneButton.titleLabel.font constrainedToSize:CGSizeMake(200, self.doneButton.frame.size.height) lineBreakMode:UILineBreakModeTailTruncation];
		doneButtonTextWidth = doneButtonTextSize.width;
	}
	CGRect rDoneButton = self.doneButton.frame;
	static const CGFloat doneButtonTextPadding = 10.0f;
	rDoneButton.size.width = doneButtonTextPadding + doneButtonTextWidth + doneButtonTextPadding;
	self.doneButton.frame = rDoneButton;
	
	/*Position container view on right to accommodate resized Done button.*/
	UIView *rightSideView = self.loadingMovie ? self.loadingMovieContainerView : self.showingMovieContainerView;
	CGRect rRightSideView = rightSideView.frame;
	static const CGFloat doneButtonMarginRight = 8.0f;
	rRightSideView.origin.x = CGRectGetMaxX(rDoneButton) + doneButtonMarginRight;
	static const CGFloat rightSideViewMarginRight = 8.0f;
	rRightSideView.size.width = (CGRectGetWidth(self.bounds) - rightSideViewMarginRight) - CGRectGetMinX(rRightSideView);
	rightSideView.frame = rRightSideView;
}


#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
	UIImage *image = [UIImage imageNamed:@"movie_upper-controls_background"];
	[image drawInRect:self.bounds blendMode:kCGBlendModeNormal alpha:0.6];
}

@end
