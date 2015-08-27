//
//  JENNode.m
//  Example
//
//  Created by Jennifer Nordwall on 3/23/14.
//  Copyright (c) 2014 Jennifer Nordwall. All rights reserved.
//

#import "JENNode.h"

@implementation JENNode

- (void)setChildren:(NSSet *)children {
    _children = children;
    for (NSObject<JENTreeViewModelNode>* eachChild in children) {
        eachChild.parent = self;
    }
}

@end
