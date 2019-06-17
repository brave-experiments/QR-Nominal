// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import GZIP
import CommonCrypto.CommonDigest


struct CoboDataExtractor {
    static func extract(from parts: CoboQRCodeCollection) throws -> String {
        //validating checksum
        var md5Context = CC_MD5_CTX()
        CC_MD5_Init(&md5Context)
        
        //building the encoded data from parts.
        var base64String = ""
        for code in parts {
            if let data = code.value.data(using: .utf8), data.count > 0 {
                data.withUnsafeBytes {
                    _ = CC_MD5_Update(&md5Context, $0, numericCast(data.count))
                }
            }
            base64String += code.value
        }
        
        var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        digest.withUnsafeMutableBytes {
            _ = CC_MD5_Final($0, &md5Context)
        }
        
        guard parts.initialQR?.checkSum == digest.hexEncodedString() else {
            throw "CheckSum Mismatch"
        }
        if parts.initialQR?.compress == false {
            return base64String
        }
        if let data = Data(base64Encoded: base64String) as NSData?, let unZippedData: Data = data.gunzipped() {
            return String(data: unZippedData, encoding: .utf8) ?? ""
        }
        throw "Failed to extract data"
    }
}
