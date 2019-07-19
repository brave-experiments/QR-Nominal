// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import AVFoundation

class ViewController: UIViewController, QRCodeViewControllerDelegate {

    var shareButton: UIButton!
    var scanButton: UIButton!
    var textView: UITextView!
    var mqrHandler: MQRCodeProtocol?
    
    var mqrType: MQRType? {
        didSet {
            setupMQRHandler()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        shareButton = UIButton(type: .system)
        shareButton.setImage(UIImage(named: "share"), for: .normal)
        shareButton.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        
        scanButton = UIButton(type: .system)
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
        textView.isEditable = false
        
//        //Dark mode below
//        textView.backgroundColor = .black
//        textView.textColor = UIColor.Photon.Green70
//        textView.adjustsFontForContentSizeCategory = true
//        view.backgroundColor = .black
        
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
    
    @objc func shareAction() {
        if let text = textView.text {
            
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [text], applicationActivities: nil)
            
            // This line is for the popover you need to show in iPad
            activityViewController.popoverPresentationController?.sourceView = shareButton
            // This line removes the arrow of the popover to show in iPad
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
            
            activityViewController.popoverPresentationController?.sourceRect.origin.x += shareButton.bounds.width/2
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
        progressLabel.text = Strings.ScanningMQRs
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
    
    func setupMQRHandler() {
        self.clearAction()
        self.mqrHandler = mqrType?.new { (success, count, total) in
            guard let handler = self.mqrHandler else {
                return
            }
            DispatchQueue.main.async {
                if success {
                    let text: String
                    do {
                        text = try handler.extractDataToString()
                    } catch {
                        text = error.localizedDescription
                    }
                    self.dismiss(animated: true, completion: nil)
                    self.textView.text = text.prettyPrinted()
                } else {
                    self.progressLabel.text = String.localizedStringWithFormat(Strings.ScannedQRCount, count, total)
                }
            }
        }
    }
    
    lazy var readerVC: QRCodeViewController = {
        let controller = QRCodeViewController()
        controller.qrCodeDelegate = self
        controller.stopScanningAutomatically = false
        controller.instructionsLabel.isHidden = true
        return controller
    }()
    
    func didScanQRCodeWithText(_ text: String) {
        do {
            let mqrDetectedTuple = try MQRType.detectType(from: text)
            if mqrType == nil || mqrType! != mqrDetectedTuple.0 {
                mqrType = mqrDetectedTuple.0
            }
            try mqrHandler?.addCode(code: mqrDetectedTuple.1)
        } catch {
            self.dismiss(animated: true, completion: nil)
            self.textView.text = error.localizedDescription
        }
    }
    
    func didCancelScanning() {
        mqrType = nil
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

