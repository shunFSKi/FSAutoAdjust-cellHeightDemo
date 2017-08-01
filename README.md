# FSAutoAdjust-cellHeightDemo
cell行高自适应，一句代码搞定需求，丝滑般顺畅的滚动体验
## API
支持两种缓存方式
```objc
/**
 cell自动计算行高

 @param tableView tableView
 @param indexPath indexPath
 @param contentViewWidth cell内容宽度，不确定可传0
 @return cell高度
 */
+ (CGFloat)FSCellHeightForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cellContentViewWidth:(CGFloat)contentViewWidth bottomOffset:(CGFloat)bottomOffset;
```
```objc
/**
 cell自动计算行高优化版

 @param tableView tableView
 @param indexPath indexPath
 @param cacheKey 当前cell唯一标识符
 @param contentViewWidth cell内容宽度，不确定可传0
 @return cell高度
 */
+ (CGFloat)FSCellHeightForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cacheKey:(NSString *)cacheKey cellContentViewWidth:(CGFloat)contentViewWidth bottomOffset:(CGFloat)bottomOffset;
```
## How To Use
1、将demo中的`FSAutoAdjust-cellHeightLib`拖入项目中导入`#import "UITableViewCell+FSAutoCountHeight.h"`；

2、后续支持cocoapods，静候佳音；
```objc
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSEntity *entity = _datas[indexPath.row];
    CGFloat height = [self.title isEqualToString:@"keyCache"]?[FSTestTableViewCell FSCellHeightForTableView:tableView indexPath:indexPath cacheKey:entity.identifier cellContentViewWidth:0 bottomOffset:0]:[FSTestTableViewCell FSCellHeightForTableView:tableView indexPath:indexPath cellContentViewWidth:0 bottomOffset:0];
    return height;
}
```
详细请下载demo查看
## Document
writing...

文档正在努力编写中。。。
