// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

extension Array {
    func insertionSort(_ isOrderedBefore: (Element, Element) -> Bool) -> [Element] {
        guard self.count > 1 else { return self }
        
        var a = self
        for x in 1..<a.count {
            var y = x
            let temp = a[y]
            while y > 0 && isOrderedBefore(temp, a[y - 1]) {
                a[y] = a[y - 1]
                y -= 1
            }
            a[y] = temp
        }
        return a
    }
}
