//
//  public_func.swift
//  silverblog
//
//  Created by qwe7002 on 2018/3/11.
//  Copyright © 2018年 qwe7002. All rights reserved.
//

import Foundation
public class public_func{
    public static var version = "v2"
    public static var group_suite = "group.org.silverblog.public"
    public static func get_error_message(error:Int) -> String {
        var result = ""
        switch error {
        case 400:
            result = "Unable to process the request."
            break
        case 403:
            result = "The request was rejected."
            break
        case 408:
            result = "Request timed out or current system time is incorrect."
            break
        case 500:
            result = "Server program error."
            break
        default:
            result = "unknown error."
        }
        return result
    }
   public static func md5(_ string: String) -> String {
        
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate()
    
        return byte2hex(digest)
    }

    private static func byte2hex(_ digest :Array<UInt8>)-> String{
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        return hexString
    }
    
    public static func sha512(string: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        let data = string.data(using: String.Encoding.utf8 , allowLossyConversion: true)
        let value =  data! as NSData
        CC_SHA512(value.bytes, CC_LONG(value.length), &digest)
        
        return byte2hex(digest)
    }
    private static func hmac(hashName:String, message:Data, key:Data) -> Data? {
        let algos = ["SHA256": (kCCHmacAlgSHA256, CC_SHA256_DIGEST_LENGTH),
                     "SHA512": (kCCHmacAlgSHA512, CC_SHA512_DIGEST_LENGTH)]
        guard let (hashAlgorithm, length) = algos[hashName]  else { return nil }
        var macData = Data(count: Int(length))
        
        macData.withUnsafeMutableBytes {macBytes in
            message.withUnsafeBytes {messageBytes in
                key.withUnsafeBytes {keyBytes in
                    CCHmac(CCHmacAlgorithm(hashAlgorithm),
                           keyBytes.baseAddress,     key.count,
                           messageBytes.baseAddress, message.count,
                           macBytes.baseAddress)
                }
            }
        }
        return macData
    }
    public static func hmac_hex(hashName:String, message:String, key:String) -> String {
        let messageData = message.data(using:.utf8)!
        let keyData = key.data(using:.utf8)!
        let digest = hmac(hashName:hashName, message:messageData, key:keyData)
        var hexString = ""
        for byte in digest! {
            hexString += String(format:"%02x", byte)
        }
        return hexString
    }
    
    public static func get_timestamp()-> CLongLong{
        let timeInterval: TimeInterval = Date().timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return millisecond
    }
}
