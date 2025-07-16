//
//  ViewController.m
//  bm8701_2Demo
//
//  Created by 莹何 on 2025/7/14.
//

#import "ViewController.h"
#import <BluetoothManager/BluetoothManager.h>
#import <BM8701_2/BM8701_2.h>
#import <BM8701_2/BM8701_2DeviceInfo.h>
#import <objc/runtime.h>

@interface ViewController ()

@property (nonatomic, strong) UIButton *scanButton;
@property (nonatomic, strong) UIButton *disconnectButton;
@property (nonatomic, strong) UIButton *clearLogButton;
@property (nonatomic, strong) UIButton *getWorkModeButton;
@property (nonatomic, strong) UIButton *setWifiModeButton;
@property (nonatomic, strong) UIButton *setBleModeButton;
@property (nonatomic, strong) UIButton *checkStatusButton;
@property (nonatomic, strong) UIButton *upgradeButton;
@property (nonatomic, strong) UIProgressView *upgradeProgressView;
@property (nonatomic, strong) UILabel *workModeLabel;
@property (nonatomic, strong) UITextView *logTextView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *deviceInfoLabel;

@property (nonatomic, strong) SLPBLEManager *bleManager;
@property (nonatomic, strong) CBPeripheral *currentPeripheral;
@property (nonatomic, strong) NSMutableArray<SLPPeripheralInfo *> *discoveredPeripherals;
@property (nonatomic, assign) BOOL isConnected;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化管理器
    [self setupManagers];
    
    // 设置UI
    [self setupUI];
    
    // 添加蓝牙连接状态监听
    [self setupBluetoothStatusMonitoring];
    
    // 添加日志
    [self addLog:@"BM8701_2 Demo 启动"];
}

