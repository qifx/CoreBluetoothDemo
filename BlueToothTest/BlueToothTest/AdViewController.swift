//
//  AdViewController.swift
//  BlueToothTest
//
//  Created by qifx on 3/21/16.
//  Copyright © 2016 qifx. All rights reserved.
//

import UIKit
import CoreBluetooth


var kServiceUUID = "C4FB2349-72FE-4CA2-94D6-1F3CB16331EE"
var kCharacteristicUUID = "6A3E4B28-522D-4B3B-82A9-D5E2004534FC"

class AdViewController: UIViewController, CBPeripheralDelegate, CBPeripheralManagerDelegate {
    @IBOutlet weak var tv: UITextView!

    var name = UIDevice.currentDevice().name
    var pm: CBPeripheralManager!
    var characteristicM: CBMutableCharacteristic!
    var centrals = [CBCentral]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ad(sender: AnyObject) {
        pm = CBPeripheralManager(delegate: self, queue: nil)

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func setup(sender: AnyObject) {
        let characteristicUUID = CBUUID(string: kCharacteristicUUID)
        let characteristicM = CBMutableCharacteristic(type: characteristicUUID, properties: .Notify, value: nil, permissions: .Readable)
        self.characteristicM = characteristicM
        let serviceUUID = CBUUID(string: kServiceUUID)
        let serviceM = CBMutableService(type: serviceUUID, primary: true)
        serviceM.characteristics = [characteristicM]
        pm.addService(serviceM)
    }
    
    func updateCharacteristicValue(){
        let valueStr = name + "--\(NSDate().timeIntervalSince1970)"
        let data = valueStr.dataUsingEncoding(NSUTF8StringEncoding)
        pm.updateValue(data!, forCharacteristic: self.characteristicM, onSubscribedCentrals: nil)
        log("更新特征值：\(valueStr)")
    }
    
    //
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            log("BLE已打开")
        } else {
            log("此设备不支持BLE或未打开蓝牙功能，无法作为外围设备.")
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if error != nil {
            log("添加服务失败：\(error!.localizedDescription)")
            return
        }
        let dic = [CBAdvertisementDataLocalNameKey: name]
        pm.startAdvertising(dic)
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if error != nil {
            log("启动广播失败：\(error!.localizedDescription)")
            return
        }
        log("启动广播...")
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
