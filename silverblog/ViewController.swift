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

        let actionSheetController: UIAlertController = UIAlertController(title: "Use the previous configuration", message: "Please select the configuration", preferredStyle: .actionSheet)
        config_list.forEach { (key,value) in
            actionSheetController.addAction(UIAlertAction(title: key, style: .default,handler: { (action: UIAlertAction!) -> () in
                self.server_name.text=key
                self.password.text = value as? String
                self.save_info()
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
        
        if(password.text != global_value.password || server_name.text != global_value.server_url){
            global_value.password=public_func.md5(password.text!)
            global_value.server_url=server_name.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        save_info()
        self.view.endEditing(true)
        if (global_value.server_url == "" || global_value.password == "") {
            let alertController = UIAlertController(title: "Error", message: "site address or password cannot be blank.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) { (ACTION) in
                return
            }
            alertController.addAction(okAction);
            self.present(alertController, animated: true, completion: nil)
        }
        push_view()


    }
    func push_view(){
        let sb = UIStoryboard(name:"Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "post_list") as! UITabBarController
        self.navigationController!.pushViewController(vc, animated:true)
    }
    func save_info(){
            shared.set(global_value.server_url, forKey: "server")
            shared.set(global_value.password, forKey: "password")
            config_list[global_value.server_url] = global_value.password
            shared.set(config_list,forKey: "config_list")
            shared.synchronize()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (global_value.isscan){
            global_value.isscan=false
            save_info()
            push_view()
        }
        server_name.text = global_value.server_url
        password.text = global_value.password
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if (shared.dictionary(forKey: "config_list") != nil){
            config_list = shared.dictionary(forKey: "config_list")!
        }
        if (shared.string(forKey: "server") != nil) {
            global_value.server_url = shared.string(forKey: "server")!
            global_value.password = shared.string(forKey: "password")!
        }
    }
}

