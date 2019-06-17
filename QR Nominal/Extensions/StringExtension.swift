// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

extension String: Error {}

extension String {
    func prettyPrinted() -> String {
        do {
            if let jsonData = self.data(using: .utf8) {
                let jsonObject:AnyObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as AnyObject
                let prettyJsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted )
                
                let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8)
                return prettyPrintedJson ?? self
            }
        } catch {
        }
        return self
    }
}
