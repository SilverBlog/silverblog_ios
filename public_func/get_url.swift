//
//  get_url.swift
//  public_func
//
//  Created by jianghua Huang on 13/05/2020.
//  Copyright © 2020 qwe7002. All rights reserved.
//

import Foundation
public class get_url{
    public static func Publish(server_url:String) -> String{
        return "https://" + server_url + "/control/"+public_func.VERSION+"/git_page_publish"
    }
    public static func get_list(server_url:String, list_name:String) -> String{
        return "https://" + server_url + "/control/" + public_func.VERSION + "/get/list/"+list_name
    }
    public static func get_content(server_url:String, list_name:String) -> String{
        return "https://" + server_url + "/control/" + public_func.VERSION + "/get/content/"+list_name
    }
    public static func delete(server_url:String) -> String{
        return "https://" + server_url + "/control/"+public_func.VERSION+"/delete"
    }
    public static func new_post(server_url:String) -> String{
        return "https://" + server_url + "/control/" + public_func.VERSION + "/new"
    }
    public static func edit_post(server_url:String, list_name:String) -> String{
        return "https://" + server_url + "/control/" + public_func.VERSION + "/edit/"+list_name
    }
}
