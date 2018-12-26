//
//  ViewController.swift
//  silverblog
//
//  Created by qwe7002 on 2018/3/11.
//  Copyright © 2018年 qwe7002. All rights reserved.
//

import UIKit
import Alamofire
class ViewController: UIViewController {
    let shared = UserDefaults(suiteName: "group.silverblog.client")!
    var config_list: [String: Any] = [:]
    @IBOutlet weak var server_name: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var previson_button: UIButton!
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
            self.shared.set(self.config_list,forKey: "config_list2")
            self.shared.synchronize()
        }))
        actionSheetController.popoverPresentationController?.sourceView = self.previson_button
        actionSheetController.popoverPresentationController?.sourceRect = self.previson_button.bounds
        actionSheetController.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
        self.present(actionSheetController, animated: true, completion: nil)
    }
    @IBAction func on_enter_click(_ sender: Any) {
        self.view.endEditing(true)
        let self_password=public_func.hmac_hax(hashName: "SHA256", message: public_func.md5(password.text!), key: "SiLvErBlOg")
        let self_server_url=server_name.text!.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "http://", with: "").replacingOccurrences(of: "https://", with: "")
        if (self_password == "" || self_server_url == "") {
            let alertController = UIAlertController(title: "Error", message: "site address or password cannot be blank.", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "ok", style: UIAlertAction.Style.default)
            alertController.addAction(okAction);
            self.present(alertController, animated: true, completion: nil)
            return
        }
        let doneController = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        doneController.view.addSubview(loadingIndicator)
        self.present(doneController, animated: true, completion: nil)
        Alamofire.request("https://" + self_server_url + "/control", method: .options).validate(statusCode: 204...204).responseJSON { response in
            doneController.dismiss(animated: true) {
                switch response.result {
                case .success:
                    self.password.text = ""
                    self.server_name.text = ""
                    self.save_info(server: self_server_url, password: self_password)
                    self.push_view()
                case .failure( _):
                    let alert = UIAlertController(title: "Failure", message: "This site cannot be connected.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }


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
            shared.set(config_list,forKey: "config_list2")
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
        if(shared.dictionary(forKey: "config_list") != nil){
            let old_list = shared.dictionary(forKey: "config_list")!
            var new_list: [String: Any] = [:]
            old_list.forEach { (arg) in
                let (key, value) = arg
                new_list[key]=public_func.hmac_hax(hashName: "SHA256", message: value as! String, key: "SiLvErBlOg")
            }
            self.shared.set(new_list,forKey: "config_list2")
            self.shared.removeObject(forKey: "config_list")
            self.shared.synchronize()
        }
        if (shared.dictionary(forKey: "config_list2") != nil){
            config_list = shared.dictionary(forKey: "config_list2")!
        }
    }
}

