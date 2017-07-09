//
//  UITableViewCell+FSAutoCountHeight.m
//  FSAutoAdjust-cellHeightDemo
//
//  Created by huim on 2017/7/7.
//  Copyright © 2017年 shunFSKi. All rights reserved.
//

#import "UITableViewCell+FSAutoCountHeight.h"
#import "FSCellCommenDefine.h"
@interface UITableView (FSAutoCountHeight)
@property (nonatomic, strong) NSMutableArray *cacheArr;
@end
@implementation UITableView (FSAutoCountHeight)
- (void)setCacheArr:(NSMutableArray *)cacheArr
{
    objc_setAssociatedObject(self, @selector(cacheArr), cacheArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)cacheArr
{
    return objc_getAssociatedObject(self, _cmd);
}
@end


@implementation UITableViewCell (FSAutoCountHeightCell)

+ (CGFloat)FSCellHeightForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cellContentViewWidth:(CGFloat)contentViewWidth
{
    
    UITableViewCell *cell = [tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    if (contentViewWidth == 0) {
        [tableView layoutIfNeeded];
        contentViewWidth = CGRectGetWidth(tableView.frame);
    }
    if (contentViewWidth == 0) {
        return 0;
    }
    cell.frame = CGRectSetWidth(cell.frame, contentViewWidth);
    cell.contentView.frame = CGRectSetWidth(cell.contentView.frame, CGRectGetWidth(tableView.frame));
    [cell layoutIfNeeded];
    
    UIView *cellBottomView = nil;
    NSArray *contentViewSubViews = cell.contentView.subviews;
    if (contentViewSubViews.count == 0) {
        cellBottomView = cell.contentView;
    }else{
        cellBottomView = contentViewSubViews[0];
        for (UIView *view in contentViewSubViews) {
            if (CGRectGetMaxY(view.frame) > CGRectGetMaxY(cellBottomView.frame)) {
                cellBottomView = view;
            }
        }
    }
    CGFloat cellHeight = CGRectGetMaxY(cellBottomView.frame);
    
    return cellHeight;
}

@end
