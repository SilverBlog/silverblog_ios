//
//  ViewController.swift
//  silverblog
//
//  Created by qwe7002 on 2018/3/11.
//  Copyright © 2018年 qwe7002. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var myUserDefaults :UserDefaults!

    @IBOutlet weak var server_name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBAction func on_enter_click(_ sender: Any) {
        self.view.endEditing(true)
        //Test:
        let md5Data = MD5(string:password.text!)
        
        let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
        myUserDefaults.set(server_name.text, forKey: "server")
        myUserDefaults.set(password.text, forKey: "password")
        myUserDefaults.synchronize()
        global_value.server_url=server_name.text!
        global_value.password=md5Hex
        print(global_value.server_url)
        print(global_value.password)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myUserDefaults = UserDefaults.standard
        server_name.text=myUserDefaults.string(forKey: "server")
        password.text=myUserDefaults.string(forKey: "password")
    }

    
    func MD5(string: String) -> Data {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData
    }
}