- (void)setupManagers {
    // 初始化 SLPBLEManager
    self.bleManager = [SLPBLEManager sharedBLEManager];
    self.discoveredPeripherals = [NSMutableArray array];
    
    [self addLog:@"SLPBLEManager 初始化完成"];
    
    // 启动连接状态监控
    [self startConnectionStatusMonitoring];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 状态标签
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"状态: 未连接";
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    self.statusLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.statusLabel];
    
    // 设备信息标签
    self.deviceInfoLabel = [[UILabel alloc] init];
    self.deviceInfoLabel.text = @"设备信息: 无";
    self.deviceInfoLabel.textAlignment = NSTextAlignmentCenter;
    self.deviceInfoLabel.font = [UIFont systemFontOfSize:14];
    self.deviceInfoLabel.textColor = [UIColor darkGrayColor];
    self.deviceInfoLabel.numberOfLines = 0;
    [self.view addSubview:self.deviceInfoLabel];
    
    // 扫描按钮
    self.scanButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.scanButton setTitle:@"扫描设备" forState:UIControlStateNormal];
    [self.scanButton addTarget:self action:@selector(scanButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scanButton];
    
    // 断开连接按钮
    self.disconnectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.disconnectButton setTitle:@"断开连接" forState:UIControlStateNormal];
    [self.disconnectButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.disconnectButton addTarget:self action:@selector(disconnectButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.disconnectButton.enabled = NO;
    [self.view addSubview:self.disconnectButton];
    
    // 工作模式标签
    self.workModeLabel = [[UILabel alloc] init];
    self.workModeLabel.text = @"工作模式: 未知";
    self.workModeLabel.textAlignment = NSTextAlignmentCenter;
    self.workModeLabel.font = [UIFont systemFontOfSize:14];
    self.workModeLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:self.workModeLabel];
    
    // 获取工作模式按钮
    self.getWorkModeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.getWorkModeButton setTitle:@"获取工作模式" forState:UIControlStateNormal];
    [self.getWorkModeButton addTarget:self action:@selector(getWorkModeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.getWorkModeButton.enabled = NO;
    [self.view addSubview:self.getWorkModeButton];
    
    // 设置WIFI模式按钮
    self.setWifiModeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.setWifiModeButton setTitle:@"设置WIFI模式" forState:UIControlStateNormal];
    [self.setWifiModeButton addTarget:self action:@selector(setWifiModeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.setWifiModeButton.enabled = NO;
    [self.view addSubview:self.setWifiModeButton];
    
    // 设置BLE模式按钮
    self.setBleModeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.setBleModeButton setTitle:@"设置BLE模式" forState:UIControlStateNormal];
    [self.setBleModeButton addTarget:self action:@selector(setBleModeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.setBleModeButton.enabled = NO;
    [self.view addSubview:self.setBleModeButton];
    
    // 清除日志按钮
    self.clearLogButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.clearLogButton setTitle:@"清除日志" forState:UIControlStateNormal];
    [self.clearLogButton addTarget:self action:@selector(clearLogButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.clearLogButton];
    
    // 检查连接状态按钮
    self.checkStatusButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.checkStatusButton setTitle:@"检查连接状态" forState:UIControlStateNormal];
    [self.checkStatusButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.checkStatusButton addTarget:self action:@selector(checkStatusButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.checkStatusButton];
    
    // 固件升级按钮
    self.upgradeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.upgradeButton setTitle:@"固件升级" forState:UIControlStateNormal];
    [self.upgradeButton addTarget:self action:@selector(upgradeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.upgradeButton.enabled = NO;
    [self.view addSubview:self.upgradeButton];
    
    // 固件升级进度条
    self.upgradeProgressView = [[UIProgressView alloc] init];
    self.upgradeProgressView.progress = 0.0;
    self.upgradeProgressView.hidden = YES;
    [self.view addSubview:self.upgradeProgressView];
    
    // 日志文本视图
    self.logTextView = [[UITextView alloc] init];
    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.logTextView.font = [UIFont systemFontOfSize:12];
    self.logTextView.editable = NO;
    self.logTextView.scrollEnabled = YES;
    self.logTextView.showsVerticalScrollIndicator = YES;
    self.logTextView.layer.cornerRadius = 5;
    self.logTextView.layer.borderWidth = 1;
    self.logTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:self.logTextView];
    
    // 设置约束
    [self setupConstraints];
}

- (void)setupConstraints {
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.deviceInfoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.workModeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.scanButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.disconnectButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.getWorkModeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.setWifiModeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.setBleModeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.checkStatusButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.clearLogButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.logTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.upgradeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.upgradeProgressView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        // 状态标签
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // 设备信息标签
        [self.deviceInfoLabel.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:10],
        [self.deviceInfoLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.deviceInfoLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // 扫描按钮
        [self.scanButton.topAnchor constraintEqualToAnchor:self.deviceInfoLabel.bottomAnchor constant:20],
        [self.scanButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:50],
        [self.scanButton.widthAnchor constraintEqualToConstant:120],
        [self.scanButton.heightAnchor constraintEqualToConstant:44],
        
        // 断开连接按钮
        [self.disconnectButton.topAnchor constraintEqualToAnchor:self.deviceInfoLabel.bottomAnchor constant:20],
        [self.disconnectButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-50],
        [self.disconnectButton.widthAnchor constraintEqualToConstant:120],
        [self.disconnectButton.heightAnchor constraintEqualToConstant:44],
        
        // 工作模式标签
        [self.workModeLabel.topAnchor constraintEqualToAnchor:self.scanButton.bottomAnchor constant:15],
        [self.workModeLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.workModeLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // 获取工作模式按钮
        [self.getWorkModeButton.topAnchor constraintEqualToAnchor:self.workModeLabel.bottomAnchor constant:10],
        [self.getWorkModeButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.getWorkModeButton.widthAnchor constraintEqualToConstant:120],
        [self.getWorkModeButton.heightAnchor constraintEqualToConstant:44],
        
        // 设置WIFI模式按钮
        [self.setWifiModeButton.topAnchor constraintEqualToAnchor:self.workModeLabel.bottomAnchor constant:10],
        [self.setWifiModeButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.setWifiModeButton.widthAnchor constraintEqualToConstant:120],
        [self.setWifiModeButton.heightAnchor constraintEqualToConstant:44],
        
        // 设置BLE模式按钮
        [self.setBleModeButton.topAnchor constraintEqualToAnchor:self.workModeLabel.bottomAnchor constant:10],
        [self.setBleModeButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.setBleModeButton.widthAnchor constraintEqualToConstant:120],
        [self.setBleModeButton.heightAnchor constraintEqualToConstant:44],
        
        // 清除日志按钮
        [self.clearLogButton.topAnchor constraintEqualToAnchor:self.getWorkModeButton.bottomAnchor constant:15],
        [self.clearLogButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.clearLogButton.widthAnchor constraintEqualToConstant:120],
        [self.clearLogButton.heightAnchor constraintEqualToConstant:44],
        
        // 检查连接状态按钮
        [self.checkStatusButton.topAnchor constraintEqualToAnchor:self.clearLogButton.bottomAnchor constant:10],
        [self.checkStatusButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.checkStatusButton.widthAnchor constraintEqualToConstant:120],
        [self.checkStatusButton.heightAnchor constraintEqualToConstant:44],
        
        // 固件升级按钮
        [self.upgradeButton.topAnchor constraintEqualToAnchor:self.checkStatusButton.bottomAnchor constant:10],
        [self.upgradeButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.upgradeButton.widthAnchor constraintEqualToConstant:120],
        [self.upgradeButton.heightAnchor constraintEqualToConstant:44],
        
        // 固件升级进度条
        [self.upgradeProgressView.topAnchor constraintEqualToAnchor:self.upgradeButton.bottomAnchor constant:10],
        [self.upgradeProgressView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.upgradeProgressView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.upgradeProgressView.heightAnchor constraintEqualToConstant:10],
        
        // 日志文本视图 - 连接到升级进度条下方
        [self.logTextView.topAnchor constraintEqualToAnchor:self.upgradeProgressView.bottomAnchor constant:20],
        [self.logTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.logTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.logTextView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20]
    ]];
}

#pragma mark - Button Actions

- (void)scanButtonTapped {
    if (![self.bleManager blueToothIsOpen]) {
        [self addLog:@"蓝牙未开启，请先开启蓝牙"];
        return;
    }
    
    [self addLog:@"开始扫描设备..."];
    [self.discoveredPeripherals removeAllObjects];
    
    // 使用 SLPBLEManager 进行扫描
    [self.bleManager scanBluetoothWithTimeoutInterval:5.0 completion:^(SLPBLEScanReturnCodes code, NSInteger handleID, SLPPeripheralInfo *peripheralInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (code) {
                case SLPBLEScanReturnCode_Normal:
                    if (peripheralInfo) {
                        [self handleDiscoveredPeripheral:peripheralInfo];
                    }
                    break;
                case SLPBLEScanReturnCode_Disable:
                    [self addLog:@"蓝牙被禁用"];
                    break;
                case SLPBLEScanReturnCode_TimeOut:
                    [self addLog:@"扫描超时"];
                    [self printDiscoveredDevices];
                    break;
            }
        });
    }];
}

- (void)clearLogButtonTapped {
    self.logTextView.text = @"";
    [self addLog:@"日志已清除"];
}

- (void)checkStatusButtonTapped {
    [self addLog:@"=== 手动检查连接状态 ==="];
    
    if (!self.currentPeripheral) {
        [self addLog:@"当前没有选择的设备"];
        return;
    }
    
    // 检查蓝牙是否开启
    BOOL bluetoothEnabled = [self.bleManager blueToothIsOpen];
    [self addLog:[NSString stringWithFormat:@"蓝牙状态: %@", bluetoothEnabled ? @"已开启" : @"已关闭"]];
    
    // 检查设备连接状态
    SLPBleConnectStatus connectStatus = [self.bleManager checkPeripheralConnecteStatus:self.currentPeripheral];
    BOOL isConnected = [self.bleManager peripheralIsConnected:self.currentPeripheral];
    
    [self addLog:[NSString stringWithFormat:@"设备连接状态: %@", [self getConnectStatusDescription:connectStatus]]];
    [self addLog:[NSString stringWithFormat:@"是否已连接: %@", isConnected ? @"是" : @"否"]];
    [self addLog:[NSString stringWithFormat:@"UI显示状态: %@", self.isConnected ? @"已连接" : @"未连接"]];
    
    // 检查设备信息
    NSString *deviceName = [self.bleManager deviceNameOfPeripheral:self.currentPeripheral];
    SLPDeviceTypes deviceType = [self.bleManager deviceTypeOfPeripheral:self.currentPeripheral];
    
    [self addLog:[NSString stringWithFormat:@"设备名称: %@", deviceName ?: @"未知"]];
    [self addLog:[NSString stringWithFormat:@"设备类型: %@", [self getDeviceTypeDescription:deviceType]]];
    
    // 如果状态不一致，更新UI
    if (self.isConnected != isConnected) {
        [self addLog:@"⚠️ 检测到状态不一致，正在更新UI..."];
        [self updateConnectionStatus:isConnected];
    } else {
        [self addLog:@"✅ 连接状态一致"];
    }
    
    [self addLog:@"=== 连接状态检查完成 ==="];
}

- (void)upgradeButtonTapped {
    if (!self.currentPeripheral) {
        [self addLog:@"当前没有连接的设备"];
        return;
    }
    
    [self addLog:@"=== 开始固件升级流程 ==="];
    
    // 显示升级进度条
    self.upgradeProgressView.hidden = NO;
    self.upgradeProgressView.progress = 0.0;
    
    // 禁用升级按钮，防止重复点击
    self.upgradeButton.enabled = NO;
    
    // 创建升级包数据（这里使用示例数据，实际使用时需要真实的固件包）
    [self startFirmwareUpgrade];
}

- (void)startFirmwareUpgrade {
    // 读取真实的固件包文件
    NSString *firmwarePath = [[NSBundle mainBundle] pathForResource:@"6.14" ofType:@"bin"];
    
    if (!firmwarePath) {
        // 如果Bundle中没有，尝试从Documents目录读取
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        firmwarePath = [documentsDirectory stringByAppendingPathComponent:@"6.14.bin"];
    }
    
    if (!firmwarePath || ![[NSFileManager defaultManager] fileExistsAtPath:firmwarePath]) {
        [self addLog:@"❌ 固件包文件不存在，请确保文件已添加到项目中"];
        [self addLog:@"请将固件包文件添加到项目的Bundle中，或放在Documents目录下"];
        [self addLog:@"文件名: BM8701-2-LB-BLE_WIFI-v7.03(v2.05.39b)-ug-20241125.bin"];
        [self resetUpgradeUI];
        return;
    }
    
    NSData *packageData = [NSData dataWithContentsOfFile:firmwarePath];
    
    if (!packageData) {
        [self addLog:@"❌ 无法读取固件包文件"];
        [self resetUpgradeUI];
        return;
    }
    
    [self addLog:[NSString stringWithFormat:@"✅ 成功读取固件包，大小: %lu 字节", (unsigned long)packageData.length]];
    
    // 设置固件版本号（float类型，如7.03）
    float firmwareVersion = 6.14f;
    
    // 设置CRC值（根据您的要求，都设为0）
    uint32_t encryptedCRC = 0;
    uint32_t sourceCRC = 0;
    
    [self addLog:[NSString stringWithFormat:@"固件版本: %.2f", firmwareVersion]];
    [self addLog:[NSString stringWithFormat:@"加密CRC: %u", encryptedCRC]];
    [self addLog:[NSString stringWithFormat:@"源CRC: %u", sourceCRC]];
    
    // 创建升级回调
    __block void (^upgradeCallback)(SLPDataTransferStatus, id) = ^(SLPDataTransferStatus status, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 打印详细的回调信息
            [self addLog:[NSString stringWithFormat:@"📡 收到升级回调 - 状态: %ld", (long)status]];
            [self addLog:[NSString stringWithFormat:@"📡 回调数据类型: %@", [data class]]];
            
            if (data) {
                [self addLog:[NSString stringWithFormat:@"📡 回调数据内容: %@", [data description]]];
            }
            
            // 处理进度更新（如果数据包含进度信息）
            if (data && [data isKindOfClass:NSClassFromString(@"BM8701_2UpgradeInfo")]) {
                [self handleUpgradeProgressUpdate:data];
            }
            
            // 处理最终结果
            if (status == SLPDataTransferStatus_Succeed) {
                [self handleUpgradeSuccess:data];
            } else {
                [self handleUpgradeFailure:status];
            }
        });
    };
    
    // 调用升级接口
    @try {
        [self.bleManager bleBM8701_2:self.currentPeripheral 
                upgradeDeviceWithPackage:packageData
                         firmwareVersion:firmwareVersion
                            encryptedCRC:encryptedCRC
                               sourceCRC:sourceCRC
                                callback:upgradeCallback];
        
        [self addLog:@"✅ 固件升级接口调用成功，等待回调..."];
        
    } @catch (NSException *exception) {
        [self addLog:[NSString stringWithFormat:@"❌ 固件升级接口调用异常: %@", exception.reason]];
        [self resetUpgradeUI];
    }
}



