import UIKit
import Alamofire
import SwiftyJSON
import public_func
class edit_post_view: UIViewController,UITextViewDelegate {
    var uuid = ""
    var function = "post"
    var new_mode = false
    var json = JSON("{}")
    let net = NetworkReachabilityManager()
    @IBOutlet var Title_input: UITextField!
    @IBOutlet var Content_input: UITextView!

    @IBOutlet weak var Slug_input: UITextField!

    @IBAction func Save_Button(_ sender: Any) {
        if(Content_input.text=="Content" || Content_input.text.isEmpty){
            let alert = UIAlertController(title: "Could not submit request", message: "You must fill in the Content field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return;
        }
        if((Title_input.text?.isEmpty) != nil){
            let alert = UIAlertController(title: "Could not submit request", message: "You must fill in the Title field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return;
        }
        let alertController = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
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
        
        AF.request(submit_url, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            alertController.dismiss(animated: true)
            switch response.result {
            case .success(let json):
                let dict = json as! Dictionary<String, AnyObject>
                let status = dict["status"] as! Bool
                if (status) {
                    global_value.refresh = true
                    self.navigationController!.popViewController(animated: true)
                }
                if (!status) {
                    let alert = UIAlertController(title: "Failure", message: "Article publication failed.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Failure", message: public_func.get_error_message(error: (response.response?.statusCode)!), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if net?.isReachable == false {
            let alert = UIAlertController(title: "Failure", message: "No network connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                self.navigationController!.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return

        }
        if(Content_input.text == "Content"){
            Content_input.textColor = UIColor.placeholderText
        }
        Content_input.delegate=self

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if (new_mode){
            self.title="New"
        }else{
            self.title="Edit"
            self.Title_input.text = json["title"].string
            self.Slug_input.text = json["name"].string
            self.Content_input.text = json["content"].string
        
            self.Content_input.textColor = UIColor.black
            if(self.traitCollection.userInterfaceStyle == .dark){
                self.Content_input.textColor = UIColor.white
            }
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.textColor == UIColor.placeholderText && textView.text == "Content") {
            textView.text = nil
            textView.textColor = UIColor.black
            if(self.traitCollection.userInterfaceStyle == .dark){
                textView.textColor = UIColor.white
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Content"
            textView.textColor = UIColor.placeholderText
        }
    }
}
