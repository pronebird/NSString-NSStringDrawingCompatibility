//
//  NSString+NSStringDrawingCompatibility.h
//
//  iOS 7 NSStringDrawing API compatible with iOS 6
//
//  Created by Andrej Mihajlov on 30/10/13.
//  Copyright (c) 2013 Andrej Mihajlov. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000

// use protocols to avoid warnings on dynamic methods
@protocol NSStringDrawingCompatibility <NSObject>
@optional
- (CGSize)sizeWithAttributes:(NSDictionary *)attrs;
- (void)drawAtPoint:(CGPoint)point withAttributes:(NSDictionary *)attrs;
- (void)drawInRect:(CGRect)rect withAttributes:(NSDictionary *)attrs;
@end

@protocol NSExtendedStringDrawingCompatibility <NSObject>
@optional
- (CGRect)boundingRectWithSize:(CGSize)size options:(NSStringDrawingOptions)options attributes:(NSDictionary *)attributes context:(NSStringDrawingContext *)context;
@end

@interface NSString (NSStringDrawingCompatibility) <NSStringDrawingCompatibility>

@end

@interface NSString (NSExtendedStringDrawingCompatibility) <NSExtendedStringDrawingCompatibility>

@end

#endif
