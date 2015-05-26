//
//  CBFakeLocationTableViewCell.h
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 10/15/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

@interface CBFakeLocationTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *title;

- (void)showCheck;
- (void)hideCheck;

@end
