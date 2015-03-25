//
// Created by Nathan  Pahucki on 9/11/14.
// Copyright (c) 2015 InfantIQ.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


typedef enum _DDProduct : NSUInteger {
    DDProductNone = 0,
    DDProductAdRemoval,
    DDProductVideoSupport
} DDProduct;

typedef enum _DDProductSalesType : NSUInteger {
    DDProductSalesTypeOneTime = 0,
    DDProductSalesTypeSubscription
} DDProductSalesType;



