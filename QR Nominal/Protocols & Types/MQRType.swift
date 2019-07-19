// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

// Add new mqr types here to get started.
enum MQRType: String, CaseIterable {
    case cobo = "COBO"
    case ellipal = "Ellipal"
    
    func new(completionBlock: MQRCodeBuildCompletionBlock) -> MQRCodeProtocol? {
        switch self {
        case .cobo:
            return CoboMQR(completionBlock: completionBlock)
        case .ellipal:
            return EllipalMQR(completionBlock: completionBlock)
        }
    }

    // Detects sequentially from this enum and returns the first found.
    static func detectType(from text: String) throws -> (MQRType, Any) {
        for type in MQRType.allCases {
            switch type {
            case .cobo:
                if let code = try? CoboMQR.decode(text: text) {
                    return (.cobo, code)
                }
            case .ellipal:
                if let code = try? EllipalMQR.decode(text: text) {
                    return (.ellipal, code)
                }
            }
        }
        throw "Failed to find any compatible MQR type for this QR"
    }
}
