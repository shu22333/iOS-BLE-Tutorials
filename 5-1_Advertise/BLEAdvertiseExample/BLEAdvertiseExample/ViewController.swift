//
//  ViewController.swift
//  BLEAdvertiseExample
//
//  Created by Shuichi Tsutsumi on 2014/12/12.
//  Copyright (c) 2014年 Shuichi Tsutsumi. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet var advertiseBtn: UIButton!
    private var peripheralManager: CBPeripheralManager!
//    private var peripheralManager2: CBPeripheralManager!
    private var currentService1: CBMutableService?
    private var currentService2: CBMutableService?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ペリフェラルマネージャ初期化
        peripheralManager = CBPeripheralManager(
            delegate: self,
            queue: nil,
            options: nil)
    }
    
    // MARK: - Private
    
    private func startAdvertise() {
        // アドバタイズメントデータを作成する
        let advertisementData = [CBAdvertisementDataServiceUUIDsKey: [CBUUID.serviceUUID1, CBUUID.serviceUUID2]]

        // アドバタイズ開始
        peripheralManager.startAdvertising(advertisementData)
        
        advertiseBtn.setTitle("STOP ADVERTISING", for: .normal)
    }
    
    private func stopAdvertise () {
        // アドバタイズ停止
        peripheralManager.stopAdvertising()
        
        advertiseBtn.setTitle("START ADVERTISING", for: .normal)
    }
    
    // MARK: - Action
    
    @IBAction func advertiseButtonTapped(_ sender: UIButton) {
        if !peripheralManager.isAdvertising {
            startAdvertise()
        } else {
            stopAdvertise()
        }
    }
}

extension ViewController: CBPeripheralManagerDelegate {

    // ペリフェラルマネージャの状態が変化すると呼ばれる
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("state: \(peripheral.state)")

        switch peripheral.state {
        case .poweredOn:
            publishService1()
        default:
            break
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("\(self.classForCoder)/\(#function), service: \(service)")
        if let error = error {
            print(error)
            return
        }

        guard let currentService1 else { fatalError() }
        if service.uuid == currentService1.uuid {
            guard currentService2 == nil else { fatalError() }
            publishService2()
        } else if let currentService2, service.uuid == currentService2.uuid {
            startAdvertise()
        } else { fatalError() }
    }

    // アドバタイズ開始処理が完了すると呼ばれる
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("アドバタイズ開始失敗！ error: \(error)")
            return
        }
        print("アドバタイズ開始成功！")

        // アドバタイズメントデータを作成する
        let advertisementData = [CBAdvertisementDataServiceUUIDsKey: [CBUUID.serviceUUID1, CBUUID.serviceUUID2]]

        // アドバタイズ開始
        peripheralManager.startAdvertising(advertisementData)
    }

    private func publishService1() {
        print("\(self.classForCoder)/\(#function)")
        guard currentService1 == nil else {
            print("Already service has been published.")
            return
        }
        let userIDCharacteristic = CBMutableCharacteristic(type: CBUUID.userID, properties: [ .read], value: nil, permissions: [.readable] )
        let newService = CBMutableService(uuid: CBUUID.serviceUUID1, characteristics: [userIDCharacteristic])
        currentService1 = newService
        peripheralManager.add(newService)
    }

    private func publishService2() {
        print("\(self.classForCoder)/\(#function)")
        guard currentService2 == nil else {
            print("Already service has been published.")
            return
        }
        let userIDCharacteristic = CBMutableCharacteristic(type: CBUUID.userID, properties: [ .read], value: nil, permissions: [.readable] )
        let newService = CBMutableService(uuid: CBUUID.serviceUUID2, characteristics: [userIDCharacteristic])
        currentService2 = newService
        peripheralManager.add(newService)
    }
}

extension CBUUID {
    static let userID = CBUUID(string: "87553620-AC3C-424C-986E-E70FB8BB5C84")
    static let discoveryToken = CBUUID(string: "87553621-AC3C-424C-986E-E70FB8BB5C84")
    static let serviceUUID1 = CBUUID(string: "00000000-0000-0000-0000-000000000039")
    static let serviceUUID2 = CBUUID(string: "00000000-0000-0000-0000-000000000040")
}

extension CBMutableService {

    convenience init(uuid: CBUUID, characteristics: [CBMutableCharacteristic]) {
        self.init(type: uuid, primary: true)
        self.characteristics = characteristics
    }
}
