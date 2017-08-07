//
//  UITableViewCell+FSAutoCountHeight.m
//  FSAutoAdjust-cellHeightDemo
//
//  Created by huim on 2017/7/7.
//  Copyright © 2017年 shunFSKi. All rights reserved.
//

#import "UITableViewCell+FSAutoCountHeight.h"
#import <objc/runtime.h>
#define ScreenScale ([[UIScreen mainScreen] scale])

CG_INLINE CGFloat
flatSpecificScale(CGFloat floatValue, CGFloat scale) {
    scale = scale == 0 ? ScreenScale : scale;
    CGFloat flattedValue = ceil(floatValue * scale) / scale;
    return flattedValue;
}

CG_INLINE CGFloat
flat(CGFloat floatValue) {
    return flatSpecificScale(floatValue, 0);
}

CG_INLINE CGRect
CGRectSetWidth(CGRect rect, CGFloat width) {
    rect.size.width = flat(width);
    return rect;
}

CG_INLINE void
ReplaceMethod(Class _class, SEL _originSelector, SEL _newSelector) {
    Method oriMethod = class_getInstanceMethod(_class, _originSelector);
    Method newMethod = class_getInstanceMethod(_class, _newSelector);
    BOOL isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}

@interface UITableView (FSAutoCountHeight)
@property (nonatomic, strong) NSMutableDictionary *keyCacheDic_Portrait;
@property (nonatomic, strong) NSMutableDictionary *keyCacheDic_Landscape;
@property (nonatomic, strong) NSMutableArray *indexCacheArr_Portrait;
@property (nonatomic, strong) NSMutableArray *indexCacheArr_Landscape;
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
- (NSMutableDictionary *)keyCacheDicForCurrentOrientation
{
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.keyCacheDic_Portrait: self.keyCacheDic_Landscape;
}

- (void)setKeyCacheDic_Portrait:(NSMutableDictionary *)keyCacheDic_Portrait
{
    objc_setAssociatedObject(self, @selector(keyCacheDic_Portrait), keyCacheDic_Portrait, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)keyCacheDic_Portrait
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setKeyCacheDic_Landscape:(NSMutableDictionary *)keyCacheDic_Landscape
{
    objc_setAssociatedObject(self, @selector(keyCacheDic_Landscape), keyCacheDic_Landscape, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)keyCacheDic_Landscape
{
    return objc_getAssociatedObject(self, _cmd);
}

- (NSMutableArray *)indexCacheArrForCurrentOrientation
{
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.indexCacheArr_Portrait: self.indexCacheArr_Landscape;
}

- (void)setIndexCacheArr_Portrait:(NSMutableArray *)indexCacheArr_Portrait
{
    objc_setAssociatedObject(self, @selector(indexCacheArr_Portrait), indexCacheArr_Portrait, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)indexCacheArr_Portrait
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setIndexCacheArr_Landscape:(NSMutableArray *)indexCacheArr_Landscape
{
    objc_setAssociatedObject(self, @selector(indexCacheArr_Landscape), indexCacheArr_Landscape, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)indexCacheArr_Landscape
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
    if (self.indexCacheArrForCurrentOrientation&&self.isIndexPath) {
        [self.indexCacheArrForCurrentOrientation removeAllObjects];
    }
    [self FS_reloadData];
}

- (void)FS_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.indexCacheArrForCurrentOrientation&&sections&&self.isIndexPath) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < self.indexCacheArrForCurrentOrientation.count) {
                [self.indexCacheArrForCurrentOrientation[idx] removeAllObjects];
            }
        }];
    }
    [self FS_reloadSections:sections withRowAnimation:animation];
}

