//
//  HGGSSynchronizeDropboxFilesViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/20/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSSynchronizeDropboxFilesViewController.h"
#import "HGGSGroceryStoreManager.h"
#import "HGGSDbGroceryFilesStore.h"
#import "HGGSGroceryStore.h"

@interface HGGSSynchronizeDropboxFilesViewController ()
{
}

@end

@implementation HGGSSynchronizeDropboxFilesViewController

#pragma mark Initialization Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc
{
    [synchOptionSelector setDelegate:nil];
    [synchOptionSelector setDataSource:nil];
    
}

#pragma mark Actions
- (IBAction)SynchronizeWithDropbox:(id)sender
{
    DbFileSynchOption optionSelected=(DbFileSynchOption)[synchOptionSelector selectedRowInComponent:0];
    [self setSynchOptionSelected:optionSelected];
    [self doSynch:optionSelected];
}

#pragma mark UIView Overloads
- (void)viewDidLoad
{
    [super viewDidLoad];
    [synchOptionSelector setDelegate:self];
    [synchOptionSelector setDataSource:self];
    
	// Do any additional setup after loading the view.
    [synchInstructionsLabel setText:[NSString stringWithFormat:@"There are existing files for %@.  Select what you would like to do:", [_groceryStore name]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIPickerViewDelegate Methods
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    [actionButton setTitle:[[self optionDescriptions] objectAtIndex:row] forState:UIControlStateNormal];
    [actionButton setNeedsDisplay];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[self optionDescriptions] objectAtIndex:row];
}

#pragma mark UIPickerViewDataSource Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}

#pragma mark Private Methods
-(void) displayError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"An error occurred copying a file to/from Dropbox server."
                                                       delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    
    [alertView show];
}

-(void)doSynch:(DbFileSynchOption) synchOptionSelected
{
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    switch(synchOptionSelected)
    {
        case ShareLocalFile:
        {
            [self showActivityIndicator];
            [dbStore copyStoreToDropbox:_groceryStore  notifyCopyCompleted:^void(BOOL succeeded)
             { [self synchActivityCompleted:succeeded];}];
        }
        break;
            
        case ShareDropboxFile:
        {
            [self showActivityIndicator];
            [dbStore copyStoreFromDropbox:_groceryStore notifyCopyCompleted:^void(BOOL succeeded)
             { [self synchActivityCompleted:succeeded];}];
        }
        break;
            
        case DoNotShareFile:
        {
            //_sharingStatus = linked;
            [[self presentingViewController] dismissViewControllerAnimated:YES completion:_dismissBlock];
        }
        break;
            
    }
}

-(NSArray *)optionDescriptions
{
    static NSArray* optionDescriptions = nil;
    if(!optionDescriptions)
    {
        optionDescriptions = [[NSArray alloc] initWithObjects:@"Copy files from dropbox",@"Copy local files to dropbox",@"Cancel",nil];
    }
    return optionDescriptions;
}

-(void)showActivityIndicator
{
    if (!_activityIndicator)
    {
        _activityIndicator  = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_activityIndicator setHidesWhenStopped:YES];
        _activityIndicator.center = CGPointMake(actionButton.center.x, actionButton.frame.origin.y + actionButton.frame.size.height + 20);
        [self.view addSubview:_activityIndicator];
        
    }
    [_activityIndicator startAnimating];
}
-(void) hideActivityIndicator
{
    [_activityIndicator stopAnimating];
    _activityIndicator = nil;
}

-(void)synchActivityCompleted:(BOOL) succeeded
{
    [self hideActivityIndicator];
    if (!succeeded)
    {
        [self displayError];
    }
    else
    {
        // if file was copied from db...
        [_groceryStore reloadLists];
        [_groceryStore setShareLists:YES];
        HGGSDbGroceryFilesStore * dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
        [dbStore notifyOfChangesToStore:_groceryStore];
    }
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:_dismissBlock];
    
}


@end
