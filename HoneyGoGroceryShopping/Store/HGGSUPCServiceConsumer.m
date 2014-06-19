//
//  HGGSUPCServiceConsumer.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 1/12/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import "HGGSUPCServiceConsumer.h"

@implementation HGGSUPCServiceConsumer 
{
    NSMutableString *_jsonResponseAsString;
    BOOL _collectingJsonResponse;
}
-(void)getProductDescriptionsFromSOAPEnvelope:(NSData*)soapEnvelopeData
{
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:soapEnvelopeData];
    _productNames = [[NSMutableArray alloc] init];
    _errorParsing = NO;
    _collectingJsonResponse = NO;
    [xmlParser setDelegate:self];
    [xmlParser parse];
}
#pragma mark Xml Parser Delegate Methods
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    
    NSString *errorString = [NSString stringWithFormat:@"Error code %li", (long)[parseError code]];
    NSLog(@"Error parsing XML: %@", errorString);
    
    _errorParsing=YES;
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"GetProductJSONResult"])
    {
        _jsonResponseAsString = [[NSMutableString alloc] init];
        _collectingJsonResponse = YES;
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_collectingJsonResponse)
        [_jsonResponseAsString appendString:string];
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"GetProductJSONResult"])
    {
        _collectingJsonResponse = NO;
        // now, need to parse the json string to get the item description
        _productNames = [self productNamesFromJSONResult:_jsonResponseAsString];
    }
}
-(NSMutableArray *) productNamesFromJSONResult:(NSString*)jsonResult
{
    _productNames = [[NSMutableArray alloc] init];
    NSData* jsonData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSString *thisProdunctName;
    
    NSDictionary* items = [NSJSONSerialization
                      JSONObjectWithData:jsonData //1
                      options:kNilOptions
                      error:&error];
    
    for (NSDictionary *item in [items objectEnumerator])
    {
        thisProdunctName = [[item objectForKey:@"productname"] stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceCharacterSet]];
        if ((thisProdunctName != nil) && (thisProdunctName.length > 0))
            [_productNames addObject:thisProdunctName];
    }
    return _productNames;

}
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (_errorParsing )
    {
        NSLog(@"Error occurred during XML processing");
    }
}
@end
