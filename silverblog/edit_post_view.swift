//
//  edit_post_view.swift
//  silverblog
//
//  Created by qwe7002 on 2018/3/29.
//  Copyright © 2018年 qwe7002. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class edit_post_view: UIViewController {
    var row = 1
    var menu = false
    var function = "post"
    @IBOutlet var Title_input: UITextField!
    @IBOutlet var Content_input: UITextView!

    @IBOutlet weak var Slug_input: UITextField!

    @IBAction func Back_Button(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func Save_Button(_ sender: Any) {
        let alertController = UIAlertController(title: "Please wait...", message: "Now publishing", preferredStyle: .alert)
        self.present(alertController, animated: false, completion: nil)
        let sign = public_func.md5(Title_input.text! as String + global_value.password)
        let parameters: Parameters = [
            "post_id": self.row,
            "title": Title_input.text! as String,
            "sign": sign,
            "content": Content_input.text! as String,
            "name": Slug_input.text! as String
        ]
        var result_message = ""
        Alamofire.request(global_value.server_url + "/control/edit/" + self.function, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            self.presentedViewController?.dismiss(animated: false, completion: nil)
            switch response.result {
            case .success(let json):
                let dict = json as! Dictionary<String, AnyObject>
                let status = dict["status"] as! Bool
                result_message = "Article publication failed."
                if (status) {
                    global_value.reflush = true
                    self.navigationController!.popViewController(animated: true)
                    return
                }
            case .failure(_):
                result_message = "Article publication failed.Please check the network."
            }
            let alert = UIAlertController(title: "Failure", message: result_message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (menu == true) {
            function = "menu"
        }
        self.load_post()
        
    }

    func load_post() {
        let parameters: Parameters = [
            "post_id": row
        ]
        let alertController = UIAlertController(title: "Please wait...", message: "Now Loading", preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        Alamofire.request(global_value.server_url + "/control/get_content/" + function, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result.isSuccess {
            case true:
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if let value = response.result.value {
                    let json = JSON(value)
                    self.Title_input.text = json["title"].string
                    self.Slug_input.text = json["name"].string
                    self.Content_input.text = json["content"].string
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }
            case false:
                let alert = UIAlertController(title: "Failure", message: response.result.error as? String, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }

        }
    }
}
