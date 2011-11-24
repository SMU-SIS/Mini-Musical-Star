//
//  StoreController.m
//  MiniMusicalStar
//
//  Created by Lee Jun Kit on 5/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StoreController.h"

@implementation StoreController
@synthesize delegate, activeTransactions;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.activeTransactions = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    // Your application should implement these two methods.
    [self recordTransaction: transaction];
    [self provideContent: transaction.payment.productIdentifier];
    
    // save transaction into activeTransactions while the content downloads
    [self.activeTransactions setObject:transaction forKey:transaction.payment.productIdentifier];
    
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to complete purchase." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    
    [delegate performSelectorInBackground:@selector(cancelPurchaseOfShow:) withObject:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    NSLog(@"product identifier is %@", transaction.payment.productIdentifier);

}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    
}

- (void) recordTransaction: (SKPaymentTransaction *)transaction
{
    
}

- (void) provideContent: (NSString *)productIdentifier
{
    [self.delegate performSelectorOnMainThread:@selector(downloadMusical:) withObject:productIdentifier waitUntilDone:NO];
}

- (void) finishTransactionForProductIdentifier: (NSString *)productIdentifier
{
    SKPaymentTransaction *transaction = [self.activeTransactions objectForKey: productIdentifier];
    
    // Remove the transaction from the payment queue
    if (transaction)
    {
        //must check because there will not be a transaction object in activeTransactions if the user cancelled it before it has even started
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }
    
    
    [self.activeTransactions removeObjectForKey:productIdentifier];
}

@end
