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
    @IBOutlet weak var server_name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBAction func on_previson_click(_ sender: Any) {
        shared.dictionary(forKey: <#T##String##Swift.String#>)
        let actionSheetController: UIAlertController = UIAlertController(title: "Please select", message: "Option to select", preferredStyle: .actionSheet)
        //todo dict
        let array = ["1":"test", "2":"test2"]
        array.forEach { (key,value) in
            actionSheetController.addAction(UIAlertAction(title: key, style: .default,handler: { (action: UIAlertAction!) -> () in
            //todo
                print(value)
            }))
        }

        actionSheetController.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))

        self.present(actionSheetController, animated: true, completion: nil)
    }
    @IBAction func on_enter_click(_ sender: Any) {
        
        if(password.text != global_value.password){
            global_value.password=public_func.md5(password.text!)
            global_value.server_url=server_name.text!
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
        if (shared.string(forKey: "server") != nil) {
            global_value.server_url = shared.string(forKey: "server")!
            global_value.password = shared.string(forKey: "password")!
        }
    }
}

