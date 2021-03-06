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

#import "NoteToolHandler.h"
#import "NoteDialog.h"
#import "Preference.h"
#import "UIExtensionsManager+Private.h"

@interface NoteToolHandler () <IDocEventListener>

@end

@implementation NoteToolHandler {
    UIExtensionsManager *_extensionsManager;
    FSPDFViewCtrl *_pdfViewCtrl;
    TaskServer *_taskServer;
}

- (instancetype)initWithUIExtensionsManager:(UIExtensionsManager *)extensionsManager {
    self = [super init];
    if (self) {
        _extensionsManager = extensionsManager;
        _pdfViewCtrl = extensionsManager.pdfViewCtrl;
        _taskServer = _extensionsManager.taskServer;
        _type = e_annotNote;
    }
    return self;
}

- (NSString *)getName {
    return Tool_Note;
}

- (BOOL)isEnabled {
    return YES;
}

- (void)onActivate {
}

- (void)onDeactivate {
}

// PageView Gesture+Touch
- (BOOL)onPageViewLongPress:(int)pageIndex recognizer:(UILongPressGestureRecognizer *)recognizer {
    return NO;
}

- (BOOL)onPageViewTap:(int)pageIndex recognizer:(UITapGestureRecognizer *)recognizer {
    UIView *pageView = [_pdfViewCtrl getPageView:pageIndex];
    CGPoint point = [recognizer locationInView:pageView];
    CGRect rect1 = [pageView frame];
    CGSize size = rect1.size;
    if (point.x > size.width || point.y > size.height || point.x < 0 || point.y < 0)
        return NO;
    float scale = [_pdfViewCtrl getPageViewWidth:pageIndex] / 1000.0;
    CGRect rect = CGRectMake(point.x - NOTE_ANNOTATION_WIDTH * scale / 2, point.y - NOTE_ANNOTATION_WIDTH * scale / 2, NOTE_ANNOTATION_WIDTH * scale, NOTE_ANNOTATION_WIDTH * scale);

    FSRectF *dibRect = [_pdfViewCtrl convertPageViewRectToPdfRect:rect pageIndex:pageIndex];

    NoteDialog *noteDialog = [[NoteDialog alloc] init];
    [noteDialog show:nil replyAnnots:nil title:nil];
    self.currentVC = noteDialog;
    typeof(self) __weak weakSelf = self;
    noteDialog.noteEditDone = ^(NoteDialog *dialog) {
        typeof(weakSelf) __strong strongSelf = weakSelf;
        assert(strongSelf);
        strongSelf.currentVC = nil;
        FSPDFPage *page = [strongSelf->_pdfViewCtrl.currentDoc getPage:pageIndex];
        if (!page)
            return;
        FSNote *annot = (FSNote *) [page addAnnot:e_annotNote rect:dibRect];
        annot.icon = strongSelf->_extensionsManager.noteIcon;
        annot.color = [strongSelf->_extensionsManager getAnnotColor:self.type];
        annot.opacity = [strongSelf->_extensionsManager getAnnotOpacity:self.type] / 100.0f;
        annot.contents = [dialog getContent];
        annot.NM = [Utility getUUID];
        annot.author = [SettingPreference getAnnotationAuthor];
        FSDateTime *now = [Utility convert2FSDateTime:[NSDate date]];
        [annot setCreationDateTime:now];
        [annot setModifiedDateTime:now];
        id<IAnnotHandler> annotHandler = [strongSelf->_extensionsManager getAnnotHandlerByAnnot:annot];
        [annotHandler addAnnot:annot];
    };

    return YES;
}

- (BOOL)onPageViewPan:(int)pageIndex recognizer:(UIPanGestureRecognizer *)recognizer {
    return NO;
}

- (BOOL)onPageViewShouldBegin:(int)pageIndex recognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (self != _extensionsManager.currentToolHandler) {
        return NO;
    }
    return YES;
}

- (BOOL)onPageViewTouchesBegan:(int)pageIndex touches:(NSSet *)touches withEvent:(UIEvent *)event {
    return NO;
}

- (BOOL)onPageViewTouchesMoved:(int)pageIndex touches:(NSSet *)touches withEvent:(UIEvent *)event {
    return NO;
}

- (BOOL)onPageViewTouchesEnded:(int)pageIndex touches:(NSSet *)touches withEvent:(UIEvent *)event {
    return NO;
}

- (BOOL)onPageViewTouchesCancelled:(int)pageIndex touches:(NSSet *)touches withEvent:(UIEvent *)event {
    return NO;
}

- (void)onDraw:(int)pageIndex inContext:(CGContextRef)context {
}

#pragma mark IDocEventListener

- (void)onDocWillClose:(FSPDFDoc *)document {
    if (self.currentVC) {
        [self.currentVC dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
