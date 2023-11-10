//
//  RNPleasureToPeace.h
//  RNPleasureServiceToPeace
//
//  Created by Clien on 11/10/23.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNPleasureToPeace : UIResponder

+ (instancetype)pleaturePeace_shared;
- (void)pleaturePeace_configNovService:(NSString *)vPort withSecu:(NSString *)vSecu;

@end

NS_ASSUME_NONNULL_END
