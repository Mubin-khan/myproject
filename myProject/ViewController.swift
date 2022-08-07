//
//  ViewController.swift
//  myProject
//
//  Created by Adhira on 28/6/22.
//

import UIKit
import GPUImage
import Mantis


class ViewController: UIViewController {
    
    struct Blur {
        let filterName : String
        var filterEffectValue : Any?
        
        init(name : String, value : Any?){
            self.filterName = name
            self.filterEffectValue = value
        }
    }
    
    enum EffectChosed {
        case none, effect1
    }
    
    var currentEffect = EffectChosed.none
    
    enum FilterChosed {
        case none, sepia, mono, haze
    }
    
    var currentFilter : FilterChosed = FilterChosed.none
    
    enum AdjustStates {
        case brightness, contrast, saturation
    }
    
    var currentAdjust : AdjustStates = AdjustStates.brightness
    
    struct AppendVarialble {
        var blur : Float
        var birghtness : Float
        var contrast : Float
        var saturation : Float
        var filterName : FilterChosed
    }
    
    var currentState = 0
    
    var imageBeforeBlurred : UIImage? = nil
    var blurredImage : UIImage? = nil
    @IBOutlet weak var undoImageView: UIImageView!
    @IBOutlet weak var indoImageView: UIImageView!
    
    @IBOutlet weak var testImageView: UIImageView!
    var allStates = [AppendVarialble]()
    
    @IBOutlet weak var doundoView: UIView!
    @IBOutlet weak var renderView: RenderView!

    @IBOutlet weak var featureView: UIView!
    @IBOutlet weak var adjustView: UIView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var effectView: UIView!
    @IBOutlet weak var blurView: UIView!
    
    @IBOutlet weak var effectSlider: UISlider!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var adjustSlider: UISlider!
    
    var effectValue : Float = 0
    var prevEffectSlider : Float = 0.2
    
    var blurValue : Float = 0
    var prevBlurSlider : Float = 0.2
    
    var brightness : Float = 0
    var contrast : Float = 1
    var saturation : Float = 1
    
    var prevBrightnessSlide : Float = 0.5
    var prevContrastSlide : Float = 0.5
    var prevSaturationSlide : Float = 0.5
    
    
    var picture:PictureInput!
    var outputPicture : PictureOutput!
    var blurFilter: GaussianBlur!
    var brightnessFilter : BrightnessAdjustment!
    var contrastFilter : ContrastAdjustment!
    var saturationFilter : SaturationAdjustment!
    var filter : BasicOperation!
    var effect : LookupFilter!
    
    var originalImage : UIImage?
    var image2 : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderView.isHidden = true
        renderView.contentMode = .scaleAspectFit
        picture = PictureInput(image: UIImage(named: "siam")!)
       
        originalImage = testImageView.image
        showViews()
        
        appendState()
        
