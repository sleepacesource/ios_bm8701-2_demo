//
//  SLPBLEManager+BM8701_2.h
//  SDK
//
//  Created by Assistant on 2024/1/1.
//  Copyright © 2024 Martin. All rights reserved.
//

#import <BluetoothManager/BluetoothManager.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BM8701_2DeviceInfo.h"

@class BM8701_2UpgradeInfo;

NS_ASSUME_NONNULL_BEGIN

@interface SLPBLEManager (BM8701_2)

/**
 连接设备
 @param peripheral 蓝牙句柄
 @param handle 回调 data类型为BM8701_2DeviceInfo
 */
- (void)bleBM8701_2:(CBPeripheral *)peripheral loginCallback:(SLPTransforCallback)handle;

/**
 获取设备信息
 @param peripheral 蓝牙句柄
 @param timeout 超时（单位秒）
 @param handle 回调
 */
- (void)bleBM8701_2:(CBPeripheral *)peripheral getDeviceInfoTimeout:(CGFloat)timeout callback:(SLPTransforCallback)handle;

/**
 设置工作模式
 @param peripheral 蓝牙句柄
 @param workMode 工作模式 0: WIFI模式(默认); 1:BLE模式
 @param timeout 超时（单位秒）
 @param handle 回调
 */
- (void)bleBM8701_2:(CBPeripheral *)peripheral setWorkMode:(UInt8)workMode timeout:(CGFloat)timeout callback:(SLPTransforCallback)handle;

/**
 获取工作模式
 @param peripheral 蓝牙句柄
 @param timeout 超时（单位秒）
 @param handle 回调 data类型为NSNumber，值为工作模式
 */
- (void)bleBM8701_2:(CBPeripheral *)peripheral getWorkModeTimeout:(CGFloat)timeout callback:(SLPTransforCallback)handle;

/**
 固件升级
 @param peripheral 蓝牙句柄
 @param package 升级包数据
 @param firmwareVersion 固件版本（如：7.03）
 @param encryptedCRC 加密包校验
 @param sourceCRC 源文件校验
 @param handle 回调 data类型为BM8701_2UpgradeInfo，包含升级进度
 */
- (void)bleBM8701_2:(CBPeripheral *)peripheral upgradeDeviceWithPackage:(NSData *)package
       firmwareVersion:(float)firmwareVersion
          encryptedCRC:(UInt32)encryptedCRC
             sourceCRC:(UInt32)sourceCRC
              callback:(SLPTransforCallback)handle;

@end

NS_ASSUME_NONNULL_END 