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
    @IBOutlet var advertiseBtn: UIButton!

    var isScanning = false
    var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        // ペリフェラルマネージャ初期化
        peripheralManager = CBPeripheralManager(
            delegate: self,
            queue: nil,
            options: nil)

        // セントラルマネージャ初期化
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Actions

    @IBAction func scanButtonTapped(_ sender: UIButton) {
        if !isScanning {
            isScanning = true
            sender.setTitle("STOP SCAN", for: .normal)

            let serviceUUID = CBUUID(string: "B36F4066-2EF7-467E-832D-8CBFF563BBB7")
            centralManager.scanForPeripherals(withServices: [serviceUUID])
        } else {
            centralManager.stopScan()
            
            sender.setTitle("START SCAN", for: .normal)
            isScanning = false
        }
    }

    @IBAction func advertiseButtonTapped(_ sender: UIButton) {
        if !peripheralManager.isAdvertising {
            startAdvertise()
        } else {
            stopAdvertise()
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
    }
}

extension ViewController: CBPeripheralManagerDelegate {

    // ペリフェラルマネージャの状態が変化すると呼ばれる
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("state: \(peripheral.state)")

        switch peripheral.state {
        case .poweredOn:
            // アドバタイズ開始
            startAdvertise()
        default:
            break
        }
    }

    // アドバタイズ開始処理が完了すると呼ばれる
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("アドバタイズ開始失敗！ error: \(error)")
            return
        }
        print("アドバタイズ開始成功！")
    }

    private func startAdvertise() {
        // アドバタイズメントデータを作成する
        let serviceUUID = CBUUID(string: "B36F4066-2EF7-467E-832D-8CBFF563BBB7")
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
}
