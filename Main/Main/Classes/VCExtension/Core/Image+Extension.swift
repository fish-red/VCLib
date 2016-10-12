//
//  UIImage+Extension.swift
//  Test
//
//  Created by 陈文强 on 16/9/12.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import ImageIO
import AVFoundation

#if os(iOS)
import UIKit

public typealias Image = UIImage
#elseif os(OSX)
import Cocoa
public typealias Image = NSImage
#endif



// MARK: - Draw circle image
// MARK: 获得圆角图片
extension Image {
    /// Draw image for round image
    /// 画一个圆图片
    public func wq_drawRoundImage() -> Image {
        // 渲染的画布尺寸
        let w = size.width
        let h = size.height
        let rect = CGRect(x: 0, y: 0, width: w, height: h)
        let wh = min(w, h)
        let radius = wh * 0.5
        let roundRect = CGRect(x: 0.5*(w - wh), y: 0.5*(h - wh), width: wh, height: wh)
        
        // 开启上下文
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        // 添加路径
        UIGraphicsGetCurrentContext()?.addPath(UIBezierPath(roundedRect: roundRect,           byRoundingCorners: UIRectCorner.allCorners,
                            cornerRadii: CGSize(width: radius, height: radius)).cgPath)
//        CGContextAddPath(UIGraphicsGetCurrentContext(), UIBezierPath(ovalInRect: roundRect).CGPath)
        
        // 获取当前上下文
        UIGraphicsGetCurrentContext()?.clip()
//        CGContextFillPath(UIGraphicsGetCurrentContext())
        
        
        // 将图片绘制到上下文
        draw(in: rect)
        
        // 渲染
        UIGraphicsGetCurrentContext()?.drawPath(using: .fillStroke)
        
        // 获取图片
        let output = UIGraphicsGetImageFromCurrentImageContext();
        
        // 释放上下文
        UIGraphicsEndImageContext();
        
        // 返回图片
        return output!
    }
    
    /// Draw image with radius
    /// 根据半径画圆图
    public func wq_drawRectWithRoundedCorner(radius: CGFloat, sizetoFit: CGSize) -> Image {
        // 渲染的画布尺寸
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: sizetoFit)
        
        // 开启上下文
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        // 添加路径
        UIGraphicsGetCurrentContext()?.addPath(UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners,
                            cornerRadii: CGSize(width: radius, height: radius)).cgPath)
        // 获取当前上下文
        UIGraphicsGetCurrentContext()?.clip()
        
        // 将图片绘制到上下文
        draw(in: rect)
        
        // 渲染
        UIGraphicsGetCurrentContext()?.drawPath(using: .fillStroke)
        
        // 获取图片
        let output = UIGraphicsGetImageFromCurrentImageContext();
        
        // 释放上下文
        UIGraphicsEndImageContext();
        
        // 返回图片
        return output!
    }
}


// MARK: - Zip
// MARK: 压缩图片
extension Image {
    /// Zip image to data length
    /// 压缩图片到指定数据大小 NSData
    public func zipImage(_ size: Int, scale: CGFloat) -> Data {
        var s: CGFloat = 0.9
        var data = UIImageJPEGRepresentation(self, s)
        while data?.count > size && s > scale {
            s -= 0.1
            data = UIImageJPEGRepresentation(self, s)
        }
        return data!
    }
    
    /// Zip image to size
    /// 压缩到指定尺寸大小
    public func scaleToSize(_ size: CGSize) -> Image {
        // 并把它设置成为当前正在使用的context
        UIGraphicsBeginImageContext(size);
        // 绘制改变大小的图片
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        // 从当前context中创建一个改变大小后的图片
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
        //返回新的改变大小后的图片
        return scaledImage!;
    }
    
    /// Zip image to px
    /// 压缩到指定像素
    public func rescaleImageToPX(_ px: CGFloat) -> Image {
        var size = self.size
        
        if size.width <= px && size.height <= px {
            return self
        }
        
        let scale = size.width/size.height
        if size.width > size.height {
            size.width = px
            size.height = size.width/scale
        }else {
            size.height = px
            size.width = size.height*scale
        }
        return scaleToSize(size)
    }
}

// MARK: - Image cover to gray
// MARK: 获得灰度图片
extension Image {
    public func coverToGray() -> Image? {
        
        let width = size.width
        let height = size.height
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)
        
        guard context != nil else {
            return nil
        }
        
        context?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        let contextRef = context?.makeImage()
        
        guard contextRef != nil else {
            return nil
        }
        return Image(cgImage: contextRef!)
    }
}

