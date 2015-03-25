//
// Created by Nathan  Pahucki on 9/11/14.
// Copyright (c) 2015 InfantIQ.. All rights reserved.
//

#import <objc/runtime.h>
#import "InAppPurchaseHelper.h"
#import "InAppPurchaseAlertView.h"
#import "NSError+AsDictionary.h"
#import "NSMutableDictionary+JSON.h"

static NSDictionary *productInfoForProduct(DDProduct product) {
    static NSArray *productCodes;
    if (!productCodes) {
        productCodes = @[
                @{@"id" : @"none"},
                @{@"id" : @"com.dataparenting.AdRemoval_1", @"type" : @(DDProductSalesTypeOneTime)},
                @{@"id" : @"com.dataparenting.VideoUpgrade_1", @"type" : @(DDProductSalesTypeSubscription)}];
    }
    return productCodes[product];
}


