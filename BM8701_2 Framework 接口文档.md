# BM8701_2 Framework 接口文档

## 概述
BM8701_2 Framework 提供了完整的蓝牙设备管理功能，包括设备扫描、连接管理、设备信息获取、工作模式设置和固件升级等功能。

## 集成准备

### 1. 导入 Framework
将以下框架文件添加到 Xcode 工程中：
- `BM8701_2.framework`
- `BluetoothManager.framework` 
- `SLPCommon.framework`

### 2. 导入头文件
```objc
#import <BluetoothManager/SLPBLEManager.h>
#import <BM8701_2/BM8701_2.h>
```

### 3. 初始化蓝牙管理器
```objc
SLPBLEManager *bleManager = [SLPBLEManager sharedBLEManager];
```

---

## 核心接口说明

### 1. 扫描设备

**接口名称：** `scanBluetoothWithTimeoutInterval:completion:`

**功能描述：** 扫描周围的蓝牙设备

**入参说明：**
- `timeOutInterval` (CGFloat): 扫描超时时间，单位秒
- `handle` (SLPBLEScanHandle): 扫描结果回调

**返回说明：**
- 无返回值，通过回调返回扫描结果

**回调参数：**
- `code` (SLPBLEScanReturnCodes): 扫描状态码
  - `SLPBLEScanReturnCode_Normal`: 正常扫描
  - `SLPBLEScanReturnCode_Disable`: 蓝牙被禁用
  - `SLPBLEScanReturnCode_TimeOut`: 扫描超时
- `handleID` (NSInteger): 扫描句柄ID
- `peripheralInfo` (SLPPeripheralInfo): 扫描到的设备信息

**使用示例：**
```objc
[bleManager scanBluetoothWithTimeoutInterval:5.0 completion:^(SLPBLEScanReturnCodes code, NSInteger handleID, SLPPeripheralInfo *peripheralInfo) {
    if (code == SLPBLEScanReturnCode_Normal && peripheralInfo) {
        NSLog(@"发现设备: %@", peripheralInfo.name);
        // 处理扫描到的设备
    }
}];
```

---

### 2. 连接设备

**接口名称：** `bleBM8701_2:loginCallback:`

**功能描述：** 连接BM8701_2设备

**入参说明：**
- `peripheral` (CBPeripheral): 蓝牙设备句柄
- `handle` (SLPTransforCallback): 连接结果回调

**返回说明：**
- 无返回值，通过回调返回连接结果

**回调参数：**
- `status` (SLPDataTransferStatus): 连接状态
  - `SLPDataTransferStatus_Succeed`: 连接成功
  - `SLPDataTransferStatus_TimeOut`: 连接超时
  - `SLPDataTransferStatus_Failed`: 连接失败
- `data` (BM8701_2DeviceInfo): 设备信息（连接成功时返回）

**使用示例：**
```objc
[bleManager bleBM8701_2:peripheral loginCallback:^(SLPDataTransferStatus status, id data) {
    if (status == SLPDataTransferStatus_Succeed) {
        BM8701_2DeviceInfo *deviceInfo = (BM8701_2DeviceInfo *)data;
        NSLog(@"连接成功，设备ID: %@", deviceInfo.deviceID);
    }
}];
```

---

### 3. 断开连接

**接口名称：** `disconnectPeripheral:timeout:completion:`

**功能描述：** 断开与指定设备的连接

**入参说明：**
- `peripheral` (CBPeripheral): 蓝牙设备句柄
- `timeout` (CGFloat): 断开连接超时时间，单位秒
- `handle` (SLPBLEDisconnectHandle): 断开连接结果回调

**返回说明：**
- `BOOL`: 是否成功发起断开连接请求

**回调参数：**
- `code` (SLPBLEDisconnectReturnCodes): 断开连接状态
  - `SLPBLEDisconnectReturnCode_Succeed`: 断开成功
  - `SLPBLEDisconnectReturnCode_Failed`: 断开失败
  - `SLPBLEDisconnectReturnCode_Timeout`: 断开超时
- `disconnectHandleID` (NSInteger): 断开连接句柄ID