- (void)FS_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.indexCacheArrForCurrentOrientation&&indexPaths&&self.isIndexPath) {
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.section < self.indexCacheArrForCurrentOrientation.count) {
                NSMutableArray *rowCacheArr = self.indexCacheArrForCurrentOrientation[obj.section];
                if (obj.row < rowCacheArr.count) {
                    rowCacheArr[obj.row] = @-1;
                }
            }
        }];
    }
    [self FS_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)FS_moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    if (self.isIndexPath && self.indexCacheArrForCurrentOrientation) {
        if (section < self.indexCacheArrForCurrentOrientation.count && newSection < self.indexCacheArrForCurrentOrientation.count) {
            [self.indexCacheArrForCurrentOrientation exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }
    }
    [self FS_moveSection:section toSection:newSection];
}

- (void)FS_moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.isIndexPath && self.indexCacheArrForCurrentOrientation) {
        if (indexPath.section < self.indexCacheArrForCurrentOrientation.count && newIndexPath.section < self.indexCacheArrForCurrentOrientation.count) {
            NSMutableArray<NSNumber *> *indexPathRows = self.indexCacheArrForCurrentOrientation[indexPath.section];
            NSMutableArray<NSNumber *> *newIndexPathRows = self.indexCacheArrForCurrentOrientation[newIndexPath.section];
            if (indexPath.row < indexPathRows.count && newIndexPath.row < newIndexPathRows.count) {
                NSNumber *indexValue = indexPathRows[indexPath.row];
                NSNumber *newIndexValue = newIndexPathRows[newIndexPath.row];
                indexPathRows[indexPath.row] = newIndexValue;
                newIndexPathRows[newIndexPath.row] = indexValue;
            }
        }
    }
    [self FS_moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)FS_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.isIndexPath && self.indexCacheArrForCurrentOrientation) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx <= self.indexCacheArrForCurrentOrientation.count) {
                [self.indexCacheArrForCurrentOrientation insertObject:[NSMutableArray array] atIndex:idx];
            }
        }];
    }
    [self FS_insertSections:sections withRowAnimation:animation];
}

- (void)FS_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.isIndexPath && self.indexCacheArrForCurrentOrientation) {
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.section < self.indexCacheArrForCurrentOrientation.count) {
                NSMutableArray<NSNumber *> *rowCacheArr = self.indexCacheArrForCurrentOrientation[obj.section];
                if (obj.row <= rowCacheArr.count) {
                    [rowCacheArr insertObject:@-1 atIndex:obj.row];
                }
            }
        }];
    }
    [self FS_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)FS_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.isIndexPath && self.indexCacheArrForCurrentOrientation) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < self.indexCacheArrForCurrentOrientation.count) {
                [self.indexCacheArrForCurrentOrientation removeObjectAtIndex:idx];
            }
        }];
    }
    [self FS_deleteSections:sections withRowAnimation:animation];
}

