//
//  HGGSUPCServiceConsumer.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 1/12/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGGSUPCServiceConsumer : NSObject<NSXMLParserDelegate>
{}
@property (strong, nonatomic) NSMutableArray* productNames;
@property BOOL errorParsing;
-(void)getProductDescriptionsFromSOAPEnvelope:(NSData*)soapEnvelope;
@end
