//
//  AddItemViewController.h
//  iWish
//
//  Created by Elena Maso Willen on 01/06/2016.
//  Copyright © 2016 Elena. All rights reserved.
//

#import <UIKit/UIKit.h>

@class List;
@class Item;
@class WishDataStore;

@interface AddItemViewController : UIViewController

@property (nonatomic, strong) List *listSelected;
@property (nonatomic, strong) Item *itemSelected;
@property (nonatomic, strong) WishDataStore *dataStore;


@end
