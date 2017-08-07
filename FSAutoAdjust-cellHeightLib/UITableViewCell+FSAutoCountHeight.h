//
//  UITableViewCell+FSAutoCountHeight.h
//  FSAutoAdjust-cellHeightDemo
//
//  Created by huim on 2017/7/7.
//  Copyright © 2017年 shunFSKi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (FSAutoCountHeightCell)

/**
 cell底视图（提高计算效率，能传则传）
 */
@property (nonatomic , strong) UIView * FS_cellBottomView;

/**
 cell底视图数组（在不确定最下面的视图关系时，可以传入一个视图数组）
 */
@property (nonatomic , strong) NSArray * FS_cellBottomViews;

/**
 cell自动计算行高

 @param tableView tableView
 @param indexPath indexPath
 @param contentViewWidth cell内容宽度，不确定可传0
 @return cell高度
 */
+ (CGFloat)FSCellHeightForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cellContentViewWidth:(CGFloat)contentViewWidth bottomOffset:(CGFloat)bottomOffset;

/**
 cell自动计算行高优化版

 @param tableView tableView
 @param indexPath indexPath
 @param cacheKey 当前cell唯一标识符
 @param contentViewWidth cell内容宽度，不确定可传0
 @return cell高度
 */
+ (CGFloat)FSCellHeightForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cacheKey:(NSString *)cacheKey cellContentViewWidth:(CGFloat)contentViewWidth bottomOffset:(CGFloat)bottomOffset;

@end
