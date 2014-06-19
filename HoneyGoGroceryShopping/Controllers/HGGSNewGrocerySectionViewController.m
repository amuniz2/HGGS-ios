//
//  HGGSNewGrocerySectionViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 3/2/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import "HGGSNewGrocerySectionViewController.h"

@interface HGGSNewGrocerySectionViewController ()

@end

@implementation HGGSNewGrocerySectionViewController
#pragma mark Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [aisleNumberStepper setMinimumValue:0];
    [aisleNumberStepper setMaximumValue:100];
    [aisleNumberStepper setStepValue:1.0];
    
    [aisleNumberField setText:[NSString stringWithFormat:@"%li", (long)_aisleNumber]];
    [aisleNumberStepper setValue:_aisleNumber];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions
- (IBAction)addSection:(id)sender
{
    //[_groceryItem setName:[name text]];
    _sectionName = [sectionNameField text];
    _aisleNumber = [[aisleNumberField text] integerValue];
    _actionTaken = saveChanges;
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:_dismissBlock];

}

- (IBAction)cancel:(id)sender
{
    _actionTaken = cancelChanges;
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:_dismissBlock];
    
}

- (IBAction)increaseOrDecreaseAisleNumber:(id)sender
{
    [aisleNumberField setText:[NSString stringWithFormat:@"%li", (long)[aisleNumberStepper value]]];
}

#pragma mark Property Overrides
-(void)setAisleNumber:(NSInteger)aisleNumber
{
    _aisleNumber = aisleNumber;
}
@end
