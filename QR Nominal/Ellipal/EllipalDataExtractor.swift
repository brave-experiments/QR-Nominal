// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import AnyCodable

struct EllipalDataExtractor {
    static func extract(from parts: EllipalMQRCodeCollection) throws -> String {
        var data = [AnyCodable]()

        for code in parts {
            data.append(AnyCodable(code.dictionary))
        }
        print("parts")
        print(data)
        
        if let json = try? JSONEncoder().encode(data) {
            print("json")
            if let text = String(data: json, encoding: .utf8) {
                print("text")
                return text
            }

            print("Unable to encode data for JSON display")
            throw "Unable to encode data for JSON display"
        }

        print("Unable to encode data for display")
        throw "Unable to encode data for display"
    }
}
