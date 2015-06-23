//
//  UIColor+LGHelper.m
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

#import "UIColor+LGHelper.h"

@implementation UIColor (LGHelper)

#pragma mark -

/** 0-255, 0-255, 0-255, 0.f-1.f */
+ (UIColor *)colorWithRGB_red:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:(CGFloat)red/255.f green:(CGFloat)green/255.f blue:(CGFloat)blue/255.f alpha:alpha];
}

/** #000000 */
+ (UIColor *)colorWithHEX:(UInt32)hex
{
    int red = (hex >> 16) & 0xFF;
    int green = (hex >> 8) & 0xFF;
    int blue = (hex) & 0xFF;
    
    return [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
}

#pragma mark -

/** #000000 */
- (NSUInteger)hex
{
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    NSInteger ired, igreen, iblue;
    ired = roundf(red * 255);
    igreen = roundf(green * 255);
    iblue = roundf(blue * 255);
    
    NSUInteger result = (ired << 16) | (igreen << 8) | iblue;
    return result;
}

#pragma mark -

+ (UIColor *)colorMixedInRGB:(UIColor *)color1 andColor:(UIColor *)color2 percent:(CGFloat)percent
{
    CGFloat mixSize = 100;
    
    CGFloat r1, g1, b1, r2, g2, b2, r3, g3, b3, empty;
    
    [color1 getRed:&r1 green:&g1 blue:&b1 alpha:&empty];
    [color2 getRed:&r2 green:&g2 blue:&b2 alpha:&empty];
    
    CGFloat mixStepR = (r2 - r1) / mixSize;
    CGFloat mixStepG = (g2 - g1) / mixSize;
    CGFloat mixStepB = (b2 - b1) / mixSize;
    
    r3 = r1 + mixStepR * percent;
    g3 = g1 + mixStepG * percent;
    b3 = b1 + mixStepB * percent;
    
    return [UIColor colorWithRed:r3 green:g3 blue:b3 alpha:1];
}

+ (UIColor *)colorMixedInLAB:(UIColor *)color1 andColor:(UIColor *)color2 percent:(CGFloat)percent
{
    if (percent <= 0) return color1;
    else if (percent >= 100) return color2;
    else
    {
        CGFloat mixSize = 100;
        
        NSArray *array1 = [self colorConvertRGBtoLAB:color1];
        NSArray *array2 = [self colorConvertRGBtoLAB:color2];
        
        NSArray *array3 = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:[[array1 objectAtIndex:0] floatValue] - (([[array1 objectAtIndex:0] floatValue] - [[array2 objectAtIndex:0] floatValue]) * (percent / mixSize))],
                           [NSNumber numberWithFloat:[[array1 objectAtIndex:1] floatValue] - (([[array1 objectAtIndex:1] floatValue] - [[array2 objectAtIndex:1] floatValue]) * (percent / mixSize))],
                           [NSNumber numberWithFloat:[[array1 objectAtIndex:2] floatValue] - (([[array1 objectAtIndex:2] floatValue] - [[array2 objectAtIndex:2] floatValue]) * (percent / mixSize))], nil];
        
        return [self colorConvertLABtoRGB:array3];
    }
}

#pragma mark -

/** 0-255 */
- (UIColor *)darkerOnRGB:(NSUInteger)k
{
    if (k > 255) k = 255;
    
    CGFloat r, g, b, a;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    CGFloat rgbMax = 255.f;
    
    return [UIColor colorWithRed:r-((CGFloat)k/rgbMax) green:g-((CGFloat)k/rgbMax) blue:b-((CGFloat)k/rgbMax) alpha:a];
}

/** 0-255 */
- (UIColor *)lighterOnRGB:(NSUInteger)k
{
    if (k > 255) k = 255;
    
    CGFloat r, g, b, a;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    CGFloat rgbMax = 255.f;
    
    return [UIColor colorWithRed:r+((CGFloat)k/rgbMax) green:g+((CGFloat)k/rgbMax) blue:b+((CGFloat)k/rgbMax) alpha:a];
}

/** 0.f-1.f */
- (UIColor *)darkerOn:(CGFloat)k
{
    if (k < 0.f) k = 0.f;
    if (k > 1.f) k = 1.f;
    
    CGFloat r, g, b, a;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    return [UIColor colorWithRed:r-k green:g-k blue:b-k alpha:a];
}

/** 0.f-1.f */
- (UIColor *)lighterOn:(CGFloat)k
{
    if (k < 0.f) k = 0.f;
    if (k > 1.f) k = 1.f;
    
    CGFloat r, g, b, a;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    return [UIColor colorWithRed:r+k green:g+k blue:b+k alpha:a];
}

