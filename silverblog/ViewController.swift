//
//  ViewController.swift
//  silverblog
//
//  Created by qwe7002 on 2018/3/11.
//  Copyright © 2018年 qwe7002. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let shared = UserDefaults(suiteName: "group.silverblog.client")!
    var config_list: [String: Any] = [:]
    @IBOutlet weak var server_name: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func on_previson_click(_ sender: Any) {

        let actionSheetController: UIAlertController = UIAlertController(title: "Use the previous config", message: "Please select the config", preferredStyle: .actionSheet)
        config_list.forEach { (key,value) in
            actionSheetController.addAction(UIAlertAction(title: key, style: .default,handler: { (action: UIAlertAction!) -> () in
                let self_server_url = key
                let self_password = value as! String
                self.save_info(server: self_server_url,password: self_password)
                self.push_view()
            }))
        }
        actionSheetController.addAction(UIAlertAction(title: "Clean", style: .destructive,handler: {(action: UIAlertAction!) -> () in
            self.config_list = [:]
            self.shared.set(self.config_list,forKey: "config_list")
            self.shared.synchronize()
        }))
        actionSheetController.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
        self.present(actionSheetController, animated: true, completion: nil)
    }
    @IBAction func on_enter_click(_ sender: Any) {
        self.view.endEditing(true)
        let self_password=public_func.md5(password.text!)
        let self_server_url=server_name.text!.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "http://", with: "").replacingOccurrences(of: "https://", with: "")
        if (self_password == "" || self_server_url == "") {
            let alertController = UIAlertController(title: "Error", message: "site address or password cannot be blank.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default)
            alertController.addAction(okAction);
            self.present(alertController, animated: true, completion: nil)
            return
        }
        password.text = ""
        server_name.text = ""
        save_info(server: self_server_url,password: self_password)
        push_view()


    }
    func push_view(){
        let sb = UIStoryboard(name:"Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "post_list") as! UITabBarController
        self.navigationController!.pushViewController(vc, animated:true)
    }
    func save_info(server: String,password: String){
            shared.set(server, forKey: "server")
            shared.set(password, forKey: "password")
            config_list[server] = password
            shared.set(config_list,forKey: "config_list")
            shared.synchronize()
            global_value.server_url=server
            global_value.password=password
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (global_value.isscan){
            global_value.isscan=false
            save_info(server: global_value.server_url,password: global_value.password)
            push_view()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if (shared.dictionary(forKey: "config_list") != nil){
            config_list = shared.dictionary(forKey: "config_list")!
        }
    }
}

