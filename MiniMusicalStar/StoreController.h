//
//  StoreController.h
//  MiniMusicalStar
//
//  Created by Lee Jun Kit on 5/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface StoreController : NSObject <SKPaymentTransactionObserver>

@property (assign, nonatomic) id delegate;
@property (retain, nonatomic) NSMutableDictionary *activeTransactions;

- (void)clearTransactionQueue;

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void)completeTransaction: (SKPaymentTransaction *)transaction;
- (void)failedTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void)recordTransaction: (SKPaymentTransaction *)transaction;
- (void) provideContent: (NSString *)productIdentifier;
- (void) finishTransactionForProductIdentifier: (NSString *)productIdentifier;

@end
