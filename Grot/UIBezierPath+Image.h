#import <UIKit/UIKit.h>

@interface UIBezierPath (Image)

/** Returns an image of the path drawn using a stroke */
-(UIImage *)fillImageWithColor:(UIColor*)color;
-(UIImage *) strokeImageWithColor:(UIColor*)color;
- (UIImage*)fillImageWithGradientFromColor:(UIColor*)color1 toColor:(UIColor*)color2;
@end
