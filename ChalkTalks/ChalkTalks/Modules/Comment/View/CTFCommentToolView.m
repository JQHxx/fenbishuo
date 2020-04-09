//
//  CTFCommentToolView.m
//  ChalkTalks
//
//  Created by vision on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFCommentToolView.h"
#import <UITextView+Placeholder.h>
#import "NSString+Size.h"

@interface CTFCommentToolView ()<UITextViewDelegate>

///遮罩层
@property (nonatomic,strong) UIView    *maskLayer;
@property (nonatomic,strong) UILabel   *titleLab;
@property (nonatomic,strong) UITextView  *commentTextView;
@property (nonatomic,strong) UIButton  *submitButton; //发布
@property (nonatomic,strong) UILabel   *textLab;
@property (nonatomic,assign) CGFloat   myOriginY;

@property (nonatomic,assign) CTFInputToolViewType myType;
@property (nonatomic, copy ) NSString  *authorName;
@property (nonatomic,assign) BOOL      isAuthor;
@property (nonatomic,assign) NSInteger  textLimit;
@property (nonatomic, copy ) SubmitCommentBlock submitBlock;
@property (nonatomic, copy ) DismissBlock dismissBlock;

@property (nonatomic,assign) BOOL  firstIn;

@end

@implementation CTFCommentToolView

-(instancetype)initWithFrame:(CGRect)frame
                        type:(CTFInputToolViewType)type
                    isAuthor:(BOOL)isAuthor
                        name:(NSString *)name
                     content:(NSString *)content
                 submitBlock:(SubmitCommentBlock)submitBlock
                dismissBlock:(DismissBlock)dismissBlock {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.myType = type;
        self.isAuthor = isAuthor;
        self.authorName = name;
        self.textLimit = type == CTFInputToolViewTypeAudioImage ? 40 : 200;
        self.submitBlock = submitBlock;
        self.dismissBlock = dismissBlock;
        
        self.firstIn = YES;
        
        [self setupUI];
        
        self.commentTextView.text = content;
        [self updateCommentToolUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toolBarKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
    }
    return self;
}

#pragma mark 显示评论输入框
+ (void)showCommentInputViewWithFrame:(CGRect)frame
                                 type:(CTFInputToolViewType)type
                             isAuthor:(BOOL)isAuthor
                                 name:(NSString *)authorName
                              content:(NSString *)content
                               submit:(SubmitCommentBlock)submitBlock
                              dismiss:(DismissBlock)dismissBlock {
    CTFCommentToolView *aView = [[CTFCommentToolView alloc] initWithFrame:frame type:type isAuthor:isAuthor name:authorName content:content submitBlock:submitBlock dismissBlock:dismissBlock];
    [aView commentToolShow];
}

#pragma mark
#pragma mark 显示
- (void)commentToolShow {
    [self addMaskLayer];
    [kKeyWindow addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.frame;
        frame.origin.y -= (self.myType == CTFInputToolViewTypeAudioImage ? 127 : 157);
        self.frame = frame;
        [self.commentTextView becomeFirstResponder];
    } completion:^(BOOL finished) {
        self.myOriginY = self.frame.origin.y;
        [self observeTextViewHeight];
    }];
}

#pragma mark 隐藏
- (void)commentToolHide {
    [self.commentTextView resignFirstResponder];
    
    //移除弹出框
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = kScreen_Height;
        self.frame = frame;
        kKeyWindow.userInteractionEnabled = NO;
    } completion:^(BOOL finished) {
        kKeyWindow.userInteractionEnabled = YES;
        // 移除遮罩
        if (self.maskLayer) {
            [self.maskLayer removeFromSuperview];
            self.maskLayer = nil;
        }
        [self removeFromSuperview];
    }];
}

#pragma mark -- NSNotification
- (void)toolBarKeyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect frame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect currentFrame = self.frame;
    [UIView animateWithDuration:0.3 animations:^{
        //输入框最终的位置
        CGRect resultFrame;
        if (frame.origin.y == kScreen_Height) {
            resultFrame = CGRectMake(currentFrame.origin.x, kScreen_Height - currentFrame.size.height, currentFrame.size.width, currentFrame.size.height);
        } else {
            resultFrame = CGRectMake(currentFrame.origin.x,kScreen_Height - currentFrame.size.height - frame.size.height, currentFrame.size.width, currentFrame.size.height);
        }
        self.frame = resultFrame;
        
        CGFloat contentH = [self getViewDynamicHeight];
        if (contentH > 67) {
            self.myOriginY = self.frame.origin.y + contentH - 67;
        } else {
            self.myOriginY = self.frame.origin.y;
        }
    }];
}

