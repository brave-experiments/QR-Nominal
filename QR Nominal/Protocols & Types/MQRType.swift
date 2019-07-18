// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

enum MQRType {
    case cobo
    case ellipal
    
    func new(completionBlock: MQRCodeBuildCompletionBlock) -> MQRCodeProtocol? {
        switch self {
        case .cobo:
            return Cobo(completionBlock: completionBlock)
        default:
            return nil
        }
    }
}
