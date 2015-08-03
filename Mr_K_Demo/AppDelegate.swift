//
//  AppDelegate.swift
//  Mr_K_Demo
//
//  Created by Leff on 15/8/3.
//  Copyright (c) 2015年 LeffPan. All rights reserved.
//

import UIKit
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CBPeripheralManagerDelegate {

    var window: UIWindow?
    //设备用户名 —— Set user's name
    let userName:String = "Leff's"
    //设备的唯一识别码 —— Set device's UUID
    let deviceUUID = UIDevice.currentDevice().identifierForVendor
    //服务的UUID —— Set service's UUID
    let kServiceUUID:String = "C4FB2349-72FE-4CA2-94D6-1F3CB16331EE"
    //特征的UUID —— Set characteristic's UUID
    let kCharacteristicUUID_1:String = "6A3E4B28-522D-4B3B-82A9-D5E2004534FA"
    let kCharacteristicUUID_2:String = "6A3E4B28-522D-4B3B-82A9-D5E2004534FB"
    let kCharacteristicUUID_3:String = "6A3E4B28-522D-4B3B-82A9-D5E2004534FC"

    var peripheralManager = CBPeripheralManager()
    var centralA = NSMutableArray()
    //保存设备用户名称（后期修改，在用户更改用户名和程序启动的时候同步
    var characteristic_UserName = CBMutableCharacteristic()
    //保存时间
    var characteristic_Time = CBMutableCharacteristic()
    //保存设备唯一识别码
    var characteristic_DeviceUUID = CBMutableCharacteristic()
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if(peripheral.state == CBPeripheralManagerState.PoweredOn){
            let serviceUUID:CBUUID = CBUUID.init(string: kServiceUUID)
            
            //添加服务后开始广播 —— Start advertising
//            let dic:Dictionary = [CBAdvertisementDataLocalNameKey:"My device",CBAdvertisementDataServiceUUIDsKey:serviceUUID]
//            self.peripheralManager.startAdvertising(dic)
            let dic:Dictionary = [CBAdvertisementDataLocalNameKey:"My device"]
            let dic2:Dictionary = [CBAdvertisementDataServiceUUIDsKey:serviceUUID]
            self.peripheralManager.startAdvertising(dic)
            self.peripheralManager.startAdvertising(dic2)
            
            //要添加的characteristic初始化 —— Initial the characteristics
            let characteristic1:CBUUID = CBUUID.init(string: kCharacteristicUUID_1)
            let characteristic2:CBUUID = CBUUID.init(string: kCharacteristicUUID_2)
            let characteristic3:CBUUID = CBUUID.init(string: kCharacteristicUUID_3)
            
            characteristic_UserName = CBMutableCharacteristic.init(
                type:characteristic1,
                properties: CBCharacteristicProperties.Read | CBCharacteristicProperties.WriteWithoutResponse | CBCharacteristicProperties.Notify,
                value: nil,
                permissions: CBAttributePermissions.Readable | CBAttributePermissions.Writeable
            )
            characteristic_Time = CBMutableCharacteristic.init(
                type:characteristic2,
                properties: CBCharacteristicProperties.Read | CBCharacteristicProperties.WriteWithoutResponse | CBCharacteristicProperties.Notify,
                value: nil,
                permissions: CBAttributePermissions.Readable | CBAttributePermissions.Writeable
            )
            characteristic_DeviceUUID = CBMutableCharacteristic.init(
                type:characteristic3,
                properties: CBCharacteristicProperties.Read | CBCharacteristicProperties.WriteWithoutResponse | CBCharacteristicProperties.Notify,
                value: nil,
                permissions: CBAttributePermissions.Readable | CBAttributePermissions.Writeable
            )
            
            //要添加的service初始化 —— Initial the service
            var serviceM: CBMutableService = CBMutableService.init(type : serviceUUID, primary : true)
            serviceM.characteristics = [characteristic_UserName,characteristic_Time,characteristic_DeviceUUID]
            
            peripheralManager.addService(serviceM)
            
            updateCharacteristicValue()
        }

    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, willRestoreState dict: [NSObject : AnyObject]!) {
        
    }
    
    func updateCharacteristicValue() {
        
        //当前时间，存在strNowTime:String中 —— Get time for now
        var date = NSDate()
        var timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "yyy-MM-dd 'at' HH:mm:ss.SSS"
        var strNowTime = timeFormatter.stringFromDate(date) as String
        
        //将存入characteristic内容转成NSData —— Translate data-to-broadcast to NSData
        let userNameInNSData:NSData = userName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        let timeInNSData:NSData = strNowTime.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        let deviceUUIDInNSData:NSData = deviceUUID.UUIDString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        
        //更新特征值 —— Update characteristics
        self.peripheralManager.updateValue(userNameInNSData, forCharacteristic: self.characteristic_UserName, onSubscribedCentrals: nil)
        self.peripheralManager.updateValue(timeInNSData, forCharacteristic: self.characteristic_Time, onSubscribedCentrals: nil)
        self.peripheralManager.updateValue(deviceUUIDInNSData, forCharacteristic: self.characteristic_DeviceUUID, onSubscribedCentrals: nil)
        
        var strToPrintln:String = "更新特征值：\n"
        strToPrintln += "特征1：" + userName + "\n"
        strToPrintln += "特征2：" + strNowTime + "\n"
        strToPrintln += "特征3：" + deviceUUID.UUIDString + "\n"
        
        println(strToPrintln)
        
    }

    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.peripheralManager =  CBPeripheralManager.init(delegate:self,queue:nil,options:[CBPeripheralManagerOptionRestoreIdentifierKey:"myPeripheralManagerIdentifier"])
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

