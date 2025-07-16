//
//  BM8701_2DeviceInfo.h
//  SDK
//
//  Created by Assistant on 2024/1/1.
//  Copyright © 2024 Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BM8701_2DeviceInfo : NSObject

@property (nonatomic,copy)  NSString *deviceID;//设备ID UTF-8 带结束符( 例: "qiwueiuqwyeui" )
@property (nonatomic,assign) ushort  deviceType;
@property (nonatomic,copy) NSString *currentHardwareVersion;//硬件版本
@property (nonatomic,copy) NSString *initialHardwareVersion;//出厂固件版本

@end

NS_ASSUME_NONNULL_END 