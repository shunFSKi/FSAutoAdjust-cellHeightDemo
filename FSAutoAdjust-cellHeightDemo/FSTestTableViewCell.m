//
//  FSTestTableViewCell.m
//  FSAutoAdjust-cellHeightDemo
//
//  Created by 冯顺 on 2017/7/9.
//  Copyright © 2017年 shunFSKi. All rights reserved.
//

#import "FSTestTableViewCell.h"

@implementation FSTestTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLab = [[UILabel alloc]init];
        self.titleLab.font = [UIFont systemFontOfSize:15];
        [self.titleLab sizeToFit];
        [self.contentView addSubview:self.titleLab];
        
        self.contentLab = [[UILabel alloc]init];
        self.contentLab.font = [UIFont systemFontOfSize:15];
        [self.contentLab sizeToFit];
        self.contentLab.numberOfLines = 0;
        [self.contentView addSubview:self.contentLab];
        
        self.contentImageView = [[UIImageView alloc]init];
        [self.contentImageView sizeToFit];
        [self.contentView addSubview:self.contentImageView];
        
        self.nameLab = [[UILabel alloc]init];
        self.nameLab.font = [UIFont systemFontOfSize:14];
        [self.nameLab sizeToFit];
        [self.contentView addSubview:self.nameLab];
        
        self.timeLab = [[UILabel alloc]init];
        self.timeLab.font = [UIFont systemFontOfSize:14];
        [self.timeLab sizeToFit];
        [self.contentView addSubview:self.timeLab];
        
        {
            [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView.mas_top).with.offset(5);
                make.left.equalTo(self.contentView.mas_left).with.offset(10);
                make.right.lessThanOrEqualTo(self.contentView.mas_right).with.offset(-10);
            }];
            
            [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.titleLab.mas_bottom).with.offset(10);
                make.left.mas_equalTo(self.titleLab);
                make.right.lessThanOrEqualTo(self.contentView.mas_right).with.offset(-10);
            }];
            
            [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentLab.mas_bottom).with.offset(10);
                make.left.mas_equalTo(self.contentLab);
            }];
            
            [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentImageView.mas_bottom).with.offset(10);
                make.left.mas_equalTo(self.titleLab);
            }];
            
            [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.nameLab);
                make.right.equalTo(self.contentView.mas_right).with.offset(-10);
            }];
        }
    }
    return self;
}

- (void)setEntity:(FDFeedEntity *)entity
{
    self.titleLab.backgroundColor = randomColor;
    self.contentLab.backgroundColor = randomColor;
    self.contentImageView.backgroundColor = randomColor;
    self.nameLab.backgroundColor = randomColor;
    self.timeLab.backgroundColor = randomColor;
    
    self.titleLab.text = entity.title;
    self.contentLab.text = entity.content;
    self.contentImageView.image = [UIImage imageNamed:entity.imageName];
    self.nameLab.text = entity.username;
    self.timeLab.text = entity.time;
    
}

@end