//MARK: - Color to image
// MARK: 通过颜色获得图片
extension Image {
    /// 通过颜色获取一张纯色图片
    public class func imageWithColor(_ color: UIColor?) -> Image? {
        return imageWithColor(color, size: CGSize(width: 1, height: 1))
    }
    
    public class func imageWithColor(_ color: UIColor?, size: CGSize) -> Image? {
        guard color != nil else {
            return nil
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color!.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.stretch()
    }
}



// MARK: - Clip
// MARK: 裁剪图片
public let IMAGE_EXTENSION_SCREEN_SCALE = UIScreen.main.scale
extension Image {
    /// Clip image to rect
    /// 切割图片到指定大小
    public func clipToRect(_ rect: CGRect) -> Image {
        let ref = (self.cgImage)?.cropping(to: rect)
        
        guard ref != nil else {
            return self
        }
        let newImage = Image(cgImage: ref!)
        return newImage
    }
    
    /// Clip image to size
    /// 切割图片到尺寸
//    public func clipToSize(size: CGSize) -> Image {
//        UIGraphicsBeginImageContext(size)
//        let ctx = UIGraphicsGetCurrentContext()
//        CGContextDrawTiledImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage)
//        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return outputImage
//    }
    
    /// Clip image to size
    /// 切割图片到尺寸
    public func clipToSize(_ pSize: CGSize) -> Image {
        
        return clipToPixSize(CGSize(width: pSize.width*IMAGE_EXTENSION_SCREEN_SCALE, height: pSize.height*IMAGE_EXTENSION_SCREEN_SCALE))
    }
    
    public func clipToPixSize(_ pixSize: CGSize) -> Image {
        let w = self.size.width * IMAGE_EXTENSION_SCREEN_SCALE
        let h = self.size.height * IMAGE_EXTENSION_SCREEN_SCALE
        
        let x = (w - pixSize.width) * 0.5
        let y = (h - pixSize.height) * 0.5
        
        return clipToRect(CGRect(x: x, y: y, width: pixSize.width, height: pixSize.height))
    }
}


// MARK: - Render
// MARK: 渲染控件图片
extension Image {
    /// Render image from view
    /// 通过截图View生成图片
    public class func renderImage(_ v: UIView?) -> Image? {
        guard v != nil else {
            return nil
        }
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(v!.frame.size, false, scale)
        
        let ctx = UIGraphicsGetCurrentContext()
        guard ctx != nil else {
            return nil
        }
        
        v?.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


// MARK: - Merge
// MARK: 合并图片
extension Image {
    /// Merger two image
    /// 合并两张图片
    public class func mergeImage(firstImage: Image?, secondImage: Image?) -> Image? {
        guard firstImage != nil && secondImage != nil else {
            return nil
        }
        
        let firstImageRef = firstImage!.cgImage
        let firstWidth = firstImageRef!.width
        let firstHeight = firstImageRef!.height
        
        let secondImageRef = secondImage!.cgImage
        let secondWidth = secondImageRef!.width
        let secondHeight = secondImageRef!.height
        
        
        let maxW = max(firstWidth, secondWidth)
        let maxH = max(firstHeight, secondHeight)
        let mergedSize = CGSize(width: CGFloat(maxW), height: CGFloat(maxH))
        
        UIGraphicsBeginImageContext(mergedSize)
        firstImage!.draw(in: CGRect(x: 0, y: 0, width: CGFloat(firstWidth), height: CGFloat(firstHeight)))
        secondImage!.draw(in: CGRect(x: 0, y: 0, width: CGFloat(secondWidth), height: CGFloat(secondHeight)))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


// MARK: - TransLate
// MARK: 图片变换
extension Image {
    /// Tile image to size
    /// 平铺图片到指定大小
    public func tileImageToSize(_ size: CGSize) -> Image? {
        let v = UIView()
        v.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        v.backgroundColor = UIColor(patternImage: self)
        
        return Image.renderImage(v)
    }
    
