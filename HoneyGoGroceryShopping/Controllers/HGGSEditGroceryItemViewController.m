//
//  HGGSEditGroceryItemViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/10/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import <MobileCoreServices/UTCoreTypes.h>

#import "HGGSEditGroceryItemViewController.h"
#import "HGGSGroceryItem.h"
#import "HGGSGrocerySection.h"
#import "HGGSGrocerySectionSelectorViewController.h"
#import "HGGSGroceryStore.h"
#import "HGGSSelectGrocerySectionViewController.h"
#import "NSString+SringExtensions.h"
#import "UIImage+UIImageResizable.h"

@interface HGGSEditGroceryItemViewController ()<UIPickerViewDataSource,UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@end

@implementation HGGSEditGroceryItemViewController

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
 
    [name setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin];
    [_additionalNotes setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    
    _originalGroceryItemName = [[self groceryItem] name];
    [name setText:_originalGroceryItemName];
    
    [_additionalNotes setText:[[self groceryItem] notes]];
    [units setText:[[self groceryItem] unit]];
    [quantity setText:[NSString stringWithFormat:@"%g",[[self groceryItem] quantity]]];
    [self initializeSelectionControls];
    [grocerySection setText:[[self groceryItem] section]];
    [_imageView setImage:[[self groceryItem] image]];

    if ([[self groceryItem] image] == nil)
    {
        _imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _imageView.layer.borderWidth = 2.0f;
    }
    [quantity setEnabled:(_itemType != shoppingItem)];
    [quantity setUserInteractionEnabled:(_itemType != shoppingItem)];
    [quantity setBackgroundColor:(_itemType != shoppingItem) ?
     ([UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]):
     ([UIColor colorWithRed:0.81 green:0.89 blue:0.95 alpha:1.0])];
    
	// Do any additional setup after loading the view.
    [_additionalNotes setDelegate:self];
    [name setDelegate:self];
    [quantity setDelegate:self];
    [grocerySection setDelegate:self];
    [units setDelegate:self];

    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _imageView.clipsToBounds = YES;
  
    // clears the keyboard if it is present
    [[self view] endEditing:YES];
    
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self adjustSizeOfTextView:name];
    [self adjustSizeOfTextView:_additionalNotes];

}
#pragma mark Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
   
    if ([segue.identifier isEqualToString:@"toSelectSection"])
    {
        HGGSSelectGrocerySectionViewController *selectionController = segue.destinationViewController;
        //[selectionController setGrocerySections:_grocerySections];
        [selectionController setGroceryAisles:[_groceryStore getGroceryAisles]];
        [selectionController setSelectedSectionName:[grocerySection text]];
        __weak HGGSSelectGrocerySectionViewController *weakRefToController = selectionController;
        
        [selectionController setDismissBlock:^{[self handleReturnFromSelectSectionController:weakRefToController];}];
        
    }
    else if ([segue.identifier isEqualToString:@"toScanner"])
    {
        HGGSBarCodeScannerViewController *scannerController = segue.destinationViewController;
        [scannerController setDelegate:self];
    
    }
    else
        NSLog(@"Seque identifier: %@", segue.identifier);
    
    
}
#pragma mark Scanner Delegate Methods
-(void) didGetProductDescription:(NSString *)productNameOrDescription
{
    // close dialog...
    //NSString* itemName = [self itemNameFromBarCode:barCode];
    
    if ([[name text] length] == 0)
    {
        [name setText:productNameOrDescription];
        [self adjustSizeOfTextView:name];
    }
    else
    {
        [_additionalNotes setText:productNameOrDescription];
        [self adjustSizeOfTextView:_additionalNotes];
    }
}
#pragma mark Property Overrides
-(NSString *)selectionLabelText
{
    switch (_itemType)
    {
        case pantryItem:
            return @"Automatically include in new shopping list";

        case newShoppingItem:
            return @"Include in master grocery list";
            
        case shoppingItem:
            return nil;
        
        default:
            return @"Needs label text defined";
    };
}

#pragma mark Actions
-(IBAction)enterEditModeOrCancel:(id)sender
{
    [self cancel];
}

- (IBAction)deleteItem:(id)sender {
    
    _actionTaken = deleteItem;
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:_dismissBlock];
}

-(IBAction)saveOrReturn:(id)sender
{
    [self save];
}

