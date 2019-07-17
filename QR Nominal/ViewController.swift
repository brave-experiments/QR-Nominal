// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import AVFoundation

class ViewController: UIViewController, QRCodeViewControllerDelegate {
    

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
        scanButton.setTitle(Strings.ScanButtonTitle, for: .normal)
        scanButton.addTarget(self, action: #selector(scanAction), for: .touchUpInside)
        
        let clearButton = UIButton(type: .system)
        clearButton.setTitle(Strings.ClearButtonTitle, for: .normal)
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
                    self.dismiss(animated: true, completion: nil)
                    self.textView.text = text
                }
            } else {
                self.progressLabel.text = String.localizedStringWithFormat(Strings.ScannedQRCount, count, total)
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
        progressLabel.text = Strings.ScanningCOBO
        resetCollection()
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
        self.textView.text = ""
    }
    
    lazy var readerVC: QRCodeViewController = {
        let controller = QRCodeViewController()
        controller.qrCodeDelegate = self
        controller.stopScanningAutomatically = false
        controller.instructionsLabel.isHidden = true
        return controller
    }()
    
    func didScanQRCodeWithURL(_ url: URL) {
        
    }
    
    func didScanQRCodeWithText(_ text: String) {
        let data = text.data(using: .utf8)
        if let data = data, let qrCode = try? JSONDecoder().decode(CoboQRCode.self, from: data) {
            do {
                try self.qrCollection.insert(qr: qrCode)
            } catch {
                self.dismiss(animated: true, completion: nil)
                self.textView.text = error.localizedDescription
            }
        }
    }
    
    func didCancelScanning() {
        resetCollection()
    }
    
    func handleError(_ text: String) {
        self.dismiss(animated: true, completion: nil)
        self.textView.text = text
    }
    
    lazy var progressLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 44.0))
        label.backgroundColor = UIColor.black
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()

}