    /// Resize image to full
    /// 将图片拉伸到铺满
    public func stretch() -> Image {
        let size: CGSize = self.size
        let inset = UIEdgeInsetsMake(CGFloat(truncf(Float(size.height-1)/2)), CGFloat(truncf(Float(size.width-1)/2)), CGFloat(truncf(Float(size.height-1)/2)), CGFloat(truncf(Float(size.width-1)/2)))
        return self.resizableImage(withCapInsets: inset)
    }
}


// MARK: - Blur
// MARK: 模糊效果
extension UIImage {
    /**
     - (instancetype)blurWithType:(XKImageBlurType)type
     {
     switch (type) {
     case XKImageBlurTypeProfileBack:
     {
     return [self imgWithLightAlpha:0.5 radius:4 colorSaturationFactor:1];
     }
     case XKImageBlurTypeGroupBack:
     {
     return [self imgWithLightAlpha:0.6 radius:2 colorSaturationFactor:1];
     }
     default:
     return nil;
     }
     }
     
     /*
     1.黑色,参数:
     透明度 0~1,  0为白,   1为深灰色
     半径:默认30,推荐值 3   半径值越大越模糊 ,值越小越清楚
     色彩饱和度(浓度)因子:  0是黑白灰, 9是浓彩色, 1是原色  默认1.8
     “彩度”，英文是称Saturation，即饱和度。将无彩色的黑白灰定为0，最鲜艳定为9s，这样大致分成十阶段，让数值和人的感官直觉一致。
     */
     - (UIImage *)imgWithLightAlpha:(CGFloat)alpha radius:(CGFloat)radius colorSaturationFactor:(CGFloat)colorSaturationFactor
     {
     UIColor *tintColor = [UIColor colorWithWhite:0.1 alpha:alpha];
     return [self imageBluredWithRadius:radius tintColor:tintColor saturationDeltaFactor:colorSaturationFactor maskImage:nil];
     }
     
     //具体实现
     - (UIImage *)imageBluredWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage{
     CGRect imageRect = { CGPointZero, self.size };
     UIImage *effectImage = self;
     BOOL hasBlur = blurRadius > __FLT_EPSILON__;
     BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
     if (hasBlur || hasSaturationChange) {
     UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
     CGContextRef effectInContext = UIGraphicsGetCurrentContext();
     CGContextScaleCTM(effectInContext, 1.0, -1.0);
     CGContextTranslateCTM(effectInContext, 0, -self.size.height);
     CGContextDrawImage(effectInContext, imageRect, self.CGImage);
     
     vImage_Buffer effectInBuffer;
     effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
     effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
     effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
     effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
     
     UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
     CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
     vImage_Buffer effectOutBuffer;
     effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
     effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
     effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
     effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
     
     if (hasBlur) {
     CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
     NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
     if (radius % 2 != 1) {
     radius += 1; // force radius to be odd so that the three box-blur methodology works.
     }
     vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (short)radius, (short)radius, 0, kvImageEdgeExtend);
     vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, (short)radius, (short)radius, 0, kvImageEdgeExtend);
     vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (short)radius, (short)radius, 0, kvImageEdgeExtend);
     }
     BOOL effectImageBuffersAreSwapped = NO;
     if (hasSaturationChange) {
     CGFloat s = saturationDeltaFactor;
     CGFloat floatingPointSaturationMatrix[] = {
     0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
     0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
     0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
     0,                    0,                    0,  1,
     };
     const int32_t divisor = 256;
     NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
     int16_t saturationMatrix[matrixSize];
     for (NSUInteger i = 0; i < matrixSize; ++i) {
     saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
     }
     if (hasBlur) {
     vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
     effectImageBuffersAreSwapped = YES;
     }
     else {
     vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
     }
     }
     if (!effectImageBuffersAreSwapped)
     effectImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     if (effectImageBuffersAreSwapped)
     effectImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     }
     
     // 开启上下文 用于输出图像
     UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
     CGContextRef outputContext = UIGraphicsGetCurrentContext();
     CGContextScaleCTM(outputContext, 1.0, -1.0);
     CGContextTranslateCTM(outputContext, 0, -self.size.height);
     
     // 开始画底图
     CGContextDrawImage(outputContext, imageRect, self.CGImage);
     
     // 开始画模糊效果
     if (hasBlur) {
     CGContextSaveGState(outputContext);
     if (maskImage) {
     CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
     }
     CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
     CGContextRestoreGState(outputContext);
     }
     
     // 添加颜色渲染
     if (tintColor) {
     CGContextSaveGState(outputContext);
     CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
     CGContextFillRect(outputContext, imageRect);
     CGContextRestoreGState(outputContext);
     }
     