- (void)handleUpgradeSuccess:(id)data {
    [self addLog:@"=== 固件升级成功 ==="];
    [self addLog:[NSString stringWithFormat:@"返回数据类型: %@", [data class]]];
    [self addLog:[NSString stringWithFormat:@"返回数据描述: %@", [data description]]];
    
    // 检查是否为 BM8701_2UpgradeInfo 类型
    if ([data isKindOfClass:NSClassFromString(@"BM8701_2UpgradeInfo")]) {
        [self addLog:@"✅ 收到 BM8701_2UpgradeInfo 类型数据"];
        
        // 尝试获取升级信息（使用运行时反射）
        [self extractUpgradeInfo:data];
        
    } else {
        [self addLog:[NSString stringWithFormat:@"未知数据类型: %@", [data class]]];
        [self addLog:[NSString stringWithFormat:@"返回数据: %@", [data description]]];
    }
    
    // 检查是否为最终完成状态
    BOOL isFinalCompletion = NO;
    
    // 如果是 BM8701_2UpgradeInfo 类型，检查是否有完成标识
    if ([data isKindOfClass:NSClassFromString(@"BM8701_2UpgradeInfo")]) {
        // 使用运行时检查是否有完成状态
        @try {
            id statusValue = [data valueForKey:@"status"];
            if (statusValue && ([statusValue isEqualToString:@"completed"] || 
                               [statusValue isEqualToString:@"finished"] ||
                               [statusValue isEqualToString:@"success"])) {
                isFinalCompletion = YES;
            }
        } @catch (NSException *exception) {
            // 如果无法获取状态，假设是完成状态
            isFinalCompletion = YES;
        }
    }
    
    // 只有在确认是最终完成状态时才显示完成
    if (isFinalCompletion) {
        self.upgradeProgressView.progress = 1.0;
        [self addLog:@"🎉 固件升级流程完成"];
        
        // 延迟重置UI（不重置状态标签，保持完成状态）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resetUpgradeUIAfterCompletion];
        });
    } else {
        [self addLog:@"📊 收到升级进度更新，继续等待完成..."];
    }
}

