import UIKit
import Alamofire
import SwiftyJSON
import public_func
class edit_post_view: UIViewController,UITextViewDelegate {
    var uuid = ""
    var function = "post"
    var new_mode = false
    var json = JSON("{}")
    let NET_REACHABILITY_MANAGER = NetworkReachabilityManager()
    @IBOutlet var title_input: UITextField!
    @IBOutlet var content_input: UITextView!
    @IBOutlet weak var slug_input: UITextField!

    @IBOutlet weak var image_input: UITextField!
    @IBAction func save_Button(_ sender: Any) {
        if(content_input.text=="Content" || content_input.text.isEmpty){
            let alert = UIAlertController(title: "Could not submit request", message: "You must fill in the Content field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return;
        }
        if(title_input.text!.isEmpty){
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
        let title:String = title_input.text!
        let content:String = content_input.text!
        let name:String = slug_input.text!
        let content_hash = public_func.sha512(string: content)
        var sign_message = title+name+content_hash
        var submit_url = get_url.new_post(server_url:global_value.server_url)
        if(!new_mode){
            sign_message = self.uuid + sign_message
            submit_url = get_url.edit_post(server_url:global_value.server_url,list_name:self.function)
        }
        let sign = public_func.sign_message(sign_message:sign_message,password:global_value.password,send_time:send_time)
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
                let alert = UIAlertController(title: "Failure", message: public_func.get_error_message(error:error.responseCode ?? -1), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if NET_REACHABILITY_MANAGER?.isReachable == false {
            let alert = UIAlertController(title: "Failure", message: "No network connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                self.navigationController!.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return

        }
        if(content_input.text == "Content"){
            content_input.textColor = UIColor.placeholderText
        }

        content_input.delegate=self

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if(self.traitCollection.userInterfaceStyle == .dark){
            content_input.backgroundColor = UIColor.black
        }
        if (new_mode){
            self.title="New"
        }else{
            self.title="Edit"
            self.title_input.text = json["title"].string
            self.slug_input.text = json["name"].string
            self.content_input.text = json["content"].string
            if(json["head_image"].exists()){
            
            }
            self.content_input.textColor = UIColor.black
            if(UITraitCollection.current.userInterfaceStyle == .dark){
                self.content_input.textColor = UIColor.white
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
