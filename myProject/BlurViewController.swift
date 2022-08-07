//
//  BlurViewController.swift
//  myProject
//
//  Created by Adhira on 30/6/22.
//

import UIKit
import GPUImage

class BlurViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var renderView: RenderView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    var thumbnailFilterImages: [UIImage] = []
    
    var originalImage : UIImage?
    
    var picture:PictureInput!
    var blurFilter: GaussianBlur!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        originalImage = imageView.image
        imageView.isHidden = true
        renderView.contentMode = .scaleAspectFit
        picture = PictureInput(image: originalImage!)
        
        setupUI()
        generateFilterImages()
    }
    
    func generateFilterImages() {
        guard let originalImage = originalImage else {
            return
        }
        let size: CGSize
        let ratio = (originalImage.size.width / originalImage.size.height)
        let fixLength: CGFloat = 100
        if ratio >= 1 {
            size = CGSize(width: fixLength * ratio, height: fixLength)
        } else {
            size = CGSize(width: fixLength, height: fixLength / ratio)
        }
        let thumbnailImage = originalImage.resize(size) ?? originalImage
        
        DispatchQueue.global().async {
            self.thumbnailFilterImages = ZLImageEditorConfiguration.default().filters.map { $0.applier?(thumbnailImage) ?? thumbnailImage }
            
            DispatchQueue.main.async {
                self.filterCollectionView?.reloadData()
                self.filterCollectionView?.performBatchUpdates {
                    
                }
//            completion: { (_) in
//                    if let index = ZLImageEditorConfiguration.default().filters.firstIndex(where: { $0 == self.currentFilter }) {
//                        self.filterCollectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
//                    }
//                }
            }
        }
    }
    
    func setupUI(){
        filterCollectionView.dataSource = self
        filterCollectionView.delegate = self
        
        let nib = UINib(nibName: "ThumbnailCollectionViewCell", bundle: nil)
        filterCollectionView.register(nib, forCellWithReuseIdentifier: "ThumbnailCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCollectionViewCell", for: indexPath) as! ThumbnailCollectionViewCell
        if thumbnailFilterImages.count > 0 {
            cell.thumbnailImageView.image = thumbnailFilterImages[indexPath.row]
        }
        
        
        print(thumbnailFilterImages.count, "okkkkkk")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}


extension UIImage {
    func resize(_ size: CGSize) -> UIImage? {
        if size.width <= 0 || size.height <= 0 {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return temp
    }
    
    func toCIImage() -> CIImage? {
        var ci = self.ciImage
        if ci == nil, let cg = self.cgImage {
            ci = CIImage(cgImage: cg)
        }
        return ci
    }
}

extension CIImage {
    