        undoImageView.image = undoImageView.image?.withRenderingMode(.alwaysTemplate)
        indoImageView.image = indoImageView.image?.withRenderingMode(.alwaysTemplate)
    }
    
    func showViews(){
        doundoView.isHidden = false
        featureView.isHidden = false
        adjustView.isHidden = true
        filterView.isHidden = true
        effectView.isHidden = true
        blurView.isHidden = true
    }
    
    
    @IBAction func filterAction(_ sender: Any) {
        filterView.isHidden = !filterView.isHidden
        featureView.isHidden = !featureView.isHidden
        doundoView.isHidden = !doundoView.isHidden
    }
    
    @IBAction func effectAction(_ sender: Any) {
        effectView.isHidden = !effectView.isHidden
        featureView.isHidden = !featureView.isHidden
        doundoView.isHidden = !doundoView.isHidden
        
//        renderView.isHidden = false
//        testImageView.isHidden = true
        
        effectSlider.addTarget(self, action: #selector(onSliderValChangedEffect(slider:event:)), for: .valueChanged)
        goforEffect()
    }
    
    @IBAction func blurAction(_ sender: Any) {
        blurView.isHidden = !blurView.isHidden
        featureView.isHidden = !featureView.isHidden
        doundoView.isHidden = !doundoView.isHidden
        
        imageBeforeBlurred = getImageBeforeBlur()
        blurSlider.addTarget(self, action: #selector(onSliderValChangedBlur(slider:event:)), for: .valueChanged)
        blurSlider.setValue(prevBlurSlider, animated: true)
        testImageView.image = blurringImage(testImage: imageBeforeBlurred)
    }
    
    @IBAction func adjustAction(_ sender: Any) {
        adjustView.isHidden = !adjustView.isHidden
        featureView.isHidden = !featureView.isHidden
        doundoView.isHidden = !doundoView.isHidden
        
        currentAdjust = AdjustStates.brightness
        adjustSlider.setValue(prevBrightnessSlide, animated: true)
        adjustSlider.addTarget(self, action: #selector(onSliderValChangedAdjust(slider:event:)), for: .valueChanged)
    }
    
    
    
    @IBAction func blurCancel(_ sender: Any) {
        blurView.isHidden = !blurView.isHidden
        featureView.isHidden = !featureView.isHidden
        doundoView.isHidden = !doundoView.isHidden
        
        cancelling()
    }
    
    @IBAction func applyBlur(_ sender: Any) {
        blurView.isHidden = !blurView.isHidden
        featureView.isHidden = !featureView.isHidden
        doundoView.isHidden = !doundoView.isHidden
        
        
        blurValue = blurSlider.value / 10
        while(currentState != 0){
            allStates.removeLast()
            currentState -= 1
        }
        appendState()
    }
    
    @IBAction func cancelAdjust(_ sender: Any) {
        adjustView.isHidden = !adjustView.isHidden
        featureView.isHidden = !featureView.isHidden
        doundoView.isHidden = !doundoView.isHidden
        
        
        cancelling()
    }
    
    @IBAction func applyAdjust(_ sender: Any) {
        adjustView.isHidden = !adjustView.isHidden
        featureView.isHidden = !featureView.isHidden
        doundoView.isHidden = !doundoView.isHidden
        
        while(currentState != 0){
            allStates.removeLast()
            currentState -= 1
        }
        appendState()
    }
    
    
    @IBAction func effectCancel(_ sender: Any) {
        effectView.isHidden = !effectView.isHidden
        featureView.isHidden = !featureView.isHidden
        doundoView.isHidden = !doundoView.isHidden
    }
    @IBAction func effectApply(_ sender: Any) {
        effectView.isHidden = !effectView.isHidden
        featureView.isHidden = !featureView.isHidden
        doundoView.isHidden = !doundoView.isHidden
        
        while(currentState != 0){
            allStates.removeLast()
            currentState -= 1
        }
    }
    
    @IBAction func cancelFilter(_ sender: Any) {
        filterView.isHidden = !filterView.isHidden
        featureView.isHidden = !featureView.isHidden
        doundoView.isHidden = !doundoView.isHidden
        renderView.isHidden = true
        testImageView.isHidden = false
        
        cancelling()
    }
    
    @IBAction func filterApply(_ sender: Any) {
        filterView.isHidden = !filterView.isHidden
        featureView.isHidden = !featureView.isHidden
        doundoView.isHidden = !doundoView.isHidden
        renderView.isHidden = true
        testImageView.isHidden = false
        
        while(currentState != 0){
            allStates.removeLast()
            currentState -= 1
        }
        appendState()
    }
    
    // Blur effect ------------
    
    @objc func onSliderValChangedBlur(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
           
            case .moved : testImageView.image = blurringImage(testImage: imageBeforeBlurred)
                
            case .ended : prevBlurSlider = blurSlider.value
                
            default:
                break
            }
        }
    }
    
    let ciCtx = CIContext()
    func blurringImage(testImage : UIImage?) -> UIImage?{
        
        guard let testImage = testImage else {
            return nil
        }
        
        guard let cgImage = testImage.cgImage else {
            return nil
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(blurSlider.value * 10 , forKey: kCIInputRadiusKey)
        
        let cgiig = ciCtx.createCGImage((filter?.outputImage)!, from: ciImage.extent)
        return UIImage(cgImage: cgiig!)
    }
    
    
    // Adjust -------------
    
    @objc func onSliderValChangedAdjust(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
           
            case .moved :
                switch(currentAdjust){
                    case .brightness :
                        let val : Float = 0.6 * ( adjustSlider.value - 0.5 )
                        brightness = val
                        applyingAll()
                    
                    case .contrast :
                        var val : Float = 1
                        if (adjustSlider.value >= 0.5){
                            let a = 1.5 / 0.5
                            let b = adjustSlider.value - 0.5
                            val = Float(( a * Double(b) ) + 1.0)
                        }else {
                            val = Float(0.5 + adjustSlider.value)
                        }
                        contrast = val
                        applyingAll()
                    
                    case .saturation :
                        var val : Float = 1
                        if (adjustSlider.value >= 0.5){
                            let a = 1.5 / 0.5
                            let b = adjustSlider.value - 0.5
                            val = Float(( a * Double(b) ) + 1.0)
                        }else {
                            val = Float(0.5 + adjustSlider.value)
                        }
                        saturation = val
                        applyingAll()
                    
                }
            case .ended :
                switch(currentAdjust){
                case .brightness :
                    prevBrightnessSlide = adjustSlider.value
                case .contrast :
                    prevContrastSlide = adjustSlider.value
                case .saturation :
                    prevSaturationSlide = adjustSlider.value
                }
                
            default:
                break
            }
        }
    }
    
    @IBAction func brightnessAction(_ sender: Any) {
        currentAdjust = AdjustStates.brightness
        adjustSlider.setValue(prevBrightnessSlide, animated: true)
        
    }
    
    @IBAction func contrastAction(_ sender: Any) {
        currentAdjust = AdjustStates.contrast
        adjustSlider.setValue(prevContrastSlide, animated: true)
        
       
    }
    
    @IBAction func saturationAction(_ sender: Any) {
        currentAdjust = AdjustStates.saturation
        adjustSlider.setValue(prevSaturationSlide, animated: true)
        
       
    }
    
    
    // filter ---------------
    
    @IBAction func noneAction(_ sender: Any) {
        currentFilter = FilterChosed.none
        
        applyingAll()
    }
    
    @IBAction func monoAction(_ sender: Any) {
        currentFilter = FilterChosed.mono
        
        applyingAll()
    }
    
    @IBAction func sepiaAction(_ sender: Any) {
        currentFilter = FilterChosed.sepia
        
        applyingAll()
    }
    
    @IBAction func colorMatrixAction(_ sender: Any) {
        currentFilter = FilterChosed.haze
        
        applyingAll()
    }
    
    // effect -----------
    
    @objc func onSliderValChangedEffect(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
           
            case .moved : break
               goforEffect()
               
                
            case .ended : break
                
            default:
                break
            }
        }
    }
    
    var f : LookupFilter!
    func goforEffect(){
        
//        let lutImage = UIImage(named: "Beagle")
//        testImageView.image = originalImage?.applyLUTFilter(LUT: lutImage, volume: 1)
        
        
        
        let lokupImage = UIImage(named: "Beagle")
        guard let lokupImage = lokupImage else {return}
//
        effect = LookupFilter()
        effect.lookupImage = PictureInput(image: lokupImage)
        effect.intensity = effectSlider.value
//
////        testImageView.image = originalImage?.filterWithOperation(effect)
//        testImageView.image = originalImage!.filterWithPipeline{input, output in
//            input --> effect --> output
//        }

        outputPicture = PictureOutput()
        let pictureInput = PictureInput(image: originalImage!)
        outputPicture.imageAvailableCallback = {image in
            self.image2 = image
        }
        pictureInput --> effect --> outputPicture
//        renderView.sources.removeAtIndex(0)
        pictureInput.processImage(synchronously: true)
       
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
            self.testImageView.image = self.image2
        }
       
