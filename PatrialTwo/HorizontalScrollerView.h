//
//  HorizontalScrollerView.h
//  PatrialTwo
//
//  Created by Serge Sychov on 08.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HorizontalScrollerView;

@protocol HorizontalScrollerDelegate <NSObject>

@required
-(NSInteger)numberOfViewForHorizontalScroller:(HorizontalScrollerView*)scroller;
-(UIView*)horizontalScroller:(HorizontalScrollerView*)scroller viewAtIndex:(NSInteger)index;
-(void)horizontalScroller:(HorizontalScrollerView*)scroller clickedViewAtIndex:(NSInteger)index;

@optional
- (NSInteger)initialViewIndexForHorizontalScroller:(HorizontalScrollerView *)scroller;

@end

@interface HorizontalScrollerView : UIView


-(void)reload;
@property (weak) id <HorizontalScrollerDelegate> delegate;

@end