#pragma mark UITextViewDelegate
#pragma mark - UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@" "] && textView.text.length <= 0){
        //首字不可以是空格
        return NO;
    }
    return YES;
}

#pragma mark  监听输入变化
- (void)textViewDidChange:(UITextView *)textView {
    self.firstIn = NO;
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) return;
    
    //高度动态变化
    [self observeTextViewHeight];
    [self updateCommentToolUI];
}

#pragma mark -- Event response
#pragma mark 发布评论
- (void)submitCommentAction:(UIButton *)sender {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *content = [self.commentTextView.text stringByTrimmingCharactersInSet:set];
    if (kIsEmptyString(content)) {
        [self makeToast:@"评论内容不能为空"];
        return;
    }
    [self commentToolHide];
    if (self.submitBlock) {
        self.submitBlock(content);
    }
}

#pragma mark
- (void)dismissAction{
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *content = [self.commentTextView.text stringByTrimmingCharactersInSet:set];
    if (self.dismissBlock) {
        self.dismissBlock(content);
    }
    [self commentToolHide];
}

#pragma mark -- Private methods
#pragma mark 添加遮罩
- (void)addMaskLayer{
    _maskLayer = [UIView new];
    [_maskLayer setFrame:[[UIScreen mainScreen] bounds]];
    [_maskLayer setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.60]];
    [_maskLayer addTapPressed:@selector(dismissAction) target:self];
    [kKeyWindow  addSubview:_maskLayer];
}

#pragma mark 更新UI
- (void)updateCommentToolUI {
    if (self.myType == CTFInputToolViewTypeComment) {
        NSString *headStr = self.isAuthor?@"评论给":@"正在回复";
        NSString *nameStr =  [NSString stringWithFormat:@"%@ %@ %@", headStr,self.authorName,self.isAuthor?@"(作者)":@""];
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:nameStr];
        [attributeStr addAttributes:@{NSFontAttributeName: [UIFont mediumFontWithSize:14]} range:NSMakeRange(headStr.length, nameStr.length-headStr.length)];
        self.titleLab.attributedText = attributeStr;
    }
    
    NSString *content = self.commentTextView.text;
    if (content.length > self.textLimit) {
        if (self.submitButton) {
            self.submitButton.enabled = NO;
        }
        self.textLab.text = [NSString stringWithFormat:@"已超出%ld个字",content.length - self.textLimit];
        self.textLab.textColor = UIColorFromHEX(0xFF5757);
    } else {
        self.textLab.text = [NSString stringWithFormat:@"%ld/%ld",content.length,self.textLimit];
        self.textLab.textColor = [UIColor ctColor99];
        if (self.submitButton) {
            self.submitButton.enabled = !kIsEmptyString(content);
        }
    }
}

#pragma mark 动态变化高度
- (void)observeTextViewHeight {
    CGFloat contentH = [self getViewDynamicHeight];
    CGFloat orginY = 0.0;
    if (contentH > 67) {
        orginY = self.myOriginY - (contentH - 67);
    } else {
        orginY = self.myOriginY;
    }
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(orginY);
        make.left.right.mas_equalTo(0);
    }];
    
    [self.commentTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(self.myType == CTFInputToolViewTypeAudioImage ? 10 : 40);
        make.height.mas_equalTo(contentH);
    }];
    
    //一行高度
    CGFloat oneLineHeight = [@"111111" boundingRectWithSize:CGSizeMake(kScreen_Width - 36, CGFLOAT_MAX) withTextFont:self.commentTextView.font].height;
    //10行高度
    CGFloat maxHeight = oneLineHeight * 10;
    CGFloat textHeight = [self.commentTextView.text boundingRectWithSize:CGSizeMake(kScreen_Width - 36, CGFLOAT_MAX) withTextFont:self.commentTextView.font].height;
    if (self.firstIn && [UIDevice currentDevice].systemVersion.floatValue < 13.0 && textHeight > maxHeight) {
        [self.commentTextView scrollRangeToVisible:NSMakeRange(0, 0)];
        [self.commentTextView setContentOffset:CGPointMake(0, self.commentTextView.contentSize.height) animated:NO];
    }
}

