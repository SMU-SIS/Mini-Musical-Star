//
//  MMS_UIViewController.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuViewController.h"
#import "UndownloadedShow.h"
#import "ShowDAO.h"
#import "Show.h"
#import "Cover.h"
#import "ChoiceSelectionViewController.h"
#import "DSActivityView.h"
#import "StoreController.h"

@implementation MenuViewController
@synthesize managedObjectContext, scrollView, buttonArray, showDAO, storeController, showsDownloadingInProgress, tutorialButton, purchaseWasCancelled;

bool downloadRequestGotCancelled = NO;

- (void)dealloc
{
    [tutorialButton release];
	[storeController release];
    [managedObjectContext release];
    [scrollView release];
    [buttonArray release];
    [showDAO release];
    [purchaseWasCancelled release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
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
    
    //set the store controller delegate
    self.storeController = [[StoreController alloc] init];
    self.storeController.delegate = self;
    
    self.showsDownloadingInProgress = [NSMutableDictionary dictionary];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver: self.storeController];
    
    //load background    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"main_background.png"]];
    [self.view setBackgroundColor:background];
    
    //load the shows on the local disk
    self.showDAO = [[[ShowDAO alloc] initWithDelegate:self] autorelease];
    
    //show the spinner as ShowDAO communicates with the app store for IAP
    [DSBezelActivityView newActivityViewForView:self.view withLabel:@"Loading Shows..."];

}

- (void)showDAO:(id)aShowDAO didFinishLoadingShows:(NSArray *)loadedShows
{
    //set up the scrollview
    [self createScrollViewOfShows];
    
    //add the KVO to loadedShows on ShowDAO
    [self.showDAO addObserver:self forKeyPath:@"loadedShows" options:NSKeyValueObservingOptionNew context:@"NewShowDownloaded"];
    
    [DSBezelActivityView removeViewAnimated:YES];
}

- (void)createScrollViewOfShows
{
    //let's start by setting the scrollview attributes
    scrollView.scrollEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = NO;
    scrollView.clipsToBounds = YES;    
    [scrollView setContentSize:CGSizeMake(35 + (self.showDAO.loadedShows.count * (280 + 125)), scrollView.frame.size.height)];
    
    //create a buttonArray as the backing for the buttons in the scrollview (so we can refer to them later)
    self.buttonArray = [NSMutableArray arrayWithCapacity:self.showDAO.loadedShows.count];
    
    //make sure to differentiate downloaded and undownloaded shows, 
    [self.showDAO.loadedShows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        CGRect frame;
        frame.origin.x = 35 + ((280 + 125) * idx);
        frame.origin.y = 0;
        frame.size.width = 280;
        frame.size.height = scrollView.frame.size.height;
        
        //add the placeholder view...
        UIView *musicalButtonView = [[[UIView alloc] initWithFrame:frame] autorelease];
        [scrollView addSubview:musicalButtonView];
        
        //add the cover image as a button...
        CGRect buttonFrame;
        buttonFrame.origin.x = 0;
        buttonFrame.origin.y = 0;
        buttonFrame.size.width = 280;
        buttonFrame.size.height = frame.size.height;
        
        UIButton *showButton;
        UILabel *downloadLabel = nil;
        UILabel *pricetag = nil;
        
        //now we check if it's downloaded or undownloaded
        if ([obj isKindOfClass:[Show class]])
        {
            showButton = [self createButtonForShow:(Show *)obj frame:buttonFrame];
        }
        
        else if ([obj isKindOfClass:[UndownloadedShow class]])
        {
            UndownloadedShow *theShow = (UndownloadedShow *)obj;
            showButton = [self createButtonForUndownloadedShow:theShow frame:buttonFrame];
            
            //add a download label in the centre of the showButton
            CGRect downloadIconFrame;
            downloadIconFrame.origin.x = 0;
            downloadIconFrame.origin.y = 310;
            downloadIconFrame.size.width = 280;
            downloadIconFrame.size.height = 60;
            
            downloadLabel = [[UILabel alloc] initWithFrame:downloadIconFrame];
            downloadLabel.tag = -1; //used to identify the label later on
            
            if ([SKPaymentQueue canMakePayments])
            {
                downloadLabel.text = @"Tap to Purchase";
            }
            
            else
            {
                downloadLabel.text = @"In-App Purchase Disabled";
            }
            
            downloadLabel.textAlignment = UITextAlignmentCenter;
            downloadLabel.font = [downloadLabel.font fontWithSize:26.0];
            downloadLabel.textColor = [UIColor whiteColor];
            downloadLabel.backgroundColor = [UIColor blackColor];
            [downloadLabel adjustsFontSizeToFitWidth];
            
            //create the price tag
            pricetag = [[UILabel alloc] init];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterCurrencyStyle;
            pricetag.text = [formatter stringFromNumber:theShow.skProduct.price];
            [formatter release];
            
            [pricetag sizeToFit];
            CGRect pricetagFrame;
            pricetagFrame.size.width = pricetag.frame.size.width + 15;
            pricetagFrame.size.height = pricetag.frame.size.height + 5;
            pricetagFrame.origin.y = downloadIconFrame.origin.y - pricetagFrame.size.height - 20;
            pricetagFrame.origin.x = musicalButtonView.frame.size.width - pricetagFrame.size.width;
            
            pricetag.frame = pricetagFrame;
            //pricetag.layer.cornerRadius = 7;
            
            pricetag.backgroundColor = [UIColor blackColor];
            pricetag.textColor = [UIColor whiteColor];
            pricetag.textAlignment = UITextAlignmentCenter;
        }
        
        showButton.tag = idx;
        [buttonArray addObject: showButton];
        [musicalButtonView addSubview: showButton];
        if (downloadLabel != nil) [musicalButtonView addSubview: downloadLabel];
        if (pricetag != nil) [musicalButtonView addSubview:pricetag];
        
        [downloadLabel release];
        [pricetag release];
        
    }];
    
    
}

