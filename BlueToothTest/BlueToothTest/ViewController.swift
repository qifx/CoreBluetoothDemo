//
//  ViewController.swift
//  BlueToothTest
//
//  Created by qifx on 1/25/16.
//  Copyright © 2016 qifx. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var manager: CBCentralManager!
    var didDiscoverPeripherals = [CBPeripheral]()
    var connectedPeripheral: CBPeripheral!
    
    @IBOutlet weak var tv: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func search(sender: AnyObject) {
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Delegate
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            manager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            log("BLE已打开")
        default:
            log("此设备不支持BLE或未打开蓝牙功能，无法作为中心设备.")
        }
    }
    
    
    

    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        log("发现外围设备")
        manager.stopScan()
        if !didDiscoverPeripherals.contains(peripheral) {
            didDiscoverPeripherals.append(peripheral)
        }
        log(peripheral.description)
        log("开始连接外围设备...")
        manager.connectPeripheral(peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        log("连接外围设备成功")
        connectedPeripheral = peripheral
        connectedPeripheral.delegate = self
        log("开始发现服务...")
        connectedPeripheral.discoverServices(nil)
    }

    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        log("连接外围设备失败")
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        log("外围设备连接断开")
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        log("willRestoreState")
    }
    
    //MAKR: Peripheral
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        log("发现可用服务")
        if error != nil {
            log(error!.description)
            return
        }
        
        let serviceUUID = CBUUID(string: kServiceUUID)
        let characteristicUUID = CBUUID(string: kCharacteristicUUID)
        for s in peripheral.services! {
            if s.UUID == serviceUUID {
                peripheral.discoverCharacteristics([characteristicUUID], forService: s)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        log("发现可用特征")
        if error != nil {
            log(error!.description)
            return
        }
        
        let serviceUUID = CBUUID(string: kServiceUUID)
        let characteristicUUID = CBUUID(string: kCharacteristicUUID)
        
        if service.UUID == serviceUUID {
            for char in service.characteristics! {
                if char.UUID == characteristicUUID {
                    peripheral.setNotifyValue(true, forCharacteristic: char)
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        log("收到特征更新通知")
        if error != nil {
            log(error!.localizedDescription)
        }
        let characteristicUUID = CBUUID(string: kCharacteristicUUID)
        if characteristic.UUID == characteristicUUID {
            if characteristic.isNotifying {
                if characteristic.properties == CBCharacteristicProperties.Notify {
                    log("已订阅特征通知")
                    return
                } else if characteristic.properties == CBCharacteristicProperties.Read {
                    peripheral.readValueForCharacteristic(characteristic)
                }
            } else {
                log("更新已停止")
                manager.cancelPeripheralConnection(peripheral)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            log("更新特征值发生错误\(error!.description)")
            return
        }
        if characteristic.value != nil {
            let value = String.init(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            log("读取到特征值\(value!)")
        } else {
            log("未读取到特征值")
        }
    }
    
    func log(str: String) {
        tv.text = tv.text + "\n" + str
    }
}

