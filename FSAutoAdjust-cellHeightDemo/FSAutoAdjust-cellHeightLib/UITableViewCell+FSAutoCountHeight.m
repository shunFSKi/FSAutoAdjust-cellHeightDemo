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
@property (nonatomic, strong) NSMutableDictionary *cacheDic;
@property (nonatomic, assign) BOOL isIndexPath;
@end

@implementation UITableView (FSAutoCountHeight)

+ (void)load
{
    SEL selectors[] = {
        @selector(reloadData),
        @selector(insertSections:withRowAnimation:),
        @selector(deleteSections:withRowAnimation:),
        @selector(reloadSections:withRowAnimation:),
        @selector(moveSection:toSection:),
        @selector(insertRowsAtIndexPaths:withRowAnimation:),
        @selector(deleteRowsAtIndexPaths:withRowAnimation:),
        @selector(reloadRowsAtIndexPaths:withRowAnimation:),
        @selector(moveRowAtIndexPath:toIndexPath:)
    };
    
    for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([@"FS_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
        ReplaceMethod(self, originalSelector, swizzledSelector);
    }
}

#pragma mark setter/getter
- (void)setCacheDic:(NSMutableArray *)cacheDic
{
    objc_setAssociatedObject(self, @selector(cacheDic), cacheDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)cacheDic
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setIsIndexPath:(BOOL)isIndexPath
{
    objc_setAssociatedObject(self, @selector(isIndexPath), @(isIndexPath), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isIndexPath
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

#pragma mark exchangeVoid
- (void)FS_reloadData
{
    if (self.cacheDic&&self.isIndexPath) {
        [self.cacheDic removeAllObjects];
    }
    [self FS_reloadData];
}

- (void)FS_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.cacheDic&&sections&&self.isIndexPath) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            [self.cacheDic removeObjectForKey:@(idx).stringValue];
            NSMutableDictionary *dic = self.cacheDic;
            [dic removeAllObjects];
        }];
    }
    [self FS_reloadSections:sections withRowAnimation:animation];
}

- (void)FS_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.cacheDic&&indexPaths&&self.isIndexPath) {
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *sectionCacheKey = @(obj.section).stringValue;
            NSMutableDictionary *rowCacheDic = self.cacheDic[sectionCacheKey];
            if (rowCacheDic) {
                [rowCacheDic removeObjectForKey:@(obj.row).stringValue];
            }
        }];
    }
    [self FS_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)FS_moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    [self FS_moveSection:section toSection:newSection];
}

- (void)FS_moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    [self FS_moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)FS_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self FS_insertSections:sections withRowAnimation:animation];
}

- (void)FS_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self FS_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)FS_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self FS_deleteSections:sections withRowAnimation:animation];
}

- (void)FS_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self FS_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

@end


@implementation UITableViewCell (FSAutoCountHeightCell)

+ (CGFloat)FSCellHeightForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cellContentViewWidth:(CGFloat)contentViewWidth
{
    tableView.isIndexPath = YES;
    if (!tableView.cacheDic) {
        tableView.cacheDic = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary *sectionCacheDic = tableView.cacheDic;
    
    NSString *sectionCacheKey = @(indexPath.section).stringValue;
    NSString *rowCacheKey = @(indexPath.row).stringValue;
    
    NSMutableDictionary *rowCacheDic = sectionCacheDic[sectionCacheKey];
    if (!rowCacheDic) {
        rowCacheDic = [NSMutableDictionary dictionary];
        [tableView.cacheDic setObject:rowCacheDic forKey:sectionCacheKey];
    }else {
        CGFloat cellHeight = 0;
        NSNumber *height = rowCacheDic[rowCacheKey];
        if (height) {
            cellHeight = height.floatValue;
            return cellHeight;
        }
    }
    
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
    [rowCacheDic setValue:@(cellHeight) forKey:rowCacheKey];
    
    return cellHeight;
}

@end