    func toUIImage() -> UIImage? {
        let context = CIContext()
        guard let cgImage = context.createCGImage(self, from: self.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
}

public typealias ZLFilterApplierType = ((_ image: UIImage) -> UIImage)

@objc public enum ZLFilterType: Int {
    case normal
    case chrome
    case fade
    case instant
    case process
    case transfer
    case tone
    case linear
    case sepia
    case mono
    case noir
    case tonal
    
    var coreImageFilterName: String {
        switch self {
        case .normal:
            return ""
        case .chrome:
            return "CIPhotoEffectChrome"
        case .fade:
            return "CIPhotoEffectFade"
        case .instant:
            return "CIPhotoEffectInstant"
        case .process:
            return "CIPhotoEffectProcess"
        case .transfer:
            return "CIPhotoEffectTransfer"
        case .tone:
            return "CILinearToSRGBToneCurve"
        case .linear:
            return "CISRGBToneCurveToLinear"
        case .sepia:
            return "CISepiaTone"
        case .mono:
            return "CIPhotoEffectMono"
        case .noir:
            return "CIPhotoEffectNoir"
        case .tonal:
            return "CIPhotoEffectTonal"
        }
    }
}

public class ZLFilter: NSObject {
    
    public var name: String
    
    let applier: ZLFilterApplierType?
    
    @objc public init(name: String, filterType: ZLFilterType) {
        self.name = name
        
        if filterType != .normal {
            self.applier = { image -> UIImage in
//                guard let ciImage = image.toCIImage() else {
//                    return image
//                }
//
//                let filter = CIFilter(name: filterType.coreImageFilterName)
//                filter?.setValue(ciImage, forKey: kCIInputImageKey)
//                guard let outputImage = filter?.outputImage?.toUIImage() else {
//                    return image
//                }
//                return outputImage
                return image
            }
            
            
        } else {
            self.applier = nil
        }
    }
    
    /// 可传入 applier 自定义滤镜
    @objc public init(name: String, applier: ZLFilterApplierType?) {
        self.name = name
        self.applier = applier
    }
    
}


extension ZLFilter {
    
    @objc public static let all: [ZLFilter] = [.normal, .haseFilter, .falseFilter, .clarendon, .nashville, .apply1977, .toaster, .chrome, .fade, .instant, .process, .transfer, .tone, .linear, .sepia, .mono, .noir, .tonal]
    
    @objc public static let normal = ZLFilter(name: "Normal", filterType: .normal)
    
    @objc public static let haseFilter = ZLFilter(name: "haseFilter", applier: ZLFilter.Hazee)
    
    @objc public static let falseFilter = ZLFilter(name: "falseFilter", applier: ZLFilter.falseColor)
    
    @objc public static let clarendon = ZLFilter(name: "Clarendon", applier: ZLFilter.clarendonFilter)
    
    @objc public static let nashville = ZLFilter(name: "Nashville", applier: ZLFilter.nashvilleFilter)
    
    @objc public static let apply1977 = ZLFilter(name: "1977", applier: ZLFilter.apply1977Filter)
    
    @objc public static let toaster = ZLFilter(name: "Toaster", applier: ZLFilter.toasterFilter)
    
    @objc public static let chrome = ZLFilter(name: "Chrome", filterType: .chrome)
    
    @objc public static let fade = ZLFilter(name: "Fade", filterType: .fade)
    
    @objc public static let instant = ZLFilter(name: "Instant", filterType: .instant)
    
    @objc public static let process = ZLFilter(name: "Process", filterType: .process)
    
    @objc public static let transfer = ZLFilter(name: "Transfer", filterType: .transfer)
    
    @objc public static let tone = ZLFilter(name: "Tone", filterType: .tone)
    
    @objc public static let linear = ZLFilter(name: "Linear", filterType: .linear)
    
    @objc public static let sepia = ZLFilter(name: "Sepia", filterType: .sepia)
    
    @objc public static let mono = ZLFilter(name: "Mono", filterType: .mono)
    
    @objc public static let noir = ZLFilter(name: "Noir", filterType: .noir)
    
    @objc public static let tonal = ZLFilter(name: "Tonal", filterType: .tonal)
    
}


public class ZLImageEditorConfiguration: NSObject {
    
    private static var single = ZLImageEditorConfiguration()
    
    @objc public class func `default`() -> ZLImageEditorConfiguration {
        return ZLImageEditorConfiguration.single
    }
    
    @objc public class func resetConfiguration() {
        ZLImageEditorConfiguration.single = ZLImageEditorConfiguration()
    }

    @objc public var filters: [ZLFilter] {
        get {
            return ZLFilter.all
        }
    }
}

extension ZLFilter {
    
    class func falseColor(image: UIImage) -> UIImage {
        let falseFilter = FalseColor()
        falseFilter.firstColor = .blue
        falseFilter.secondColor = .white
        let img = image.filterWithOperation(falseFilter)
        return img
    }
    
    class func Hazee(image: UIImage) -> UIImage {
        let hazeFilter = Haze()
        let img = image.filterWithOperation(hazeFilter)
        return img
    }
    
    class func clarendonFilter(image: UIImage) -> UIImage {
        guard let ciImage = image.toCIImage() else {
            return image
        }
        
        let backgroundImage = self.getColorImage(red: 127, green: 187, blue: 227, alpha: Int(255 * 0.2),
                                            rect: ciImage.extent)
        let outputCIImage = ciImage.applyingFilter("CIOverlayBlendMode", parameters: [
            "inputBackgroundImage": backgroundImage
            ])
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.35,
                "inputBrightness": 0.05,
                "inputContrast": 1.1
                ])
        guard let outputImage = outputCIImage.toUIImage() else {
            return image
        }
        return outputImage
    }
    
