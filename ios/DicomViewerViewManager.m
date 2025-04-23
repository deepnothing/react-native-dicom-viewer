#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(DicomViewerViewManager, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(src, NSString)
RCT_EXPORT_VIEW_PROPERTY(onFrameChange, RCTDirectEventBlock)
@end