// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

struct EllipalDataExtractor {
    static func extract(from parts: EllipalMQRCodeCollection) throws -> String {
        let value = parts.map({$0.dictionary})

        do {
            let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)

            let string = String(data: data, encoding: .utf8)

            return string!
        } catch {
            throw "Unable to encode data for display" + error.localizedDescription
        }
    }
}