/** 0.f-100.f */
- (UIColor *)darkerOnPercent:(CGFloat)percent
{
    if (percent < 0.f) percent = 0.f;
    if (percent > 100.f) percent = 100.f;
    
    CGFloat r, g, b, a;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    CGFloat percent_ = percent/100.f;
    
    return [UIColor colorWithRed:r-r*percent_ green:g-g*percent_ blue:b-b*percent_ alpha:a];
}

/** 0.f-100.f */
- (UIColor *)lighterOnPercent:(CGFloat)percent
{
    if (percent < 0.f) percent = 0.f;
    if (percent > 100.f) percent = 100.f;
    
    CGFloat r, g, b, a;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    CGFloat rgbMax = 255.f;
    
    CGFloat percent_ = percent/100.f;
    
    return [UIColor colorWithRed:r+(rgbMax-r)*percent_ green:g+(rgbMax-g)*percent_ blue:b+(rgbMax-b)*percent_ alpha:a];
}

#pragma mark -

- (NSArray *)convertedRGBtoXYZ
{
    ////make variables to get color values
    CGFloat red2;
    CGFloat green2;
    CGFloat blue2;
    
    [self getRed:&red2 green:&green2 blue:&blue2 alpha:nil];
    
    //convert to XYZ
    
    float red = (float)red2;
    float green = (float)green2;
    float blue = (float)blue2;
    
    // adjusting values
    if (red > 0.04045)
    {
        red = (red + 0.055)/1.055;
        red = pow(red,2.4);
    }
    else red = red/12.92;
    
    if (green > 0.04045)
    {
        green = (green + 0.055)/1.055;
        green = pow(green,2.4);
    }
    else green = green/12.92;
    
    if (blue > 0.04045)
    {
        blue = (blue + 0.055)/1.055;
        blue = pow(blue,2.4);
    }
    else blue = blue/12.92;
    
    red *= 100;
    green *= 100;
    blue *= 100;
    
    //make x, y and z variables
    float x;
    float y;
    float z;
    
    // applying the matrix to finally have XYZ
    x = (red * 0.4124) + (green * 0.3576) + (blue * 0.1805);
    y = (red * 0.2126) + (green * 0.7152) + (blue * 0.0722);
    z = (red * 0.0193) + (green * 0.1192) + (blue * 0.9505);
    
    NSNumber *xNumber = [NSNumber numberWithFloat:x];
    NSNumber *yNumber = [NSNumber numberWithFloat:y];
    NSNumber *zNumber = [NSNumber numberWithFloat:z];
    
    //add them to an array to return.
    NSArray *xyzArray = [NSArray arrayWithObjects:xNumber, yNumber, zNumber, nil];
    
    return xyzArray;
}

- (NSArray *)convertedRGBtoLAB
{
    return [UIColor colorConvertXYZtoLAB:[UIColor colorConvertRGBtoXYZ:self]];
}

#pragma mark -

+ (NSArray *)colorConvertRGBtoXYZ:(UIColor *)color
{
    ////make variables to get color values
    CGFloat red2;
    CGFloat green2;
    CGFloat blue2;
    
    [color getRed:&red2 green:&green2 blue:&blue2 alpha:nil];
    
    //convert to XYZ
    
    float red = (float)red2;
    float green = (float)green2;
    float blue = (float)blue2;
    
    // adjusting values
    if (red > 0.04045)
    {
        red = (red + 0.055)/1.055;
        red = pow(red,2.4);
    }
    else red = red/12.92;
    
    if (green > 0.04045)
    {
        green = (green + 0.055)/1.055;
        green = pow(green,2.4);
    }
    else green = green/12.92;
    
    if (blue > 0.04045)
    {
        blue = (blue + 0.055)/1.055;
        blue = pow(blue,2.4);
    }
    else blue = blue/12.92;
    
    red *= 100;
    green *= 100;
    blue *= 100;
    
    //make x, y and z variables
    float x;
    float y;
    float z;
    
    // applying the matrix to finally have XYZ
    x = (red * 0.4124) + (green * 0.3576) + (blue * 0.1805);
    y = (red * 0.2126) + (green * 0.7152) + (blue * 0.0722);
    z = (red * 0.0193) + (green * 0.1192) + (blue * 0.9505);
    
    NSNumber *xNumber = [NSNumber numberWithFloat:x];
    NSNumber *yNumber = [NSNumber numberWithFloat:y];
    NSNumber *zNumber = [NSNumber numberWithFloat:z];
    
    //add them to an array to return.
    NSArray *xyzArray = [NSArray arrayWithObjects:xNumber, yNumber, zNumber, nil];
    
    return xyzArray;
}