- (void)handleUpgradeFailure:(SLPDataTransferStatus)status {
    [self addLog:[NSString stringWithFormat:@"❌ 固件升级失败，状态: %ld", (long)status]];
    
    NSString *statusText = @"固件升级状态: 升级失败";
    switch (status) {
        case SLPDataTransferStatus_Failed:
            statusText = @"固件升级状态: 升级失败";
            break;
        case SLPDataTransferStatus_TimeOut:
            statusText = @"固件升级状态: 升级超时";
            break;
        case SLPDataTransferStatus_ConnectionDisabled:
            statusText = @"固件升级状态: 蓝牙已禁用";
            break;
        case SLPDataTransferStatus_ConnectionDisconnected:
            statusText = @"固件升级状态: 连接断开";
            break;
        case SLPDataTransferStatus_ParameterError:
            statusText = @"固件升级状态: 参数错误";
            break;
        case SLPDataTransferStatus_ConfigMode:
            statusText = @"固件升级状态: 配置模式";
            break;
        default:
            statusText = [NSString stringWithFormat:@"固件升级状态: 未知错误(%ld)", (long)status];
            break;
    }
    
    // 延迟重置UI（不重置状态标签，保持失败状态）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self resetUpgradeUIAfterCompletion];
    });
}

- (void)handleUpgradeProgressUpdate:(id)progressData {
    [self addLog:@"🔄 处理升级进度更新"];
    
    if ([progressData isKindOfClass:NSClassFromString(@"BM8701_2UpgradeInfo")]) {
        [self addLog:@"📊 处理 BM8701_2UpgradeInfo 进度数据"];
        [self extractUpgradeInfo:progressData];
    }
}

- (void)extractUpgradeInfo:(id)upgradeInfo {
    // 使用运行时反射获取 BM8701_2UpgradeInfo 的属性
    Class upgradeInfoClass = [upgradeInfo class];
    [self addLog:[NSString stringWithFormat:@"升级信息类: %@", NSStringFromClass(upgradeInfoClass)]];
    
    // 获取所有属性
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(upgradeInfoClass, &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = @(property_getName(property));
        
        @try {
            id value = [upgradeInfo valueForKey:propertyName];
            [self addLog:[NSString stringWithFormat:@"📊 属性 %@: %@", propertyName, value]];
            
            // 如果是进度属性，更新进度条
            if ([propertyName.lowercaseString containsString:@"progress"]) {
                if ([value isKindOfClass:[NSNumber class]]) {
                    float progressValue = [value floatValue];
                    self.upgradeProgressView.progress = progressValue;
                    [self addLog:[NSString stringWithFormat:@"📈 升级进度: %.1f%%", progressValue * 100]];
                }
            }
        } @catch (NSException *exception) {
            [self addLog:[NSString stringWithFormat:@"❌ 无法获取属性 %@: %@", propertyName, exception.reason]];
        }
    }
    
    free(properties);
}

- (void)resetUpgradeUI {
    // 重置升级UI状态
    self.upgradeProgressView.hidden = YES;
    self.upgradeProgressView.progress = 0.0;
    self.upgradeButton.enabled = YES;
}

- (void)resetUpgradeUIAfterCompletion {
    // 重置升级UI状态（保持状态标签不变）
    self.upgradeProgressView.hidden = YES;
    self.upgradeProgressView.progress = 0.0;
    self.upgradeButton.enabled = YES;
    // 不重置状态标签，让用户看到最终结果
}