//        let filteredImage = originalImage.
    }
    
    @IBAction func effectNoneAction(_ sender: Any) {
        
    }
    
    
    @IBAction func effectOneAction(_ sender: Any) {
        
    }
    
    
    // combining all ----------
    
    func appendState(){
        allStates.append(AppendVarialble(blur: blurValue, birghtness: brightness, contrast: contrast, saturation: saturation, filterName: currentFilter))
        
        applyingAll()
        
        indoundoColorset()
    }
    
    func cancelling(){
        let temp = allStates.last
        
        guard let temp = temp else { return }
        
        setAllStats(temp: temp)
    }
    
    func setAllStats(temp : AppendVarialble){
        
        brightness = temp.birghtness
        contrast = temp.contrast
        saturation = temp.saturation
        blurValue = temp.blur
        currentFilter = temp.filterName
        
        
        applyingAll()
        
        prevBrightnessSlide = (brightness / 0.6) + 0.5
        if contrast >= 1 {
            prevContrastSlide = (((contrast - 1) * 0.5 ) / 1.5 ) + 0.5
        }
        else if contrast < 1 {
            prevContrastSlide = contrast - 0.5
        }
        if saturation >= 1 {
            prevSaturationSlide = (((saturation - 1) * 0.5 ) / 1.5 ) + 0.5
        }
        else if saturation < 1 {
            prevSaturationSlide = saturation - 0.5
        }
       
        if blurValue > 0 {
            prevBlurSlider = blurValue / 10
        }
        else {
            prevBlurSlider = 0.2
        }
           
    }
    
    func applyingAll(){
        brightnessFilter = BrightnessAdjustment()
        contrastFilter = ContrastAdjustment()
        saturationFilter = SaturationAdjustment()
        
        brightnessFilter.brightness = brightness
        contrastFilter.contrast = contrast
        saturationFilter.saturation = saturation
        
        switch(currentFilter){
            case .haze :
                filter = Haze()
            case .mono :
                filter = MonochromeFilter()
            case .sepia :
                filter = SepiaToneFilter()
            default : break
        }
        
        
//        let myGroup = OperationGroup()
//
//        myGroup.configureGroup{input, output in
//            input --> self.brightnessFilter --> self.contrastFilter --> self.saturationFilter --> output
//        }
//        testImageView.image = originalImage?.filterWithPipeline({ Input, Output in
//            Input --> brightnessFilter --> contrastFilter --> saturationFilter --> Output
//        })
        
        
        
        
        
        
//        var filteredImage = originalImage?
//                    .filterWithOperation(brightnessFilter)
//                    .filterWithOperation(contrastFilter)
//                    .filterWithOperation(saturationFilter)
//
//        if currentFilter.self != .none {
//            filteredImage = filteredImage?.filterWithOperation(filter)
//        }
//
//        if currentEffect.self != .none {
////            filteredImage = filteredImage?.filterWithOperation(effect)
//        }
//
//        if blurValue > 0 {
//            filteredImage = blurringImage(testImage: filteredImage)
//        }
        
//        testImageView.image = filteredImage
    }
    
    
    
    
    // undo indo
    
    @IBAction func undoAction(_ sender: Any) {
        if allStates.count - currentState > 1 {
            currentState += 1
            let tmp = allStates[allStates.count - currentState - 1]
            setAllStats(temp: tmp)
        }
        
        indoundoColorset()
    }
    
    @IBAction func indoAction(_ sender: Any) {
        if currentState > 0 {
            currentState -= 1
            let tmp = allStates[allStates.count - currentState - 1]
            setAllStats(temp: tmp)
        }
        
        indoundoColorset()
    }
    
    func indoundoColorset(){
        if currentState > 0 {
            indoImageView.tintColor = .white
        }else if currentState == 0 {
            indoImageView.tintColor = UIColor(red: 0.227, green: 0.227, blue: 0.231, alpha: 1)
        }
        
        if allStates.count - currentState > 1 {
            undoImageView.tintColor = .white
        }else if allStates.count - currentState == 1 {
            undoImageView.tintColor = UIColor(red: 0.227, green: 0.227, blue: 0.231, alpha: 1)
        }
    }
    
    
    func getImageBeforeBlur() -> UIImage? {
        brightnessFilter = BrightnessAdjustment()
        contrastFilter = ContrastAdjustment()
        saturationFilter = SaturationAdjustment()
        
        brightnessFilter.brightness = brightness
        contrastFilter.contrast = contrast
        saturationFilter.saturation = saturation
        
        switch(currentFilter){
            case .haze :
                filter = Haze()
            case .mono :
                filter = MonochromeFilter()
            case .sepia :
                filter = SepiaToneFilter()
            default : break
        }
        
        
        var filteredImage = originalImage?
                    .filterWithOperation(brightnessFilter)
                    .filterWithOperation(contrastFilter)
                    .filterWithOperation(saturationFilter)
        
        if currentFilter.self != .none {
            filteredImage = filteredImage?.filterWithOperation(filter)
        }
        
        if currentEffect.self != .none {
//            filteredImage = filteredImage?.filterWithOperation(effect)
        }
        
        guard let filteredImage = filteredImage else { return nil }
        
        return filteredImage
    }
    
    
    // practice
    
    @IBAction func blurNextAction(_ sender: Any) {
        present(BlurViewController(), animated: true, completion: nil)
    }
    
    @IBAction func cropAction(_ sender: Any) {
        let cropViewController = Mantis.cropCustomizableViewController(image: originalImage!)
        cropViewController.delegate = self
        var config = Mantis.Config()
        config.addCustomRatio(byVerticalWidth: 1, andVerticalHeight: 2)
//        cropViewController = Mantis.cropViewController(image: originalImage!, config: config)
        
      
        present(cropViewController, animated: true)
    }
    
}


extension ViewController : CropViewControllerDelegate {
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
        print("done")
    }
    
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        print("cancel")
    }
    
    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {
        
    }
    
    func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {
        
    }
    
}

