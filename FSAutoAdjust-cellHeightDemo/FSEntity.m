//
//  FSEntity.m
//  FSAutoAdjust-cellHeightDemo
//
//  Created by 冯顺 on 2017/7/31.
//  Copyright © 2017年 shunFSKi. All rights reserved.
//

#import "FSEntity.h"

@implementation FSEntity

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = super.init;
    if (self) {
        _identifier = [self uniqueIdentifier];
        _title = dictionary[@"title"];
        _content = dictionary[@"content"];
        _username = dictionary[@"username"];
        _time = dictionary[@"time"];
        _imageName = dictionary[@"imageName"];
    }
    return self;
}

- (NSString *)uniqueIdentifier
{
    static NSInteger counter = 0;
    return [NSString stringWithFormat:@"unique-id-%@", @(counter++)];
}

@end
