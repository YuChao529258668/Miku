//
//  IDESourceCodeEditor+Hook.m
//  ActivatePowerMode
//
//  Created by Jobs on 16/1/11.
//  Copyright © 2015年 Jobs. All rights reserved.
//

#import "IDESourceCodeEditor+Miku.h"
#import "Miku.h"

NSTimer *timer;

@implementation IDESourceCodeEditor (Miku)

+ (void)hookMiku
{
    [self jr_swizzleMethod:@selector(viewDidLoad)
                withMethod:@selector(miku_viewDidLoad)
                     error:nil];
    
    //    [self jr_swizzleMethod:@selector(textView:shouldChangeTextInRange:replacementString:)
    //                withMethod:@selector(miku_textView:shouldChangeTextInRange:replacementString:)
    //                     error:nil];
    
    
    // ARC forbids use of 'dealloc' in a @selector. 为了移除通知和timer。
    SEL aSelector = NSSelectorFromString(@"dealloc");
    [self jr_swizzleMethod:aSelector withMethod:@selector(yc_dealloc) error:nil];
}


- (void)miku_viewDidLoad
{
    [self miku_viewDidLoad];
    
    // 创建超时空结界空间
    MikuDragView *mikuDragView = [Miku sharedPlugin].mikuDragView;
    //    [self.containerView addSubview:mikuDragView]; // 敲代码miku就会消失
    
    
    // 把miku添加到编辑器
    NSView *textView = [self valueForKey:@"textView"];
    [textView addSubview:mikuDragView];
    
    // 监听编辑器滚动，防止miku跟着滚动
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yc_textViewDidScroll:) name:NSScrollViewDidLiveScrollNotification object:self.scrollView];
    
    // 定时充电
    timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(yc_charge) userInfo:nil repeats:YES];
}

// 不让miku跟着滚动。。。
- (void)yc_textViewDidScroll:(NSNotification *)notification {
    MikuDragView *mikuDragView = [Miku sharedPlugin].mikuDragView;
    NSRect frame = mikuDragView.frame;
    static float oldY = 0;
    float translationY = self.scrollView.documentVisibleRect.origin.y - oldY;
    oldY = self.scrollView.documentVisibleRect.origin.y;
    frame.origin.y += translationY;
    mikuDragView.frame = frame;
}

// 定时给miku充能量
- (void)yc_charge {
    MikuWebView *mikuWebView = [Miku sharedPlugin].mikuDragView.mikuWebView;
    [mikuWebView setPlayingTime:10];
}

// 移除通知和timer
- (void)yc_dealloc {
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSScrollViewDidLiveScrollNotification object:self.scrollView];
    
    // 关闭timer
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    
    [self yc_dealloc];
}

//- (BOOL)miku_textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
//{
//    // 给Miku充能量
//    MikuWebView *mikuWebView = [Miku sharedPlugin].mikuDragView.mikuWebView;
//    [mikuWebView setPlayingTime:10];
//
//    return [self miku_textView:textView shouldChangeTextInRange:affectedCharRange replacementString:replacementString];
//}

@end
