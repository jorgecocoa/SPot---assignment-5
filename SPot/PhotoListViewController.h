//
//  PhotoListViewController.h
//  SPot
//
//  Created by Jorge García-Luengo on 08/03/13.
//  Copyright (c) 2013 Jorge García-Luengo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoListViewController : UITableViewController

@property (nonatomic, strong) NSArray *photos;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
- (NSString *)titleForRow:(NSInteger)row;
- (NSString *)subtitleForRow:(NSInteger)row;

@end
