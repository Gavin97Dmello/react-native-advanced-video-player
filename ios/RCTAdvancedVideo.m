//
//  Controls.m
//  Hit88
//
//  Created by Sim Hann Zern  on 15/06/2020.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "React/RCTViewManager.h"

@interface RCT_EXTERN_MODULE(RCTAdvancedVideo, RCTViewManager)

//CALL FROM JS
RCT_EXTERN_METHOD(pauseAvPlayer:(nonnull NSNumber *)node)
RCT_EXTERN_METHOD(playAvPlayer:(nonnull NSNumber *)node)
RCT_EXTERN_METHOD(killAvPlayer:(nonnull NSNumber *)node)
RCT_EXTERN_METHOD(mutePlayer:(nonnull NSNumber *)node)
RCT_EXTERN_METHOD(unmutePlayer:(nonnull NSNumber *)node)
RCT_EXTERN_METHOD(showSystemHUD:(nonnull NSNumber *)node)

///Props from JS
RCT_EXPORT_VIEW_PROPERTY(source, NSString)
RCT_EXPORT_VIEW_PROPERTY(isFullscreen, BOOL)
RCT_EXPORT_VIEW_PROPERTY(swipeToSeek, BOOL)
RCT_EXPORT_VIEW_PROPERTY(isLiked, BOOL)
RCT_EXPORT_VIEW_PROPERTY(title, NSString)
RCT_EXPORT_VIEW_PROPERTY(showLikeButton, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showShareButton, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showDownloadButton, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showFullscreenControls, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showHomeIndicator, BOOL)
//Styling
RCT_EXPORT_VIEW_PROPERTY(seekBarColor, NSString)
///

//CALLBACKS
RCT_EXPORT_VIEW_PROPERTY(onFullscreen, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onBackPressed, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLikePressed, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onSharePressed, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onDownloadPressed, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLivePressed, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onControlsShow, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onControlsHide, RCTDirectEventBlock)
@end
