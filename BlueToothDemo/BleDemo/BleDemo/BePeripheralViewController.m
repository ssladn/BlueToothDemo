//
//  BePeripheralViewController.m
//  BleDemo
//
//  Created by linguomao on 2017/11/20.
//  Copyright © 2017年 lin_gm. All rights reserved.
//

#import "BePeripheralViewController.h"

#define SRCEENWIDTH [UIScreen mainScreen].bounds.size.width
#define SRCEENHEIGHT [UIScreen mainScreen].bounds.size.height

static NSString *const ServiceUUID1 =  @"FFF0";
static NSString *const notiyCharacteristicUUID =  @"FFF1";
static NSString *const readwriteCharacteristicUUID =  @"FFF2";
static NSString *const ServiceUUID2 =  @"FFE0";
static NSString *const readCharacteristicUUID =  @"FFE1";
static NSString * const LocalNameKey =  @"GiannPeripheral";

@implementation BePeripheralViewController{
    CBPeripheralManager *peripheralManager;
    //定时器
    NSTimer *timer;
    //添加成功的service数量
    int serviceNum;
    UILabel *info;
    
    NSInteger num;
    NSString *textStr;
    
    CBMutableCharacteristic *notiCBNotify;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     和CBCentralManager类似，蓝牙设备打开需要一定时间，打开成功后会进入委托方法
     - (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral;
     模拟器永远也不会得CBPeripheralManagerStatePoweredOn状态
     */
    peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
    //页面样式
    [self.view setBackgroundColor:[UIColor whiteColor]];
    info = [[UILabel alloc]initWithFrame:CGRectMake(0, 64, SRCEENWIDTH, 40)];
    info.numberOfLines = 0;
    info.font = [UIFont systemFontOfSize:14];
    [info setText:@"正在打开设备"];
    [info setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:info];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 40+64, SRCEENWIDTH, (SRCEENHEIGHT-134)/2)];
    btn.backgroundColor = [UIColor greenColor];
    [btn setTitle:@"yes" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(sendMesage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btn.frame)+30, SRCEENWIDTH, (SRCEENHEIGHT-134)/2)];
    btn2.backgroundColor = [UIColor redColor];
    [btn2 setTitle:@"no" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(sendMesage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [peripheralManager stopAdvertising];
}

- (void)sendMesage:(UIButton *)btn
{
    if (notiCBNotify) {
        NSString *str = btn.titleLabel.text;
        [self sendData2:notiCBNotify andMessage:str];

    }
    else
    {
        NSLog(@"暂无订阅");
    }
}

//配置bluetooch的
-(void)setUp{
    //characteristics字段描述
    CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
    
    /*
     可以通知的Characteristic
     properties：CBCharacteristicPropertyNotify 
     permissions CBAttributePermissionsReadable
     */
    CBMutableCharacteristic *notiyCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:notiyCharacteristicUUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];

    /*
     可读写的characteristics
     properties：CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead
     permissions CBAttributePermissionsReadable | CBAttributePermissionsWriteable
     */
    CBMutableCharacteristic *readwriteCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:readwriteCharacteristicUUID] properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    //设置description
    CBMutableDescriptor *readwriteCharacteristicDescription1 = [[CBMutableDescriptor alloc]initWithType: CBUUIDCharacteristicUserDescriptionStringUUID value:@"name"];
    [readwriteCharacteristic setDescriptors:@[readwriteCharacteristicDescription1]];
    

    /*
     只读的Characteristic
     properties：CBCharacteristicPropertyRead
     permissions CBAttributePermissionsReadable
     */
    CBMutableCharacteristic *readCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:readCharacteristicUUID] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];

    
    //service1初始化并加入两个characteristics
    CBMutableService *service1 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:ServiceUUID1] primary:YES];
    NSLog(@"%@",service1.UUID);
    
    [service1 setCharacteristics:@[notiyCharacteristic,readwriteCharacteristic]];
    
    //service2初始化并加入一个characteristics
    CBMutableService *service2 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:ServiceUUID2] primary:YES];
    [service2 setCharacteristics:@[readCharacteristic]];
    
    //添加后就会调用代理的- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
    [peripheralManager addService:service1];
    [peripheralManager addService:service2];
}




#pragma  mark -- CBPeripheralManagerDelegate

