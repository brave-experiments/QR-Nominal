// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

struct Strings {
    public static let ScanQRCodeInstructionsLabel = NSLocalizedString("ScanQRCodeInstructionsLabel", bundle: Bundle.qrNominal, value: "Align QR code within frame to scan", comment: "Text for the instructions label, displayed in the QR scanner view")
    public static let ScanQRCodeViewTitle = NSLocalizedString("ScanQRCodeViewTitle", bundle: Bundle.qrNominal, value: "Scan QR Code", comment: "Title for the QR code scanner view.")
    public static let ScanQRCodePermissionErrorMessage = NSLocalizedString("ScanQRCodePermissionErrorMessage", bundle: Bundle.qrNominal, value: "Please allow Brave to access your device’s camera in ‘Settings’ -> ‘Privacy’ -> ‘Camera’.", comment: "Text of the prompt user to setup the camera authorization.")
    public static let ScanQRCodeErrorOKButton = NSLocalizedString("ScanQRCodeErrorOKButton", bundle: Bundle.qrNominal, value: "OK", comment: "OK button to dismiss the error prompt.")
    public static let ScanQRCodeInvalidDataErrorMessage = NSLocalizedString("ScanQRCodeInvalidDataErrorMessage", bundle: Bundle.qrNominal, value: "The data is invalid", comment: "Text of the prompt that is shown to the user when the data is invalid")
    public static let ScanningCOBO = NSLocalizedString("ScanningCOBO", bundle: Bundle.qrNominal, value: "Scannig for COBO QR", comment: "QR Code reader Title")
    public static let ScannedQRCount = NSLocalizedString("ScannedQRCount", bundle: Bundle.qrNominal, value: "Please continue scanning (%d of %d)", comment: "Title describing number of qr captured")
    public static let ScanButtonTitle = NSLocalizedString("ScanButtonTitle", bundle: Bundle.qrNominal, value: "Scan", comment: "Scan button title.")
    public static let ClearButtonTitle = NSLocalizedString("ClearButtonTitle", bundle: Bundle.qrNominal, value: "Clear", comment: "Clear Button title")
    public static let CancelButtonTitle = NSLocalizedString("CancelButtonTitle", bundle: Bundle.qrNominal, value: "Cancel", comment: "Cancel Button title")
    
}
