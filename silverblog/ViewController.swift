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
        print("update info")
        self.view.endEditing(true)
        myUserDefaults.set(server_name.text, forKey: "server")
        myUserDefaults.set(password.text, forKey: "password")
        myUserDefaults.synchronize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myUserDefaults = UserDefaults.standard
        server_name.text=myUserDefaults.string(forKey: "server")
        password.text=myUserDefaults.string(forKey: "password")
    }


}

