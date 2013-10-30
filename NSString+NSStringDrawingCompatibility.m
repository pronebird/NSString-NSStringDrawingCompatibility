//
//  NSString+NSStringDrawingCompatibility.m
//
//  iOS 7 NSStringDrawing API compatible with iOS 6
//
//  Created by Andrej Mihajlov on 30/10/13.
//  Copyright (c) 2013 Andrej Mihajlov. All rights reserved.
//

#import "NSString+NSStringDrawingCompatibility.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000

#import <objc/runtime.h>
#import <float.h>

#define fequalzero(a) (fabs(a) < FLT_EPSILON)

NS_INLINE void swizzle(Class c, SEL orig, SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
	
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
		method_exchangeImplementations(origMethod, newMethod);
	}
}

@implementation NSString (NSStringDrawingCompatibility)

+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if(floor(NSFoundationVersionNumber) <= 993.00) { // 6.1
			swizzle(self.class, @selector(sizeWithAttributes:), @selector(pb_sizeWithAttributes:));
			swizzle(self.class, @selector(drawInRect:withAttributes:), @selector(pb_drawInRect:withAttributes:));
		}
	});
}

- (CGSize)pb_sizeWithAttributes:(NSDictionary*)attrs {
	NSParagraphStyle* paragraphStyle = attrs[NSParagraphStyleAttributeName];
	NSLineBreakMode lineBreakMode = paragraphStyle != nil ? paragraphStyle.lineBreakMode : NSLineBreakByWordWrapping;
	UIFont* font = attrs[NSFontAttributeName];
	
	return [self sizeWithFont:font forWidth:CGFLOAT_MAX lineBreakMode:lineBreakMode];
}

- (void)pb_drawInRect:(CGRect)rect withAttributes:(NSDictionary *)attrs {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	UIFont* font = attrs[NSFontAttributeName];
	NSParagraphStyle* paragraphStyle = attrs[NSParagraphStyleAttributeName];
	NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
	NSTextAlignment textAlignment = NSTextAlignmentLeft;
	
	if(paragraphStyle != nil) {
		lineBreakMode = paragraphStyle.lineBreakMode;
		
		// natural and justified alignment aren't supported on iOS 6
		if(paragraphStyle.alignment != NSTextAlignmentNatural && paragraphStyle.alignment != NSTextAlignmentJustified) {
			textAlignment = paragraphStyle.alignment;
		}
	}
	
	if(attrs[NSBackgroundColorAttributeName] != nil) {
		CGSize size = [self sizeWithAttributes:attrs];
		
		CGContextSaveGState(ctx);
		[((UIColor*)attrs[NSBackgroundColorAttributeName]) setFill];
		UIRectFill(CGRectMake(0, 0, size.width, size.height));
		CGContextRestoreGState(ctx);
	}
	
	if(attrs[NSForegroundColorAttributeName] != nil) {
		[((UIColor*)attrs[NSForegroundColorAttributeName]) setFill];
	}
	
	[self drawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:textAlignment];
}

@end

@implementation NSString (NSExtendedStringDrawingCompatibility)

+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if(floor(NSFoundationVersionNumber) <= 993.00) { // 6.1
			swizzle(self.class, @selector(boundingRectWithSize:options:attributes:context:), @selector(pb_boundingRectWithSize:options:attributes:context:));
		}
	});
}

- (CGRect)pb_boundingRectWithSize:(CGSize)size options:(NSStringDrawingOptions)options attributes:(NSDictionary *)attributes context:(NSStringDrawingContext *)context {
	UIFont* font = attributes[NSFontAttributeName];
	NSParagraphStyle* paragraphStyle = attributes[NSParagraphStyleAttributeName];
	NSLineBreakMode lineBreakMode = paragraphStyle != nil ? paragraphStyle.lineBreakMode : NSLineBreakByWordWrapping;
	CGSize textSize;
	
	if(context != nil) {
		CGFloat minFontSize = font.pointSize;
		__unused CGFloat actualFontSize;
		
		if(!fequalzero(context.minimumScaleFactor)) {
			minFontSize *= font.pointSize;
		}
		
		textSize = [self sizeWithFont:font minFontSize:minFontSize actualFontSize:&actualFontSize forWidth:CGFLOAT_MAX lineBreakMode:lineBreakMode];
	} else {
		textSize = [self sizeWithFont:font forWidth:CGFLOAT_MAX lineBreakMode:lineBreakMode];
	}
	
	return CGRectMake(0, 0, textSize.width, textSize.height);
}

@end

#endif
