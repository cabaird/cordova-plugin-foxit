/**
 * Copyright (C) 2003-2018, Foxit Software Inc..
 * All Rights Reserved.
 *
 * http://www.foxitsoftware.com
 *
 * The following code is copyrighted and is the proprietary of Foxit Software Inc.. It is not allowed to
 * distribute any parts of Foxit Mobile PDF SDK to third party or public without permission unless an agreement
 * is signed between Foxit Software Inc. and customers to explicitly grant customers permissions.
 * Review legal.txt for additional license and legal information.
 */

#import "UIExtensionsManager.h"
#import <FoxitRDK/FSPDFViewControl.h>

@interface FtToolHandler : NSObject <IToolHandler, IScrollViewEventListener, IRotationEventListener> {
    UITextView *_textView;
    BOOL _isSaved;
    BOOL _keyboardShown;
}

@property (nonatomic, assign) FSAnnotType type;
@property (nonatomic, assign) CGPoint freeTextStartPoint;
@property (nonatomic, assign) BOOL isTypewriterToolbarActive;

- (instancetype)initWithUIExtensionsManager:(UIExtensionsManager *)extensionsManager;
- (void)save;
- (void)exitWithoutSave;

@end
