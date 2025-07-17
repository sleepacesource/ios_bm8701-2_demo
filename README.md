# BM871 蓝牙设备管理 Demo

这是一个完整的 BM871_2牙设备管理 iOS 应用示例，展示了如何使用 BM87012 Framework 进行设备扫描、连接、信息获取、工作模式管理和固件升级等功能。

## 🚀 功能特性

- 🔍 **设备扫描**: 扫描附近的 BM87012牙设备
- 🔗 **设备连接**: 使用框架接口连接设备
- 📊 **设备信息获取**: 获取设备详细信息（设备ID、类型、版本等）
- ⚙️ **工作模式管理**: 获取和设置设备工作模式（WIFI/BLE）
- 🔄 **固件升级**: 支持设备固件升级，带进度显示
- 📝 **实时日志**: 显示所有操作过程和状态变化
- 🔌 **连接管理**: 支持断开连接和连接状态监控
- 🧹 **日志管理**: 支持清除日志功能

## 📱 界面功能

### 主要界面组件
- **状态显示**: 实时显示连接状态和设备信息
- **扫描控制**: 扫描设备按钮，支持设备列表选择
- **连接管理**: 断开连接按钮
- **工作模式**: 获取工作模式、设置WIFI模式、设置BLE模式按钮
- **功能操作**: 清除日志、检查连接状态、固件升级按钮
- **升级进度**: 升级进度条显示
- **日志区域**: 可滚动的日志显示区域

## 🏗️ 项目结构

```
bm8701_2Demo/
├── bm8701Demo/
│   ├── ViewController.h          # 主视图控制器头文件
│   ├── ViewController.m          # 主视图控制器实现
│   ├── AppDelegate.h/.m          # 应用代理
│   ├── SceneDelegate.h/.m        # 场景代理
│   ├── Info.plist               # 应用配置文件
│   ├── Assets.xcassets/         # 应用资源
│   └── Base.lproj/              # 本地化资源
├── framework/
│   ├── BM8701_2.framework/      # BM87012设备管理框架
│   │   ├── Headers/
│   │   │   ├── BM871_2.h
│   │   │   ├── SLPBLEManager+BM871_2.h
│   │   │   └── BM871_2DeviceInfo.h
│   │   └── BM8701_2
│   ├── BluetoothManager.framework/  # 蓝牙管理框架
│   │   ├── Headers/
│   │   │   ├── SLPBLEManager.h
│   │   │   ├── SLPBLEManager+Scan.h
│   │   │   └── SLPBLEDef.h
│   │   └── BluetoothManager
│   └── SLPCommon.framework/     # 通用工具框架
│       ├── Headers/
│       │   ├── SLPCommon.h
│       │   └── SLPDataTransferDef.h
│       └── SLPCommon
└── README.md                    # 项目说明文档
```

## 🔧 集成配置

### 1 Framework 集成

将以下框架文件添加到 Xcode 工程中：

```objc
// 必需框架
BM8701ramework
BluetoothManager.framework
SLPCommon.framework

// 系统框架
CoreBluetooth.framework
libc++.tbd
```

### 2入

```objc
#import <BluetoothManager/SLPBLEManager.h>
#import <BM8701/BM8701_2.h>
```

### 3. 权限配置

