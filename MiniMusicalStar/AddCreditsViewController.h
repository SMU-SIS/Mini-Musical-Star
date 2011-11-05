//
//  AddCreditsViewController.h
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 3/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCreditsViewController : UIViewController

@property (retain,nonatomic) IBOutlet UITextField *textFieldOne;
@property (retain,nonatomic) IBOutlet UITextField *textFieldTwo;
@property (retain,nonatomic) IBOutlet UITextField *textFieldThree;
@property (retain,nonatomic) IBOutlet UITextField *textFieldFour;
@property (retain,nonatomic) IBOutlet UITextField *textFieldFive;

@property (retain,nonatomic) IBOutlet NSMutableArray *textFieldArray;

//- (IBAction)onValueChange:(id)sender;

- (NSMutableArray*) getTextFieldArray;

@end