+ (NSArray *)colorConvertRGBtoLAB:(UIColor *)color
{
    return [UIColor colorConvertXYZtoLAB:[UIColor colorConvertRGBtoXYZ:color]];
}

+ (NSArray *)colorConvertXYZtoLAB:(NSArray *)xyzArray
{
    NSNumber *xNumber = [xyzArray objectAtIndex:0];
    NSNumber *yNumber = [xyzArray objectAtIndex:1];
    NSNumber *zNumber = [xyzArray objectAtIndex:2];
    
    //make x, y and z variables
    float x = xNumber.floatValue;
    float y = yNumber.floatValue;
    float z = zNumber.floatValue;
    
    //NSLog(@"LGKit: XYZ color - %f, %f, %f", x, y, z);
    
    //then convert XYZ to LAB
    
    x = x/95.047;
    y = y/100;
    z = z/108.883;
    
    // adjusting the values
    if (x > 0.008856) x = powf(x,(1.0/3.0));
    else x = ((7.787 * x) + (16/116));
    
    if (y > 0.008856) y = pow(y,(1.0/3.0));
    else y = ((7.787 * y) + (16/116));
    
    if (z > 0.008856) z = pow(z,(1.0/3.0));
    else z = ((7.787 * z) + (16/116));
    
    //make L, A and B variables
    float l;
    float a;
    float b;
    
    //finally have your l, a, b variables!!!!
    l = ((116 * y) - 16);
    a = 500 * (x - y);
    b = 200 * (y - z);
    
    NSNumber *lNumber = [NSNumber numberWithFloat:l];
    NSNumber *aNumber = [NSNumber numberWithFloat:a];
    NSNumber *bNumber = [NSNumber numberWithFloat:b];
    
    //add them to an array to return.
    NSArray *labArray = [NSArray arrayWithObjects:lNumber, aNumber, bNumber, nil];
    
    return labArray;
}

+ (NSArray *)colorConvertLABtoXYZ:(NSArray *)labArray
{
    NSNumber *lNumber = [labArray objectAtIndex:0];
    NSNumber *aNumber = [labArray objectAtIndex:1];
    NSNumber *bNumber = [labArray objectAtIndex:2];
    
    //make l, a and b variables
    float l = lNumber.floatValue;
    float a = aNumber.floatValue;
    float b = bNumber.floatValue;
    
    float delta = 6 / 29;
    
    float y = (l + 16) / 116;
    float x = y + (a / 500);
    float z = y - (b / 200);
    
    if (pow(x, 3.0) > delta) x = pow(x, 3);
    else x = (x - 16 / 116) * 3 * (delta * delta);
    
    if (pow(y, 3.0) > delta) y = pow(y, 3);
    else y = (y - 16 / 116) * 3 * (delta * delta);
    
    if (pow(z, 3.0) > delta) z = pow(z, 3);
    else z = (z - 16 / 116) * 3 * (delta * delta);
    
    x = x * 95.047;
    y = y * 100;
    z = z * 108.883;
    
    NSNumber *xNumber = [NSNumber numberWithFloat:x];
    NSNumber *yNumber = [NSNumber numberWithFloat:y];
    NSNumber *zNumber = [NSNumber numberWithFloat:z];
    
    //add them to an array to return.
    NSArray *xyzArray = [NSArray arrayWithObjects:xNumber, yNumber, zNumber, nil];
    
    return xyzArray;
}

+ (UIColor *)colorConvertXYZtoRGB:(NSArray *)xyzArray
{
    NSNumber *xNumber = [xyzArray objectAtIndex:0];
    NSNumber *yNumber = [xyzArray objectAtIndex:1];
    NSNumber *zNumber = [xyzArray objectAtIndex:2];
    
    //make x, y and z variables
    float x = xNumber.floatValue;
    float y = yNumber.floatValue;
    float z = zNumber.floatValue;
    
    x = x / 100;
    y = y / 100;
    z = z / 100;
    
    float r = x *  3.2406 + y * -1.5372 + z * -0.4986;
    float g = x * -0.9689 + y *  1.8758 + z *  0.0415;
    float b = x *  0.0557 + y * -0.2040 + z *  1.0570;
    
    if (r > 0.0031308) r = 1.055 * pow(r, 1 / 2.4) - 0.055;
    else r = 12.92 * r;
    
    if (g > 0.0031308) g = 1.055 * pow(g, 1 / 2.4) - 0.055;
    else g = 12.92 * g;
    
    if (b > 0.0031308) b = 1.055 * pow(b, 1 / 2.4) - 0.055;
    else b = 12.92 * b;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

+ (UIColor *)colorConvertLABtoRGB:(NSArray *)labArray
{
    return [UIColor colorConvertXYZtoRGB:[UIColor colorConvertLABtoXYZ:labArray]];
}

@end
