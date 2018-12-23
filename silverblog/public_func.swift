//
//  public_func.swift
//  silverblog
//
//  Created by qwe7002 on 2018/3/11.
//  Copyright © 2018年 qwe7002. All rights reserved.
//

import Foundation

class public_func {
    static func get_time_stamp() -> Int64 {
        let now = NSDate()
        let timeInterval: TimeInterval = now.timeIntervalSince1970
        let timestamp = timeInterval * 1000
        return Int64(timestamp)
    }

    static func md5(_ string: String) -> String {

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

    static func sha512Hex(string: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        if let data = string.cString(using: String.Encoding.utf8) {
            CC_SHA512(data, CC_LONG(data.count), &digest)

        }
        var digestHex = ""
        for index in 0..<Int(CC_SHA512_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }

    static func hmac(hashName: String, message: Data, key: Data) -> Data? {
        let algos = ["SHA256": (kCCHmacAlgSHA256, CC_SHA256_DIGEST_LENGTH),
                     "SHA512": (kCCHmacAlgSHA512, CC_SHA512_DIGEST_LENGTH)]
        guard let (hashAlgorithm, length) = algos[hashName] else {
            return nil
        }
        var macData = Data(count: Int(length))

        macData.withUnsafeMutableBytes { macBytes in
            message.withUnsafeBytes { messageBytes in
                key.withUnsafeBytes { keyBytes in
                    CCHmac(CCHmacAlgorithm(hashAlgorithm),
                            keyBytes, key.count,
                            messageBytes, message.count,
                            macBytes)
                }
            }
        }
        return macData
    }

    static func hmac(hashName: String, message: String, key: String) -> String {
        let messageData = message.data(using: .utf8)!
        let keyData = key.data(using: .utf8)!
        let digest = hmac(hashName: hashName, message: messageData, key: keyData)
        var hexString = ""
        for byte in digest! {
            hexString += String(format: "%02x", byte)
        }
        return hexString
    }
}