#pragma mark 计算动态高度
- (CGFloat)getViewDynamicHeight {
    //一行高度
    CGFloat oneLineHeight = [@"111111" boundingRectWithSize:CGSizeMake(kScreen_Width - 36, CGFLOAT_MAX) withTextFont:self.commentTextView.font].height;
    //10行高度
    CGFloat maxHeight = oneLineHeight * 10;
    CGFloat textHeight = [self.commentTextView.text boundingRectWithSize:CGSizeMake(kScreen_Width - 36, CGFLOAT_MAX) withTextFont:self.commentTextView.font].height;
    if (textHeight > 0) {
        CGFloat contentH = 0;
        if (textHeight < 67) {
            contentH = 67 ;
        } else if (textHeight > maxHeight) {
            contentH = maxHeight;
        } else {
            contentH = textHeight;
        }
        return contentH;
    } else {
        return 67;
    }
}

#pragma mark 初始化界面
- (void)setupUI {
    if (self.myType == CTFInputToolViewTypeAudioImage) {
        [self addSubview:self.commentTextView];
        [self.commentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-20);
            make.height.mas_equalTo(67);
        }];
        
        [self addSubview:self.textLab];
        [self.textLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.commentTextView.mas_bottom).offset(10);
            make.right.mas_equalTo(-10);
            make.height.mas_equalTo(32);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
        }];
    } else {
        [self addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(15);
            make.left.right.mas_equalTo(16);
            make.height.mas_equalTo(20);
        }];
        
        [self addSubview:self.commentTextView];
        [self.commentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLab.mas_bottom).offset(5);
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-20);
            make.height.mas_equalTo(67);
        }];
        
        [self addSubview:self.submitButton];
        [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-16);
            make.top.mas_equalTo(self.commentTextView.mas_bottom).offset(10);
            make.size.mas_equalTo(CGSizeMake(32, 32));
            make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
        }];
        
        [self addSubview:self.textLab];
        [self.textLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.commentTextView.mas_bottom).offset(20);
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(self.submitButton.mas_left).offset(-10);
        }];
    }
}

#pragma mark -- Getters
#pragma mark 标题
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont regularFontWithSize:14.0];
        _titleLab.textColor = [UIColor ctColor99];
        _titleLab.text = @"评论给";
    }
    return _titleLab;
}

#pragma mark 评论
- (UITextView*)commentTextView {
    if (!_commentTextView) {
        _commentTextView = [[UITextView alloc] init];
        _commentTextView.delegate = self;
        _commentTextView.font = [UIFont regularFontWithSize:16.0];
        _commentTextView.textColor = [UIColor ctColor33];
        _commentTextView.textContainerInset = UIEdgeInsetsZero;
        _commentTextView.textContainer.lineFragmentPadding = 0;
        
        NSString *str = @"友善的评论是交流的起点";
        NSDictionary *attributeDict = @{NSFontAttributeName:[UIFont regularFontWithSize:16.0],NSForegroundColorAttributeName:[UIColor ctColorC2]};
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:str];
        [attributeStr addAttributes:attributeDict range:NSMakeRange(0, str.length)];
        _commentTextView.attributedPlaceholder = attributeStr;
    }
    return _commentTextView;
}

#pragma mark 字数统计
- (UILabel *)textLab {
    if (!_textLab) {
        _textLab = [[UILabel alloc] init];
        _textLab.font = [UIFont regularFontWithSize:12];
        _textLab.textColor = [UIColor ctColor99];
    }
    return _textLab;
}

#pragma mark 发布
- (UIButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [[UIButton alloc] init];
        [_submitButton setTitle:@"发布" forState:UIControlStateNormal];
        [_submitButton setTitleColor:[UIColor ctMainColor] forState:UIControlStateNormal];
        [_submitButton setTitleColor:UIColorFromHEXWithAlpha(0xFF6885, 0.6f) forState:UIControlStateDisabled];
        [_submitButton doBorderWidth:0 color:nil cornerRadius:16];
        _submitButton.titleLabel.font = [UIFont mediumFontWithSize:16.0];
        [_submitButton addTarget:self action:@selector(submitCommentAction:) forControlEvents:UIControlEventTouchUpInside];
        _submitButton.enabled = NO;
    }
    return _submitButton;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

@end
