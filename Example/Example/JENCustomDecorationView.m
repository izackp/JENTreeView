//
//  JENCustomDecorationView.m
//  Example
//
//  Created by Jennifer Nordwall on 3/31/14.
//  Copyright (c) 2014 Jennifer Nordwall. All rights reserved.
//

#import "JENCustomDecorationView.h"
#import "JENSubtreeView.h"

@implementation JENCustomDecorationView

-(id)init {
    self = [super init];
    
    if(self) {
        self.backgroundColor = [[UIColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:0.0f];
    }
    
    return self;
}

#pragma mark Properties

- (void)setShowViewFrame:(BOOL)showViewFrame {
    if (_showViewFrame == showViewFrame)
        return;
    
    _showViewFrame = showViewFrame;
    
    if (self.layer) {
        self.layer.borderWidth = showViewFrame ? 1.0f : 0.0f;
        self.layer.borderColor = [UIColor redColor].CGColor;
    }
}

- (void)setShowView:(BOOL)showView {
    if (_showView == showView)
        return;
    
    _showView = showView;
    
    float alpha = showView ? 0.2f : 0.0f;
    self.backgroundColor = [[UIColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:alpha];
}

- (UIBezierPath*)directConnectionsPath {
    CGPoint rootPoint   = CGPointMake(CGRectGetMidX(self.bounds), 0.0f);
    UIBezierPath *path  = [UIBezierPath bezierPath];
    
    if ([self.superview isKindOfClass:[JENSubtreeView class]]) {
        for (UIView *subview in [self.superview subviews]) {
            if ([subview isKindOfClass:[JENSubtreeView class]]) {
                CGPoint targetPoint = [self convertPoint:CGPointMake(CGRectGetMidX(subview.bounds), subview.bounds.origin.y) fromView:subview];
                
                [path moveToPoint:rootPoint];
                [path addLineToPoint:targetPoint];
            }
        }
    }
    return path;
}

- (UIBezierPath*)orthogonalConnectionsPath {
    
    CGPoint rootPoint           = CGPointMake(CGRectGetMidX(self.bounds), 0.0f);
    CGPoint rootIntersection    = CGPointMake(CGRectGetMidX(self.bounds), 0.0 + (self.parentChildSpacing / 2));
    
    UIBezierPath *path          = [UIBezierPath bezierPath];
    NSInteger subtreeViewCount  = 0;
    CGFloat minX                = rootPoint.x;
    CGFloat maxX                = rootPoint.x;
    
    if ([self.superview isKindOfClass:[JENSubtreeView class]]) {
        for (UIView *subview in [self.superview subviews]) {
            if ([subview isKindOfClass:[JENSubtreeView class]]) {
                ++subtreeViewCount;
                
                CGRect subviewBounds    = [subview bounds];
                CGPoint targetPoint     = [self convertPoint:CGPointMake(CGRectGetMidX(subviewBounds), subviewBounds.origin.y) fromView:subview];
                
                [path moveToPoint:CGPointMake(targetPoint.x, rootIntersection.y)];
                [path addLineToPoint:targetPoint];
                
                minX = MIN(minX, targetPoint.x);
                maxX = MAX(maxX, targetPoint.x);
            }
        }
    }
    
    if (subtreeViewCount) {
        [path moveToPoint:rootPoint];
        [path addLineToPoint:rootIntersection];
        [path moveToPoint:CGPointMake(minX - 0.5, rootIntersection.y)];
        [path addLineToPoint:CGPointMake(maxX + 0.5, rootIntersection.y)];
    }
    
    return path;
}

- (void)drawRect:(CGRect)dirtyRect {
    UIBezierPath *path = self.ortogonalConnection ?
    [self orthogonalConnectionsPath] :
    [self directConnectionsPath];
    
    [[UIColor blackColor] set];
    path.lineWidth = 1.0;
    [path stroke];
}

@end
