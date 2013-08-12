//
//  AFPickerView.m
//  PickerView
//
//  Created by Fraerman Arkady on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AFPickerView.h"
#include <Quartzcore/Quartzcore.h>

@implementation AFPickerView

#pragma mark - Synthesization

@synthesize dataSource;
@synthesize delegate;
@synthesize selectedRow = currentRow;
@synthesize rowFont = _rowFont;
@synthesize rowIndent = _rowIndent;
@synthesize rowHeight = _rowHeight;
@synthesize rowFontColor = _rowFontColor;



#pragma mark - Custom getters/setters

- (void)setSelectedRow:(int)selectedRow
{
    if (selectedRow >= rowsCount)
        return;
    
    currentRow = selectedRow;
    [contentView setContentOffset:CGPointMake(0.0, _rowHeight * currentRow) animated:NO];
}




- (void)setRowFont:(UIFont *)rowFont
{
    _rowFont = rowFont;
    
    for (UILabel *aLabel in visibleViews) 
    {
        aLabel.font = _rowFont;
    }
}




- (void)setRowIndent:(CGFloat)rowIndent
{
    _rowIndent = rowIndent;
    
    for (UILabel *aLabel in visibleViews) 
    {
        CGRect frame = aLabel.frame;
        frame.origin.x = _rowIndent;
        frame.size.width = self.frame.size.width - _rowIndent;
        aLabel.frame = frame;
    }
}




#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame backgroundImage:(UIImage *) backgroundImage pickerShadowsImage:(UIImage *) pickerShadows
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // setup
        [self setup];
        
        // backgound
        if (backgroundImage) {
            UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
            background.frame = CGRectMake(0, (self.frame.size.height - backgroundImage.size.height)/2, backgroundImage.size.width, backgroundImage.size.height);
            [self addSubview:background];
        }
        
        // content
        contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        contentView.showsHorizontalScrollIndicator = NO;
        contentView.showsVerticalScrollIndicator = NO;
        contentView.delegate = self;
        [self addSubview:contentView];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [contentView addGestureRecognizer:tapRecognizer];
        
        
        // shadows
        if (pickerShadows) {
        UIImageView *shadows = [[UIImageView alloc] initWithImage:pickerShadows];
        [self addSubview:shadows];
        }
    }
    return self;
}




- (void)setup
{
    _rowFont = [UIFont boldSystemFontOfSize:24.0];
    _rowIndent = 30.0;
    _rowFontColor = [UIColor whiteColor];
    _rowHeight = 39.0;
    
    currentRow = 0;
    rowsCount = 0;
    visibleViews = [[NSMutableSet alloc] init];
}




#pragma mark - Buisness

- (void)reloadData
{
    // empry views
    currentRow = 0;
    rowsCount = 0;
    
    for (UIView *aView in visibleViews) 
        [aView removeFromSuperview];
    
    visibleViews = [[NSMutableSet alloc] init];
    
    rowsCount = [dataSource numberOfRowsInPickerView:self];
    [contentView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    contentView.contentSize = CGSizeMake(contentView.frame.size.width, _rowHeight * rowsCount + 3 * _rowHeight);
    [self tileViews];
}




- (void)determineCurrentRow
{
    CGFloat delta = contentView.contentOffset.y;
    int position = round(delta / _rowHeight);
    currentRow = position;
    [contentView setContentOffset:CGPointMake(0.0, _rowHeight * position) animated:YES];
    [delegate pickerView:self didSelectRow:currentRow];
}




- (void)didTap:(id)sender
{
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)sender;
    CGPoint point = [tapRecognizer locationInView:self];
    int steps = floor(point.y / _rowHeight) - 2;
    [self makeSteps:steps];
}




- (void)makeSteps:(int)steps
{
    if (steps == 0 || steps > 2 || steps < -2)
        return;
    
    [contentView setContentOffset:CGPointMake(0.0, _rowHeight * currentRow) animated:NO];
    
    int newRow = currentRow + steps;
    if (newRow < 0 || newRow >= rowsCount)
    {
        if (steps == -2)
            [self makeSteps:-1];
        else if (steps == 2)
            [self makeSteps:1];
        
        return;
    }
    
    currentRow = currentRow + steps;
    [contentView setContentOffset:CGPointMake(0.0, _rowHeight * currentRow) animated:YES];
    [delegate pickerView:self didSelectRow:currentRow];
}




#pragma mark - recycle queue



- (BOOL)isDisplayingViewForIndex:(NSUInteger)index
{
	BOOL foundPage = NO;
    for (UIView *aView in visibleViews) 
	{
        int viewIndex = aView.frame.origin.y / _rowHeight - 2;
        if (viewIndex == index) 
		{
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}




- (void)tileViews
{
	for (int index = 0; index < rowsCount; index++)
	{
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_rowIndent, 0, self.frame.size.width - _rowIndent, _rowHeight)];
        label.backgroundColor = [UIColor clearColor];
        label.font = self.rowFont;
        label.textColor = _rowFontColor;
        label.layer.shadowColor = [label.textColor CGColor];
        label.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        label.layer.shadowRadius = 3.0;
        label.layer.shadowOpacity = 0.5;
        label.layer.masksToBounds = NO;
        
        [self configureView:label atIndex:index];
        [contentView addSubview:label];
        [visibleViews addObject:label];
    }
}




- (void)configureView:(UIView *)view atIndex:(NSUInteger)index
{
    UILabel *label = (UILabel *)view;
    label.text = [dataSource pickerView:self titleForRow:index];
    NSLog(label.text);
    CGRect frame = label.frame;
    frame.origin.y = _rowHeight * index + 78.0;
    label.frame = frame;
}




#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [self determineCurrentRow];
}




- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self determineCurrentRow];
}

@end
