/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import AVFoundation
import SnapKit
import UIKit

private struct QRCodeViewControllerUX {
    static let navigationBarBackgroundColor = UIColor.black
    static let navigationBarTitleColor = UIColor.Photon.White100
    static let maskViewBackgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    static let isLightingNavigationItemColor = UIColor(red: 0.45, green: 0.67, blue: 0.84, alpha: 1)
}

protocol QRCodeViewControllerDelegate {
    func didScanQRCodeWithText(_ text: String)
    func handleError(_ text: String)
    func didCancelScanning()
}

class QRCodeViewController: UIViewController {
    var qrCodeDelegate: QRCodeViewControllerDelegate?
    var stopScanningAutomatically: Bool = true
    fileprivate lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.high
        return session
    }()
    
    private lazy var captureDevice: AVCaptureDevice? = {
        return AVCaptureDevice.default(for: AVMediaType.video)
    }()
    
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private let scanLine: UIImageView = UIImageView(image: #imageLiteral(resourceName: "qrcode-scanLine"))
    private let scanBorder: UIImageView = UIImageView(image: #imageLiteral(resourceName: "qrcode-scanBorder"))
    lazy var instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.ScanQRCodeInstructionsLabel
        label.textColor = UIColor.Photon.White100
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    private var maskView: UIView = UIView()
    private var isAnimating: Bool = false
    private var isLightOn: Bool = false
    private var shapeLayer: CAShapeLayer = CAShapeLayer()
    
    private var scanRange: CGRect {
        let val = UIDevice.current.orientation.isLandscape ? view.frame.height : view.frame.width
        let size = UIDevice.current.userInterfaceIdiom == .pad ?
            CGSize(width: val / 2, height: val / 2) :
            CGSize(width: val / 3 * 2, height: val / 3 * 2)
        var rect = CGRect(origin: .zero, size: size)
        rect.center = view.center
        return rect
    }
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.CancelButtonTitle, for: .normal)
        button.backgroundColor = UIColor.black
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = self.captureDevice else {
            dismiss(animated: false)
            return
        }
        
        let getAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if getAuthorizationStatus != .denied {
            setupCamera()
        } else {
            let alert = UIAlertController(title: "", message: Strings.ScanQRCodePermissionErrorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Strings.ScanQRCodeErrorOKButton, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        maskView.backgroundColor = QRCodeViewControllerUX.maskViewBackgroundColor
        self.view.addSubview(maskView)
        self.view.addSubview(scanBorder)
        self.view.addSubview(scanLine)
        self.view.addSubview(instructionsLabel)
        self.view.addSubview(cancelButton)
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let rectPath = UIBezierPath(rect: view.bounds)
        rectPath.append(UIBezierPath(rect: scanRange).reversing())
        shapeLayer.path = rectPath.cgPath
        maskView.layer.mask = shapeLayer
        self.captureSession.startRunning()
        isAnimating = true
        startScanLineAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
        stopScanLineAnimation()
    }
    
    private func setupConstraints() {
        cancelButton.snp.makeConstraints {
            $0.bottom.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(44.0)
        }
        maskView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            scanBorder.snp.makeConstraints { (make) in
                make.center.equalTo(self.view)
                make.width.equalTo(view).multipliedBy(0.5)
                make.height.equalTo(scanBorder.snp.width)
            }
        } else {
            scanBorder.snp.makeConstraints { (make) in
                make.center.equalTo(self.view)
                make.width.equalTo(view).multipliedBy(2.0/3)
                make.height.equalTo(scanBorder.snp.width)
            }
        }
        scanLine.snp.makeConstraints { (make) in
            make.left.equalTo(scanBorder.snp.left)
            make.top.equalTo(scanBorder.snp.top).offset(6)
            make.width.equalTo(scanBorder.snp.width)
            make.height.equalTo(6)
        }
        
        instructionsLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view.layoutMarginsGuide)
            make.top.equalTo(scanBorder.snp.bottom).offset(30)
        }
    }
    
    @objc func startScanLineAnimation() {
        if !isAnimating {
            return
        }
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        UIView.animate(withDuration: 2.4, delay: 0, options: [.autoreverse, .allowUserInteraction], animations: {
            self.scanLine.snp.updateConstraints({ (make) in
                make.top.equalTo(self.scanBorder.snp.top).offset(self.scanBorder.bounds.height - 12)
            })
            self.view.layoutIfNeeded()
        }) { (value: Bool) in
            self.scanLine.snp.updateConstraints({ (make) in
                make.top.equalTo(self.scanBorder.snp.top).offset(6)
            })
            self.perform(#selector(self.startScanLineAnimation), with: nil, afterDelay: 0)
        }
    }
    
    func stopScanLineAnimation() {
        isAnimating = false
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func openLight() {
        guard let captureDevice = self.captureDevice else {
            return
        }
        
        if isLightOn {
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.torchMode = AVCaptureDevice.TorchMode.off
                captureDevice.unlockForConfiguration()
                navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "qrcode-light")
                navigationItem.rightBarButtonItem?.tintColor = UIColor.Photon.White100
            } catch {
                print(error)
            }
        } else {
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.torchMode = AVCaptureDevice.TorchMode.on
                captureDevice.unlockForConfiguration()
                navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "qrcode-isLighting")
                navigationItem.rightBarButtonItem?.tintColor = QRCodeViewControllerUX.isLightingNavigationItemColor
            } catch {
                print(error)
            }
        }
        isLightOn = !isLightOn
    }
    
    func setupCamera() {
        guard let captureDevice = self.captureDevice else {
            dismiss(animated: false)
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print(error)
        }
        let output = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        }
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(videoPreviewLayer)
        self.videoPreviewLayer = videoPreviewLayer
        captureSession.startRunning()
        
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        shapeLayer.removeFromSuperlayer()
        let rectPath = UIBezierPath(rect: view.bounds)
        rectPath.append(UIBezierPath(rect: scanRange).reversing())
        shapeLayer.path = rectPath.cgPath
        maskView.layer.mask = shapeLayer
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            scanBorder.snp.remakeConstraints { (make) in
                make.center.equalTo(self.view)
                switch toInterfaceOrientation {
                case .landscapeLeft, .landscapeRight:
                    make.height.equalTo(view).multipliedBy(0.5)
                    make.width.equalTo(scanBorder.snp.height)
                default:
                    make.width.equalTo(view).multipliedBy(0.5)
                    make.height.equalTo(scanBorder.snp.width)
                }
                
            }
        } else {
            scanBorder.snp.remakeConstraints { (make) in
                make.center.equalTo(self.view)
                switch toInterfaceOrientation {
                case .landscapeLeft, .landscapeRight:
                    make.height.equalTo(view).multipliedBy(2.0/3)
                    make.width.equalTo(scanBorder.snp.height)
                default:
                    make.width.equalTo(view).multipliedBy(2.0/3)
                    make.height.equalTo(scanBorder.snp.width)
                }
            }
        }
        
        
        guard let videoPreviewLayer = self.videoPreviewLayer else {
            return
        }
        videoPreviewLayer.frame = UIScreen.main.bounds
        switch toInterfaceOrientation {
        case .portrait:
            videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        case .landscapeLeft:
            videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
        case .landscapeRight:
            videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
        case .portraitUpsideDown:
            videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        }
    }
}

extension QRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metaData = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let qrCodeDelegate = self.qrCodeDelegate, let text = metaData.stringValue else {
            return
        }
        func sendText(text: String) {
            qrCodeDelegate.didScanQRCodeWithText(text)
        }
        if stopScanningAutomatically {
            self.captureSession.stopRunning()
            stopScanLineAnimation()
            self.dismiss(animated: true, completion: {
                sendText(text: text)
            })
        } else {
            sendText(text: text)
        }
    }
}

class QRCodeNavigationController: UINavigationController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
