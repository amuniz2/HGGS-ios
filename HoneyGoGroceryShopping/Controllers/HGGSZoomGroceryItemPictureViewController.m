//
//  HGGSZoomGroceryItemPictureViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/20/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import "HGGSZoomGroceryItemPictureViewController.h"
#import "HGGSGroceryItem.h"

@interface HGGSZoomGroceryItemPictureViewController ()

@end

@implementation HGGSZoomGroceryItemPictureViewController

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
    
    // Do any additional setup after loading the view.
    [groceryItemPicture setImage:[[self groceryItem] image]];
    [groceryItemName setText:[[self groceryItem] name]];
     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma name Actions
-(void)finishedViewing:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
