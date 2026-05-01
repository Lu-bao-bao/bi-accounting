//
//  AboutUsViewController.m
//  Accounting
//
//  Created by AmeRin on 26/12/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIProgressView* progressView;
@property (strong, nonatomic) NSTimer *myTimer;
@property (assign, nonatomic) BOOL isWebLoading;
@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    self.progressView = [[UIProgressView alloc] initWithFrame:barFrame];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.progressView.progressTintColor = [UIColor colorWithRed:43.0/255.0 green:186.0/255.0 blue:0.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar addSubview: self.progressView];
    
    NSURL *url = [NSURL URLWithString: @"https://blogrms.wordpress.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    self.webView.delegate = self;
    [self.webView.scrollView setBounces:NO];
    [self.webView loadRequest:request];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // because UINavigationBar is shared with other ViewControllers
    [self.progressView removeFromSuperview];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.progressView.progress = 0;
    self.progressView.hidden = false;
    self.isWebLoading = false;
    //0.01667 is roughly 1/60, so it will update at 60 FPS
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.isWebLoading = true;
    
    self.progressView.hidden = true;
    [self.myTimer invalidate];
    self.myTimer = nil;
    self.isWebLoading = false;
}

- (void) timerCallback {
    if (!self.isWebLoading) {
        self.progressView.progress += 0.05;
        if (self.progressView.progress >= 0.95) {
            self.progressView.progress = 0.95;
            
            [self.myTimer invalidate];
            self.myTimer = nil;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
