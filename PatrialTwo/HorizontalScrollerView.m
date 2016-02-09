//
//  HorizontalScrollerView.m
//  PatrialTwo
//
//  Created by Serge Sychov on 08.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "HorizontalScrollerView.h"

#define VIEW_PADDING 30
//#define VIEW_DIMENSIONS 100
//#define VIEWS_OFFSET 20

@interface HorizontalScrollerView() <UIScrollViewDelegate>
@property (nonatomic,weak) UIScrollView *scroller;
@end

@implementation HorizontalScrollerView


-(void) setup{
    UIScrollView *scroller = [[UIScrollView alloc] init];
    scroller.delegate  = self;
    [self addSubview:scroller];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollerTapped:)];
    [scroller addGestureRecognizer:tapRecognizer];
    scroller.backgroundColor = [UIColor clearColor];
    scroller.clipsToBounds = NO;
    self.scroller = scroller;
}

-(void)scrollerTapped:(UITapGestureRecognizer*)sender
{
    CGPoint location = [sender locationInView:sender.view];
    for(NSInteger i = 0; i< [self.delegate numberOfViewForHorizontalScroller:self]; i++){
        UIView *view = self.scroller.subviews[i];
        if(CGRectContainsPoint(view.frame, location)){
            [self.delegate horizontalScroller:self clickedViewAtIndex:i];
            CGPoint offset = CGPointMake(view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, 0);
            [self.scroller setContentOffset:offset animated:YES];
        }
    }
}

-(void)reload
{

    if (self.delegate == nil) return;
    
    // 2 - удалить все subviews:
    [self.scroller.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        [obj removeFromSuperview];
    }];

    //one bounds for all views
    CGFloat boundsWidth = self.bounds.size.width/1.5;
    CGRect boundsViews = CGRectMake(0, 0, boundsWidth, (boundsWidth)*1.33);
    
    CGFloat xOffset = 0;
    for (int i = 0; i < [self.delegate numberOfViewForHorizontalScroller:self]; i++)
    {
        
        // 4 - добавляем представление в нужную позицию:
        UIView * view = [self.delegate horizontalScroller:self viewAtIndex:i];
        [self.scroller addSubview:view];
        view.bounds = boundsViews;
        view.center = CGPointMake(self.bounds.size.width/2+xOffset,
                                  self.bounds.size.height/2);
        
        xOffset+=(boundsWidth+VIEW_PADDING);

    }
    
    // 5
    [self.scroller setContentSize:CGSizeMake(xOffset + boundsWidth, self.frame.size.height)];
    
    // 6 - если определён initialView, центрируем его в скроллере:
    if ([self.delegate respondsToSelector:@selector(initialViewIndexForHorizontalScroller:)])
    {
        NSInteger initialView = [self.delegate initialViewIndexForHorizontalScroller:self];
        CGPoint offset = CGPointMake(initialView * (boundsWidth+VIEW_PADDING)+boundsWidth/2, 0);
        [self.scroller setContentOffset:offset animated:YES];
    }
}

- (void)centerCurrentView
{
    CGFloat boundsWidth = self.bounds.size.width/1.5;
    CGFloat xFinal = self.scroller.contentOffset.x + boundsWidth + VIEW_PADDING;
    NSInteger viewIndex = xFinal / (boundsWidth + VIEW_PADDING);
    xFinal = viewIndex * (boundsWidth + VIEW_PADDING);
    [self.scroller setContentOffset:CGPointMake(xFinal, 0) animated:YES];
    //[self.delegate horizontalScroller:self clickedViewAtIndex:viewIndex];
}

#pragma mark SCROLL VIEW DELEGATE
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self centerCurrentView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self centerCurrentView];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self.scroller setFrame:rect];
    [self reload];
}


-(id) init{
    self = [super init];
    if(self){
        [self setup];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
    
}

@end


