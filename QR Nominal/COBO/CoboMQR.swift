// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class CoboMQR: MQRCodeProtocol {
    
    var collection: CoboMQRCodeCollection
    
    required init(completionBlock: MQRCodeBuildCompletionBlock) {
        collection = CoboMQRCodeCollection()
        collection.completionBlock = completionBlock
    }
    
    func extractDataToString() throws -> String {
        return try CoboDataExtractor.extract(from: collection)
    }
    
    func addCode(code: Any) throws {
        if let code = code as? CoboMQRCode {
            try collection.insert(qr: code)
        } else {
            throw "Failed to add Cobo code: Invalid concrete type"
        }
    }
    
    static func decode(text: String) throws -> Any {
        if let data = text.data(using: .utf8) {
            return try JSONDecoder().decode(CoboMQRCode.self, from: data)
        }
        throw "Text not UTF8"
    }
}
