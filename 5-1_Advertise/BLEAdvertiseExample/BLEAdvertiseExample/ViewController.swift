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
    private var currentService: CBMutableService?

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
        let serviceUUID = CBUUID.serviceUUID
        let advertisementData = [CBAdvertisementDataServiceUUIDsKey: [serviceUUID]]

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
            publishService()
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

        startAdvertise()
    }

    // アドバタイズ開始処理が完了すると呼ばれる
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("アドバタイズ開始失敗！ error: \(error)")
            return
        }
        print("アドバタイズ開始成功！")
    }

    private func publishService() {
        print("\(self.classForCoder)/\(#function)")
        guard currentService == nil else {
            print("Already service has been published.")
            return
        }
        let userIDCharacteristic = CBMutableCharacteristic(type: CBUUID.userID, properties: [ .read], value: nil, permissions: [.readable] )
//        let niCharacteristic = CBMutableCharacteristic(type: CBUUID.discoveryToken, properties: [ .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable] )
        let newService = CBMutableService(uuid: CBUUID.serviceUUID, characteristics: [userIDCharacteristic])
        currentService = newService
        peripheralManager.add(newService)
    }
}

extension CBUUID {
    static let userID = CBUUID(string: "87553620-AC3C-424C-986E-E70FB8BB5C84")
    static let discoveryToken = CBUUID(string: "87553621-AC3C-424C-986E-E70FB8BB5C84")
    static let serviceUUID = CBUUID(string: "B36F4066-2EF7-467E-832D-8CBFF563BBB7")
}

extension CBMutableService {

    convenience init(uuid: CBUUID, characteristics: [CBMutableCharacteristic]) {
        self.init(type: uuid, primary: true)
        self.characteristics = characteristics
    }
}
