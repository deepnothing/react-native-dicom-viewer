#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(DicomViewerViewManager, RCTViewManager)
RCT_EXTERN_METHOD(setPath:(nonnull NSNumber *)node path:(NSString *)path)
@end