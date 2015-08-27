 //
//  JENSubtreeView.m
//
//  Created by Jennifer Nordwall on 3/8/14.
//  Copyright (c) 2014 Jennifer Nordwall. All rights reserved.
//

#import "JENSubtreeView.h"
#import "JENTreeViewModelNode.h"
#import "JENDefaultNodeView.h"


@interface JENSubtreeView ()

@property (nonatomic, strong) UIView *nodeView;
@property (nonatomic, strong) UIView<JENDecorationView> *decorationsView;

@end

@implementation JENSubtreeView

-(id)initWithNodeView:(UIView*)nodeView decorationView:(UIView<JENDecorationView>*)decorationView {
    self = [super initWithFrame:CGRectMake(10, 10, 100, 25)];
    
    if(self) {
        self.autoresizesSubviews    = FALSE;
        self.parentChildSpacing     = 40.0;
        self.siblingSpacing         = 10.0;
        
        self.nodeView               = nodeView;
        self.decorationsView        = decorationView;

        [self addSubview:self.nodeView];
        [self addSubview:self.decorationsView];
    }
    return self;
}

#pragma mark Properties

-(void)setInvertedLayout:(BOOL)invertedLayout {
    if(_invertedLayout != invertedLayout) {
        _invertedLayout = invertedLayout;
        
        for(UIView *subview in self.subviews) {
            if([subview isKindOfClass:[JENSubtreeView class]]) {
                ((JENSubtreeView*)subview).invertedLayout = invertedLayout;
            }
        }
    }
}

-(void)setAlignChildren:(BOOL)alignChildren {
    if(_alignChildren != alignChildren) {
        _alignChildren = alignChildren;
        
        for(UIView *subview in self.subviews) {
            if([subview isKindOfClass:[JENSubtreeView class]]) {
                ((JENSubtreeView*)subview).alignChildren = alignChildren;
            }
        }
    }
}

-(void)setShowView:(BOOL)showView {
    if(_showView != showView) {
        _showView = showView;
        
        float alpha = showView ? 0.2f : 0.0f;
        self.backgroundColor = [[UIColor alloc] initWithRed:1.0
                                                      green:1.0
                                                       blue:1.0
                                                      alpha:alpha];
        
        for(UIView *subview in self.subviews) {
            if([subview isKindOfClass:[JENSubtreeView class]]) {
                ((JENSubtreeView*)subview).showView = showView;
            }
        }
    }
}

-(void)setShowViewFrame:(BOOL)showViewFrame {
    if(_showViewFrame != showViewFrame) {
        _showViewFrame = showViewFrame;
        
        if(self.layer) {
            self.layer.borderWidth = showViewFrame ? 1.0f : 0.0f;
            self.layer.borderColor  = [UIColor blackColor].CGColor;
        }
        
        for(UIView *subview in self.subviews) {
            if([subview isKindOfClass:[JENSubtreeView class]]) {
                ((JENSubtreeView*)subview).showViewFrame = showViewFrame;
            }
        }
    }
}

#pragma mark Layout

-(CGSize)layoutGraph {
    NSArray *subviews                   = self.subviews;
    CGFloat maxHeight                   = 0.0;
    CGFloat minHeight                   = CGFLOAT_MAX;
    NSUInteger subtreeViewCount         = 0;
    CGSize nodeViewSize                 = self.nodeView.frame.size;
    CGPoint subtreeOrigion              = CGPointMake(0.0, 0.0);
    NSMutableDictionary *subViewSizes   = [[NSMutableDictionary alloc] init];
    
    // get max/minWidth of the subviews that we will use later on
    for (UIView *subview in subviews) {
        if([subview isKindOfClass:[JENSubtreeView class]]) {
            CGSize subViewSize = [((JENSubtreeView*)subview) layoutGraph];
            
            maxHeight = MAX(maxHeight, subViewSize.height);
            minHeight = MIN(minHeight, subViewSize.height);
            
            [subViewSizes setObject:[NSValue valueWithCGSize:subViewSize] forKey:@(subview.hash)];
        }
    }

    // walk through subviews and position them
    for (UIView *subview in subviews.reverseObjectEnumerator) {
        if([subview isKindOfClass:[JENSubtreeView class]]) {
            subtreeViewCount++;
            
            CGSize subtreeViewSize = [subViewSizes[@(subview.hash)] CGSizeValue];
            
            if(self.invertedLayout) {
                subtreeOrigion.y = 0.0;
            } else subtreeOrigion.y = nodeViewSize.height + self.parentChildSpacing;

            if((self.invertedLayout && !self.alignChildren) ||
               (!self.invertedLayout && self.alignChildren)) {
                subtreeOrigion.y += (maxHeight - subtreeViewSize.height);
            }

            CGRect frame    = subview.frame;
            frame.origin    = subtreeOrigion;
            subview.frame   = frame;
            
            // for next run
            subtreeOrigion.x += subtreeViewSize.width + self.siblingSpacing;
        }
    }
    
    CGSize selfTargetSize;
    CGRect nodeViewFrame = self.nodeView.frame;
    
    if(subtreeViewCount > 0) {
        // *** NODE VIEW *** //
        
//        float width = nodeViewSize.width + self.parentChildSpacing + maxWidth;
//        float height = MAX(subtreeOrigion.y - self.siblingSpacing, nodeViewSize.height);
        float width = MAX(subtreeOrigion.x - self.siblingSpacing, nodeViewSize.width);
        float height = nodeViewSize.height + self.parentChildSpacing + maxHeight;
        selfTargetSize  = CGSizeMake(width, height);
    
        CGRect frame    = self.frame;
        frame.size      = selfTargetSize;
        self.frame      = frame;
        
        nodeViewFrame.origin = CGPointMake(0.5 * (selfTargetSize.width - nodeViewSize.width), 0.0f);
        self.nodeView.frame  = nodeViewFrame;
        
        // *** DECORATION VIEW *** //
		if(self.decorationsView) {
			CGFloat decorationViewHeight = self.parentChildSpacing;
			CGFloat decorationViewY      = nodeViewSize.height;
			
			if(self.invertedLayout) {
				decorationViewY = self.alignChildren ? minHeight : maxHeight;
			}
			
			if(self.alignChildren) {
				decorationViewHeight = self.frame.size.height - nodeViewSize.height - minHeight;
			}
			
			CGRect decorationsViewFrame = CGRectMake(0.0f, decorationViewY, selfTargetSize.width, decorationViewHeight);
			self.decorationsView.frame  = decorationsViewFrame;
			
			self.decorationsView.hidden                 = false;
			self.decorationsView.parentChildSpacing     = self.parentChildSpacing;
			self.decorationsView.invertedLayout         = self.invertedLayout;
			
			[self.decorationsView setNeedsDisplay];
		}
        
    } else { // leaf node
        // *** NODE VIEW *** //
        selfTargetSize          = nodeViewSize;
        
        nodeViewFrame.origin    = CGPointMake(0.0f, 0.0);
        self.frame              = nodeViewFrame;
    }
    
    return selfTargetSize;
}

@end
