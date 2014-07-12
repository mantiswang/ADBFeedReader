//
//  ADBFeedParser.m
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import "ADBFeedParser.h"
#import "ADBFeedInfoDTO.h"
#import "ADBFeedItemDTO.h"
#import "NSString+HTML.h"
#import "NSDate+InternetDateTime.h"

NSString *const ADBErrorDomain = @"ADBFeedParser";

@interface ADBFeedParser ()

@property (nonatomic, strong) ADBFeedInfoDTO *info;
@property (nonatomic, strong) ADBFeedItemDTO *item;
@property (nonatomic, strong) NSMutableString *currentText;
@property (nonatomic, strong) NSString *currentPath;
@property (nonatomic, strong) NSDictionary *currentElementAttributes;
@property (nonatomic, strong) NSXMLParser *feedParser;
@property (nonatomic, strong) NSString *connectionTextEncodingName;
@property (nonatomic, strong) dispatch_queue_t workingQueue;

@end

@implementation ADBFeedParser

@synthesize delegate = _delegate;
@synthesize url = _url;

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithURL:(NSURL *)url
{
    NSAssert(url, @"url parameter cannot be nil");
    
    self = [super init];
    
    if (self) {
        _url = [url copy];
        _workingQueue = dispatch_queue_create("com.albertodebortoli.feedparser", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

#pragma mark - Public

- (BOOL)start
{
    [self _reset];
    
    // Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                            timeoutInterval:60];
    [request setValue:@"ADBFeedParser" forHTTPHeaderField:@"User-Agent"];
	
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            [self _startParsingData:data];
        }
        else {
            [self _parsingFailedWithErrorCode:ADBErrorCodeConnectionFailed
                                  description:[NSString stringWithFormat:@"NSURLConnection failed at URL: %@", self.url]];
        }
    }];
    
    return YES;
}