- (void)disconnectButtonTapped {
    if (!self.currentPeripheral) {
        [self addLog:@"当前没有连接的设备"];
        return;
    }
    
    [self addLog:@"开始断开蓝牙连接..."];
    
    // 创建断开连接回调
    __block void (^disconnectCallback)(SLPBLEDisconnectReturnCodes, NSInteger) = ^(SLPBLEDisconnectReturnCodes code, NSInteger disconnectHandleID) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (code) {
                case SLPBLEDisconnectReturnCode_Succeed:
                    [self addLog:@"✅ 蓝牙连接断开成功"];
                    [self updateConnectionStatus:NO];
                    break;
                case SLPBLEDisconnectReturnCode_Failed:
                    [self addLog:@"❌ 蓝牙连接断开失败"];
                    break;
                case SLPBLEDisconnectReturnCode_Disable:
                    [self addLog:@"❌ 蓝牙已禁用，无法断开连接"];
                    break;
                case SLPBLEDisconnectReturnCode_Timeout:
                    [self addLog:@"❌ 断开连接超时"];
                    break;
                default:
                    [self addLog:[NSString stringWithFormat:@"❌ 断开连接未知错误: %ld", (long)code]];
                    break;
            }
        });
    };
    
    // 调用断开连接接口
    @try {
        BOOL result = [self.bleManager disconnectPeripheral:self.currentPeripheral timeout:5.0 completion:disconnectCallback];
        if (result) {
            [self addLog:@"断开连接接口调用成功"];
        } else {
            [self addLog:@"❌ 断开连接接口调用失败"];
        }
    } @catch (NSException *exception) {
        [self addLog:[NSString stringWithFormat:@"❌ 断开连接接口调用异常: %@", exception.reason]];
    }
}

- (void)updateConnectionStatus:(BOOL)isConnected {
    self.isConnected = isConnected;
    
    if (isConnected) {
        // 连接状态
        self.statusLabel.text = @"状态: 已连接";
        self.statusLabel.textColor = [UIColor greenColor];
        
        // 启用相关按钮
        self.getWorkModeButton.enabled = YES;
        self.setWifiModeButton.enabled = YES;
        self.setBleModeButton.enabled = YES;
        self.disconnectButton.enabled = YES;
        self.upgradeButton.enabled = YES; // 启用固件升级按钮
        
        // 禁用扫描按钮
        self.scanButton.enabled = NO;
    } else {
        // 断开状态
        self.statusLabel.text = @"状态: 未连接";
        self.statusLabel.textColor = [UIColor redColor];
        
        // 禁用相关按钮
        self.getWorkModeButton.enabled = NO;
        self.setWifiModeButton.enabled = NO;
        self.setBleModeButton.enabled = NO;
        self.disconnectButton.enabled = NO;
        self.upgradeButton.enabled = NO; // 禁用固件升级按钮
        
        // 启用扫描按钮
        self.scanButton.enabled = YES;
        
        // 清空设备信息
        self.deviceInfoLabel.text = @"设备信息: 无";
        self.workModeLabel.text = @"工作模式: 未知";
        
        // 清空当前设备
        self.currentPeripheral = nil;
    }
}





#pragma mark - Helper Methods

- (void)addLog:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 确保 message 是字符串类型，并添加额外的安全检查
        NSString *safeMessage = @"";
        
        if (message == nil) {
            safeMessage = @"(nil)";
        } else if ([message isKindOfClass:[NSString class]]) {
            safeMessage = message;
        } else {
            // 对于非字符串对象，使用更安全的方式转换
            @try {
                safeMessage = [NSString stringWithFormat:@"%@", message];
            } @catch (NSException *exception) {
                safeMessage = [NSString stringWithFormat:@"[无法转换的对象: %@]", [message class]];
            }
        }
        
        NSString *timestamp = [NSDateFormatter localizedStringFromDate:[NSDate date] 
                                                               dateStyle:NSDateFormatterNoStyle 
                                                               timeStyle:NSDateFormatterMediumStyle];
        NSString *logMessage = [NSString stringWithFormat:@"[%@] %@\n", timestamp, safeMessage];
        
        // 确保 logTextView.text 不为 nil
        if (self.logTextView.text == nil) {
            self.logTextView.text = @"";
        }
        
        self.logTextView.text = [self.logTextView.text stringByAppendingString:logMessage];
        
        // 滚动到底部 - 修复滚动问题
        if (self.logTextView.text.length > 0) {
            // 使用延迟确保文本已更新
            dispatch_async(dispatch_get_main_queue(), ^{
                NSRange bottom = NSMakeRange(self.logTextView.text.length - 1, 1);
                [self.logTextView scrollRangeToVisible:bottom];
                
                // 强制滚动到底部
                CGFloat maxOffset = self.logTextView.contentSize.height - self.logTextView.frame.size.height;
                if (maxOffset > 0) {
                    [self.logTextView setContentOffset:CGPointMake(0, maxOffset) animated:NO];
                }
            });
        }
    });
}

- (void)handleDiscoveredPeripheral:(SLPPeripheralInfo *)peripheralInfo {
    // 检查是否已经发现过这个设备
    BOOL alreadyDiscovered = NO;
    for (SLPPeripheralInfo *existingInfo in self.discoveredPeripherals) {
        if ([existingInfo.peripheral.identifier isEqual:peripheralInfo.peripheral.identifier]) {
            alreadyDiscovered = YES;
            break;
        }
    }
    
    if (!alreadyDiscovered) {
        [self.discoveredPeripherals addObject:peripheralInfo];
        
        // 使用 SLPPeripheralInfo.name 作为设备名称
        NSString *deviceName = peripheralInfo.name ?: @"未知设备";
        [self addLog:[NSString stringWithFormat:@"发现设备: %@", deviceName]];
        
        // 选择第一个设备
        if (!self.currentPeripheral) {
            self.currentPeripheral = peripheralInfo.peripheral;

            [self addLog:@"已选择设备"];
        }
    }
}

- (void)updateDeviceInfoDisplay:(NSString *)deviceName deviceID:(NSString *)deviceID deviceType:(NSString *)deviceType {
    NSString *infoText = [NSString stringWithFormat:@"设备信息:\n设备名称: %@\n设备类型: %@\n设备ID: %@",
                          deviceName ?: @"未知",
                          deviceType ?: @"未知",
                          deviceID ?: @"未知"];
    
    self.deviceInfoLabel.text = infoText;
}

