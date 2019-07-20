// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import AnyCodable

struct EllipalDataExtractor {
    static func extract(from parts: EllipalMQRCodeCollection) throws -> String {
        var value = [AnyCodable]()

        for code in parts {
            value.append(AnyCodable(code.dictionary))
        }
        print("value")
        print(value)

        do {
            let data = try JSONEncoder().encode(value)
            print("data")
            print(data)

            let string = String(data: data, encoding: .utf8)
            print("string")

            return string!
        } catch {
            print("Unable to encode data for display")
            print(error.localizedDescription)

            throw "Unable to encode data for display" + error.localizedDescription
        }
    }
}
