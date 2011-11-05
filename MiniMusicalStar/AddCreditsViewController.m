//
//  AddCreditsViewController.m
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 3/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AddCreditsViewController.h"

@implementation AddCreditsViewController

@synthesize textFieldOne;
@synthesize textFieldTwo;
@synthesize textFieldThree;
@synthesize textFieldFour;
@synthesize textFieldFive;

@synthesize textFieldArray;

- (void) dealloc
{
    [textFieldArray release];
    [textFieldOne release];
    [textFieldTwo release];
    [textFieldThree release];
    [textFieldFour release];
    [textFieldFive release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.textFieldArray = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//- (IBAction)onValueChange:(id)sender 
//{
//    NSString *text = nil;
//    int MAX_LENGTH = 20;
//    switch ([sender tag] ) 
//    {
//        case 1: 
//        {
//            text = textFieldOne.text;
//            if (MAX_LENGTH < [text length]) {
//                textFieldOne.text = [text substringToIndex:MAX_LENGTH];
//            }
//        }
//            break;
//        default:
//            break;
//    }
//    
//}

- (NSMutableArray*) getTextFieldArray
{
    [self.textFieldArray addObject:textFieldOne];
    [self.textFieldArray addObject:textFieldTwo];
    [self.textFieldArray addObject:textFieldThree];
    [self.textFieldArray addObject:textFieldFour];
    [self.textFieldArray addObject:textFieldFive];
    return self.textFieldArray;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
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
	return YES;
}

@end