在 `Info.plist` 中添加蓝牙权限：

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>需要蓝牙权限来连接 BM8712 设备</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>需要蓝牙权限来连接 BM8701 设备</string>
```

## 📖 核心接口说明

### 1. 初始化蓝牙管理器

```objc
SLPBLEManager *bleManager = [SLPBLEManager sharedBLEManager];
```

### 2扫描设备

```objc
[bleManager scanBluetoothWithTimeoutInterval:5.0completion:^(SLPBLEScanReturnCodes code, NSInteger handleID, SLPPeripheralInfo *peripheralInfo)[object Object]
    if (code == SLPBLEScanReturnCode_Normal && peripheralInfo) [object Object]        NSLog(@"发现设备: %@", peripheralInfo.name);
    }
}];
```

### 3连接设备

```objc
[bleManager bleBM8701_2eral loginCallback:^(SLPDataTransferStatus status, id data) {
    if (status == SLPDataTransferStatus_Succeed) [object Object]    BM8701DeviceInfo *deviceInfo = (BM87012eviceInfo *)data;
        NSLog(@"连接成功，设备ID: %@", deviceInfo.deviceID);
    }
}];
```

### 4. 获取设备信息

```objc
[bleManager bleBM8701ripheral getDeviceInfoTimeout:5callback:^(SLPDataTransferStatus status, id data) {
    if (status == SLPDataTransferStatus_Succeed) [object Object]    BM8701DeviceInfo *deviceInfo = (BM87012eviceInfo *)data;
        NSLog(@设备ID: %@", deviceInfo.deviceID);
        NSLog(@"设备类型: %hu", deviceInfo.deviceType);
        NSLog(@当前版本: %@", deviceInfo.currentHardwareVersion);
        NSLog(@初始版本: %@", deviceInfo.initialHardwareVersion);
    }
}];
```

### 5. 工作模式管理

```objc
// 获取工作模式
[bleManager bleBM8701peripheral getWorkModeTimeout:3callback:^(SLPDataTransferStatus status, id data) {
    if (status == SLPDataTransferStatus_Succeed) [object Object]        NSNumber *workMode = (NSNumber *)data;
        NSString *modeText = workMode intValue] == 0 @WIFI模式" : @"BLE模式";
        NSLog(@当前工作模式: %@", modeText);
    }
}];

// 设置工作模式
[bleManager bleBM8701peripheral setWorkMode:0 timeout:3callback:^(SLPDataTransferStatus status, id data) {
    if (status == SLPDataTransferStatus_Succeed) [object Object]        NSLog(@设置WIFI模式成功");
    }
}];
```

###6. 固件升级

```objc
// 读取升级包文件
NSString *packagePath = [[NSBundle mainBundle] pathForResource:@"firmwareofType:@"bin"];
NSData *packageData = [NSData dataWithContentsOfFile:packagePath];

[bleManager bleBM8701_2:peripheral 
    upgradeDeviceWithPackage:packageData
    firmwareVersion:73
    encryptedCRC:0x12345678   sourceCRC:0x87654321
    callback:^(SLPDataTransferStatus status, id data) {
        if (status == SLPDataTransferStatus_Succeed)[object Object]
            // 处理升级进度更新
            if ([data isKindOfClass:NSClassFromString(@"BM8701UpgradeInfo")])[object Object]             NSLog(@"升级进度更新);         }
        }
    }];
```

### 7断开连接

```objc
[bleManager disconnectPeripheral:peripheral timeout:3.0completion:^(SLPBLEDisconnectReturnCodes code, NSInteger disconnectHandleID)[object Object]
    if (code == SLPBLEDisconnectReturnCode_Succeed) [object Object]        NSLog(@断开连接成功");
    }
}];
```

## 📊 数据结构

### BM8701DeviceInfo

```objc
@interface BM8701iceInfo : NSObject

@property (nonatomic, copy) NSString *deviceID;                    // 设备ID
@property (nonatomic, assign) ushort deviceType;                   // 设备类型
@property (nonatomic, copy) NSString *currentHardwareVersion;      // 当前硬件版本
@property (nonatomic, copy) NSString *initialHardwareVersion;      // 出厂固件版本

@end
```

### 工作模式

- `0`: WIFI模式（默认）
- `1: BLE模式

### 状态码说明

```objc
typedef NS_ENUM(NSInteger, SLPDataTransferStatus) {
    SLPDataTransferStatus_Succeed = 0,              // 操作成功
    SLPDataTransferStatus_ConnectionDisconnected = -1/ 连接断开
    SLPDataTransferStatus_TimeOut = -2             // 操作超时
    SLPDataTransferStatus_Failed = -3,              // 操作失败
    SLPDataTransferStatus_ConnectionDisabled = -4  // 连接被禁用
    SLPDataTransferStatus_ParameterError =-5,      // 参数错误
    SLPDataTransferStatus_ConfigMode = -6,          // 正在配置模式
};
```

## 🎯 使用流程

### 完整操作流程1. **启动应用** → 自动初始化蓝牙管理器2. **扫描设备** → 点击扫描设备按钮，选择目标设备
3. **连接设备** → 自动连接选中的设备
4. **获取信息** → 连接成功后自动获取设备信息
5. **工作模式管理** → 获取或设置设备工作模式
6. **固件升级** → 选择升级包文件进行升级
7. **断开连接** → 操作完成后断开设备连接

### 界面操作说明

- **扫描设备**: 点击后弹出设备列表，选择要连接的设备
- **断开连接**: 断开当前连接的设备
- **获取工作模式**: 获取设备当前工作模式
- **设置WIFI模式**: 将设备设置为WIFI工作模式
- **设置BLE模式**: 将设备设置为BLE工作模式
- **清除日志**: 清空日志显示区域
- **检查连接状态**: 检查当前设备连接状态
- **固件升级**: 选择升级包文件进行设备升级

## ⚠️ 注意事项
1 **真机测试**: 蓝牙功能必须在真机上测试，模拟器不支持2. **权限授权**: 首次使用需要用户授权蓝牙权限
3**设备距离**: 确保 BM87012设备在有效范围内
4 **连接状态**: 操作前确保设备已正确连接
5**升级包**: 固件升级需要有效的升级包文件6内存管理**: 注意回调 block 的循环引用问题

## 🔧 故障排除

### 常见问题

1. **扫描不到设备**
   - 检查设备是否开启并处于可发现状态
   - 确认设备在有效范围内
   - 检查蓝牙权限是否已授权
2. **连接失败**
   - 确认设备未被其他应用占用
   - 尝试重新扫描设备
   - 检查设备电量是否充足

3. **获取信息失败**
   - 确认设备已成功连接
   - 等待连接稳定后再获取信息
   - 检查设备是否支持信息查询功能
4. **升级失败**
   - 确认升级包文件有效
   - 检查设备电量充足
   - 确保升级过程中设备不断开连接

## 📋 系统要求

- **iOS 版本**: iOS 120
- **Xcode 版本**: Xcode 120+
- **设备要求**: 支持蓝牙的 iOS 设备
- **框架版本**: 
  - BM8701_2framework v1.0
  - BluetoothManager.framework v10LPCommon.framework v100.8

## 📞 技术支持

如有问题，请参考框架文档或联系技术支持团队。

## 📄 许可证

本项目仅供学习和演示使用。

---

**版本**: v1.0  
**更新时间**: 224年12月  
**开发者**: BM8701_2 开发团队 