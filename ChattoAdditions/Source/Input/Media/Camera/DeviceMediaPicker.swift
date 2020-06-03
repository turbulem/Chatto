/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import UIKit

final class DeviceMediaPicker: NSObject, MediaPicker, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let controller: UIViewController
    private weak var delegate: MediaPickerDelegate?

    init(delegate: MediaPickerDelegate, mediaTypes: [String]) {
        let pickerController = UIImagePickerController()
        self.controller = pickerController
        self.delegate = delegate
        super.init()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        pickerController.mediaTypes = mediaTypes
    }

    @objc
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        self.delegate?.imagePickerDidFinish(self, mediaInfo: info)
    }

    @objc
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.delegate?.imagePickerDidCancel(self)
    }
}

public final class DeviceMediaPickerFactory: MediaPickerFactory {

    private let mediaTypes: [String]

    public init(mediaTypes: [String]) {
        self.mediaTypes = mediaTypes
    }

    public func makeImagePicker(delegate: MediaPickerDelegate) -> MediaPicker? {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return nil
        }
        return DeviceMediaPicker(delegate: delegate,
                                 mediaTypes: self.mediaTypes)
    }
}