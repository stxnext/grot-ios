#import <UIKit/UIKit.h>

@interface UIBezierPath (Image)

/** Returns an image of the path drawn using a stroke */
-(UIImage *) strokeImageWithColor:(UIColor*)color;

@end
