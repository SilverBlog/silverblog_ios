import UIKit
import Social
import Alamofire
import public_func

class ShareViewController: SLComposeServiceViewController {
    let USER_CONFIG = UserDefaults(suiteName: public_func.USER_DEFAULTS_GROUP)!
    var post_title = "No Title"
    var slug = ""
    var image = ""
    var config_list: [String: Any] = [:]
    override func isContentValid() -> Bool {
        if (contentText.isEmpty || USER_CONFIG.string(forKey: "server") == nil) {
            return false
        }
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if(USER_CONFIG.dictionary(forKey: "config_list") != nil){
            let old_list = USER_CONFIG.dictionary(forKey: "config_list")!
            var new_list: [String: Any] = [:]
            old_list.forEach { (arg) in
                let (key, value) = arg
                new_list[key]=public_func.hmac_hex(hashName: "SHA256", message: value as! String, key: "SiLvErBlOg")
            }
            self.USER_CONFIG.set(new_list,forKey: "config_list_v2")
            self.USER_CONFIG.removeObject(forKey: "config_list")
            self.USER_CONFIG.synchronize()
        }
        if (USER_CONFIG.dictionary(forKey: "config_list_v2") != nil) {
            config_list = USER_CONFIG.dictionary(forKey: "config_list_v2")!
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (USER_CONFIG.string(forKey: "server") == nil) {
            self.displayUIAlertController(title: "Please set the server information first.", message: "")
        }
    }

    override func didSelectPost() {
        let content = contentText
        let split = content!.components(separatedBy: "\n")
        if (split[0].hasPrefix("# ")) {
            let alertQuestController = UIAlertController(title: "Notice", message: "The title has been found in the content. Do you want to remove the title?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                action in
                self.send_post(content: content!)
            })
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                action in
                var nl = "\n"
                if(split[1] == ""){
                    nl = "\n\n"
                }
                self.send_post(content: content!.replacingOccurrences(of: split[0] + nl, with: ""))
            })
            alertQuestController.addAction(cancelAction)
            alertQuestController.addAction(okAction)
            self.present(alertQuestController, animated: true, completion: nil)
        } else {
            self.send_post(content: content!)
        }
    }

    override func configurationItems() -> [Any]! {
        if (!contentText.isEmpty) {
            let split = contentText.components(separatedBy: "\n")
            if (split[0].hasPrefix("# ")) {
                post_title = split[0].replacingOccurrences(of: "# ", with: "")
            }
        }
        return [title_item, sulg_item,image_item, site_table_Item]
    }

    func send_post(content: String) {
        let password: String = USER_CONFIG.string(forKey: "password")!
        let server: String = USER_CONFIG.string(forKey: "server")!
        let send_time = public_func.get_timestamp()
        let sign_message = post_title+slug+public_func.sha512(string:content)
        let sign = public_func.sign_message(sign_message:sign_message,password:password,send_time:send_time)
        let alertController = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        if #available(iOSApplicationExtension 13.0, *) {
            loadingIndicator.style = UIActivityIndicatorView.Style.medium
        } else {
            // Fallback on earlier versions
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
        }
        loadingIndicator.startAnimating();
        alertController.view.addSubview(loadingIndicator)
        self.present(alertController, animated: true, completion: nil)


        let parameters: Parameters = [
            "title": post_title,
            "sign": sign,
            "content": content,
            "name": slug,
            "send_time":send_time,
            "head_image": image
        ]
        var result_message = ""
        AF.request(get_url.new_post(server_url: server), method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            self.dismiss(animated: true) {
                switch response.result {
                case .success(let json):
                    let dict = json as! Dictionary<String, AnyObject>
                    let status = dict["status"] as! Bool
                    result_message = "Article publication failed."
                    if (status) {
                        result_message = "The article has been successfully published."
                        self.USER_CONFIG.set(true, forKey: "refresh")
                        self.USER_CONFIG.synchronize()
                    }
                case .failure(let error):
                    print(error)
                    result_message = public_func.get_error_message(error: (response.response?.statusCode)!)
                }
                self.displayUIAlertController(title: "Notice", message: result_message)
            }
        }
    }

    func displayUIAlertController(title: String, message: String) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) -> () in
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }))

        self.present(alert, animated: true, completion: nil)
    }

    private lazy var site_table_Item: SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()!
        item.title = "Sites"
        item.value = USER_CONFIG.string(forKey: "server")!
        item.tapHandler = {
            let actionSheetController: UIAlertController = UIAlertController(title: "Config list", message: "Please select the config", preferredStyle: .actionSheet)
            self.config_list.forEach { (key, value) in
                actionSheetController.addAction(UIAlertAction(title: key, style: .default, handler: { (action: UIAlertAction!) -> () in
                    let self_server_url = key
                    let self_password = value as! String
                    item.value = self_server_url
                    self.save_info(server: self_server_url, password: self_password)
                }))
            }
            actionSheetController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(actionSheetController, animated: true, completion: nil)
        }
        return item
    }()

    func save_info(server: String, password: String) {
        USER_CONFIG.set(server, forKey: "server")
        USER_CONFIG.set(password, forKey: "password")
        USER_CONFIG.synchronize()
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
            let confirm = UIAlertAction(title: "OK", style: .default) { (action) in
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
            let alert = UIAlertController(title: "Please enter a slug:", message: "", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Slug"
                textField.keyboardType = .default
                textField.text = self.slug
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            let confirm = UIAlertAction(title: "OK", style: .default) { (action) in
                let textField = alert.textFields![0] // Force unwrapping because we know it exists.
                item.value = textField.text
                self.slug = textField.text!
            }
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
        return item
    }()
    lazy var image_item: SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()!
        item.title = "Image"
        item.value = ""
        item.tapHandler = {
            let alert = UIAlertController(title: "Please enter a image URL:", message: "", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "image"
                textField.keyboardType = .default
                textField.text = self.image
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            let confirm = UIAlertAction(title: "OK", style: .default) { (action) in
                let textField = alert.textFields![0] // Force unwrapping because we know it exists.
                item.value = textField.text
                self.slug = textField.text!
            }
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
        return item
    }()

}