- (UIButton *)createButtonForShow:(Show *)aShow frame:(CGRect)buttonFrame
{
    UIButton *showButton = [[UIButton alloc] initWithFrame:buttonFrame];
    showButton.layer.cornerRadius = 10; // this value vary as per your desire
    showButton.clipsToBounds = YES;
    showButton.adjustsImageWhenHighlighted = NO;
    
    [showButton setImage:aShow.coverPicture forState:UIControlStateNormal];
    [showButton addTarget:self action:@selector(selectMusical:) forControlEvents:UIControlEventTouchUpInside];
    
    return [showButton autorelease];
    
}

- (UIButton *)createButtonForUndownloadedShow:(UndownloadedShow *)aShow frame:(CGRect)buttonFrame
{
    UIButton *showButton = [[UIButton alloc] initWithFrame:buttonFrame];
    showButton.layer.cornerRadius = 10; // this value vary as per your desire
    showButton.clipsToBounds = YES;
    showButton.adjustsImageWhenHighlighted = NO;
    showButton.alpha = 0.5; //make the undownloaded musical lighter

    [showButton setImage:aShow.coverImage forState:UIControlStateNormal];
    if ([SKPaymentQueue canMakePayments])
    {
        [showButton addTarget:self action:@selector(initiateShowPurchase:) forControlEvents:UIControlEventTouchUpInside];
    }

    return [showButton autorelease];
    
}

- (void)initiateShowPurchase:(UIButton *)sender
{
    //disable the button to prevent user from clicking twice
    UIButton *showButton = (UIButton *)sender;
    [showButton removeTarget:self action:@selector(initiateShowPurchase:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *theView = [sender superview];
    __block UILabel *theLabel;
    
    [theView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *aView = (UIView *)obj;
        if (aView.tag == -1) theLabel = (UILabel *)aView;
    }];
    
    //update the show's label
    theLabel.text = @"Starting Purchase...";
    
    UndownloadedShow *showForPurchase = [self.showDAO.loadedShows objectAtIndex:sender.tag];
    
    //add this show to the showsDownloadingInProgress dictionary so we can keep track
    [self.showsDownloadingInProgress setObject:showForPurchase forKey:showForPurchase.showHash];
    
    //create a new SKPayment and add it to the payment queue
    SKPayment *payment = [SKPayment paymentWithProduct: showForPurchase.skProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)cancelPurchaseOfShow:(NSString *)productIdentifier
{
    downloadRequestGotCancelled = YES;
    
    //get the UIButton out
    UndownloadedShow *theShow = [self.showsDownloadingInProgress objectForKey:productIdentifier];
    
    //inserted this if statement for v1.3.2
    //this method was somehow called when i started the app, even though there wasnt any cancellation of any purchase
    //to be removed in future releases
    if (theShow == nil) {
        return;
    }
    
    [self resetToCleanStateForPartiallyDownloadedShow:theShow];
    
}

- (void)downloadMusical:(NSString *)productIdentifier
{
    //find back the target show
    [self.showDAO.loadedShows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UndownloadedShow class]])
        {
            UndownloadedShow *aShow = (UndownloadedShow *)obj;
            if ([aShow.showHash isEqualToString:productIdentifier])
            {
                BOOL finished = YES;
                stop = &finished;
                
                
                
                //find back the label and add a progress bar
                UIView *theView = [[self.buttonArray objectAtIndex:idx] superview];
                
                __block UILabel *theLabel;
                
                [theView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    UIView *aView = (UIView *)obj;
                    if (aView.tag == -1) theLabel = (UILabel *)aView;
                }];
                
                //and we set the label to "tap to cancel"
                theLabel.text = @"Tap to Cancel";
                
                //and we wire up the button to cancel
                UIButton *theButton = (UIButton *)[self.buttonArray objectAtIndex:idx];
                [theButton addTarget:self action:@selector(cancelDownloadOfShow:) forControlEvents:UIControlEventTouchUpInside];
                theButton.enabled = YES;
                
                //create a progress indicator
                CGRect progressBarFrame;
                progressBarFrame.size.width = 250;
                progressBarFrame.size.height = 40;
                progressBarFrame.origin.x = 15;
                progressBarFrame.origin.y = 280;
                
                UIProgressView *progressBar = [[[UIProgressView alloc] initWithFrame:progressBarFrame] autorelease];
                progressBar.tag = -2; //progress bar tag is 2
                [theView addSubview:progressBar];
                
                //FINALLY we download the show
                [self.showDAO downloadShow:aShow progressIndicatorDelegate:progressBar];
                
            }
        }
    }];
}