**使用示例：**
```objc
BOOL success = [bleManager disconnectPeripheral:peripheral timeout:3.0 completion:^(SLPBLEDisconnectReturnCodes code, NSInteger disconnectHandleID) {
    if (code == SLPBLEDisconnectReturnCode_Succeed) {
        NSLog(@"断开连接成功");
    }
}];
```

---

### 4. 获取设备信息

**接口名称：** `bleBM8701_2:getDeviceInfoTimeout:callback:`

**功能描述：** 获取BM8701_2设备的详细信息

**入参说明：**
- `peripheral` (CBPeripheral): 蓝牙设备句柄
- `timeout` (CGFloat): 请求超时时间，单位秒
- `handle` (SLPTransforCallback): 获取结果回调

**返回说明：**
- 无返回值，通过回调返回设备信息

**回调参数：**
- `status` (SLPDataTransferStatus): 请求状态
- `data` (BM8701_2DeviceInfo): 设备信息对象

**BM8701_2DeviceInfo 属性说明：**
- `deviceID` (NSString): 设备ID，UTF-8编码
- `deviceType` (ushort): 设备类型
- `currentHardwareVersion` (NSString): 当前版本
- `initialHardwareVersion` (NSString): 出厂版本（现在暂时不用）

**使用示例：**
```objc
[bleManager bleBM8701_2:peripheral getDeviceInfoTimeout:5.0 callback:^(SLPDataTransferStatus status, id data) {
    if (status == SLPDataTransferStatus_Succeed) {
        BM8701_2DeviceInfo *deviceInfo = (BM8701_2DeviceInfo *)data;
        NSLog(@"设备ID: %@", deviceInfo.deviceID);
        NSLog(@"设备类型: %hu", deviceInfo.deviceType);
        NSLog(@"当前版本: %@", deviceInfo.currentHardwareVersion);
        NSLog(@"初始版本: %@", deviceInfo.initialHardwareVersion);
    }
}];
```

---

### 5. 获取工作模式

**接口名称：** `bleBM8701_2:getWorkModeTimeout:callback:`

**功能描述：** 获取BM8701_2设备当前的工作模式

**入参说明：**
- `peripheral` (CBPeripheral): 蓝牙设备句柄
- `timeout` (CGFloat): 请求超时时间，单位秒
- `handle` (SLPTransforCallback): 获取结果回调

**返回说明：**
- 无返回值，通过回调返回工作模式

**回调参数：**
- `status` (SLPDataTransferStatus): 请求状态
- `data` (NSNumber): 工作模式值
  - `0`: WIFI模式（默认）
  - `1`: BLE模式

**使用示例：**
```objc
[bleManager bleBM8701_2:peripheral getWorkModeTimeout:3.0 callback:^(SLPDataTransferStatus status, id data) {
    if (status == SLPDataTransferStatus_Succeed) {
        NSNumber *workMode = (NSNumber *)data;
        NSString *modeText = [workMode intValue] == 0 ? @"WIFI模式" : @"BLE模式";
        NSLog(@"当前工作模式: %@", modeText);
    }
}];
```

---

### 6. 设置工作模式

**接口名称：** `bleBM8701_2:setWorkMode:timeout:callback:`

**功能描述：** 设置BM8701_2设备的工作模式

**入参说明：**
- `peripheral` (CBPeripheral): 蓝牙设备句柄
- `workMode` (UInt8): 工作模式
  - `0`: WIFI模式（默认）
  - `1`: BLE模式
- `timeout` (CGFloat): 请求超时时间，单位秒
- `handle` (SLPTransforCallback): 设置结果回调

**返回说明：**
- 无返回值，通过回调返回设置结果

**回调参数：**
- `status` (SLPDataTransferStatus): 设置状态
- `data` (id): 设置结果数据（通常为nil，表示设置成功）

**使用示例：**
```objc
// 设置为WIFI模式
[bleManager bleBM8701_2:peripheral setWorkMode:0 timeout:3.0 callback:^(SLPDataTransferStatus status, id data) {
    if (status == SLPDataTransferStatus_Succeed) {
        NSLog(@"设置WIFI模式成功");
    }
}];

// 设置为BLE模式
[bleManager bleBM8701_2:peripheral setWorkMode:1 timeout:3.0 callback:^(SLPDataTransferStatus status, id data) {
    if (status == SLPDataTransferStatus_Succeed) {
        NSLog(@"设置BLE模式成功");
    }
}];
```

