//
//  CenterScrollView.m
//  Porygon-Demo
//
//  Created by Pavel Kozlov on 05/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

#import "CenterScrollView.h"

@implementation CenterScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setContentOffset:(CGPoint)contentOffset
{
    const CGSize contentSize = self.contentSize;
    const CGSize scrollViewSize = self.bounds.size;
    
    if (contentSize.width < scrollViewSize.width)
    {
        contentOffset.x = -(scrollViewSize.width - contentSize.width) / 2.0;
    }
    
    if (contentSize.height < scrollViewSize.height)
    {
        contentOffset.y = -(scrollViewSize.height - contentSize.height) / 2.0;
    }
    
    [super setContentOffset:contentOffset];
}

@end
