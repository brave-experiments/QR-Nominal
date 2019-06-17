// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import QRCodeReader
import AVFoundation

class ViewController: UIViewController, QRCodeReaderViewControllerDelegate {

    var shareButton: UIButton!
    var textView: UITextView!
    var qrCollection: CoboQRCodeCollection!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        
    }
    
    func setupView() {
        shareButton = UIButton(type: .system)
        shareButton.setImage(UIImage(named: "share"), for: .normal)
        shareButton.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        
        let scanButton = UIButton(type: .system)
        scanButton.setTitle("Scan", for: .normal)
        scanButton.addTarget(self, action: #selector(scanAction), for: .touchUpInside)
        
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.addTarget(self, action: #selector(clearAction), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [clearButton, scanButton, shareButton])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stackView)
        
        textView = UITextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 44.0),
            stackView.topAnchor.constraint(equalTo: self.textView.bottomAnchor, constant: 8.0),
            textView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
            textView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
            textView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
            ])
        
    }

    func resetCollection() {
        qrCollection = CoboQRCodeCollection()
        qrCollection.completionBlock = { (success, count, total) in
            if success {
                DispatchQueue.main.async {
                    let text: String
                    do {
                        text = try self.textFromCollection()
                    } catch {
                        text = error.localizedDescription
                    }
                    self.show(text: text)
                }
            } else {
                self.progressLabel.text = "Please continue scanning (\(count) of \(total))"
            }
        }
    }
    
    func textFromCollection() throws -> String {
        return try CoboDataExtractor.extract(from: self.qrCollection).prettyPrinted()
    }
    
    @objc func shareAction() {
        if let text = textView.text {
            
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [text], applicationActivities: nil)
            
            // This lines is for the popover you need to show in iPad
            activityViewController.popoverPresentationController?.sourceView = shareButton
            
            // This line remove the arrow of the popover to show in iPad
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
            
            // Anything you want to exclude
            activityViewController.excludedActivityTypes = [
                .postToWeibo,
                .assignToContact,
                .saveToCameraRoll,
                .addToReadingList,
                .postToFlickr,
                .postToVimeo,
                .postToTencentWeibo
            ]
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @objc func scanAction() {
        readerVC.delegate = self
        progressLabel.text = "Scan within the box"
        resetCollection()
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if let jsonData = result?.value.data(using: .utf8)
            {
                do {
                    if let qrCode = try? JSONDecoder().decode(CoboQRCode.self, from: jsonData) {
                        try self.qrCollection.insert(qr: qrCode)
                    }
                } catch {
                    self.show(text: error.localizedDescription)
                }
            }
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true) {
            self.progressLabel.translatesAutoresizingMaskIntoConstraints = false
            self.readerVC.view.addSubview(self.progressLabel)
            self.progressLabel.topAnchor.constraint(equalTo: self.readerVC.view.safeAreaLayoutGuide.topAnchor, constant: 0.0).isActive = true
            self.progressLabel.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
            self.progressLabel.leftAnchor.constraint(equalTo: self.readerVC.view.safeAreaLayoutGuide.leftAnchor, constant: 0.0).isActive = true
            self.progressLabel.rightAnchor.constraint(equalTo: self.readerVC.view.safeAreaLayoutGuide.rightAnchor, constant: 0.0).isActive = true
        }
    }
    @objc func clearAction() {
        show(text: "")
    }
    
    func show(text: String) {
        self.dismiss(animated: true, completion: nil)
        self.readerVC.stopScanning()
        self.textView.text = text
    }
    
    // Good practice: create the reader lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            
            // Configure the view controller (optional)
            $0.showTorchButton        = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = true
            $0.showOverlayView        = true
            $0.reader.stopScanningWhenCodeIsFound = false
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        resetCollection()
        show(text: textView.text)
    }
    
    lazy var progressLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 44.0))
        label.backgroundColor = UIColor.black
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()

}