- (NSString *)getDeviceTypeDescription:(SLPDeviceTypes)deviceType {
    switch (deviceType) {
        case SLPDeviceType_Unknown:
            return @"未知设备";
        case SLPDeviceType_Phone:
            return @"手机";
        case SLPDeviceType_None:
            return @"无设备";
        case SLPDeviceType_Z1:
            return @"Z1设备";
        case SLPDeviceType_Nox:
            return @"Nox设备";
        case SLPDeviceType_Pillow:
            return @"智能枕头";
        case SLPDeviceType_WIFIReston:
            return @"WiFi Reston";
        case SLPDeviceType_BLE_SingleMattress:
            return @"蓝牙单床垫";
        case SLPDeviceType_WIFI_SingleMattress:
            return @"WiFi单床垫";
        case SLPDeviceType_BLE_DoubleMattress:
            return @"蓝牙双床垫";
        case SLPDeviceType_WIFI_DoubleMattress:
            return @"WiFi双床垫";
        case SLPDeviceType_Z2:
            return @"Z2设备";
        case SLPDeviceType_Milky:
            return @"Milky设备";
        case SLPDeviceType_NOX2:
            return @"NOX2设备";
        case SLPDeviceType_NOX2_WiFi:
            return @"NOX2 WiFi";
        case SLPDeviceType_Milky2:
            return @"Milky2设备";
        case SLPDeviceType_Milky2T:
            return @"Milky2T设备";
        case SLPDeviceType_Patch:
            return @"眼罩设备";
        case SLPDeviceType_Z4:
            return @"Z4设备";
        case SLPDeviceType_Z5:
            return @"Z5设备";
        case SLPDeviceType_Z6:
            return @"Z6设备";
        case SLPDeviceType_Sal:
            return @"香薰灯WiFi版";
        case SLPDeviceType_Sal_Ble:
            return @"香薰灯蓝牙版";
        case SLPDeviceType_EW201B:
            return @"唤醒灯蓝牙版";
        case SLPDeviceType_EW201W:
            return @"唤醒灯WiFi版";
        case SLPDeviceType_Binatone:
            return @"贝纳通设备";
        case SLPDeviceType_P3:
            return @"P300设备";
        case SLPDeviceType_M800:
            return @"M800设备";
        default:
            return [NSString stringWithFormat:@"未知类型(%ld)", (long)deviceType];
    }
}

- (NSString *)getConnectStatusDescription:(SLPBleConnectStatus)connectStatus {
    switch (connectStatus) {
        case SLPBleConnectStatus_Connected:
            return @"已连接";
        case SLPBleConnectStatus_Connecting:
            return @"连接中";
        case SLPBleConnectStatus_Disconnected:
            return @"已断开";
        default:
            return [NSString stringWithFormat:@"未知状态(%ld)", (long)connectStatus];
    }
}

- (void)printDiscoveredDevices {
    if (self.discoveredPeripherals.count == 0) {
        [self addLog:@"未发现任何蓝牙设备"];
        return;
    }
    
    [self addLog:@"=== 扫描到的蓝牙设备列表 ==="];
    [self addLog:[NSString stringWithFormat:@"总共发现 %lu 个蓝牙设备:", (unsigned long)self.discoveredPeripherals.count]];
    
    for (NSInteger i = 0; i < self.discoveredPeripherals.count; i++) {
        SLPPeripheralInfo *peripheralInfo = self.discoveredPeripherals[i];
        NSString *deviceName = peripheralInfo.name ?: @"未知设备";
        NSString *deviceID = peripheralInfo.peripheral.identifier.UUIDString;
        
        NSString *deviceInfo = [NSString stringWithFormat:@"%ld. %@\n   ID: %@",
                               (long)(i + 1),
                               deviceName,
                               deviceID];
        
        [self addLog:deviceInfo];
    }
    
    [self addLog:@"=== 设备列表结束 ==="];
    
    // 弹窗选择设备
    [self showDeviceSelectionAlert];
}

- (void)showDeviceSelectionAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择要连接的设备"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSInteger i = 0; i < self.discoveredPeripherals.count; i++) {
        SLPPeripheralInfo *peripheralInfo = self.discoveredPeripherals[i];
        NSString *deviceName = peripheralInfo.name ?: [NSString stringWithFormat:@"设备%ld", (long)(i+1)];
        UIAlertAction *action = [UIAlertAction actionWithTitle:deviceName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.currentPeripheral = peripheralInfo.peripheral;

            [self addLog:[NSString stringWithFormat:@"已选择设备: %@，正在连接...", deviceName]];
            // 使用 BM8701_2 框架的 loginCallback 接口连接设备
            [self connectDeviceWithBM8701_2Login:peripheralInfo.peripheral deviceName:deviceName];
        }];
        [alert addAction:action];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    
    // 适配iPad
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = self.view.bounds;
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 使用 BM8701_2 框架的 loginCallback 接口连接设备
- (void)connectDeviceWithBM8701_2Login:(CBPeripheral *)peripheral deviceName:(NSString *)deviceName {
    if (!peripheral) {
        [self addLog:@"设备对象为空"];
        return;
    }
    
    self.currentPeripheral = peripheral;
    [self addLog:[NSString stringWithFormat:@"开始使用 BM8701_2 loginCallback 连接设备: %@", deviceName]];
    
    // 检查 loginCallback 方法是否存在
    SEL loginSelector = @selector(bleBM8701_2:loginCallback:);
    if (![self.bleManager respondsToSelector:loginSelector]) {
        [self addLog:@"❌ BM8701_2 loginCallback 方法不可用"];
        return;
    }
    
    [self addLog:@"✅ BM8701_2 loginCallback 方法可用，开始连接..."];
    
    // 创建登录回调
    __block void (^loginCallback)(SLPDataTransferStatus, id) = ^(SLPDataTransferStatus status, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == SLPDataTransferStatus_Succeed) {
                [self addLog:@"=== BM8701_2 登录成功 ==="];
                [self addLog:[NSString stringWithFormat:@"登录返回数据类型: %@", [data class]]];
                [self addLog:[NSString stringWithFormat:@"登录返回数据: %@", [data description]]];
                
                // 更新连接状态
                [self updateConnectionStatus:YES];
                
                // 登录成功后自动获取设备信息
                [self getDeviceInfoFromBM8701_2];
                
            } else {
                [self addLog:[NSString stringWithFormat:@"❌ BM8701_2 登录失败，状态: %ld", (long)status]];
            }
        });
    };
    
    // 调用 BM8701_2 登录接口
    @try {
        [self.bleManager bleBM8701_2:peripheral loginCallback:loginCallback];
        [self addLog:@"BM8701_2 登录接口调用成功，等待回调..."];
    } @catch (NSException *exception) {
        [self addLog:[NSString stringWithFormat:@"❌ BM8701_2 登录接口调用异常: %@", exception.reason]];
    }
}

