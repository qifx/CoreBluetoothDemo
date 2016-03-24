//
//  AdViewController.swift
//  BlueToothTest
//
//  Created by qifx on 3/21/16.
//  Copyright © 2016 qifx. All rights reserved.
//  外围设备

import UIKit
import CoreBluetooth


var kServiceUUID = "CDC504CF-22D4-47DC-B842-3E0DB8BE2594"
var kCharacteristicUUID = "334E6E68-D6AE-4DDD-86B9-96D2AC80E396"
var name = "CoreBluetoothTestDevice"

class AdViewController: UIViewController, CBPeripheralDelegate, CBPeripheralManagerDelegate {
    @IBOutlet weak var tv: UITextView!

    var pm: CBPeripheralManager!
    var characteristicM: CBMutableCharacteristic!
    var centrals = [CBCentral]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func ad(sender: AnyObject) {
        pm = CBPeripheralManager(delegate: self, queue: nil)
        log("创建外围设备:\(pm.description)")
    }
    
    func setup() {
        let characteristicUUID = CBUUID(string: kCharacteristicUUID)
        let characteristicM = CBMutableCharacteristic(type: characteristicUUID, properties: .Notify, value: nil, permissions: .Readable)
        self.characteristicM = characteristicM
        let serviceUUID = CBUUID(string: kServiceUUID)
        let serviceM = CBMutableService(type: serviceUUID, primary: true)
        serviceM.characteristics = [characteristicM]
        pm.addService(serviceM)
        log("添加服务:\(serviceM.UUID)")
        log("添加特征:\(characteristicM.UUID)")
    }
    
    func updateCharacteristicValue(){
        let valueStr = kCharacteristicUUID + "--\(NSDate().timeIntervalSince1970)"
        let data = valueStr.dataUsingEncoding(NSUTF8StringEncoding)
        pm.updateValue(data!, forCharacteristic: self.characteristicM, onSubscribedCentrals: nil)
        log("更新特征值：\(valueStr)")
    }

    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            log("BLE已打开")
            setup()
        } else {
            log("此设备不支持BLE或未打开蓝牙功能，无法作为外围设备.")
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if error != nil {
            log("添加服务失败：\(error!.localizedDescription)")
            return
        }
        log("添加服务成功：\(service.UUID)")
        let dic = [CBAdvertisementDataLocalNameKey: name]
        pm.startAdvertising(dic)
        log("开始启动广播...\(name)")
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if error != nil {
            log("启动广播失败：\(error!.localizedDescription)")
            return
        }
        log("已经启动广播...")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        log("中心设备\(central)已订阅特征\(characteristic)")
        if !centrals.contains(central) {
            centrals.append(central)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        log("didUnsubscribeFromCharacteristic")
    }

    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        log("didReceiveReadRequest")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        log("didReceiveWriteRequests")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, willRestoreState dict: [String : AnyObject]) {
        log("willRestoreState")
    }
    
    func log(str: String) {
        tv.text = tv.text + "\n" + str
    }
}