#pragma mark Camera Actions
- (void) useCamera:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
    }
}
-(void)deleteImage:(id)sender
{
    [_groceryItem setImage:nil];
    [_imageView setImage:nil];
    
}
- (void) useCameraRoll:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
    }
}
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
       
        CGSize imageMaxSize = [_imageView bounds].size;
        //CGSize newSize = [image proportionateReducedSize:imageMaxSize];
        //_imageView.image = image;
        [[self groceryItem] setImage:[image resizeImageToMaxSize:imageMaxSize origin:CGPointMake(0,0)]] ;
        _imageView.layer.borderColor = nil;
        _imageView.layer.borderWidth = 0.0f;
        
        _imageView.image = [[self groceryItem] image];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_imageView setClipsToBounds:YES];
        
        /*if (_newMedia)
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
         */
    }
}

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) hideKeyboard
{
    
    for (UIView *view in [self.view subviews]) {
        if ([view isFirstResponder]) {
            [view resignFirstResponder];
            break;
        }
    }
}


#pragma mark Overrides

#pragma mark UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark UIPickerViewDataSource
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_grocerySections count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    HGGSGrocerySection* section = [_grocerySections objectAtIndex:row];
    return [section name ];
}
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark UITextViewDelegate
- (BOOL)textViewShouldReturn:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView
{
    [self adjustSizeOfTextView:textView];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}
#pragma mark Private
-(void)adjustSizeOfTextView:(UITextView*)textView
{
    // http://stackoverflow.com/questions/50467/how-do-i-size-a-uitextview-to-its-content
    //uint originalHeight = [textView frame].size.height;
    
    /*CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:[textView contentSize]];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    if ([textView contentSize].height != newFrame.size.height)
        [textView sizeToFit];
*/
    CGRect frame = textView.frame;
    UIEdgeInsets inset = textView.contentInset;
    frame.size.height = textView.contentSize.height + inset.top + inset.bottom;
    textView.frame = frame;
   
    [textView setNeedsLayout];
    [[self view] setNeedsLayout];
}

- (void)cancel
{
    
    _actionTaken = cancelChanges;
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:_dismissBlock];
    
}
-(void)initializeSelectionControls
{
    NSString* selectionLabelText = [self selectionLabelText];
    if (selectionLabelText != nil)
    {
        [select setOn:((_itemType == pantryItem) ? [[self groceryItem] selected]:  YES)];
        [selectionLabel setText:selectionLabelText];
        return;
    }
    [selectionLabel setHidden:YES];
    [select setHidden:YES];
    
}
-(bool) valid
{
    NSString* newItemName = [name text] ;
   
    if ([NSString isEmptyOrNil:newItemName])
    {
        [name setBackgroundColor:[UIColor redColor]];
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Name Required" message:@"Please specify a name / description for the grocery item." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        errorAlert.alertViewStyle = UIAlertViewStyleDefault;
        [errorAlert show];
        
        return NO;
    }
    else if ((![_originalGroceryItemName isEqualToString:newItemName]) && [_existingItems itemExists:newItemName])
    {
        //Duplicate Item
        [name setBackgroundColor:[UIColor redColor]];
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Duplicate Item"
                                   message:[NSString stringWithFormat:@"Item '%@' already exists. Please specify a unique name / description for the grocery item.", newItemName]
                                    delegate:nil
                                    cancelButtonTitle:@"Okay"
                                   otherButtonTitles: nil];
        errorAlert.alertViewStyle = UIAlertViewStyleDefault;
        [errorAlert show];
        
        return NO;
    }
    
    return YES;
}
- (void)save
{
    
    if (![self valid])
        return;
    
    //_originalGroceryItemName = [_groceryItem name];
    _actionTaken = saveChanges;
    if (![_originalGroceryItemName isEqualToString:[name text]])
    {
        // new grocery item must be created, as an existing one cannot have its name changed
        _groceryItem = [[HGGSGroceryItem alloc] initWithDetails:[name text]
                                                        quantity:[[quantity text] doubleValue]
                                                        unit:[units text]
                                                        section:[grocerySection text]
                                                        notes:[_additionalNotes text]
                                                        select:[select isOn]
                                                lastPurchasedOn:[NSDate date] ];
                                                         // image:[_imageView image]] ;
        [_groceryItem setImage:[_imageView image]];
        _actionTaken = (_isNewItem ? saveChanges : replaceItem);
    }
    else
    {
        [_groceryItem setUnit:[units text]];
        [_groceryItem setNotes:[_additionalNotes text]];
        [_groceryItem setSection:[grocerySection text]];
        //[_groceryItem setImage:[_imageView image]];
        
        if (_itemType != shoppingItem)
        {
            [_groceryItem setSelected:[select isOn]];
            [_groceryItem setQuantity:[[quantity text] doubleValue] ];
            
        }
        else
        {
            _saveToMasterList = [select isOn];
        }
        _actionTaken = saveChanges;
    }
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:_dismissBlock];
}

-(void) handleReturnFromSelectSectionController:(HGGSSelectGrocerySectionViewController*) selectController
{
    [grocerySection setText:[selectController selectedSectionName]];
     
}

-(BOOL) automaticallyAdjustsScrollViewInsets
{
    return NO;
}
@end
