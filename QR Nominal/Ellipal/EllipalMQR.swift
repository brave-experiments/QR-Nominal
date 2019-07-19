// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class EllipalMQR: MQRCodeProtocol {

    var collection: EllipalMQRCodeCollection
    
    required init(completionBlock: MQRCodeBuildCompletionBlock) {
        collection = EllipalMQRCodeCollection()
        collection.completionBlock = completionBlock
    }
    
    func extractDataToString() throws -> String {
        return try EllipalDataExtractor.extract(from: collection)
    }
    
    func addCode(code: Any) throws {
        if let code = code as? EllipalMQRCode {
            try collection.insert(qr: code)
        } else {
            throw "Failed to add Ellipal code: Invalid concrete type"
        }
    }
    
/*  https://github.com/ELLIPAL/air-gapped_qrcode_data_format/blob/master/ELLIPAL_AIR-GAPPED_QRCODE_DATA_FORMAT_R1.18.pdf

    if you're going to use the URL format to encode your data, then you need to make sure that you adhere to the syntax

        elp://[OPTIONS@]ACTION/ACTIONDATA

    if present, OPTIONS is one of:

        - V2
        - index:count
        - V2|index:count

    since the "@" is used to delimit the OPTIONS from the ACTION, the syntax of OPTIONS should conform to 'userinfo',
    cf., https://www.rfc-editor.org/rfc/rfc3986.html#section-3.2.1

    however, an unencoded "|" is not in the character set for 'userinfo'. RFC 3986 was approved in January, 2005...
    that's 14 years and 3 months before the Ellipal MQR format was defined.

    so, here's what we're going to get:

    1. elp://signed/BTC/...

        scheme         : "elp"
        user           : empty
        password       : empty
        host           : "signed"
        pathComponents : [ "/", "BTC", ... ]

    2. elp://V2@signed/BTC/...

        scheme         : "elp"
        user           : "V2"
        password       : empty

    3. elp://2:8@signed/BTC/...

        scheme         : "elp"
        user           : "2"
        password       : "8"

    4. elp://V2|2:8@signed/BTC/... 

        URL(string: text) will fail

    5. elp://2:8|V2@signed/BTC/...

        URL(string: text) will fail
     
 */
    static func decode(text: String) throws -> Any {
        print(text)
        guard let url = URL(string: text) else {
            throw "Ellipal MQRcodes encode URLs, not strings"
        }
        if (url.scheme != "elp") {
            throw "Not an elp:// URL"
        }
        if (url.host == nil) {
            throw "Missing ACTION in elp:// URL"
        }

        var index = 1
        if let user = url.user {
            index = Int(user) ?? 1
        }

        var total = 1
        if let password = url.password {
            total = Int(password) ?? 1
        }

        return EllipalMQRCode(version: "V2", index: index, total: total, action: url.host!, components: url.pathComponents)

    }
}
