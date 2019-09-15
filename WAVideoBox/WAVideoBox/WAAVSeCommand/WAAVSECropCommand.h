//   
//   WAAVSECropCommand.h
//   WAVideoBox
//   
//   Created  by Hallfry on 2019/4/17
//   Modified by Hallfry
//   Copyright © 2019年 XPLO. All rights reserved.
//   区域裁剪
   

#import "WAAVSECommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface WAAVSECropCommand : WAAVSECommand

- (void)performWithAsset:(AVAsset *)asset cropRect:(CGRect)cropRect;

@end

NS_ASSUME_NONNULL_END
