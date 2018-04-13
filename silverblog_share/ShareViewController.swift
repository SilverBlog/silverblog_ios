//
//  ShareViewController.swift
//  silverblog_share
//
//  Created by 黄江华 on 2018/3/15.
//  Copyright © 2018年 qwe7002. All rights reserved.
//

import UIKit
import Social
import Alamofire

class ShareViewController: SLComposeServiceViewController {
    let shared = UserDefaults(suiteName: "group.silverblog.client")!
    var post_title = "No Title"
    var sulg = ""

    override func isContentValid() -> Bool {
        if (contentText.isEmpty) {
            return false
        }
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (shared.string(forKey: "server")?.isEmpty)! {
            self.displayUIAlertController(title: "Please set the server information first.", message: "")
        }
    }
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        let password = shared.string(forKey: "password")!
        let server = shared.string(forKey: "server")!
        let sign = md5(post_title + password)
        let alertController = UIAlertController(title: "Now publishing, please wait...", message: "", preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)

        let parameters: Parameters = [
            "title": post_title,
            "sign": sign,
            "content": contentText,
            "name": sulg
        ]
        var result_message = ""
        Alamofire.request(server + "/control/new", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success(let json):
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                let dict = json as! Dictionary<String, AnyObject>
                let status = dict["status"] as! Bool
                result_message = "Article publication failed."
                if (status) {
                    result_message = "The article has been successfully published."
                }
            case .failure(_):
                result_message = "Article publication failed.Please check the network."
            }
            self.displayUIAlertController(title: "Article release completed", message: result_message)
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        if (!contentText.isEmpty){
            let split = contentText.components(separatedBy: "\n")
            if (split[0].hasPrefix("# ")){
                post_title=split[0].replacingOccurrences(of:"# ",with: "")
            }
        }
        return [title_item, sulg_item]
    }

    func displayUIAlertController(title: String, message: String) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) -> () in
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }))

        self.present(alert, animated: true, completion: nil)
    }

    lazy var title_item: SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()!
        item.title = "Title"
        item.value = self.post_title
        item.tapHandler = {
            let alert = UIAlertController(title: "Please enter a title:", message: "", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Title"
                textField.keyboardType = .default
                textField.text = self.post_title
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            let confirm = UIAlertAction(title: "Ok", style: .default) { (action) in
                let textField = alert.textFields![0] // Force unwrapping because we know it exists.
                item.value = textField.text
                self.post_title = textField.text!
            }
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
        return item
    }()
    lazy var sulg_item: SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()!
        item.title = "Slug"
        item.value = ""
        item.tapHandler = {
            let alert = UIAlertController(title: "Please enter a sulg:", message: "", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Sulg"
                textField.keyboardType = .default
                textField.text=self.sulg
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            let confirm = UIAlertAction(title: "Ok", style: .default) { (action) in
                let textField = alert.textFields![0] // Force unwrapping because we know it exists.
                item.value = textField.text
                self.sulg = textField.text!
            }
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
        return item
    }()

    func md5(_ string: String) -> String {

        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate()
        var hexString = ""
        for byte in digest {
            hexString += String(format: "%02x", byte)
        }

        return hexString
    }
}
