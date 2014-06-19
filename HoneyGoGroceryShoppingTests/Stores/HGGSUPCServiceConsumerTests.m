//
//  HGGSUPCServiceConsumerTests.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 1/12/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import "HGGSUPCServiceConsumerTests.h"
#import "HGGSUPCServiceConsumer.h"

@implementation HGGSUPCServiceConsumerTests
{
    NSData *_jsonResponseData;
    HGGSUPCServiceConsumer *_serviceConsumer;
}
- (void)setUp
{
    [super setUp];
    
    NSString *jsonResponse = @"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><soap:Body><GetProductJSONResponse xmlns=\"http://searchupc.com/\"><GetProductJSONResult>{\"0\":{\"productname\":\"Tampax Plastic, Super Absorbency, Unscented, 18 tampons\",\"imageurl\":\"http://img.rakuten.com/PIC/49842143/0/1/250/49842143.jpg\",\"producturl\":\"http://www.searchupc.com/rd.aspx?u=Hn95ES%2f0oGeTkm5WOHBJEsf38kXKsGqp%2fhJB6oKvmfiQrwjK%2b6rOxLkxl%2bGlBDqIiq%2fVhFBoEmlHZ5miVRJHRx53Rmei8L9NjQTGLq3UV9Rh%2fUv4VnW%2fFTPUKSLN6k%2bG%2bsYc6CCN6QoqP3cuEVZotymzR5qjCkTeuGUSPSAPzRg39z6hKRhyQ%2bvmLiAZYuCAEmeckdo3QfKTTW1pa6689sV6%2fZC%2fWpyehNSTExpMSs%2f9QFAdc5soyQeUAh5HSc2liqxm%2f1mWx4aGcu58kfHnuQ%3d%3d\",\"price\":\"5.59\",\"currency\":\"USD\",\"saleprice\":\"\",\"storename\":\"Buy.com (dba Rakuten.com Shopping)\"}}</GetProductJSONResult></GetProductJSONResponse></soap:Body></soap:Envelope>";

    _jsonResponseData =[jsonResponse dataUsingEncoding:NSUTF8StringEncoding];
    _serviceConsumer = [[HGGSUPCServiceConsumer alloc] init];
}

- (void)tearDown
{
    
}

-(void)testGetProductDescriptionsFromValidSOAPEnvelope_WhenOneProduct
{
    [_serviceConsumer getProductDescriptionsFromSOAPEnvelope:_jsonResponseData];
    NSArray *productNames = [_serviceConsumer productNames];
    
    XCTAssertEqual([productNames count], (NSUInteger)1);
}

@end