// 获取 BM8701_2 设备信息
- (void)getDeviceInfoFromBM8701_2 {
    if (!self.currentPeripheral) {
        [self addLog:@"当前没有连接的设备"];
        return;
    }
    
    [self addLog:@"开始获取 BM8701_2 设备信息..."];
    
    // 创建回调
    __block void (^callback)(SLPDataTransferStatus, id) = ^(SLPDataTransferStatus status, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == SLPDataTransferStatus_Succeed) {
                [self addLog:@"=== BM8701_2 设备信息获取成功 ==="];
                [self addLog:[NSString stringWithFormat:@"返回数据类型: %@", [data class]]];
                [self addLog:[NSString stringWithFormat:@"返回数据描述: %@", [data description]]];
                
                    BM8701_2DeviceInfo *deviceInfo = (BM8701_2DeviceInfo *)data;
                    
                    NSString *deviceID = deviceInfo.deviceID ?: @"未知";
                    NSString *deviceType = [NSString stringWithFormat:@"%hu", deviceInfo.deviceType];
                    NSString *currentHardwareVersion = deviceInfo.currentHardwareVersion ?: @"未知";
                    NSString *initialHardwareVersion = deviceInfo.initialHardwareVersion ?: @"未知";
                    
                    NSString *infoText = [NSString stringWithFormat:@"设备ID: %@\n设备类型: %@\n当前版本: %@\n初始版本: %@", 
                                         deviceID, deviceType, currentHardwareVersion, initialHardwareVersion];
                    
                    self.deviceInfoLabel.text = infoText;
                    [self addLog:infoText];
                    
             
            } else {
                [self addLog:[NSString stringWithFormat:@"BM8701_2 设备信息获取失败，状态: %ld", (long)status]];
            }
        });
    };
    
    // 调用接口
    @try {
        [self.bleManager bleBM8701_2:self.currentPeripheral getDeviceInfoTimeout:10.0 callback:callback];
        [self addLog:@"BM8701_2 设备信息接口调用成功"];
    } @catch (NSException *exception) {
        [self addLog:[NSString stringWithFormat:@"BM8701_2 设备信息接口调用异常: %@", exception.reason]];
    }
}



#pragma mark - 工作模式相关方法

- (void)getWorkModeButtonTapped {
    if (!self.currentPeripheral) {
        [self addLog:@"当前没有连接的设备"];
        return;
    }
    
    [self addLog:@"开始获取工作模式..."];
    
    // 创建回调
    __block void (^callback)(SLPDataTransferStatus, id) = ^(SLPDataTransferStatus status, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == SLPDataTransferStatus_Succeed) {
                [self addLog:@"=== 获取工作模式成功 ==="];
                [self addLog:[NSString stringWithFormat:@"返回数据类型: %@", [data class]]];
                [self addLog:[NSString stringWithFormat:@"返回数据描述: %@", [data description]]];
                
                if ([data isKindOfClass:[NSNumber class]]) {
                    NSNumber *workMode = (NSNumber *)data;
                    NSInteger mode = [workMode integerValue];
                    NSString *modeText = (mode == 0) ? @"WIFI模式" : @"BLE模式";
                    
                    self.workModeLabel.text = [NSString stringWithFormat:@"工作模式: %@", modeText];
                    [self addLog:[NSString stringWithFormat:@"当前工作模式: %@ (%ld)", modeText, (long)mode]];
                } else {
                    [self addLog:[NSString stringWithFormat:@"未知数据类型: %@", [data class]]];
                    [self addLog:[NSString stringWithFormat:@"返回数据: %@", [data description]]];
                }
            } else {
                [self addLog:[NSString stringWithFormat:@"❌ 获取工作模式失败，状态: %ld", (long)status]];
            }
        });
    };
    
    // 调用接口
    @try {
        [self.bleManager bleBM8701_2:self.currentPeripheral getWorkModeTimeout:5.0 callback:callback];
        [self addLog:@"获取工作模式接口调用成功"];
    } @catch (NSException *exception) {
        [self addLog:[NSString stringWithFormat:@"❌ 获取工作模式接口调用异常: %@", exception.reason]];
    }
}

- (void)setWifiModeButtonTapped {
    [self setWorkMode:0 modeName:@"WIFI"];
}

- (void)setBleModeButtonTapped {
    [self setWorkMode:1 modeName:@"BLE"];
}

- (void)setWorkMode:(UInt8)workMode modeName:(NSString *)modeName {
    if (!self.currentPeripheral) {
        [self addLog:@"当前没有连接的设备"];
        return;
    }
    
    [self addLog:[NSString stringWithFormat:@"开始设置工作模式为: %@", modeName]];
    
    // 创建回调
    __block void (^callback)(SLPDataTransferStatus, id) = ^(SLPDataTransferStatus status, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == SLPDataTransferStatus_Succeed) {
                [self addLog:[NSString stringWithFormat:@"✅ 设置%@模式成功", modeName]];
        
                
                // 设置成功后更新工作模式标签
                self.workModeLabel.text = [NSString stringWithFormat:@"工作模式: %@模式", modeName];
                
                // 延迟1秒后自动获取最新工作模式
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self getWorkModeButtonTapped];
                });
            } else {
                [self addLog:[NSString stringWithFormat:@"❌ 设置%@模式失败，状态: %ld", modeName, (long)status]];
            }
        });
    };
    
    // 调用接口
    @try {
        [self.bleManager bleBM8701_2:self.currentPeripheral setWorkMode:workMode timeout:5.0 callback:callback];
        [self addLog:[NSString stringWithFormat:@"设置%@模式接口调用成功", modeName]];
    } @catch (NSException *exception) {
        [self addLog:[NSString stringWithFormat:@"❌ 设置%@模式接口调用异常: %@", modeName, exception.reason]];
    }
}

