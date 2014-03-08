//
//  ADBWebBrowserViewController.m
//  ADBWebBrowserViewController
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import "ADBWebBrowserViewController.h"
#import "MBProgressHUD.h"

@implementation ADBWebBrowserViewController

#pragma mark - View lifecycle

- (id)initWithURL:(NSURL *)aUrlAddress delegate:(id <ADBWebBrowserViewControllerDelegate>)aDelegate
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self = [super initWithNibName:@"ADBWebBrowserViewController_iPhone" bundle:nil];
    } else {
        self = [super initWithNibName:@"ADBWebBrowserViewController_iPad" bundle:nil];
    }
        
    if (self) {
        _delegate = aDelegate;
        _urlAddress = aUrlAddress;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addressField.text = [self.urlAddress absoluteString]; 
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.urlAddress]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Actions

- (IBAction)doneButtonPress:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(webBrowserViewControllerDidDismiss:)]) {
        [self.delegate webBrowserViewControllerDidDismiss:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
    if ([self.delegate respondsToSelector:@selector(webBrowserViewController:didRequestURL:)]) {
        [self.delegate webBrowserViewController:self didRequestURL:self.urlAddress];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:self.webView animated:YES];
    self.addressField.text = [[self.webView.request URL] absoluteString];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.webView animated:YES];
    self.addressField.text = [[self.webView.request URL] absoluteString];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.urlAddress = [NSURL URLWithString:textField.text];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.urlAddress]];
    [textField resignFirstResponder];
    return YES;
}

@end
