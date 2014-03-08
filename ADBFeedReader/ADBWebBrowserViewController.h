//
//  ADBWebBrowserViewController.h
//  ADBWebBrowserViewController
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ADBWebBrowserViewController;

@protocol ADBWebBrowserViewControllerDelegate <NSObject>
@optional
- (void)webBrowserViewControllerDidDismiss:(ADBWebBrowserViewController *)controller;
- (void)webBrowserViewController:(ADBWebBrowserViewController *)controller didRequestURL:(NSURL *)url;
@end

@interface ADBWebBrowserViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate> {
    UIWebView *_webView;
    UITextField *_addressField;
    NSURL *_urlAddress;
    id <ADBWebBrowserViewControllerDelegate> _delegate;
}

- (id)initWithURL:(NSURL *)aUrlAddress delegate:(id <ADBWebBrowserViewControllerDelegate>)aDelegate;
- (IBAction)doneButtonPress:(id)sender;

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UITextField *addressField;
@property (nonatomic) id <ADBWebBrowserViewControllerDelegate> delegate;
@property (nonatomic, strong) NSURL *urlAddress;

@end