- (void)stop
{
	// Debug Log
	DLog(@"ADBFeedParser: Parsing stopped");
    
	self.connectionTextEncodingName = nil;
    [self.feedParser abortParsing];
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"didStartDocument");
        if ([self.delegate respondsToSelector:@selector(feedParserDidStart:)]) {
            [self.delegate feedParserDidStart:self];
        }
    });
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"didEndDocument");
        
        if ([self.delegate respondsToSelector:@selector(feedParserDidFinish:)]) {
            [self.delegate feedParserDidFinish:self];
        }
        
        [self _reset];
    });
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"parser:foundCharacters: %@", string);
        [self.currentText appendString:string];
    });
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"NSXMLParser: foundCDATA (%d bytes)", CDATABlock.length);
        
        NSString *string = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
        
        if (!string) {
            string = [[NSString alloc] initWithData:CDATABlock encoding:NSISOLatin1StringEncoding];
        }
        
        if (string) {
            [self.currentText appendString:string];
        }
    });
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"didStartElement: %@", elementName);
        
        // Adjust path
        self.currentPath = [self.currentPath stringByAppendingPathComponent:qName];
        self.currentText = [NSMutableString string];
        self.currentElementAttributes = attributeDict;
        
        // print all attributes for this element
        NSEnumerator *attrs = [attributeDict keyEnumerator];
        NSString *key;
        //    NSString *value;
        
        while((key = [attrs nextObject]) != nil) {
            //value = [attributeDict objectForKey:key];
            DLog(@"  attribute: %@ = %@", key, value);
        }
    });
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"didEndElement: %@", elementName);
        DLog(@"NSXMLParser: didEndElement: %@", qName);
        
        // Store data
        BOOL processed = NO;
        if (self.currentText) {
            
            // Remove newlines and whitespace from currentText
            NSString *trimmedText = [self.currentText stringByRemovingNewLinesAndWhitespace];
            
            // Info
            if (!processed) {
                if ([self.currentPath isEqualToString:@"/rss/channel/title"]) {
                    if (trimmedText.length) {
                        self.info = [[ADBFeedInfoDTO alloc] init];
                        self.info.title = trimmedText;
                    }
                    processed = YES;
                }
                else if ([self.currentPath isEqualToString:@"/rss/channel/description"]) {
                    if (trimmedText.length) {
                        self.info.summary = trimmedText;
                    }
                    processed = YES;
                }
                else if ([self.currentPath isEqualToString:@"/rss/channel/link"]) {
                    if (trimmedText.length) {
                        self.info.link = trimmedText;
                    }
                    processed = YES;
                }
            }
            
            // Item
            if (!processed) {
                if ([self.currentPath isEqualToString:@"/rss/channel/item/title"]) {
                    if (trimmedText.length) {
                        self.item = [[ADBFeedItemDTO alloc] init];
                        self.item.title = trimmedText;
                    }
                    processed = YES;
                }
                else if ([self.currentPath isEqualToString:@"/rss/channel/item/link"]) {
                    if (trimmedText.length) {
                        self.item.link = trimmedText;
                    }
                    processed = YES;
                }
                else if ([self.currentPath isEqualToString:@"/rss/channel/item/guid"]) {
                    if (trimmedText.length) {
                        self.item.identifier = trimmedText;
                    }
                    processed = YES;
                }
                else if ([self.currentPath isEqualToString:@"/rss/channel/item/description"]) {
                    if (trimmedText.length) {
                        self.item.summary = trimmedText;
                    }
                    processed = YES;
                }
                else if ([self.currentPath isEqualToString:@"/rss/channel/item/media:thumbnail"]) {
                    [self _processImageLink:self.currentElementAttributes addToObject:self.item];
                    processed = YES;
                }
                else if ([self.currentPath isEqualToString:@"/rss/channel/item/content:encoded"]) {
                    if (trimmedText.length) {
                        self.item.content = trimmedText;
                    }
                    processed = YES;
                }
                else if ([self.currentPath isEqualToString:@"/rss/channel/item/pubDate"]) {
                    if (trimmedText.length) {
                        self.item.date = [NSDate dateFromInternetDateTimeString:trimmedText formatHint:DateFormatHintRFC822];
                    }
                    processed = YES;
                }
                else if ([self.currentPath isEqualToString:@"/rss/channel/item/dc:date"]) {
                    if (trimmedText.length) {
                        self.item.date = [NSDate dateFromInternetDateTimeString:trimmedText formatHint:DateFormatHintRFC3339];
                    }
                    processed = YES;
                }
            }
        }
        
        // Adjust path
        self.currentPath = [self.currentPath stringByDeletingLastPathComponent];
        
        // If end of an item then tell delegate
        if (!processed) {
            if ([qName isEqualToString:@"item"]) {
                // Dispatch item to delegate
                [self _dispatchFeedItemToDelegate];
            }
        }
        
        // Check if the document has finished parsing and send off info if needed (i.e. there were no items)
        if (!processed) {
            if ([qName isEqualToString:@"rss"]) {
                // Document ending so if we havent sent off feed info yet, do so
                if (self.info) [self _dispatchFeedInfoToDelegate];
            }
        }
    });
}

// error handling
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"XMLParser error: %@", [parseError localizedDescription]);
        [self _parsingFailedWithErrorCode:ADBErrorCodeFeedParsingError description:[parseError localizedDescription]];
    });
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"XMLParser error: %@", [validationError localizedDescription]);
        [self _parsingFailedWithErrorCode:ADBErrorCodeFeedValidationError description:[validationError localizedDescription]];
    });
}

#pragma mark - Private

