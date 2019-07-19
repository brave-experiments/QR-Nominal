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
        default:
            return nil
        }
    }
    
    // Detects sequentially from this enum and returns the first found.
    static func detectType(from data: Data) throws -> (MQRType, Any) {
        for type in MQRType.allCases {
            switch type {
            case .cobo:
                if let code = try? CoboMQR.decode(data: data) {
                    return (.cobo, code)
                }
            default: break
            }
        }
        throw "Failed to find any compatible MQR type for this QR"
    }
}
