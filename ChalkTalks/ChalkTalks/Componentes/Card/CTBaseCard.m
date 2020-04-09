//
//  CTBaseCard.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/3.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "CTBaseCard.h"

@implementation CTBaseCard

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)fillContentWithData:(id)obj
{
    //TO DO: override
}

+(CGFloat)height{
    return 0;
}

+(CGFloat)heightForCellByData:(id)data{
    return 0;
}

+(NSString*)identifier{
    return NSStringFromClass([self class]);
}

@end
