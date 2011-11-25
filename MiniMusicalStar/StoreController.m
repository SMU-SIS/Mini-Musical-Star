//
//  StoreController.m
//  MiniMusicalStar
//
//  Created by Lee Jun Kit on 5/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StoreController.h"
#import "MiniMusicalStarUtilities.h"
#import "ASIFormDataRequest.h"
#import "SBJSON.h"

#ifdef DEBUG
BOOL isBuiltDebug = YES;
#else
BOOL isBuiltDebug = NO;
#endif


@implementation StoreController
@synthesize delegate, activeTransactions;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.activeTransactions = [[NSMutableDictionary alloc] init];
        [self clearTransactionQueue];
    }
    
    return self;
}

- (void)clearTransactionQueue
{
    NSArray *transactions = [[SKPaymentQueue defaultQueue] transactions];
    for (SKPaymentTransaction *transaction in transactions)
    {
        NSLog(@"Transaction to be cleared is %@", transaction);
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
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
    BOOL verified = [self verifyTransactionWithServer: transaction];
    if (verified)
    {
        [self provideContent: transaction.payment.productIdentifier];
        
        // save transaction into activeTransactions while the content downloads
        [self.activeTransactions setObject:transaction forKey:transaction.payment.productIdentifier];
    }
    
    else
    {
        NSLog(@"Transaction cannot be verified.");
        [delegate performSelectorOnMainThread:@selector(displayTransactionUnverifiedErrorMessage) withObject:nil waitUntilDone:NO];
    }

    
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to complete purchase." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    
    else
    {
        //if the user has cancelled the payment
        [delegate performSelector:@selector(setPurchaseWasCancelled:) withObject:[NSNumber numberWithBool:YES]];
    }
    
    [delegate performSelectorInBackground:@selector(cancelPurchaseOfShow:) withObject:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    NSLog(@"product identifier is %@", transaction.payment.productIdentifier);

}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    //restoring transactions not implemented yet, instead get users to redownload for free
}

- (BOOL) verifyTransactionWithServer: (SKPaymentTransaction *)transaction
{
    //create the dictionary
//    NSDictionary *transactionDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                     [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"], @"device_uuid",
//                                     transaction.transactionIdentifier, @"transaction_identifier",
//                                     transaction.transactionDate, @"transaction_date",
//                                     transaction.payment.productIdentifier, @"product_identifier",
//                                     [MiniMusicalStarUtilities encodeBase64WithData:transaction.transactionReceipt], @"transaction_receipt",
//                                     nil];
    
    //post this to my server
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://mmsmusicalstore.appspot.com/receipts/new"]];
    [request setPostValue:[MiniMusicalStarUtilities encodeBase64WithData:transaction.transactionReceipt] forKey:@"transaction-receipt"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"] forKey:@"uuid"];
    if (isBuiltDebug)
    {
        [request setPostValue:@"debug" forKey:@"build"]; 
    }
    
    else
    {
        [request setPostValue:@"release" forKey:@"build"]; 
    }
    
    //start the request (synchronously haha)
    [request startSynchronous];
    NSError *error = [request error];
    if (!error)
    {
        NSString *response = [request responseString];
        NSDictionary *responseDict = [response JSONValue];
        
        NSString *verified = [responseDict objectForKey:@"verified"];
        if ([verified isEqualToString:@"true"])
        {
            return YES;
        }
        
        else
        {
            return NO;
        }
    }
    
    else
    {
        NSLog(@"Error communicating with MMS server");
    }
    
    return NO;
    
    
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
