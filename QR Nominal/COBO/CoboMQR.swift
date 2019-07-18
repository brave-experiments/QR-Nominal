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
    
    func addCode(data: Data) throws {
        if let qrCode = try? JSONDecoder().decode(CoboMQRCode.self, from: data) {
            try collection.insert(qr: qrCode)
        } else {
            throw "Failed to create CoboQRCode: Invalid data"
        }
    }
}