---

### 7. 固件升级

**接口名称：** `bleBM8701_2:upgradeDeviceWithPackage:firmwareVersion:encryptedCRC:sourceCRC:callback:`

**功能描述：** 对BM8701_2设备进行固件升级

**入参说明：**
- `peripheral` (CBPeripheral): 蓝牙设备句柄
- `package` (NSData): 升级包数据
- `firmwareVersion` (float): 固件版本号（如：7.03）
- `encryptedCRC` (UInt32): 加密包校验值 ，固定值：0
- `sourceCRC` (UInt32): 源文件校验值，固定值：0
- `handle` (SLPTransforCallback): 升级进度和结果回调

**返回说明：**
- 无返回值，通过回调返回升级进度和结果

**回调参数：**
- `status` (SLPDataTransferStatus): 升级状态
- `data` (BM8701_2UpgradeInfo): 升级信息对象，包含进度等详细信息

**使用示例：**
```objc
// 读取升级包文件
NSString *packagePath = [[NSBundle mainBundle] pathForResource:@"firmware" ofType:@"bin"];
NSData *packageData = [NSData dataWithContentsOfFile:packagePath];

[bleManager bleBM8701_2:peripheral 
    upgradeDeviceWithPackage:packageData
    firmwareVersion:7.03
    encryptedCRC:0
    sourceCRC:0
    callback:^(SLPDataTransferStatus status, id data) {
        if (status == SLPDataTransferStatus_Succeed) {
            // 处理升级进度更新
            if ([data isKindOfClass:NSClassFromString(@"BM8701_2UpgradeInfo")]) {
                // 解析升级进度信息
                NSLog(@"升级进度更新");
            }
        } else {
            NSLog(@"升级失败，状态码: %ld", (long)status);
        }
    }];
```

---

## 状态码说明

### SLPDataTransferStatus 枚举值
- `SLPDataTransferStatus_Succeed = 0`: 操作成功
- `SLPDataTransferStatus_ConnectionDisconnected = -1`: 连接断开
- `SLPDataTransferStatus_TimeOut = -2`: 操作超时
- `SLPDataTransferStatus_Failed = -3`: 操作失败
- `SLPDataTransferStatus_ConnectionDisabled = -4`: 连接被禁用
- `SLPDataTransferStatus_ParameterError = -5`: 参数错误
- `SLPDataTransferStatus_ConfigMode = -6`: 正在配置模式

---

## 注意事项

1. **蓝牙权限**：确保在Info.plist中添加蓝牙使用权限描述
2. **设备类型**：BM8701_2设备类型为 `SLPDeviceType_BM8701_2 = 0x31`
3. **连接状态**：使用前请确保设备已连接
4. **超时设置**：根据网络环境合理设置超时时间
5. **错误处理**：所有接口都应进行错误状态检查
6. **内存管理**：注意回调block的循环引用问题

---

## 完整使用流程

```objc
// 1. 初始化
SLPBLEManager *bleManager = [SLPBLEManager sharedBLEManager];

// 2. 扫描设备
[bleManager scanBluetoothWithTimeoutInterval:5.0 completion:^(SLPBLEScanReturnCodes code, NSInteger handleID, SLPPeripheralInfo *peripheralInfo) {
    if (code == SLPBLEScanReturnCode_Normal && peripheralInfo) {
        // 3. 连接设备
        [bleManager bleBM8701_2:peripheralInfo.peripheral loginCallback:^(SLPDataTransferStatus status, id data) {
            if (status == SLPDataTransferStatus_Succeed) {
                // 4. 获取设备信息
                [bleManager bleBM8701_2:peripheralInfo.peripheral getDeviceInfoTimeout:5.0 callback:^(SLPDataTransferStatus status, id data) {
                    // 处理设备信息
                }];
                
                // 5. 获取工作模式
                [bleManager bleBM8701_2:peripheralInfo.peripheral getWorkModeTimeout:3.0 callback:^(SLPDataTransferStatus status, id data) {
                    // 处理工作模式信息
                }];
            }
        }];
    }
}];
```