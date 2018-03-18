//
//  ViewController.swift
//  silverblog
//
//  Created by qwe7002 on 2018/3/11.
//  Copyright © 2018年 qwe7002. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let shared = UserDefaults(suiteName: "group.silverblog")!
    @IBOutlet weak var server_name: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBAction func on_enter_click(_ sender: Any) {
        self.view.endEditing(true)
        global_value.server_url = server_name.text!
        if (global_value.password == "" && password.text != ""){
            global_value.password = public_func.md5(password.text!)
        }
        if (global_value.server_url == "" || global_value.password == "") {
            let alertController = UIAlertController(title: "Error", message: "site address or password cannot be blank.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) { (ACTION) in
                return
            }
            alertController.addAction(okAction);
            self.present(alertController, animated: true, completion: nil)
        }
        print(global_value.password)
        shared.set(global_value.server_url, forKey: "server")
        shared.set(global_value.password, forKey: "password")
        shared.synchronize()
        let alertController = UIAlertController(title: "Success", message: "Your settings have been saved.", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) { (ACTION) in
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if (shared.string(forKey: "server") != nil) {
            global_value.server_url = shared.string(forKey: "server")!
            global_value.password = shared.string(forKey: "password")!
            server_name.text = global_value.server_url
        }
    }
}