//peripheralManager状态改变
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    switch (peripheral.state) {
            //在这里判断蓝牙设别的状态  当开启了则可调用  setUp方法(自定义)
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"powered on");
            [info setText:[NSString stringWithFormat:@"设备名%@已经打开，可以使用center进行连接",LocalNameKey]];
            [self setUp];
            break;
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"powered off");
            [info setText:@"powered off"];
            break;
            
        default:
            break;
    }
}

//perihpheral添加了service
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (error == nil) {
        serviceNum++;
    }

    //因为我们添加了2个服务，所以想两次都添加完成后才去发送广播
    if (serviceNum==2) {
        //添加服务后可以在此向外界发出通告 调用完这个方法后会调用代理的
        //(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
        [peripheralManager startAdvertising:@{
                                              CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:ServiceUUID1],[CBUUID UUIDWithString:ServiceUUID2]],
                                              CBAdvertisementDataLocalNameKey : LocalNameKey
                                             }
         ];
        
    }
    
}

//peripheral开始发送advertising
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    NSLog(@"in peripheralManagerDidStartAdvertisiong");
}

//订阅characteristics
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"订阅了 %@的数据",characteristic.UUID);
    //每秒执行一次给主设备发送一个当前时间的秒数
//    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendData:) userInfo:characteristic  repeats:YES];
    info.text = [[NSString stringWithFormat:@"设备名%@已经打开，可以使用center进行连接",LocalNameKey] stringByAppendingString:[NSString stringWithFormat:@"订阅了 %@的数据",characteristic.UUID]];
    notiCBNotify = (CBMutableCharacteristic *)characteristic;
//    [self sendData2:(CBMutableCharacteristic *)characteristic andMessage:@"yes"];
}

//取消订阅characteristics
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"取消订阅 %@的数据",characteristic.UUID);
    info.text = [[NSString stringWithFormat:@"设备名%@已经打开，可以使用center进行连接",LocalNameKey] stringByAppendingString:[NSString stringWithFormat:@"取消订阅 %@的数据",characteristic.UUID]];

    //取消回应
//    [timer invalidate];
}

//发送数据，发送当前时间的秒数
-(BOOL)sendData2:(CBMutableCharacteristic *)cht andMessage:(NSString *)msg {
    CBMutableCharacteristic *characteristic = cht;

    //    NSData *data = [@"1234567890123456789012345678901234567890" dataUsingEncoding:NSUTF8StringEncoding];
    //执行回应Central通知数据
    return  [peripheralManager updateValue:[msg dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:nil];
}
//发送数据，发送当前时间的秒数
-(BOOL)sendData:(NSTimer *)t {
    CBMutableCharacteristic *characteristic = t.userInfo;
    NSDateFormatter *dft = [[NSDateFormatter alloc]init];
    [dft setDateFormat:@"ss"];
    NSLog(@"%@",[dft stringFromDate:[NSDate date]]);
//    [[dft stringFromDate:[NSDate date]] dataUsingEncoding:NSUTF8StringEncoding]
    if (textStr.length>0) {
        textStr = [textStr stringByAppendingString:[dft stringFromDate:[NSDate date]]];
    }
    else
    {
        textStr = [dft stringFromDate:[NSDate date]];
    }
//    NSData *data = [@"1234567890123456789012345678901234567890" dataUsingEncoding:NSUTF8StringEncoding];
    //执行回应Central通知数据
    return  [peripheralManager updateValue:[textStr dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:nil];
}


//读characteristics请求
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    NSLog(@"didReceiveReadRequest");
    //判断是否有读数据的权限
    if (request.characteristic.properties & CBCharacteristicPropertyRead) {
        NSData *data = request.characteristic.value;
        [request setValue:data];
        //对请求作出成功响应
        [peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }else{
        [peripheralManager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
}


//写characteristics请求
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    NSLog(@"didReceiveWriteRequests");
    CBATTRequest *request = requests[0];
    
    //判断是否有写数据的权限
    if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
        //需要转换成CBMutableCharacteristic对象才能进行写值
        CBMutableCharacteristic *c =(CBMutableCharacteristic *)request.characteristic;
        c.value = request.value;
        NSData *data = request.value;
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",str);
        NSString *text = info.text;
        info.text = [text stringByAppendingString:str];
        [peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        
        BOOL issend = [peripheralManager updateValue:[text dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:(CBMutableCharacteristic *)c onSubscribedCentrals:nil];
        NSLog(@"%d",issend);

    }else{
        [peripheralManager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
    
    
}

//
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral{
    NSLog(@"peripheralManagerIsReadyToUpdateSubscribers");
    
}


@end