     // 输出成品,并关闭上下文
     UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     return outputImage;
     }
    */
}

// MARK: - <#Description#>
extension Image {
    /**
     
     + (UIImage *)imageWithOriginalImageName:(NSString *)imageName
     {
     UIImage *image = [UIImage imageNamed:imageName];
     return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
     }
     
     - (UIImage *)applyLightEffect
     {
     UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
     return [self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
     }
     
     
     - (UIImage *)applyExtraLightEffect
     {
     UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
     return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
     }
     
     
     - (UIImage *)applyDarkEffect
     {
     UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
     return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
     }
     
     
     - (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor
     {
     const CGFloat EffectColorAlpha = 0.6;
     UIColor *effectColor = tintColor;
     int componentCount = (int)CGColorGetNumberOfComponents(tintColor.CGColor);
     if (componentCount == 2) {
     CGFloat b;
     if ([tintColor getWhite:&b alpha:NULL]) {
     effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
     }
     }
     else {
     CGFloat r, g, b;
     if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
     effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
     }
     }
     return [self applyBlurWithRadius:20
     tintColor:effectColor
     saturationDeltaFactor:1.4
     maskImage:nil];
     }
     
     - (UIImage *)blurImage
     {
     return [self applyBlurWithRadius:20
     tintColor:[UIColor colorWithWhite:0 alpha:0.0]
     saturationDeltaFactor:1.4
     maskImage:nil];
     }
     
     - (UIImage *)blurImageWithRadius:(CGFloat)radius
     {
     return [self applyBlurWithRadius:radius
     tintColor:[UIColor colorWithWhite:0 alpha:0.0]
     saturationDeltaFactor:1.4
     maskImage:nil];
     }
     
     
     - (UIImage *)blurImageWithMask:(UIImage *)maskImage
     {
     return [self applyBlurWithRadius:20
     tintColor:[UIColor colorWithWhite:0 alpha:0.0]
     saturationDeltaFactor:1.4
     maskImage:maskImage];
     }
     
     - (UIImage *)blurImageAtFrame:(CGRect)frame
     {
     return [self applyBlurWithRadius:20
     tintColor:[UIColor colorWithWhite:0 alpha:0.0]
     saturationDeltaFactor:1.4
     maskImage:nil
     atFrame:frame];
     }
     
     // 核心代码
     - (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
     {
     // Check pre-conditions.
     if (self.size.width < 1 || self.size.height < 1) {
     NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
     return nil;
     }
     if (!self.CGImage) {
     NSLog (@"*** error: image must be backed by a CGImage: %@", self);
     return nil;
     }
     if (maskImage && !maskImage.CGImage) {
     NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
     return nil;
     }
     
     CGRect imageRect = { CGPointZero, self.size };
     UIImage *effectImage = self;
     
     BOOL hasBlur = blurRadius > __FLT_EPSILON__;
     BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
     if (hasBlur || hasSaturationChange) {
     UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
     CGContextRef effectInContext = UIGraphicsGetCurrentContext();
     CGContextScaleCTM(effectInContext, 1.0, -1.0);
     CGContextTranslateCTM(effectInContext, 0, -self.size.height);
     CGContextDrawImage(effectInContext, imageRect, self.CGImage);
     
     vImage_Buffer effectInBuffer;
     effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
     effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
     effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
     effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
     
     UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
     CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
     vImage_Buffer effectOutBuffer;
     effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
     effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
     effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
     effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
     
     if (hasBlur) {
     // A description of how to compute the box kernel width from the Gaussian
     // radius (aka standard deviation) appears in the SVG spec:
     // For larger values of 's' (s >= 2.0), an approximation can be used: Three
     // successive box-blurs build a piece-wise quadratic convolution kernel, which
     // approximates the Gaussian kernel to within roughly 3%.
     //
     // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
     //
     // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
     //
     CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
     NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
     if (radius % 2 != 1) {
     radius += 1; // force radius to be odd so that the three box-blur methodology works.
     }
     vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
     vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
     vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
     }
     BOOL effectImageBuffersAreSwapped = NO;
     if (hasSaturationChange) {
     CGFloat s = saturationDeltaFactor;
     CGFloat floatingPointSaturationMatrix[] = {
     0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
     0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
     0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
     0,                    0,                    0,  1,
     };
     const int32_t divisor = 256;
     NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
     int16_t saturationMatrix[matrixSize];
     for (NSUInteger i = 0; i < matrixSize; ++i) {
     saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
     }
     if (hasBlur) {
     vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
     effectImageBuffersAreSwapped = YES;
     }
     else {
     vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
     }
     }
     if (!effectImageBuffersAreSwapped)
     effectImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     if (effectImageBuffersAreSwapped)
     effectImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     }
     
     // Set up output context.
     UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
     CGContextRef outputContext = UIGraphicsGetCurrentContext();
     CGContextScaleCTM(outputContext, 1.0, -1.0);
     CGContextTranslateCTM(outputContext, 0, -self.size.height);
     
     // Draw base image.
     CGContextDrawImage(outputContext, imageRect, self.CGImage);
     
     // Draw effect image.
     if (hasBlur) {
     CGContextSaveGState(outputContext);
     if (maskImage) {
     CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
     }
     CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
     CGContextRestoreGState(outputContext);
     }
     
     // Add in color tint.
     if (tintColor) {
     CGContextSaveGState(outputContext);
     CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
     CGContextFillRect(outputContext, imageRect);
     CGContextRestoreGState(outputContext);
     }
     
     // Output image is ready.
     UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     return outputImage;
     }
     
     - (UIImage *)grayScale
     {
     int width = self.size.width;
     int height = self.size.height;
     
     CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
     
     CGContextRef context = CGBitmapContextCreate(nil,
     width,
     height,
     8, // bits per component
     0,
     colorSpace,
     kCGBitmapByteOrderDefault);
     
     CGColorSpaceRelease(colorSpace);
     
     if (context == NULL) {
     return nil;
     }
     
     CGContextDrawImage(context,
     CGRectMake(0, 0, width, height), self.CGImage);
     CGImageRef image = CGBitmapContextCreateImage(context);
     UIImage *grayImage = [UIImage imageWithCGImage:image];
     CFRelease(image);
     CGContextRelease(context);
     
     return grayImage;
     }
     
     - (UIImage *)scaleWithFixedWidth:(CGFloat)width
     {
     float newHeight = self.size.height * (width / self.size.width);
     CGSize size = CGSizeMake(width, newHeight);
     UIGraphicsBeginImageContextWithOptions(size, NO, 0);
     
     CGContextRef context = UIGraphicsGetCurrentContext();
     
     CGContextTranslateCTM(context, 0.0, size.height);
     CGContextScaleCTM(context, 1.0, -1.0);
     
     CGContextSetBlendMode(context, kCGBlendModeCopy);
     CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
     
     UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
     
     UIGraphicsEndImageContext();
     
     return imageOut;
     }
     
     - (UIImage *)scaleWithFixedHeight:(CGFloat)height
     {
     float newWidth = self.size.width * (height / self.size.height);
     CGSize size = CGSizeMake(newWidth, height);
     
     UIGraphicsBeginImageContextWithOptions(size, NO, 0);
     
     CGContextRef context = UIGraphicsGetCurrentContext();
     
     CGContextTranslateCTM(context, 0.0, size.height);
     CGContextScaleCTM(context, 1.0, -1.0);
     
     CGContextSetBlendMode(context, kCGBlendModeCopy);
     CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
     
     UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
     
     UIGraphicsEndImageContext();
     
     return imageOut;
     }
     
     
     
     - (UIImage *)croppedImageAtFrame:(CGRect)frame
     {
     frame = CGRectMake(frame.origin.x * self.scale, frame.origin.y * self.scale, frame.size.width * self.scale, frame.size.height * self.scale);
     CGImageRef sourceImageRef = [self CGImage];
     CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, frame);
     UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[self scale] orientation:[self imageOrientation]];
     CGImageRelease(newImageRef);
     return newImage;
     }
     
     - (UIImage *)addImageToImage:(UIImage *)img atRect:(CGRect)cropRect{
     
     CGSize size = CGSizeMake(self.size.width, self.size.height);
     UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
     
     CGPoint pointImg1 = CGPointMake(0,0);
     [self drawAtPoint:pointImg1];
     
     CGPoint pointImg2 = cropRect.origin;
     [img drawAtPoint: pointImg2];
     
     UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     return result;
     }
     
     - (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius
     tintColor:(UIColor *)tintColor
     saturationDeltaFactor:(CGFloat)saturationDeltaFactor
     maskImage:(UIImage *)maskImage
     atFrame:(CGRect)frame
     {
     UIImage *blurredFrame = \
     [[self croppedImageAtFrame:frame] applyBlurWithRadius:blurRadius
     tintColor:tintColor
     saturationDeltaFactor:saturationDeltaFactor
     maskImage:maskImage];
     
     return [self addImageToImage:blurredFrame atRect:frame];
     }
     */
}


// MARK: - Rotate
extension Image {
    /*
     
     //由角度转换弧度
     #define kDegreesToRadian(x)      (M_PI * (x) / 180.0)
     //由弧度转换角度
     #define kRadianToDegrees(radian) (radian * 180.0) / (M_PI)
     
     
     - (UIImage *)fixOrientation
     {
     if (self.imageOrientation == UIImageOrientationUp) return self;
     
     // We need to calculate the proper transformation to make the image upright.
     // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
     CGAffineTransform transform = CGAffineTransformIdentity;
     
     switch (self.imageOrientation)
     {
     case UIImageOrientationDown:
     case UIImageOrientationDownMirrored:
     transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
     transform = CGAffineTransformRotate(transform, M_PI);
     break;
     
     case UIImageOrientationLeft:
     case UIImageOrientationLeftMirrored:
     transform = CGAffineTransformTranslate(transform, self.size.width, 0);
     transform = CGAffineTransformRotate(transform, M_PI_2);
     break;
     
     case UIImageOrientationRight:
     case UIImageOrientationRightMirrored:
     transform = CGAffineTransformTranslate(transform, 0, self.size.height);
     transform = CGAffineTransformRotate(transform, -M_PI_2);
     break;
     case UIImageOrientationUp:
     case UIImageOrientationUpMirrored:
     break;
     }
     
     switch (self.imageOrientation)
     {
     case UIImageOrientationUpMirrored:
     case UIImageOrientationDownMirrored:
     transform = CGAffineTransformTranslate(transform, self.size.width, 0);
     transform = CGAffineTransformScale(transform, -1, 1);
     break;
     
     case UIImageOrientationLeftMirrored:
     case UIImageOrientationRightMirrored:
     transform = CGAffineTransformTranslate(transform, self.size.height, 0);
     transform = CGAffineTransformScale(transform, -1, 1);
     break;
     case UIImageOrientationUp:
     case UIImageOrientationDown:
     case UIImageOrientationLeft:
     case UIImageOrientationRight:
     break;
     }
     
     // Now we draw the underlying CGImage into a new context, applying the transform
     // calculated above.
     CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
     CGImageGetBitsPerComponent(self.CGImage), 0,
     CGImageGetColorSpace(self.CGImage),
     CGImageGetBitmapInfo(self.CGImage));
     CGContextConcatCTM(ctx, transform);
     
     switch (self.imageOrientation)
     {
     case UIImageOrientationLeft:
     case UIImageOrientationLeftMirrored:
     case UIImageOrientationRight:
     case UIImageOrientationRightMirrored:
     CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
     break;
     
     default:
     CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
     break;
     }
     
     CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
     UIImage *img = [UIImage imageWithCGImage:cgimg];
     CGContextRelease(ctx);
     CGImageRelease(cgimg);
     
     return img;
     }
     
     /** 按给定的方向旋转图片 */
     - (UIImage*)rotate:(UIImageOrientation)orient
     {
     CGRect bnds = CGRectZero;
     UIImage* copy = nil;
     CGContextRef ctxt = nil;
     CGImageRef imag = self.CGImage;
     CGRect rect = CGRectZero;
     CGAffineTransform tran = CGAffineTransformIdentity;
     
     rect.size.width = CGImageGetWidth(imag);
     rect.size.height = CGImageGetHeight(imag);
     
     bnds = rect;
     
     switch (orient)
     {
     case UIImageOrientationUp:
     return self;
     
     case UIImageOrientationUpMirrored:
     tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
     tran = CGAffineTransformScale(tran, -1.0, 1.0);
     break;
     
     case UIImageOrientationDown:
     tran = CGAffineTransformMakeTranslation(rect.size.width,
     rect.size.height);
     tran = CGAffineTransformRotate(tran, M_PI);
     break;
     
     case UIImageOrientationDownMirrored:
     tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
     tran = CGAffineTransformScale(tran, 1.0, -1.0);
     break;
     
     case UIImageOrientationLeft:
     bnds = swapWidthAndHeight(bnds);
     tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
     tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
     break;
     
     case UIImageOrientationLeftMirrored:
     bnds = swapWidthAndHeight(bnds);
     tran = CGAffineTransformMakeTranslation(rect.size.height,
     rect.size.width);
     tran = CGAffineTransformScale(tran, -1.0, 1.0);
     tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
     break;
     
     case UIImageOrientationRight:
     bnds = swapWidthAndHeight(bnds);
     tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
     tran = CGAffineTransformRotate(tran, M_PI / 2.0);
     break;
     
     case UIImageOrientationRightMirrored:
     bnds = swapWidthAndHeight(bnds);
     tran = CGAffineTransformMakeScale(-1.0, 1.0);
     tran = CGAffineTransformRotate(tran, M_PI / 2.0);
     break;
     
     default:
     return self;
     }
     
     UIGraphicsBeginImageContext(bnds.size);
     ctxt = UIGraphicsGetCurrentContext();
     
     switch (orient)
     {
     case UIImageOrientationLeft:
     case UIImageOrientationLeftMirrored:
     case UIImageOrientationRight:
     case UIImageOrientationRightMirrored:
     CGContextScaleCTM(ctxt, -1.0, 1.0);
     CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
     break;
     
     default:
     CGContextScaleCTM(ctxt, 1.0, -1.0);
     CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
     break;
     }
     
     CGContextConcatCTM(ctxt, tran);
     CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
     
     copy = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     return copy;
     }
     
