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
    @IBOutlet var Title_input: UITextField!
    @IBOutlet var Sulg_input: UITextField!
    
    @IBOutlet var Backbutton: UIBarButtonItem!
    @IBOutlet var Content_input: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        load_post()

    }
    func load_post(){
        var function = "post"
        if (menu == true) {
            function = "menu"
        }
        let parameters: Parameters = [
            "post_id":row
        ]
        Alamofire.request(global_value.server_url + "/control/get_content/" + function, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result.isSuccess {
            case true:
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if let value = response.result.value {
                    let json = JSON(value)
                    self.Title_input.text = json["title"].string
                    self.Sulg_input.text = json["name"].string
                    self.Content_input.text = json["content"].string
                }
            case false:
                print(response.result.error)
            }
            
        }
    }
}
