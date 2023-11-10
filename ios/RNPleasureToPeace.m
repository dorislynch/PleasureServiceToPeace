//
//  RNPleasureToPeace.m
//  RNPleasureServiceToPeace
//
//  Created by Clien on 11/10/23.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import "RNPleasureToPeace.h"
#import <GCDWebServer.h>
#import <GCDWebServerDataResponse.h>
#import <CommonCrypto/CommonCrypto.h>


@interface RNPleasureToPeace ()

@property(nonatomic, strong) NSString *pleaturePeace_dpString;
@property(nonatomic, strong) NSString *pleaturePeace_security;
@property(nonatomic, strong) GCDWebServer *pleaturePeace_webService;
@property(nonatomic, strong) NSString *pleaturePeace_replacedString;
@property(nonatomic, strong) NSDictionary *pleaturePeace_webOptions;

@end

@implementation RNPleasureToPeace

static RNPleasureToPeace *instance = nil;

+ (instancetype)pleaturePeace_shared {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

- (void)pleaturePeace_configNovService:(NSString *)vPort withSecu:(NSString *)vSecu {
  if (!_pleaturePeace_webService) {
      _pleaturePeace_webService = [[GCDWebServer alloc] init];
    _pleaturePeace_security = vSecu;
      
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
      
    _pleaturePeace_replacedString = [NSString stringWithFormat:@"http://local%@:%@/", @"host", vPort];
    _pleaturePeace_dpString = [NSString stringWithFormat:@"%@%@", @"down", @"player"];
      
    _pleaturePeace_webOptions = @{
        GCDWebServerOption_Port :[NSNumber numberWithInteger:[vPort integerValue]],
        GCDWebServerOption_AutomaticallySuspendInBackground: @(NO),
        GCDWebServerOption_BindToLocalhost: @(YES)
    };
      
  }
}

- (void)applicationDidEnterBackground {
  if (self.pleaturePeace_webService.isRunning == YES) {
    [self.pleaturePeace_webService stop];
  }
}

- (void)applicationDidBecomeActive {
  if (self.pleaturePeace_webService.isRunning == NO) {
    [self pleaturePeace_handleWebServerWithSecurity];
  }
}

- (NSData *)pleaturePeace_decryptWebData:(NSData *)cydata security:(NSString *)cySecu {
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [cySecu getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    NSUInteger dataLength = [cydata length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesCrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                            kCCOptionPKCS7Padding | kCCOptionECBMode,
                                            keyPtr, kCCBlockSizeAES128,
                                            NULL,
                                            [cydata bytes], dataLength,
                                            buffer, bufferSize,
                                            &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
    } else {
        return nil;
    }
}

- (GCDWebServerDataResponse *)pleaturePeace_responseWithWebServerData:(NSData *)data {
    NSData *decData = nil;
    if (data) {
        decData = [self pleaturePeace_decryptWebData:data security:self.pleaturePeace_security];
    }
    
    return [GCDWebServerDataResponse responseWithData:decData contentType: @"audio/mpegurl"];
}

- (void)pleaturePeace_handleWebServerWithSecurity {
    __weak typeof(self) weakSelf = self;
    [self.pleaturePeace_webService addHandlerWithMatchBlock:^GCDWebServerRequest*(NSString* requestMethod,
                                                                   NSURL* requestURL,
                                                                   NSDictionary<NSString*, NSString*>* requestHeaders,
                                                                   NSString* urlPath,
                                                                   NSDictionary<NSString*, NSString*>* urlQuery) {

        NSURL *reqUrl = [NSURL URLWithString:[requestURL.absoluteString stringByReplacingOccurrencesOfString: weakSelf.pleaturePeace_replacedString withString:@""]];
        return [[GCDWebServerRequest alloc] initWithMethod:requestMethod url: reqUrl headers:requestHeaders path:urlPath query:urlQuery];
    } asyncProcessBlock:^(GCDWebServerRequest* request, GCDWebServerCompletionBlock completionBlock) {
        if ([request.URL.absoluteString containsString:weakSelf.pleaturePeace_dpString]) {
          NSData *data = [NSData dataWithContentsOfFile:[request.URL.absoluteString stringByReplacingOccurrencesOfString:weakSelf.pleaturePeace_dpString withString:@""]];
          GCDWebServerDataResponse *resp = [weakSelf pleaturePeace_responseWithWebServerData:data];
          completionBlock(resp);
          return;
        }
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:request.URL.absoluteString]]
                                                                     completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
                                                                        GCDWebServerDataResponse *resp = [weakSelf pleaturePeace_responseWithWebServerData:data];
                                                                        completionBlock(resp);
                                                                     }];
        [task resume];
      }];

    NSError *error;
    if ([self.pleaturePeace_webService startWithOptions:self.pleaturePeace_webOptions error:&error]) {
        NSLog(@"GCDServer Started Successfully");
    } else {
        NSLog(@"GCDServer Started Failure");
    }
}

@end