     /** 垂直翻转 */
     - (UIImage *)flipVertical
     {
     return [self rotate:UIImageOrientationDownMirrored];
     }
     
     /** 水平翻转 */
     - (UIImage *)flipHorizontal
     {
     return [self rotate:UIImageOrientationUpMirrored];
     }
     
     /** 将图片旋转弧度radians */
     - (UIImage *)imageRotatedByRadians:(CGFloat)radians
     {
     // calculate the size of the rotated view's containing box for our drawing space
     UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
     CGAffineTransform t = CGAffineTransformMakeRotation(radians);
     rotatedViewBox.transform = t;
     CGSize rotatedSize = rotatedViewBox.frame.size;
     
     // Create the bitmap context
     UIGraphicsBeginImageContext(rotatedSize);
     CGContextRef bitmap = UIGraphicsGetCurrentContext();
     
     // Move the origin to the middle of the image so we will rotate and scale around the center.
     CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
     
     //   // Rotate the image context
     CGContextRotateCTM(bitmap, radians);
     
     // Now, draw the rotated/scaled image into the context
     CGContextScaleCTM(bitmap, 1.0, -1.0);
     CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
     
     UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     return newImage;
     }
     
     /** 将图片旋转角度degrees */
     - (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
     {
     return [self imageRotatedByRadians:kDegreesToRadian(degrees)];
     }
     
     /** 交换宽和高 */
     static CGRect swapWidthAndHeight(CGRect rect)
     {
     CGFloat swap = rect.size.width;
     
     rect.size.width = rect.size.height;
     rect.size.height = swap;
     
     return rect;
     }
     */
}



// MARK: - Pixel
extension Image {
    /// 通过图片点获取像素
//    func colorAtPoint(point: CGPoint) -> UIColor? {
//        guard CGRectContainsPoint(CGRectMake(0, 0, size.width, size.height), point) == true else {
//            return nil
//        }
//        
//        let pointX = trunc(point.x)
//        let pointY = trunc(point.y)
//        let cgImage = self.CGImage
//        let width: Int = Int(size.width)
//        let height: Int = Int(size.height)
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let bytesPerPixel = 4
//        let bytesPerRow = bytesPerPixel * 1
//        let bitsPerComponent = 8
//        
////        let width  = CGFloat(CGImageGetWidth(cgImage))
////        let height = CGFloat(CGImageGetHeight(cgImage))
//        var pixelData:UnsafeMutablePointer<CGFloat> = UnsafeMutablePointer<CGFloat>.alloc(height*width*4)
//        
//        let context = CGBitmapContextCreate(&pixelData, 1, 1, bitsPerComponent, bytesPerRow, colorSpace, CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)
//        
//        CGContextSetBlendMode(context, .Copy)
//        
//        CGContextTranslateCTM(context, -pointX, pointY-CGFloat(height))
//        CGContextDrawImage(context, CGRectMake(0.0, 0.0, CGFloat(width), CGFloat(height)), cgImage)
//        
//        let red   = CGFloat(pixelData[0] / 255.0)
//        let green = CGFloat(pixelData[1] / 255.0)
//        let blue  = CGFloat(pixelData[2] / 255.0)
//        let alpha = CGFloat(pixelData[3] / 255.0)
//        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
//    }
    
    
    /// 获得平均颜色 
//    internal func averageColor() -> UIColor {
//        
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        
////        unsigned char rgba[4]
//        var rgba:UnsafeMutablePointer<CGFloat> = UnsafeMutablePointer<CGFloat>.alloc(Int(self.size.height*self.size.width*4))
//        let context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)
//        
//        CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage)
//    
//        if(rgba[3] > 0) {
//            let alpha = rgba[3]/255.0
//            let multiplier = alpha/255.0
//            let red = rgba[0]*multiplier
//            let green = rgba[1]*multiplier
//            let blue = rgba[2]*multiplier
//            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
//            
//        }
//        else {
//            let red = rgba[0]/255.0
//            let green = rgba[1]/255.0
//            let blue = rgba[2]/255.0
//            let alpha = rgba[3]/255.0
//            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
//        }
//        return UIColor.blueColor()
//    }
}


// MARK: - Gif
extension Image {
    /*
     static int delayCentisecondsForImageAtIndex(CGImageSourceRef const source, size_t const i)
     {
     int delayCentiseconds = 1;
     CFDictionaryRef const properties = CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
     if (properties)
     {
     CFDictionaryRef const gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
     if (gifProperties)
     {
     NSNumber *number = (__bridge id) CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
     if (number == NULL || [number doubleValue] == 0)
     {
     number = (__bridge id) CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
     }
     if ([number doubleValue] > 0)
     {
     delayCentiseconds = (int)lrint([number doubleValue] * 100);
     }
     }
     CFRelease(properties);
     }
     return delayCentiseconds;
     }
     
     static void createImagesAndDelays(CGImageSourceRef source, size_t count, CGImageRef imagesOut[count], int delayCentisecondsOut[count])
     {
     for (size_t i = 0; i < count; ++i)
     {
     imagesOut[i] = CGImageSourceCreateImageAtIndex(source, i, NULL);
     delayCentisecondsOut[i] = delayCentisecondsForImageAtIndex(source, i);
     }
     }
     
     static int sum(size_t const count, int const *const values)
     {
     int theSum = 0;
     for (size_t i = 0; i < count; ++i)
     {
     theSum += values[i];
     }
     return theSum;
     }
     
     static int pairGCD(int a, int b)
     {
     if (a < b)
     {
     return pairGCD(b, a);
     }
     
     while (true)
     {
     int const r = a % b;
     if (r == 0)
     {
     return b;
     }
     a = b;
     b = r;
     }
     }
     
     static int vectorGCD(size_t const count, int const *const values)
     {
     int gcd = values[0];
     for (size_t i = 1; i < count; ++i)
     {
     gcd = pairGCD(values[i], gcd);
     }
     return gcd;
     }
     
     static NSArray *frameArray(size_t const count, CGImageRef const images[count], int const delayCentiseconds[count], int const totalDurationCentiseconds)
     {
     int const gcd = vectorGCD(count, delayCentiseconds);
     size_t const frameCount = totalDurationCentiseconds / gcd;
     UIImage *frames[frameCount];
     for (size_t i = 0, f = 0; i < count; ++i)
     {
     UIImage *const frame = [UIImage imageWithCGImage:images[i]];
     for (size_t j = delayCentiseconds[i] / gcd; j > 0; --j)
     {
     frames[f++] = frame;
     }
     }
     return [NSArray arrayWithObjects:frames count:frameCount];
     }
     
     static void releaseImages(size_t const count, CGImageRef const images[count])
     {
     for (size_t i = 0; i < count; ++i)
     {
     CGImageRelease(images[i]);
     }
     }
     
     static UIImage *animatedImageWithAnimatedGIFImageSource(CGImageSourceRef const source)
     {
     size_t const count = CGImageSourceGetCount(source);
     CGImageRef images[count];
     int delayCentiseconds[count]; // in centiseconds
     createImagesAndDelays(source, count, images, delayCentiseconds);
     int const totalDurationCentiseconds = sum(count, delayCentiseconds);
     NSArray *const frames = frameArray(count, images, delayCentiseconds, totalDurationCentiseconds);
     UIImage *const animation = [UIImage animatedImageWithImages:frames duration:(NSTimeInterval)totalDurationCentiseconds / 100.0];
     releaseImages(count, images);
     return animation;
     }
     
     static UIImage *animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceRef CF_RELEASES_ARGUMENT source)
     {
     if (source)
     {
     UIImage *const image = animatedImageWithAnimatedGIFImageSource(source);
     CFRelease(source);
     return image;
     }
     else
     {
     return nil;
     }
     }
     
     + (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)data
     {
     return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithData((__bridge CFTypeRef) data, NULL));
     }
     
     + (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)url
     {
     return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithURL((__bridge CFTypeRef) url, NULL));
     }
     
     */
}



#if os(OSX)
// MARK: - Video thumbnail
// MARK: 获得Video视频首帧图
extension Image {
    /// 通过视频URL获取一张缩略图
    public convenience init(url: NSURL?) {
        guard url != nil else {
            return
        }
        
        let asset = AVURLAsset(URL: url!, options: nil)
        let generate = AVAssetImageGenerator(asset: asset)
        
        let time = CMTimeMake(1, 65)
        
        do {
            let refImg = try generate.copyCGImageAtTime(time, actualTime: nil)
        }catch {
            
        }
        
        let frameImage = NSImage(refImg, size: CGSizeMake(180, 140))
        return frameImage
    }
}
#endif