- (void)FS_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.isIndexPath && self.indexCacheArrForCurrentOrientation) {
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.section < self.indexCacheArrForCurrentOrientation.count) {
                NSMutableArray<NSNumber *> *rowCacheArr = self.indexCacheArrForCurrentOrientation[obj.section];
                if (obj.row < rowCacheArr.count) {
                    [rowCacheArr removeObjectAtIndex:obj.row];
                }
            }
        }];
    }
    [self FS_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

@end


@implementation UITableViewCell (FSAutoCountHeightCell)

- (void)setFS_cellBottomViews:(NSArray *)FS_cellBottomViews {
    objc_setAssociatedObject(self,
                             @selector(FS_cellBottomViews),
                             FS_cellBottomViews,
                             OBJC_ASSOCIATION_COPY);
}

- (NSArray *)FS_cellBottomViews {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFS_cellBottomView:(UIView *)FS_cellBottomView {
    objc_setAssociatedObject(self,
                             @selector(FS_cellBottomView),
                             FS_cellBottomView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)FS_cellBottomView {
    return objc_getAssociatedObject(self, _cmd);
}

+ (CGFloat)FSCellHeightForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cellContentViewWidth:(CGFloat)contentViewWidth bottomOffset:(CGFloat)bottomOffset
{
    if (!indexPath) {
        return 0;
    }
    tableView.isIndexPath = YES;
    if (!tableView.indexCacheArr_Portrait) {
        tableView.indexCacheArr_Portrait = [NSMutableArray array];
    }
    if (!tableView.indexCacheArr_Landscape) {
        tableView.indexCacheArr_Landscape = [NSMutableArray array];
    }
    
    for (NSInteger sectionIndex = 0; sectionIndex <= indexPath.section; sectionIndex++) {
        if (sectionIndex >= tableView.indexCacheArrForCurrentOrientation.count) {
            tableView.indexCacheArrForCurrentOrientation[sectionIndex] = [NSMutableArray array];
        }
    }
    NSMutableArray *rowCacheArr = tableView.indexCacheArrForCurrentOrientation[indexPath.section];
    for (NSInteger rowIndex = 0; rowIndex <= indexPath.row; rowIndex++) {
        if (rowIndex >= rowCacheArr.count) {
            rowCacheArr[rowIndex] = @-1;
        }
    }
    
    if (![tableView.indexCacheArrForCurrentOrientation[indexPath.section][indexPath.row] isEqualToNumber:@-1]) {
        CGFloat cellHeight = 0;
        NSNumber *heightNumber = tableView.indexCacheArrForCurrentOrientation[indexPath.section][indexPath.row];
        cellHeight = heightNumber.floatValue;
        return cellHeight;
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
    if (cell.FS_cellBottomView) {
        cellBottomView = cell.FS_cellBottomView;
    }else if (cell.FS_cellBottomViews && cell.FS_cellBottomViews.count > 0) {
        cellBottomView = cell.FS_cellBottomViews[0];
        for (UIView *view in cell.FS_cellBottomViews) {
            if (CGRectGetMaxY(view.frame) > CGRectGetMaxY(cellBottomView.frame)) {
                cellBottomView = view;
            }
        }
    }else {
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
    }
    
    CGFloat cellHeight = CGRectGetMaxY(cellBottomView.frame) + bottomOffset;
    
    tableView.indexCacheArrForCurrentOrientation[indexPath.section][indexPath.row] = @(cellHeight);
    return cellHeight;
}


+ (CGFloat)FSCellHeightForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cacheKey:(NSString *)cacheKey cellContentViewWidth:(CGFloat)contentViewWidth bottomOffset:(CGFloat)bottomOffset
{
    if (!indexPath || !cacheKey) {
        return 0;
    }
    tableView.isIndexPath = NO;
    if (!tableView.keyCacheDic_Portrait) {
        tableView.keyCacheDic_Portrait = [NSMutableDictionary dictionary];
    }
    if (!tableView.keyCacheDic_Landscape) {
        tableView.keyCacheDic_Landscape = [NSMutableDictionary dictionary];
    }
    NSNumber *cacheHeight = tableView.keyCacheDicForCurrentOrientation[cacheKey];
    if (cacheHeight != nil) {
        CGFloat cellHeight = 0;
        cellHeight = cacheHeight.floatValue;
        return cellHeight;
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
    if (cell.FS_cellBottomView) {
        cellBottomView = cell.FS_cellBottomView;
    }else if (cell.FS_cellBottomViews && cell.FS_cellBottomViews.count > 0) {
        cellBottomView = cell.FS_cellBottomViews[0];
        for (UIView *view in cell.FS_cellBottomViews) {
            if (CGRectGetMaxY(view.frame) > CGRectGetMaxY(cellBottomView.frame)) {
                cellBottomView = view;
            }
        }
    }else {
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
    }
    
    CGFloat cellHeight = CGRectGetMaxY(cellBottomView.frame) + bottomOffset;
    [tableView.keyCacheDicForCurrentOrientation setValue:@(cellHeight) forKey:cacheKey];
    return cellHeight;
}

@end
