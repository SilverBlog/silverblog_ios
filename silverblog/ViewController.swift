//
//  ViewController.swift
//  silverblog
//
//  Created by qwe7002 on 2018/3/11.
//  Copyright © 2018年 qwe7002. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var myUserDefaults: UserDefaults!
    @IBOutlet weak var server_name: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBAction func on_enter_click(_ sender: Any) {
        self.view.endEditing(true)
        global_value.server_url = server_name.text!
        if (global_value.server_url == "" || password.text=="") {
            let alertController = UIAlertController(title: "Error", message: "site address or password cannot be blank.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) { (ACTION) in
                return
            }
            alertController.addAction(okAction);
            self.present(alertController, animated: true, completion: nil)
        }
        global_value.password = public_func.md5(password.text!)
        myUserDefaults.set(global_value.server_url, forKey: "server")
        myUserDefaults.set(global_value.password, forKey: "password")
        myUserDefaults.synchronize()

        print("server_url:" + global_value.server_url)
        print("password:" + global_value.password)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        myUserDefaults = UserDefaults.standard
        server_name.text = myUserDefaults.string(forKey: "server")
        password.text = myUserDefaults.string(forKey: "password")
    }
}