    class func nashvilleFilter(image: UIImage) -> UIImage {
        guard let ciImage = image.toCIImage() else {
            return image
        }
        
        let backgroundImage = getColorImage(red: 247, green: 176, blue: 153, alpha: Int(255 * 0.56),
                                            rect: ciImage.extent)
        let backgroundImage2 = getColorImage(red: 0, green: 70, blue: 150, alpha: Int(255 * 0.4),
                                             rect: ciImage.extent)
        let outputCIImage = ciImage
            .applyingFilter("CIDarkenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage
                ])
            .applyingFilter("CISepiaTone", parameters: [
                "inputIntensity": 0.2
                ])
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.2,
                "inputBrightness": 0.05,
                "inputContrast": 1.1
                ])
            .applyingFilter("CILightenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage2
                ])
        
        guard let outputImage = outputCIImage.toUIImage() else {
            return image
        }
        return outputImage
    }
    
    class func apply1977Filter(image: UIImage) -> UIImage {
        guard let ciImage = image.toCIImage() else {
            return image
        }
        
        let filterImage = getColorImage(red: 243, green: 106, blue: 188, alpha: Int(255 * 0.1), rect: ciImage.extent)
        let backgroundImage = ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.3,
                "inputBrightness": 0.1,
                "inputContrast": 1.05
                ])
            .applyingFilter("CIHueAdjust", parameters: [
                "inputAngle": 0.3
                ])
        
        let outputCIImage = filterImage
            .applyingFilter("CIScreenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage
                ])
            .applyingFilter("CIToneCurve", parameters: [
                "inputPoint0": CIVector(x: 0, y: 0),
                "inputPoint1": CIVector(x: 0.25, y: 0.20),
                "inputPoint2": CIVector(x: 0.5, y: 0.5),
                "inputPoint3": CIVector(x: 0.75, y: 0.80),
                "inputPoint4": CIVector(x: 1, y: 1)
                ])
        
        guard let outputImage = outputCIImage.toUIImage() else {
            return image
        }
        return outputImage
    }
    
    class func toasterFilter(image: UIImage) -> UIImage {
        guard let ciImage = image.toCIImage() else {
            return image
        }
        
        let width = ciImage.extent.width
        let height = ciImage.extent.height
        let centerWidth = width / 2.0
        let centerHeight = height / 2.0
        let radius0 = min(width / 4.0, height / 4.0)
        let radius1 = min(width / 1.5, height / 1.5)
        
        let color0 = self.getColor(red: 128, green: 78, blue: 15, alpha: 255)
        let color1 = self.getColor(red: 79, green: 0, blue: 79, alpha: 255)
        let circle = CIFilter(name: "CIRadialGradient", parameters: [
            "inputCenter": CIVector(x: centerWidth, y: centerHeight),
            "inputRadius0": radius0,
            "inputRadius1": radius1,
            "inputColor0": color0,
            "inputColor1": color1
            ])?.outputImage?.cropped(to: ciImage.extent)
        
        let outputCIImage = ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.0,
                "inputBrightness": 0.01,
                "inputContrast": 1.1
                ])
            .applyingFilter("CIScreenBlendMode", parameters: [
                "inputBackgroundImage": circle!
                ])
        
        guard let outputImage = outputCIImage.toUIImage() else {
            return image
        }
        return outputImage
    }
    
    class func getColor(red: Int, green: Int, blue: Int, alpha: Int = 255) -> CIColor {
        return CIColor(red: CGFloat(Double(red) / 255.0),
                       green: CGFloat(Double(green) / 255.0),
                       blue: CGFloat(Double(blue) / 255.0),
                       alpha: CGFloat(Double(alpha) / 255.0))
    }
    
    class func getColorImage(red: Int, green: Int, blue: Int, alpha: Int = 255, rect: CGRect) -> CIImage {
        let color = self.getColor(red: red, green: green, blue: blue, alpha: alpha)
        return CIImage(color: color).cropped(to: rect)
    }
    
}
