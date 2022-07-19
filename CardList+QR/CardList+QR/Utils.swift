//
//  Utils.swift
//  LINE Fintech
//

import Foundation
import UIKit

enum Utils {
    /// 문자열과 사이즈를 입력받아 QR코드 이미지로 반환합니다.
    static func generateQRCode(from string: String, size: CGSize) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setDefaults()
            filter.setValue(data, forKey: "inputMessage")
            if let outputImage = filter.outputImage {
                let imageRect = outputImage.extent.integral
                let transform = CGAffineTransform(scaleX: size.width / imageRect.width, y: size.height / imageRect.height)
                let transformedImage = outputImage.transformed(by: transform)
                if let cgImage = CIContext().createCGImage(transformedImage, from: transformedImage.extent) {
                    return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: UIImage.Orientation.up)
                } else {
                    return nil
                }
            }
        }

        return nil
    }
}
