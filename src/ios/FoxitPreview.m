/********* FoxitPreview.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>

#import <FoxitRDK/FSPDFViewControl.h>
#import "uiextensions/UIExtensionsManager.h"


NSString *SN = @"JenPmSMLexX6uicWQ+S1J/VJIvxBbN5qa1FiWiez6dM9z0W5WjOnHQ==";
NSString *UNLOCK = @"ezJvjt/HtGh39DvoP0WUjY5Q/oyNvFY8ym9Cusfzwi7VglXhC6NHl4mC/6/QlRUmsQaQyDdEMVQs92WVcRUXTDdelIhD4BKC2ghe+00bTDPLx5abfeiEaOukPNKyFyAwmh/ed4nJBC3uz/mzocNggVQ3Kx4sW9H8jWCe1rfhPY7v9EvCp+LBBfnpn/+j5iQsPoFX52W46PxB5grGlP3uPqiioBa9Y3/VV29DPNr38Ltf+gJaApdcYjVUsrTSMqE0ti+XzOstpcrGwGh9deYJq9VcitiZP/+yA1fyBPryOvfUQ7kH/qeTf+5BG7Q0ZEJKMb5ESfuSaATgVibC6WA1nlUHuyrqzcgHQAqGRPqz2Gmp8WYPZSlHP86xZmaaNLW28RsNNNsXxrnTIIwgI9rl2JlGoWro04LBCvOpiyPhoMhq+HQ9yfNyWOhnv1AuXGDXDPFROuJ1Nz6PfXlum7KzFMM4zS3/VE5eCdV37GR11+Zxqp23jUZfvMmDTHaK9wqui5ckKQZG17M9HH7rbqqQOcdvL0qNZ1PbH9IBJw/RjpTKeYNTQe9t+jSeTSOffJirGro8XBCxdmaf4J/uTh3zmsB/S7t0H9drpcGIlvu4wHZuFHpgYxn2KlFTcg2DRUpluYVTt8U5sYgTe2lE+ax8uEEuhp0EUh7FsQ584K5LNtyqDyLZaulrGidbBchssZ3mXGl5LSZSdrRilCphY4OkpdySZG8TYF7HSXY8qebRcNTWKz9fZx0MjZiMlV+EUzzoygzou2Twx5p1HdQRHTIsGpBPMka35GEmpROCo21l8ObL0bQD8CSh7iBVlKHxEcIy4gN2PWVGoxFTd6LfdoA7TO5q+M/zA1hhQ2Msr6Us1TB0VbxI3deGvhfYt5f0dzkWcGCQk607yyTLccCb7y1VkqcWS8TMtjNrDB9z27UuZ4qK9oJ6GOSDohv44LDsg8BZ8kIVxc5hRCrL6Tc5z4Z3UlTi2TwjBS1K1Z7QWL+vSe0wdxRb+NJmmXJGWMY4cvzse8F89pswxjrhS+3nELWZgsZgwpYvjqKg6feizU5daZE5YtWxCH2rZIs2FFWCxXq3sjZJLFRYxiCf6tJhPq1Y8bVZUxmX+m5N86AgagPPslG8WrnQnhR39D44ll1LkGLQmTJFrALaMT2nctvxVwvqYkRRhGRwYzxTLsUxKtQ8DnoFEP1HYr6uZQYrz2aw3MB5A7EcK127uEimHn2r197j1qLDwCMpbFN10snfjrFs6Tab+qmD2niI1JiNX3J7wXYzfqgO8sHcFXohupZX28/6";

@interface FoxitPreview : CDVPlugin <IDocEventListener>{
    // Member variables go here.
}
@property (nonatomic, strong) NSArray *topToolbarVerticalConstraints;
@property (nonatomic, strong) UIExtensionsManager *extensionsMgr;
@property (nonatomic, strong) FSPDFViewCtrl *pdfViewControl;
@property (nonatomic, strong) UIViewController *pdfViewController;

- (void)Preview:(CDVInvokedUrlCommand *)command;
@end

@implementation FoxitPreview
{
    NSString *tmpCommandCallbackID;
}

- (void)Preview:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult *pluginResult = nil;

    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"%@", docDir);

    // URL
    NSString *filePath = [command.arguments objectAtIndex:0];

    // check file exist
    NSURL *fileURL = [[NSURL alloc] initWithString:filePath];
    BOOL isFileExist = [self isExistAtPath:fileURL.path];

    if (filePath != nil && filePath.length > 0  && isFileExist) {
        // preview
        [self FoxitPdfPreview:fileURL.path];

        // result object
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"preview success"];
        tmpCommandCallbackID = command.callbackId;
    } else {
        NSString* errMsg = [NSString stringWithFormat:@"file not find"];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:@"file not found"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

# pragma mark -- Foxit preview
-(void)FoxitPdfPreview:(NSString *)filePath {
    // init foxit sdk
    FSErrorCode eRet = [FSLibrary init:SN key:UNLOCK];
    if (e_errSuccess != eRet) {
        NSString* errMsg = [NSString stringWithFormat:@"Invalid license"];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Check License" message:errMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    self.pdfViewControl = [[FSPDFViewCtrl alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.pdfViewControl registerDocEventListener:self];

    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"uiextensions_config" ofType:@"json"];
    self.extensionsMgr = [[UIExtensionsManager alloc] initWithPDFViewControl:self.pdfViewControl configuration:[NSData dataWithContentsOfFile:configPath]];
    self.pdfViewControl.extensionsManager = self.extensionsMgr;
    self.extensionsMgr.delegate = self;

    //load doc
    if (filePath == nil) {
        filePath = [[NSBundle mainBundle] pathForResource:@"general-staff-form" ofType:@"pdf"];
    }

    if (e_errSuccess != eRet) {
        NSString *errMsg = [NSString stringWithFormat:@"Invalid license"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check License" message:errMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    self.pdfViewController = [[UIViewController alloc] init];
    self.pdfViewController.view = self.pdfViewControl;

    [self.pdfViewControl openDoc:filePath
                        password:nil
                      completion:^(FSErrorCode error) {
                          if (error != e_errSuccess) {
                              UIAlertView *alert = [[UIAlertView alloc]
                                                    initWithTitle:@"error"
                                                    message:@"Failed to open the document"
                                                    delegate:nil
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:@"ok", nil];
                              [alert show];
                          }
                      }];

    UINavigationController *test = [[UINavigationController alloc] initWithRootViewController:self.pdfViewController];
    test.navigationBarHidden = YES;
    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    [top presentViewController:test animated:YES completion:nil];

    [self wrapTopToolbar];
    self.topToolbarVerticalConstraints = @[];

    self.extensionsMgr.goBack = ^() {
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    };

    [self.extensionsMgr setToolbarItemHiddenWithTag:FS_TOPBAR_ITEM_MORE_TAG hidden:YES];
}

#pragma mark <IDocEventListener>

- (void)onDocOpened:(FSPDFDoc *)document error:(int)error {
    // Called when a document is opened.
}

- (void)onDocClosed:(FSPDFDoc *)document error:(int)error {
    // Called when a document is closed.
}

# pragma mark -- isExistAtPath
- (BOOL)isExistAtPath:(NSString *)filePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:filePath];
    return isExist;
}

#pragma mark <UIExtensionsManagerDelegate>
- (void)uiextensionsManager:(UIExtensionsManager *)uiextensionsManager setTopToolBarHidden:(BOOL)hidden {
    UIToolbar *topToolbar = self.extensionsMgr.topToolbar;
    UIView *topToolbarWrapper = topToolbar.superview;
    id topGuide = self.pdfViewController.topLayoutGuide;
    assert(topGuide);

    [self.pdfViewControl removeConstraints:self.topToolbarVerticalConstraints];
    if (!hidden) {
        NSMutableArray *contraints = @[].mutableCopy;
        [contraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0-[topToolbar(44)]"
                                                 options:0
                                                 metrics:nil
                                                   views:NSDictionaryOfVariableBindings(topToolbar, topGuide)]];
        [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[topToolbarWrapper]"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(topToolbarWrapper)]];
        self.topToolbarVerticalConstraints = contraints;

    } else {
        self.topToolbarVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topToolbarWrapper]-0-[topGuide]"
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:NSDictionaryOfVariableBindings(topToolbarWrapper, topGuide)];
    }
    [self.pdfViewControl addConstraints:self.topToolbarVerticalConstraints];
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.pdfViewControl layoutIfNeeded];
                     }];
}

- (void)wrapTopToolbar {
    // let status bar be translucent. top toolbar is top layout guide (below status bar), so we need a wrapper to cover the status bar.
    UIToolbar *topToolbar = self.extensionsMgr.topToolbar;
    UIToolbar *bottomToolbar = self.extensionsMgr.bottomToolbar;
    [topToolbar setTranslatesAutoresizingMaskIntoConstraints:NO];

    UIView *topToolbarWrapper = [[UIToolbar alloc] init];
    [topToolbarWrapper setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.pdfViewControl insertSubview:topToolbarWrapper belowSubview:topToolbar];
    [topToolbarWrapper addSubview:topToolbar];

    [self.pdfViewControl addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[topToolbarWrapper]-0-|"
                                             options:0
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(topToolbarWrapper)]];
    [topToolbarWrapper addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[topToolbar]-0-|"
                                             options:0
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(topToolbar)]];
    [topToolbarWrapper addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topToolbar]-0-|"
                                             options:0
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(topToolbar)]];
}
@end
