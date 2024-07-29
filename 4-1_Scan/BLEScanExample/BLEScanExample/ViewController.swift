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
    @IBOutlet private var textView: UITextView!

    var isScanning = false
    var centralManager: CBCentralManager!
    
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

            let serviceUUID1 = CBUUID(string: "00000000-0000-0000-0000-000000000039")
            let serviceUUID2 = CBUUID(string: "00000000-0000-0000-0000-000000000040")
            let options: [String : Any] = [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(value: true)]
            centralManager.scanForPeripherals(withServices: [serviceUUID1, serviceUUID2], options: options)
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
        print("advertisementData: \(advertisementData)")
        textView.text += """

        --------------------
        \(Date())
        \(peripheral)
        """
    }
}

