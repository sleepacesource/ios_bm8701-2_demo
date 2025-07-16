# 蓝牙设备 Demo

这是一个用于演示如何使用 CoreBluetooth 框架进行蓝牙设备扫描和连接的 iOS 应用示例。

## 功能特性

- 🔍 **设备扫描**: 扫描附近的蓝牙设备
- 🔗 **设备连接**: 连接选中的设备
- 📊 **设备信息获取**: 获取设备的基本信息（设备名称、ID等）
- 📝 **实时日志**: 显示操作过程和状态变化
- 🔄 **状态监控**: 实时监控设备连接状态

## 重要说明

由于第三方框架的链接问题，本 Demo 改用了 Apple 官方的 CoreBluetooth 框架：

1. **管理器**: 使用 `CBCentralManager` 进行蓝牙管理
2. **扫描方法**: 使用 `scanForPeripheralsWithServices:options:` 方法
3. **连接方式**: 使用 `connectPeripheral:options:` 方法
4. **信息获取**: 直接获取设备的名称和 UUID
5. **状态监听**: 使用代理方法监听连接状态变化

这样可以确保代码的稳定性和兼容性。

## 项目结构

```
bm8701_2Demo/
├── bm8701_2Demo/
│   ├── ViewController.h          # 主视图控制器头文件
│   ├── ViewController.m          # 主视图控制器实现
│   ├── Info.plist               # 应用配置文件（包含蓝牙权限）
│   └── ...                      # 其他 iOS 应用文件
├── framework/
│   ├── BM8701_2.framework/      # BM8701_2 设备管理框架
│   ├── BluetoothManager.framework/  # 蓝牙管理框架
│   └── SLPCommon.framework/     # 通用工具框架
└── README.md                    # 项目说明文档
```

## 使用步骤

### 1. 项目配置

确保在 Xcode 项目中正确链接了以下框架：

- `BM8701_2.framework`
- `BluetoothManager.framework`
- `SLPCommon.framework`
- `libc++.tbd`

### 2. 权限设置

在 `Info.plist` 中已添加必要的蓝牙权限：

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>需要蓝牙权限来连接 BM8701_2 设备</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>需要蓝牙权限来连接 BM8701_2 设备</string>
```

### 3. 运行应用

1. 在 Xcode 中打开项目
2. 选择目标设备（真机或模拟器）
3. 点击运行按钮

### 4. 使用流程

1. **启动应用**: 应用启动后会自动初始化管理器
2. **扫描设备**: 点击"扫描设备"按钮开始扫描附近的 BM8701_2 设备
3. **连接设备**: 扫描到设备后，点击"连接设备"按钮进行连接
4. **获取信息**: 连接成功后，点击"获取设备信息"按钮获取设备详细信息

## 主要接口说明

### 管理器初始化

```objc
// 初始化蓝牙管理器
CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

// 实现代理方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // 处理蓝牙状态变化
}
```

### 设备扫描

```objc
[centralManager scanForPeripheralsWithServices:nil options:nil];

// 实现扫描回调
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    // 处理发现的设备
}
```

### 设备连接

```objc
[centralManager connectPeripheral:peripheral options:nil];

// 实现连接回调
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // 处理连接成功
}
```

### 获取设备信息

```objc
NSString *deviceName = peripheral.name;
NSString *deviceID = peripheral.identifier.UUIDString;
```

## 设备信息结构

```objc
@interface CBPeripheral : NSObject

@property (nonatomic, readonly, nullable) NSString *name;           // 设备名称
@property (nonatomic, readonly) NSUUID *identifier;                 // 设备唯一标识符
@property (nonatomic, readonly) CBPeripheralState state;           // 设备连接状态

@end
```

## 代理方法

### CBCentralManagerDelegate

```objc
// 蓝牙状态变化
- (void)centralManagerDidUpdateState:(CBCentralManager *)central;

// 发现设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

// 连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;

// 连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

// 断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
```

### CBPeripheralDelegate

```objc
// 发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
```

## 注意事项

1. **真机测试**: 蓝牙功能需要在真机上测试，模拟器无法使用蓝牙
2. **权限授权**: 首次使用蓝牙功能时，系统会请求用户授权
3. **设备距离**: 确保 BM8701_2 设备在有效范围内且处于可发现状态
4. **连接超时**: 如果连接失败，请检查设备是否可用或重新扫描

## 故障排除

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

## 技术支持

如有问题，请参考框架文档或联系技术支持团队。

## 版本信息

- iOS 版本要求: iOS 12.0+
- Xcode 版本要求: Xcode 12.0+
- 框架版本: BM8701_2.framework v1.0 