- (void)cancelDownloadOfShow:(UIButton *)sender
{
    downloadRequestGotCancelled = YES;
    [self.showDAO cancelDownloadForShow:[self.showDAO.loadedShows objectAtIndex:sender.tag]];
    
    //the callback on the request will handle the resetting of the button using the method below
}

- (void)resetToCleanStateForPartiallyDownloadedShow:(UndownloadedShow *)aShow
{
    UIButton *showButton = [buttonArray objectAtIndex:[self.showDAO.loadedShows indexOfObject:aShow]];
    showButton.enabled = YES; //re-enable the show button if it was disabled (happens when purchasing)
    [[showButton.superview viewWithTag:-2] removeFromSuperview]; //remove the progress bar
    
    [showButton removeTarget:self action:@selector(cancelDownloadOfShow:) forControlEvents:UIControlEventTouchUpInside];
    [showButton addTarget:self action:@selector(initiateShowPurchase:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *downloadLabel = (UILabel *)[showButton.superview viewWithTag:-1];
    downloadLabel.text = @"Tap to Purchase";
    
    if (!downloadRequestGotCancelled) //meaning that the request failed
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Failed" message:@"Your iPad's internet connection might be busy or unstable. Try again later!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    if (![purchaseWasCancelled boolValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Cancelled" message:@"You can redownload this musical again by repurchasing it. Don't worry, you will not be charged." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        self.purchaseWasCancelled = [NSNumber numberWithBool:NO];
    }
    
    downloadRequestGotCancelled = NO;
    
    //clear the store controller entry
    [storeController finishTransactionForProductIdentifier: aShow.showHash];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //cast the context as a string
    NSString *contextString = (NSString *)context;
    if ([contextString isEqualToString:@"NewShowDownloaded"])
    {
        //find out what is the index of the show
        NSIndexSet *changedObjects = [change objectForKey:NSKeyValueChangeIndexesKey];
        int indexOfShow = [changedObjects firstIndex];
        if (indexOfShow < 0) NSLog(@"Error: Cannot find index of new show");
        else
        {
            //up the button opacity and change the button target
            UIButton *theButton = [buttonArray objectAtIndex:indexOfShow];
            theButton.alpha = 1.0;
            [theButton removeTarget:self action:@selector(cancelDownloadOfShow:) forControlEvents:UIControlEventTouchUpInside];
            [theButton addTarget:self action:@selector(selectMusical:) forControlEvents:UIControlEventTouchUpInside];
            
            //remove the label
            [[theButton.superview viewWithTag:-1] removeFromSuperview];
            
            //find the show to clear the store controller entry
            Show *theShow = [self.showDAO.loadedShows objectAtIndex:indexOfShow];
            [storeController finishTransactionForProductIdentifier:theShow.showHash];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    //scrollView.hidden = YES;

}
- (void)viewDidAppear:(BOOL)animated
{
    //scrollView.hidden = NO;
    //hide the navigation bar
    
}


- (void)viewDidUnload
{
    [self.showDAO removeObserver:self forKeyPath:@"loadedShows"];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//weijie test method
-(void)selectMusical:(UIImageView *)musicalButton
{
    
    Show *theShow = [self.showDAO.loadedShows objectAtIndex:musicalButton.tag];
    
    ChoiceSelectionViewController *choiceView = [[ChoiceSelectionViewController alloc] initWithAShowForSelection: theShow context:self.managedObjectContext];
    
    
    choiceView.title = theShow.title;
    [self.navigationController pushViewController:choiceView animated:YES];
    [choiceView release];
}

- (IBAction) playTutorial:(id)sender
{
    //play tutorial video player
    [self playMovie:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"mainmenu" ofType:@"m4v"]]];
}

- (void) playMovie:(NSURL*)filePath
{
    MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: filePath];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    [moviePlayer setFullscreen:YES animated:YES];
    moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    moviePlayer.shouldAutoplay = YES;
    [moviePlayer.view setFrame: self.view.bounds];  // player's frame must match parent's
    
    [self.view addSubview: moviePlayer.view];
    
    [moviePlayer play];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *moviePlayer = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayer];
    
    // If the moviePlayer.view was added to the view, it needs to be removed
    if ([moviePlayer respondsToSelector:@selector(setFullscreen:animated:)]) {
        [moviePlayer.view removeFromSuperview];
    }
    
    [moviePlayer release];
}

- (void)displayTransactionUnverifiedErrorMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to verify Transaction" message:@"Sorry, we are unable to verify the transaction. It's probably ilicit." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}


@end
