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
    
    
}