#pragma mark - 蓝牙连接状态监听

- (void)setupBluetoothStatusMonitoring {
    // 监听蓝牙设备连接成功通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBluetoothDeviceConnected:)
                                                 name:kNotificationNameBLEDeviceConnected
                                               object:nil];
    
    // 监听蓝牙设备断开连接通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBluetoothDeviceDisconnected:)
                                                 name:kNotificationNameBLEDeviceDisconnect
                                               object:nil];
    
    // 监听蓝牙启用通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBluetoothEnabled:)
                                                 name:kNotificationNameBLEEnable
                                               object:nil];
    
    // 监听蓝牙禁用通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBluetoothDisabled:)
                                                 name:kNotificationNameBLEDisable
                                               object:nil];
    
    [self addLog:@"蓝牙连接状态监听已设置"];
}

- (void)removeBluetoothStatusMonitoring {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationNameBLEDeviceConnected object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationNameBLEDeviceDisconnect object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationNameBLEEnable object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationNameBLEDisable object:nil];
    
    [self addLog:@"蓝牙连接状态监听已移除"];
}

- (void)handleBluetoothDeviceConnected:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:@"🔵 蓝牙设备连接成功通知"];
        
        // 获取通知中的设备信息
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            [self addLog:[NSString stringWithFormat:@"连接通知用户信息: %@", userInfo]];
            
            // 检查是否是我们当前连接的设备
            CBPeripheral *connectedPeripheral = userInfo[@"peripheral"];
            if (connectedPeripheral && [connectedPeripheral.identifier isEqual:self.currentPeripheral.identifier]) {
                [self addLog:@"✅ 确认是当前设备连接成功"];
                [self updateConnectionStatus:YES];
            } else if (connectedPeripheral) {
                [self addLog:[NSString stringWithFormat:@"其他设备连接成功: %@", connectedPeripheral.name ?: @"未知设备"]];
            }
        }
        
        // 更新连接状态
        if (!self.isConnected) {
            [self addLog:@"自动更新连接状态为已连接"];
            [self updateConnectionStatus:YES];
        }
    });
}

- (void)handleBluetoothDeviceDisconnected:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:@"🔴 蓝牙设备断开连接通知"];
        
        // 获取通知中的设备信息
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            [self addLog:[NSString stringWithFormat:@"断开通知用户信息: %@", userInfo]];
            
            // 检查是否是我们当前连接的设备
            CBPeripheral *disconnectedPeripheral = userInfo[@"peripheral"];
            if (disconnectedPeripheral && [disconnectedPeripheral.identifier isEqual:self.currentPeripheral.identifier]) {
                [self addLog:@"✅ 确认是当前设备断开连接"];
                [self updateConnectionStatus:NO];
            } else if (disconnectedPeripheral) {
                [self addLog:[NSString stringWithFormat:@"其他设备断开连接: %@", disconnectedPeripheral.name ?: @"未知设备"]];
            }
        }
        
        // 更新连接状态
        if (self.isConnected) {
            [self addLog:@"自动更新连接状态为未连接"];
            [self updateConnectionStatus:NO];
        }
    });
}

- (void)handleBluetoothEnabled:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:@"🔵 蓝牙已启用"];
        
        // 更新UI状态
        self.scanButton.enabled = YES;
        [self addLog:@"扫描按钮已启用"];
    });
}

- (void)handleBluetoothDisabled:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:@"🔴 蓝牙已禁用"];
        
        // 更新UI状态
        self.scanButton.enabled = NO;
        [self addLog:@"扫描按钮已禁用"];
        
        // 如果当前已连接，则断开连接
        if (self.isConnected) {
            [self addLog:@"蓝牙禁用，自动断开当前连接"];
            [self updateConnectionStatus:NO];
        }
    });
}

// 定期检查连接状态的方法
- (void)startConnectionStatusMonitoring {
    // 创建定时器，每5秒检查一次连接状态
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(checkConnectionStatus)
                                   userInfo:nil
                                    repeats:YES];
    
    [self addLog:@"连接状态定期检查已启动（每5秒）"];
}

- (void)checkConnectionStatus {
    if (!self.currentPeripheral) {
        return;
    }
    
    // 使用框架方法检查连接状态
    SLPBleConnectStatus connectStatus = [self.bleManager checkPeripheralConnecteStatus:self.currentPeripheral];
    BOOL isConnected = [self.bleManager peripheralIsConnected:self.currentPeripheral];
    
    // 如果状态不一致，更新UI
    if (self.isConnected != isConnected) {
        [self addLog:[NSString stringWithFormat:@"连接状态检查：框架返回 %@，UI显示 %@", 
                     isConnected ? @"已连接" : @"未连接",
                     self.isConnected ? @"已连接" : @"未连接"]];
        
        [self updateConnectionStatus:isConnected];
    }
    
    // 记录连接状态变化
    static SLPBleConnectStatus lastStatus = -1;
    if (lastStatus != connectStatus) {
        [self addLog:[NSString stringWithFormat:@"连接状态变化: %@ -> %@", 
                     [self getConnectStatusDescription:lastStatus],
                     [self getConnectStatusDescription:connectStatus]]];
        lastStatus = connectStatus;
    }
}

- (void)dealloc {
    // 移除蓝牙连接状态监听
    [self removeBluetoothStatusMonitoring];
}

@end
