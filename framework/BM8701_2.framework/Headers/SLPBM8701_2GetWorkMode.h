//
//  SLPBM8701_2GetWorkMode.h
//  SDK
//
//  Created by Assistant on 2024/1/1.
//  Copyright © 2024 Martin. All rights reserved.
//

#import <BluetoothManager/SLPBLEBaseEntity.h>

@interface SLPBM8701_2GetWorkMode : SLPBLEBaseEntity

@property (nonatomic, assign) UInt8 workMode; // 工作模式 0: WIFI模式(默认); 1:BLE模式

@end 