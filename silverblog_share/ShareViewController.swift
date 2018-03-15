//
//  ShareViewController.swift
//  silverblog_share
//
//  Created by 黄江华 on 2018/3/15.
//  Copyright © 2018年 qwe7002. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    var myUserDefaults: UserDefaults!
    var post_title = ""
    var sulg = ""
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        print(contentText)
        print(myUserDefaults.string(forKey: "server"))
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return [title_item,sulg_item]
    }

    lazy var title_item: SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()!
        item.title = "Title"
        item.value = ""
        item.tapHandler={
            let alert = UIAlertController(title:"Please enter a title:",message:"",preferredStyle:.alert)
            alert.addTextField(configurationHandler: {(textField)in
                textField.placeholder="Title"
                textField.keyboardType = .default
            })
            let cancel=UIAlertAction(title:"Cancel",style:.cancel)
            let confirm=UIAlertAction(title:"Ok",style:.default){(action)in
                let textField = alert.textFields![0] // Force unwrapping because we know it exists.
                item.value=textField.text
                print("Text field: \(textField.text)")
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
        item.tapHandler={
            let alert = UIAlertController(title:"Please enter a sulg:",message:"",preferredStyle:.alert)
            alert.addTextField(configurationHandler: {(textField)in
                textField.placeholder="Title"
                textField.keyboardType = .default
            })
            let cancel=UIAlertAction(title:"Cancel",style:.cancel)
            let confirm=UIAlertAction(title:"Ok",style:.default){(action)in
                let textField = alert.textFields![0] // Force unwrapping because we know it exists.
                item.value=textField.text
                print("Text field: \(textField.text)")
            }
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
        return item
    }()

}
