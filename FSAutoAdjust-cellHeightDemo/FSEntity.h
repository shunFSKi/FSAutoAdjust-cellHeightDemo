//
//  FSEntity.h
//  FSAutoAdjust-cellHeightDemo
//
//  Created by 冯顺 on 2017/7/31.
//  Copyright © 2017年 shunFSKi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSEntity : NSObject
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *content;
@property (nonatomic, copy, readonly) NSString *username;
@property (nonatomic, copy, readonly) NSString *time;
@property (nonatomic, copy, readonly) NSString *imageName;
@end
