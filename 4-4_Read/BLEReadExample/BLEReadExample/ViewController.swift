//
//  ViewController.swift
//  BLEScanExample
//
//  Created by Shuichi Tsutsumi on 2014/12/12.
//  Copyright (c) 2014年 Shuichi Tsutsumi. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    var isScanning = false
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // セントラルマネージャ初期化
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Actions

    @IBAction func scanButtonTapped(_ sender: UIButton) {
        
        if !isScanning {
            isScanning = true
            sender.setTitle("STOP SCAN", for: .normal)

            centralManager.scanForPeripherals(withServices: nil)
        } else {
            centralManager.stopScan()
            
            sender.setTitle("START SCAN", for: .normal)
            isScanning = false
        }
    }
}

extension ViewController: CBCentralManagerDelegate {
    
    // セントラルマネージャの状態が変化すると呼ばれる
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state: \(central.state)")
    }
    
    // 周辺にあるデバイスを発見すると呼ばれる
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber)
    {
        print("発見したBLEデバイス: \(peripheral)")
        
        if let name = peripheral.name, name.hasPrefix("konashi") {
            self.peripheral = peripheral
            
            centralManager.connect(peripheral)
            centralManager.stopScan()
        }
    }
    
    // ペリフェラルへの接続が成功すると呼ばれる
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral)
    {
        print("接続成功！")
        
        // サービス探索結果を受け取るためにデリゲートをセット
        peripheral.delegate = self
        
        // サービス探索開始
        peripheral.discoverServices(nil)
    }
    
    // ペリフェラルへの接続が失敗すると呼ばれる
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?)
    {
        print("接続失敗・・・")
    }
}

extension ViewController: CBPeripheralDelegate {
    // サービス発見時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("エラー: \(error)")
            return
        }
        
        guard let services = peripheral.services, services.count > 0 else {
            print("no services")
            return
        }
        print("\(services.count) 個のサービスを発見！ \(services)")
        
        for service in services {
            // キャラクタリスティック探索開始
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // キャラクタリスティック発見時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?)
    {
        if let error = error {
            print("エラー: \(error)")
            return
        }
        guard let characteristics = service.characteristics, characteristics.count > 0 else {
            print("no characteristics for service: \(service)")
            return
        }
        print("\(characteristics.count) 個のキャラクタリスティックを発見！ service: \(service), characteristic: \(characteristics) ")
        
        for characteristic in characteristics {
            // Read専用のキャラクタリスティックに限定して読み出す場合
            if characteristic.properties == .read {
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    // データ読み出しが完了すると呼ばれる
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?)
    {
        if let error = error {
            print("読み出し失敗...error: \(error), characteristic uuid: \(characteristic.uuid)")
            return
        }
        print("読み出し成功！service uuid: \(String(describing: characteristic.service?.uuid)), characteristic uuid: \(characteristic.uuid)")
        
        // キャラクタリスティックのvalueを取得
        guard let data = characteristic.value else {
            print("no value")
            return }
        print("value: \(String(describing: characteristic.value))")
        
        // バッテリーレベルのキャラクタリスティックかどうかを判定
        if characteristic.uuid.isEqual(CBUUID(string: "2A19")) {
            // 1バイト取り出す
            let byte = data[0]
            print("Battery Level: \(byte)")
        }
    }
}

