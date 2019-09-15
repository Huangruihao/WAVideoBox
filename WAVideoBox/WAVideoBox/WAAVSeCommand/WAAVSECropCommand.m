//   
//   WAAVSECropCommand.m
//   WAVideoBox
//   
//   Created  by Hallfry on 2019/4/17
//   Modified by Hallfry
//   Copyright © 2019年 XPLO. All rights reserved.
//   
   

#import "WAAVSECropCommand.h"


@interface AVAssetTrack(XPAssetTrack)

- (CGAffineTransform)getTransformWithCropRect:(CGRect)cropRect;

@end

@implementation AVAssetTrack(XPAssetTrack)
- (CGAffineTransform)getTransformWithCropRect:(CGRect)cropRect {
    
    CGSize renderSize = cropRect.size;
    CGFloat renderScale = renderSize.width / cropRect.size.width;
    CGPoint offset = CGPointMake(-cropRect.origin.x, -cropRect.origin.y);
    double rotation = atan2(self.preferredTransform.b, self.preferredTransform.a);
    
    CGPoint rotationOffset = CGPointMake(0, 0);
    if (self.preferredTransform.b == -1.0) { // 倒着拍 -M_PI_2
        rotationOffset.y = self.naturalSize.width;
    } else if (self.preferredTransform.c == -1.0) { // 正着拍 M_PI_2
        // 奇怪的偏移
        rotationOffset.x = self.naturalSize.height;
    } else if (self.preferredTransform.a == -1.0) { // 两侧拍 M_PI
        rotationOffset.x = self.naturalSize.width;
        rotationOffset.y = self.naturalSize.height;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, renderScale, renderScale);
    transform = CGAffineTransformTranslate(transform, offset.x + rotationOffset.x, offset.y + rotationOffset.y);
    transform = CGAffineTransformRotate(transform, rotation);
    
    return transform;
}

@end


@implementation WAAVSECropCommand

- (void)performWithAsset:(AVAsset *)asset cropRect:(CGRect)cropRect {
    [super performWithAsset:asset];
    
    if ([[self.composition.mutableComposition tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        
        [super performVideoCompopsition];
        
        // 绿边问题，是因为宽或高不是偶数
        int64_t renderWidth = round(cropRect.size.width);
        int64_t renderHeight = round(cropRect.size.height);
        if (renderWidth % 2 != 0) {
            renderWidth -= 1;
        }
        if (renderHeight % 2 != 0) {
            renderHeight -= 1;
        }
        
        AVMutableVideoCompositionInstruction *instruction = [self.composition.instructions lastObject];
        AVMutableVideoCompositionLayerInstruction *layerInstruction = (AVMutableVideoCompositionLayerInstruction *)instruction.layerInstructions[0];
        
        // 获取父类的属性进行方向矫正
        // 更安全的话，可以考虑让父类暴露属性
        AVAssetTrack *videoTrack = [self valueForKey:@"assetVideoTrack"];
        
        [layerInstruction setTransform:[videoTrack getTransformWithCropRect:cropRect] atTime:kCMTimeZero];
        [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
        
        
        self.composition.mutableVideoComposition.renderSize = CGSizeMake(renderWidth, renderHeight);
    }
}

@end
