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

import XCTest
@testable import ChattoAdditions
import CoreServices

class MediaInputCameraPickerTests: XCTestCase {
    var sut: MediaInputCameraPicker!
    var presentingController: UIViewController!
    var imagePickerFactoryStorage: MediaPickerFactory!
    private var fakeImagePicker: FakeImagePicker!
    private var fakeImagePickerFactory: FakeImagePickerFactory!

    override func setUp() {
        super.setUp()
        self.presentingController = DummyViewController()
        self.fakeImagePicker = FakeImagePicker()
        self.fakeImagePickerFactory = FakeImagePickerFactory()
        self.fakeImagePickerFactory.picker = self.fakeImagePicker
        self.sut = MediaInputCameraPicker(mediaPickerFactory: self.fakeImagePickerFactory,
                                          presentingControllerProvider: { self.presentingController })
    }

    override func tearDown() {
        self.sut = nil
        self.presentingController = nil
        self.imagePickerFactoryStorage = nil
        self.fakeImagePickerFactory = nil
        self.fakeImagePicker = nil
        super.tearDown()
    }

    func testThat_GivenImageFactoryCannotCreateImagePicker_WhenPresentCameraPicker_ThenCallbacksGetCalledImmediately() {
        // Given
        self.fakeImagePickerFactory.picker = nil
        // When
        var onImageTakenCalled = false
        var onCameraPickerDismissedCalled = false
        self.sut.presentCameraPicker(onImageTaken: { (image) in
            onImageTakenCalled = true
            XCTAssertNil(image)
        }, onVideoTaken: { _ in },
           onCameraPickerDismissed: {
            onCameraPickerDismissedCalled = true
        })
        // Then
        XCTAssertTrue(onImageTakenCalled)
        XCTAssertTrue(onCameraPickerDismissedCalled)
    }

    func testThat_GivenPresentedPicker_WhenPickerFinishedWithImage_ThenOnImageTakenCallbackReceivedImage() {
        // Given
        var onImageTakenCalled = false
        self.sut.presentCameraPicker(onImageTaken: { (image) in
            onImageTakenCalled = true
            XCTAssertNotNil(image)
        }, onVideoTaken: { _ in },
           onCameraPickerDismissed: {})
        // When
        self.fakeImagePicker.finish(with: [UIImagePickerController.InfoKey.originalImage: UIImage(),
                                           UIImagePickerController.InfoKey.mediaType: kUTTypeImage as String])
        // Then
        XCTAssertTrue(onImageTakenCalled)
    }

    func testThat_GivenPresentedPicker_WhenPickerFinishedWithoutImage_ThenOnImageTakenCallbackDidntReceiveImage() {
        // Given
        var onImageTakenCalled = false
        self.sut.presentCameraPicker(onImageTaken: { (image) in
            onImageTakenCalled = true
            XCTAssertNil(image)
        }, onVideoTaken: { _ in },
           onCameraPickerDismissed: {})
        // When
        self.fakeImagePicker.finish(with: [:])
        // Then
        XCTAssertTrue(onImageTakenCalled)
    }

    func testThat_GivenPresentedPicker_WhenPickerCanceled_ThenOnImageTakenCallbackDidntReceiveImage() {
        // Given
        var onImageTakenCalled = false
        self.sut.presentCameraPicker(onImageTaken: { (image) in
            onImageTakenCalled = true
            XCTAssertNil(image)
        }, onVideoTaken: { _ in },
           onCameraPickerDismissed: {})
        // When
        self.fakeImagePicker.cancel()
        // Then
        XCTAssertTrue(onImageTakenCalled)
    }
}

private class FakeImagePicker: MediaPicker {
    let controller: UIViewController = DummyViewController()
    weak var delegate: MediaPickerDelegate?

    func finish(with mediaInfo: [UIImagePickerController.InfoKey: Any]) {
        self.delegate?.mediaPickerDidFinish(self, mediaInfo: mediaInfo)
    }

    func cancel() {
        self.delegate?.mediaPickerDidCancel(self)
    }
}

private class FakeImagePickerFactory: MediaPickerFactory {
    var picker: FakeImagePicker!

    func makeImagePicker(delegate: MediaPickerDelegate) -> MediaPicker? {
        picker?.delegate = delegate
        return picker
    }
}

private class DummyViewController: UIViewController {
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
    }
}
