//
//  AppDelegate.swift
//  Mr_K_Demo
//
//  Created by Leff on 15/8/3.
//  Copyright (c) 2015年 LeffPan. All rights reserved.
//

import UIKit
import CoreBluetooth
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CBPeripheralManagerDelegate,CBPeripheralDelegate {

    var window: UIWindow?
    //设备用户名 —— Set user's name
    let userName:String = "Leff's"
    //设备的唯一识别码 —— Set device's UUID
    let deviceUUID = UIDevice.currentDevice().identifierForVendor
    //服务的UUID —— Set service's UUID
    let kServiceUUID:String = "C4FB2349-72FE-4CA2-94D6-1F3CB16222AA"
    //特征的UUID —— Set characteristic's UUID
    let kCharacteristicUUID_1:String = "6A3E4B28-522D-4B3B-82A9-D5E2004534FA"
    let kCharacteristicUUID_2:String = "6A3E4B28-522D-4B3B-82A9-D5E2004534FB"
    let kCharacteristicUUID_3:String = "6A3E4B28-522D-4B3B-82A9-D5E2004534FC"

    internal var peripheralManager = CBPeripheralManager()
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
//TODO:Make it look better
            var advertisementData : [NSObject:AnyObject] = [CBAdvertisementDataLocalNameKey:"Leff"]
            advertisementData[CBAdvertisementDataServiceUUIDsKey] = [serviceUUID]
            self.peripheralManager.startAdvertising(advertisementData)
            
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
            
//            var datastring = NSString(data: characteristic_UserName.value!, encoding: NSUTF8StringEncoding)
//
//            println(datastring)
            
            peripheralManager.addService(serviceM)
            
//            updateCharacteristicValue()
            
        }

    }
    
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
//        if characteristic == characteristic_UserName {
//            let userNameInNSData:NSData = userName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
//            self.peripheralManager.updateValue(userNameInNSData, forCharacteristic: self.characteristic_UserName, onSubscribedCentrals: nil)
//            println("特征1：" + userName + "\n")
//        }
        
        var getUUID: CBUUID = characteristic.UUID
        
        let characteristic1:CBUUID = CBUUID.init(string: kCharacteristicUUID_1)
        let characteristic2:CBUUID = CBUUID.init(string: kCharacteristicUUID_2)
        let characteristic3:CBUUID = CBUUID.init(string: kCharacteristicUUID_3)
        
        //当前时间，存在strNowTime:String中 —— Get time for now
        var date = NSDate()
        var timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "yyy-MM-dd 'at' HH:mm:ss.SSS"
        var strNowTime = timeFormatter.stringFromDate(date) as String
        
        switch (characteristic.UUID){
        case characteristic1:
            let userNameInNSData:NSData = userName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
            self.peripheralManager.updateValue(userNameInNSData, forCharacteristic: self.characteristic_UserName, onSubscribedCentrals: nil)
            println("特征1：" + userName + "\n")
            
        case characteristic2:
            let timeInNSData:NSData = strNowTime.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
            self.peripheralManager.updateValue(timeInNSData, forCharacteristic: self.characteristic_Time, onSubscribedCentrals: nil)
            println("特征2：" + strNowTime + "\n")
            
        case characteristic3:
            let deviceUUIDInNSData:NSData = deviceUUID.UUIDString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
            self.peripheralManager.updateValue(deviceUUIDInNSData, forCharacteristic: self.characteristic_DeviceUUID, onSubscribedCentrals: nil)
            println("特征3：" + deviceUUID.UUIDString + "\n")
            
        default:
            println("Characteristic not found in service")
        }
        
        
//        //当前时间，存在strNowTime:String中 —— Get time for now
//        var date = NSDate()
//        var timeFormatter = NSDateFormatter()
//        timeFormatter.dateFormat = "yyy-MM-dd 'at' HH:mm:ss.SSS"
//        var strNowTime = timeFormatter.stringFromDate(date) as String
//        
//        //将存入characteristic内容转成NSData —— Translate data-to-broadcast to NSData
//        let userNameInNSData:NSData = userName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
//        let timeInNSData:NSData = strNowTime.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
//        let deviceUUIDInNSData:NSData = deviceUUID.UUIDString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
//        
//        //更新特征值 —— Update characteristics
//        //        self.peripheralManager.updateValue(userNameInNSData, forCharacteristic: self.characteristic_UserName, onSubscribedCentrals: nil)
//        //        self.peripheralManager.updateValue(timeInNSData, forCharacteristic: self.characteristic_Time, onSubscribedCentrals: nil)
//        //        self.peripheralManager.updateValue(deviceUUIDInNSData, forCharacteristic: self.characteristic_DeviceUUID, onSubscribedCentrals: nil)
//        
//        var strToPrintln:String = "更新特征值：\n"
//        strToPrintln += "特征1：" + userName + "\n"
//        strToPrintln += "特征2：" + strNowTime + "\n"
//        strToPrintln += "特征3：" + deviceUUID.UUIDString + "\n"
//        
//        println(strToPrintln)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didAddService service: CBService!, error: NSError!) {
        
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
        self.peripheralManager =  CBPeripheralManager.init(delegate:self,queue:nil,options:[CBPeripheralManagerOptionRestoreIdentifierKey:"peripheralRestoreKey"])
        
        return true
    }


}