- (void)_startParsingData:(NSData *)data
{
    if (data) {
		// Check whether it's UTF-8
		if (![[self.connectionTextEncodingName lowercaseString] isEqualToString:@"utf-8"]) {
			// Not UTF-8 so convert
			DLog(@"ADBFeedParser: XML document was not UTF-8... converting it...");
			NSString *string = nil;
			
			// Attempt to detect encoding from response header
			NSStringEncoding nsEncoding = 0;
			if (self.connectionTextEncodingName) {
				CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)self.connectionTextEncodingName);
				if (cfEncoding != kCFStringEncodingInvalidId) {
					nsEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);
					if (nsEncoding != 0) string = [[NSString alloc] initWithData:data encoding:nsEncoding];
				}
			}
			
			// If that failed then make our own attempts
			if (!string) {
				// http://www.mikeash.com/pyblog/friday-qa-2010-02-19-character-encodings.html
				string			    = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
				if (!string) string = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
				if (!string) string = [[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding];
			}
			
			data = nil;
			
			// Parse
			if (string) {
				// Set XML encoding to UTF-8
				if ([string hasPrefix:@"<?xml"]) {
					NSRange a = [string rangeOfString:@"?>"];
					if (a.location != NSNotFound) {
						NSString *xmlDec = [string substringToIndex:a.location];
						if ([xmlDec rangeOfString:@"encoding=\"UTF-8\""
										  options:NSCaseInsensitiveSearch].location == NSNotFound) {
							NSRange b = [xmlDec rangeOfString:@"encoding=\""];
							if (b.location != NSNotFound) {
								NSUInteger s = b.location+b.length;
								NSRange c = [xmlDec rangeOfString:@"\"" options:0 range:NSMakeRange(s, [xmlDec length] - s)];
								if (c.location != NSNotFound) {
									NSString *temp = [string stringByReplacingCharactersInRange:NSMakeRange(b.location,c.location+c.length-b.location)
                                                                                     withString:@"encoding=\"UTF-8\""];
									string = temp;
								}
							}
						}
					}
				}
				
				// Convert string to UTF-8 data
				if (string) {
					data = [string dataUsingEncoding:NSUTF8StringEncoding];
				}
				
			}
			
		}
		
		// Create NSXMLParser
		if (data) {
            NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:data];
            
            // this class will handle the events
            [xmlparser setDelegate:self];
            [xmlparser setShouldResolveExternalEntities:NO];
            [xmlparser setShouldProcessNamespaces:YES];
            
            self.feedParser = xmlparser;
            dispatch_async(self.workingQueue, ^{
                [self.feedParser parse];
            });
		} else {
			[self _parsingFailedWithErrorCode:ADBErrorCodeFeedParsingError description:@"Error with feed encoding"];
		}
	}
}

- (void)_dispatchFeedInfoToDelegate
{
	if (self.info) {
		// Inform delegate
		if ([self.delegate respondsToSelector:@selector(feedParser:didParseFeedInfo:)]) {
			[self.delegate feedParser:self didParseFeedInfo:self.info];
        }
		
		// Debug log
		DLog(@"ADBFeedParser: info for \"%@\" successfully parsed", self.info.title);
		
        // Finish
		self.info = nil;
	}
}

- (void)_dispatchFeedItemToDelegate
{
	if (self.item) {
		// Process before hand
		if (!self.item.summary) {
            self.item.summary = self.item.content;
            self.item.content = nil;
        }
        
		if (!self.item.date && self.item.update_date) {
            self.item.date = self.item.update_date;
        }
        
		// Debug log
		DLog(@"ADBFeedParser: item \"%@\" successfully parsed", self.item.title);
		
		// Inform delegate
		if ([self.delegate respondsToSelector:@selector(feedParser:didParseFeedItem:)])
			[self.delegate feedParser:self didParseFeedItem:self.item];
		
		// Finish
		self.item = nil;
	}
}

- (void)_reset
{
	self.connectionTextEncodingName = nil;
	self.currentPath = @"/";
	self.currentText = [[NSMutableString alloc] init];
	self.item = nil;
	self.info = nil;
	self.currentElementAttributes = nil;
}

- (BOOL)_processImageLink:(NSDictionary *)attributes addToObject:(id)obj
{
	if (attributes && [attributes objectForKey:@"url"]) {
        [obj setImage_url:[attributes objectForKey:@"url"]];
		return YES;
    }
	return NO;
}

- (void)_parsingFailedWithErrorCode:(int)code description:(NSString *)description
{
    // Create error
    NSError *error = [NSError errorWithDomain:ADBErrorDomain
                                         code:code
                                     userInfo:[NSDictionary dictionaryWithObject:description
                                                                          forKey:NSLocalizedDescriptionKey]];
    DLog(@"%@", error);
    
    [self.feedParser abortParsing];
    
    [self _reset];
    
    if ([self.delegate respondsToSelector:@selector(feedParser:didFailWithError:)]) {
        [self.delegate feedParser:self didFailWithError:error];
    }
}

@end
