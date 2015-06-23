//
//  UIImage+LGHelper.m
//  LGHelper+UI
//
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Grigory Lutkov <Friend.LGA@gmail.com>
//  (https://github.com/Friend-LGA/LGHelper-UI)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//
//  Image with mask, color at pixel
//  Copyright (c) 2009 Ole Begemann
//  https://github.com/ole/OBShapedButton
//

#import "UIImage+LGHelper.h"

@implementation UIImage (LGHelper)

- (UIImage *)imageWithOrientationExifFix
{
    // No-op if the orientation is already correct
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
            transform = CGAffineTransformTranslate(transform, self.size.width, 0.f);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0.f, self.size.height);
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
            transform = CGAffineTransformTranslate(transform, self.size.width, 0.f);
            transform = CGAffineTransformScale(transform, -1.f, 1.f);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0.f);
            transform = CGAffineTransformScale(transform, -1.f, 1.f);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             self.size.width,
                                             self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0.f,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0.f, 0.f, self.size.height, self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0.f, 0.f, self.size.width, self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)image1x1WithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.f, 0.f, 1.f, 1.f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)imageWithAlpha:(CGFloat)alpha
{
    CGRect rect = CGRectMake(0.f, 0.f, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(context, 1.f, -1.f);
    CGContextTranslateCTM(context, 0.f, -rect.size.height);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGContextSetAlpha(context, alpha);
    
    CGContextDrawImage(context, rect, self.CGImage);
    
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageNew;
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.f, 0.f, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawInRect:rect];
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageNew;
}

- (UIImage *)imageBlackAndWhite
{
    CGRect rect = CGRectMake(0.f, 0.f, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawInRect:rect];
    
    CGContextSetBlendMode(context, kCGBlendModeLuminosity);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageNew;
}

- (UIImage *)imageScaledToSize:(CGSize)size scalingMode:(LGImageScalingMode_)scalingMode
{
    return [self imageScaledToSize:size scalingMode:scalingMode backgroundColor:nil];
}

- (UIImage *)imageScaledToSize:(CGSize)size scalingMode:(LGImageScalingMode_)scalingMode backgroundColor:(UIColor *)backgroundColor
{
    if (scalingMode == LGImageScalingModeAspectFit_)
    {
        CGFloat koefWidth = (self.size.height > self.size.width ? self.size.width/self.size.height : 1.f);
        CGFloat koefHeight = (self.size.width > self.size.height ? self.size.height/self.size.width : 1.f);
        
        size.width *= koefWidth;
        size.height *= koefHeight;
    }
    
    CGRect rect = CGRectMake(0.f, 0.f, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (backgroundColor && ![backgroundColor isEqual:[UIColor clearColor]])
    {
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
        CGContextFillRect(context, rect);
    }
    
    if (scalingMode == LGImageScalingModeAspectFill_)
    {
        if (self.size.width / self.size.height >= 1 && self.size.width / self.size.height > size.width / size.height)
            size.width = size.height * (self.size.width / self.size.height);
        else if (self.size.height / self.size.width >= 1 && self.size.height / self.size.width > size.height / size.width)
            size.height = size.width * (self.size.height / self.size.width);
        
        if (rect.size.width < size.width)
        {
            rect.origin.x = -(size.width - rect.size.width)/2;
            rect.size.width = size.width;
        }
        
        if (rect.size.height < size.height)
        {
            rect.origin.y = -(size.height - rect.size.height)/2;
            rect.size.height = size.height;
        }
    }
    else if (scalingMode == LGImageScalingModeAspectFit_)
    {
        if (self.size.width / self.size.height <= 1 && self.size.width / self.size.height < size.width / size.height)
            size.width = size.height * (self.size.width / self.size.height);
        else if (self.size.height / self.size.width <= 1 && self.size.height / self.size.width < size.height / size.width)
            size.height = size.width * (self.size.height / self.size.width);
        
        if (rect.size.width > size.width)
        {
            rect.origin.x = (rect.size.width - size.width)/2;
            rect.size.width = size.width;
        }
        
        if (rect.size.height > size.height)
        {
            rect.origin.y = (rect.size.height - size.height)/2;
            rect.size.height = size.height;
        }
    }
    
    [self drawInRect:rect];
    
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageNew;
}

- (UIImage *)imageScaledWithMultiplier:(float)multiplier
{
    CGSize size = CGSizeMake(self.size.width*multiplier, self.size.height*multiplier);
    CGRect rect = CGRectMake(0.f, 0.f, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    
    [self drawInRect:rect];
    
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageNew;
}

- (UIImage *)imageRoundedWithRadius:(CGFloat)radius
{
    return [self imageRoundedWithRadius:radius backgroundColor:nil];
}

- (UIImage *)imageRoundedWithRadius:(CGFloat)radius backgroundColor:(UIColor *)backgroundColor
{
    CGRect rect = CGRectMake(0.f, 0.f, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (backgroundColor && ![backgroundColor isEqual:[UIColor clearColor]])
    {
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
        CGContextFillRect(context, rect);
    }
    
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    
    [self drawInRect:rect];
    
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageNew;
}

- (UIImage *)imageCroppedCenterWithSize:(CGSize)size
{
    return [self imageCroppedCenterWithSize:size backgroundColor:nil];
}

- (UIImage *)imageCroppedCenterWithSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor
{
    CGRect rect = CGRectMake(0.f, 0.f, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (backgroundColor && ![backgroundColor isEqual:[UIColor clearColor]])
    {
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
        CGContextFillRect(context, rect);
    }
    
    int heightDifference = size.height-self.size.height;
    int widthDifference = size.width-self.size.width;
    
    CGRect bounds = CGRectMake(widthDifference/2, heightDifference/2, self.size.width, self.size.height);
    
    [self drawInRect:bounds];
    
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageNew;
}

- (UIImage *)imageWithMaskImage:(UIImage *)maskImage
{
    CGImageRef imageReference = self.CGImage;
    CGImageRef maskImageReference = maskImage.CGImage;
    
    maskImageReference = CGImageMaskCreate(CGImageGetWidth(maskImageReference),
                                           CGImageGetHeight(maskImageReference),
                                           CGImageGetBitsPerComponent(maskImageReference),
                                           CGImageGetBitsPerPixel(maskImageReference),
                                           CGImageGetBytesPerRow(maskImageReference),
                                           CGImageGetDataProvider(maskImageReference),
                                           NULL,
                                           YES);
    
    CGImageRef maskedImageReference = CGImageCreateWithMask(imageReference, maskImageReference);
    CGImageRelease(maskImageReference);
    
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageReference];
    CGImageRelease(maskedImageReference);
    
    return maskedImage;
}

+ (UIImage *)imageFromView:(UIView *)view
{
    return [UIImage imageFromView:view inPixels:NO];
}

+ (UIImage *)imageFromView:(UIView *)view inPixels:(BOOL)inPixels
{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, (inPixels ? 1.f : 0.f));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [view.layer renderInContext:context];
    
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return capturedImage;
}

- (UIColor *)colorAtPixel:(CGPoint)point
{
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point))
        return nil;
    
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    // Reference: http://stackoverflow.com/questions/1042830/retrieving-a-pixel-alpha-value-for-a-uiimage
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
