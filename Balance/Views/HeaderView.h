//
//  HeaderView.h
//  Balance
//
//  Created by Chris Nolet on 5/12/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

@interface HeaderView : UIView

@property (strong, nonatomic) IBOutlet UIView *balanceView;
@property (strong, nonatomic) IBOutlet UILabel *balanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

+ (instancetype)viewWithDefaultNib;

@end
