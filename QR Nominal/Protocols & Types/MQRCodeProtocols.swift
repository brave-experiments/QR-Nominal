// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

typealias MQRCodeBuildCompletionBlock = ((_ finished: Bool, _ currentCount: Int, _ totalCount: Int) -> ())?

protocol MQRCodeProtocol: AnyObject {
    init(completionBlock: MQRCodeBuildCompletionBlock)
    func extractDataToString() throws -> String
    func addCode(data: Data) throws
}
