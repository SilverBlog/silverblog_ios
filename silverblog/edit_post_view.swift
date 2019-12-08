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
import public_func
class edit_post_view: UIViewController,UITextViewDelegate {
    var uuid = ""
    var menu = false
    var function = "post"
    var load = false
    var new_mode = false
    let net = NetworkReachabilityManager()
    let textview_shadow_color = UIColor(red:201/255.0,green:201/255.0,blue:206/255.0,alpha:1)
    @IBOutlet var Title_input: UITextField!
    @IBOutlet var Content_input: UITextView!

    @IBOutlet weak var Slug_input: UITextField!

    @IBAction func Save_Button(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alertController.view.addSubview(loadingIndicator)
        self.present(alertController, animated: true, completion: nil)
        let send_time = public_func.get_timestamp()
        let title:String = Title_input.text!
        let content:String = Content_input.text!
        let name:String = Slug_input.text!
        let content_hash = public_func.sha512(string: content)
        var sign_message = title+name+content_hash
        var submit_url = "https://" + global_value.server_url + "/control/"+public_func.version+"/new"
        if(!new_mode){
            sign_message = self.uuid+title+name+content_hash
            submit_url = "https://" + global_value.server_url + "/control/"+public_func.version+"/edit/" + self.function
        }
        let sign = public_func.hmac_hex(hashName: "SHA512", message: sign_message, key: global_value.password+String(send_time))
        let parameters: Parameters = [
            "post_uuid": self.uuid,
            "title": title,
            "sign": sign,
            "content": content,
            "name": name,
            "send_time":send_time
        ]
        
        Alamofire.request(submit_url, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            alertController.dismiss(animated: true) {
                switch response.result {
                case .success(let json):
                    let dict = json as! Dictionary<String, AnyObject>
                    let status = dict["status"] as! Bool
                    if (status) {
                        global_value.reflush = true
                        self.navigationController!.popViewController(animated: true)
                    }
                    if (!status) {
                        let alert = UIAlertController(title: "Failure", message: "Article publication failed.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                case .failure(_):
                    let alert = UIAlertController(title: "Failure", message: public_func.get_error_message(error: (response.response?.statusCode)!), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (menu == true) {
            function = "menu"
        }
        if net?.isReachable == false {
            let alert = UIAlertController(title: "Failure", message: "No network connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                self.navigationController!.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return

        }
        if(Content_input.text == "Content"){
            Content_input.textColor = textview_shadow_color
        }
        Content_input.delegate=self

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if (new_mode){
            self.title="New"

        }
        if (!load && !new_mode){
            self.load_post()
            self.title="Edit"
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.textColor == textview_shadow_color && textView.text == "Content") {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Content"
            textView.textColor = textview_shadow_color
        }
    }
    func load_post() {
        let parameters: Parameters = [
            "post_uuid": self.uuid
        ]
        let alertController = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alertController.view.addSubview(loadingIndicator)
        self.present(alertController, animated: true, completion: nil)
        Alamofire.request("https://" + global_value.server_url + "/control/"+public_func.version+"/get/content/" + function, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            self.dismiss(animated: true) {
                
                switch response.result.isSuccess {
                case true:
                    if let value = response.result.value {
                        let json = JSON(value)
                        self.Title_input.text = json["title"].string
                        self.Slug_input.text = json["name"].string
                        self.Content_input.text = json["content"].string
                        self.load=true
                        self.Content_input.textColor = UIColor.black
                    }
                case false:
                    let alert = UIAlertController(title: "Failure", message: public_func.get_error_message(error: (response.response?.statusCode)!), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
