//
//  HGGSBarCodeScannerViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 1/6/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "HGGSBarCodeScannerViewController.h"
#import "HGGSUPCServiceConsumer.h"

#define UPC_LOOKUP_URL @"http://www.searchupc.com/service/UPCSearch.asmx"
#define UPC_NAMESPACE @"http://searchupc.com/"
#define UPC_ACCESS_TOKEN @"2ADB35B4-7F5C-485F-B616-E2E38120EA14"

@interface HGGSBarCodeScannerViewController () <AVCaptureMetadataOutputObjectsDelegate, NSURLConnectionDataDelegate,
UIPickerViewDelegate, UIPickerViewDataSource>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer * _previewLayer;
    NSMutableData * _productDataReceived;
    NSURLConnection *_connectionToWebService ;
    UIActivityIndicatorView * _activityIndicator;
    NSInteger _heightNeededToDisplayLongestProductDescription;
    
    NSArray *_productChoices;
}

@end

@implementation HGGSBarCodeScannerViewController
#pragma mark Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
// reference: http://stackoverflow.com/questions/20274544/barcode-scanning-in-ios-7
//- (void)viewDidAppear:(BOOL)animated
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [_highlightView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin /*| UIViewAutoresizingFlexibleBottomMargin*/];
    
    //[[self view] setAutoresizesSubviews:NO];
    [[_highlightView layer] setBorderColor:[[UIColor greenColor] CGColor]];
    [[_highlightView layer] setBorderWidth:3.0];
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    [_session addInput:_input];
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    [_output setMetadataObjectTypes:[_output availableMetadataObjectTypes]];
    [_output setRectOfInterest:[_highlightView bounds]];
    
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_previewLayer setFrame:[_highlightView bounds]];
    if ([[_previewLayer connection] isVideoOrientationSupported]) {
        [[_previewLayer connection] setVideoOrientation:(AVCaptureVideoOrientation)[[UIApplication sharedApplication] statusBarOrientation]];
    }
    [[[self view] layer] insertSublayer:_previewLayer above:[_highlightView layer]];
    [_session startRunning];
    //[[self view] bringSubviewToFront:_highlightView];

    [_selectSingleProductView setHidden:YES];
    [_selectSingleProductView setUserInteractionEnabled:NO];
    [cancelScanButton setHidden:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Capture Image
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (_connectionToWebService == nil)
    {
        CGRect highlightViewRect = CGRectZero;
        AVMetadataMachineReadableCodeObject *barcode;
        NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
        
        for (AVMetadataObject *metadata in metadataObjects)
        {
            if ([barCodeTypes containsObject:[metadata type]])
            {
                barcode = (AVMetadataMachineReadableCodeObject *)[_previewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = [barcode bounds];
                break;
            }
        }
        
        [_highlightView setFrame:highlightViewRect];
        if (barcode)
        {
            [self stopCapture];
            [self itemNameFromBarCode:[barcode stringValue]];
        }
            /*else
        {
            [self displayMessage:@"Unable to capture barcode." type:@"Error"];
            [self returnToParent];
        }*/
    }
    
}
-(void) stopCapture
{
    [_session stopRunning];
    _device = nil;
    //_previewLayer = nil;
    //_output = nil;
    _input = nil;
    _session = nil;
}
#pragma mark Private
-(void)itemNameFromBarCode:(NSString *)barCode
{
    // todo:
    //refer to:http://codewithchris.com/tutorial-how-to-use-ios-nsurlconnection-by-example/#post
    //todo: start activity indicator?
    static NSString* getProductJSON_SOAPRequestXML = @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">"
    "<soap12:Body>"
    "<GetProductJSON xmlns=\"http://searchupc.com/\">"
    "<upc>%@</upc>"
    "<accesstoken>%@</accesstoken>"
    "</GetProductJSON>"
    "</soap12:Body>"
    "</soap12:Envelope>";
    
    _productDataReceived = [[NSMutableData alloc] init];
    NSURL *webServiceURL = [NSURL URLWithString:UPC_LOOKUP_URL];
    NSMutableURLRequest *webServiceRequest = [NSMutableURLRequest requestWithURL:webServiceURL];
    
    [webServiceRequest setHTTPMethod:@"POST"];
    
    // This is how we set header fields
    [webServiceRequest setValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    // Convert your data and set your request's HTTPBody property
    NSString *stringData = [NSString stringWithFormat:getProductJSON_SOAPRequestXML, barCode, UPC_ACCESS_TOKEN];
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    
    
    [webServiceRequest setHTTPBody: requestBodyData];
    //[_highlightView setHidden:YES];
    //[self showActivityIndicator];
    _connectionToWebService = [[NSURLConnection alloc] initWithRequest:webServiceRequest delegate:self startImmediately:YES];
    
}
-(void)showActivityIndicator
{
    _activityIndicator  = [[UIActivityIndicatorView alloc] init];
    [_activityIndicator setHidesWhenStopped:YES];
    [_activityIndicator startAnimating];
    
}
-(void) hideActivityIndicator
{
    [_activityIndicator stopAnimating];
    _activityIndicator = nil;
}
-(void)returnToParent
{
    [self hideActivityIndicator];
    [_session stopRunning];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)getSingleProductDescription:(NSArray*)possibleProductDescriptions
{
    NSInteger count = [possibleProductDescriptions count];
    
    if (count == 0)
    {
        [self displayMessage:@"Product description not available." type:@"Error"];
        [self returnToParent];
    }
    else if (count > 1)
    {
        [self displayProductChoices:possibleProductDescriptions];
    }
    else
    {
        NSString *singleProductDescription = [possibleProductDescriptions objectAtIndex:0] ;
        [[self delegate] didGetProductDescription:singleProductDescription];
        [self returnToParent];
    }
}

-(void) displayProductChoices:(NSArray*)productChoices
{
    _productChoices = productChoices;
    [self pickerRowHeight];
    [_productSelector setDataSource:self];
    [_productSelector setDelegate:self];
    
    [_selectSingleProductView setHidden:NO];
   // [cancelScanButton setHidden:YES];
    [_selectSingleProductView setUserInteractionEnabled:YES];
    [_productSelector reloadAllComponents];
    [_productSelector selectRow:[productChoices count]-1 inComponent:0 animated:NO];
    [[self view] layoutIfNeeded];

}

-(NSInteger)pickerRowHeight
{
    NSInteger maxStringLen = 0;
    NSString *longestProductName = @"";
    
    for (NSString *p in _productChoices)
    {
        if ([p length] > maxStringLen)
        {
            maxStringLen = [p length];
            longestProductName = p;
        }
    }
    CGRect rect = [longestProductName boundingRectWithSize:CGSizeMake([_productSelector frame].size.width,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil];
   // CGSize size = [longestProductName sizeWithAttributes:[NSDictionary dictionaryWithObjects:nil forKeys:nil count:0]];
    _heightNeededToDisplayLongestProductDescription = rect.size.height * 1.5;
    return _heightNeededToDisplayLongestProductDescription;

}
-(UIView *)createViewForPickerRow:(NSInteger)row
{
    UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(0.f, 0.f, [_productSelector frame].size.width, 60.f)];
    [tv setTextAlignment:NSTextAlignmentLeft];
    [tv setText:[_productChoices objectAtIndex:row]];
    [self adjustSizeOfTextView:tv];
    return tv;
    
    
}

-(void)adjustSizeOfTextView:(UITextView*)textView
{
    // http://stackoverflow.com/questions/50467/how-do-i-size-a-uitextview-to-its-content
    //uint originalHeight = [textView frame].size.height;
    
    CGFloat fixedWidth = textView.frame.size.width;
    //CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    //CGSize newSize = [textView contentSize];
    CGSize newSize = [textView sizeThatFits:[textView contentSize]];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    if ([textView contentSize].height != newFrame.size.height)
        [textView sizeToFit];
    //[textView setNeedsDisplay];
    
    //[[self view] setNeedsLayout];
}


#pragma mark NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //concatenate to data received perviously
    [_productDataReceived appendData:data];
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //parse the data received and handle the products returned.
    //i.e., if only one product, return the product name/info and return from the dialog
    // otherwise, show the user the list of items returned and have them select one
    //NSString* reply = [[NSString alloc] initWithUTF8String:[_productDataReceived bytes]];
    HGGSUPCServiceConsumer *serviceConsumer = [[HGGSUPCServiceConsumer alloc] init];
    [serviceConsumer getProductDescriptionsFromSOAPEnvelope:_productDataReceived];
    
    NSArray* productDescriptions = [serviceConsumer productNames];
    
    [self getSingleProductDescription:productDescriptions];
    
    
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //display connection error and return from dialog
    _connectionToWebService = nil;
    _productDataReceived = nil;
    NSString *errorDescription = [NSString stringWithFormat:@"Error getting product informaiton: %@", [error localizedDescription]];
    
    [self displayMessage:errorDescription type:@"Error"];
    
    [self returnToParent];
}
-(void)displayMessage:(NSString*)message type:(NSString*)typeOfMessage
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:typeOfMessage message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [av show];
    
}
#pragma mark Actions
- (IBAction)ProductSelected:(id)sender
{
    NSString *singleProductDescription = [_productChoices objectAtIndex:[_productSelector selectedRowInComponent:0]];
    [[self delegate] didGetProductDescription:singleProductDescription];
    [self returnToParent];
    
}
-(IBAction)Cancel:(id)sender
{
    [self returnToParent];
}
#pragma mark UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return _heightNeededToDisplayLongestProductDescription;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    return [self createViewForPickerRow:row];
}

#pragma mark UIPickerViewDataSource
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_productChoices count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_productChoices objectAtIndex:row];
}

@end
