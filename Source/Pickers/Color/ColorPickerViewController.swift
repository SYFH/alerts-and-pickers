import UIKit

public typealias ColorSelection = (UIColor) -> Swift.Void
class ColorPickerViewController: UIViewController {
    
    fileprivate var selection: ColorSelection?
    
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var saturationSlider: GradientSlider!
    @IBOutlet weak var brightnessSlider: GradientSlider!
    @IBOutlet weak var hueSlider: GradientSlider!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    public var color: UIColor {
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    public var hue: CGFloat = 0.5
    public var saturation: CGFloat = 0.5
    public var brightness: CGFloat = 0.5
    public var alpha: CGFloat = 1
    
    fileprivate var preferredHeight: CGFloat = 0
    
    func set(color: UIColor, selection: ColorSelection?) {
        let components = color.hsbaComponents
        
        hue = components.hue
        saturation = components.saturation
        brightness = components.brightness
        alpha = components.alpha
        
        let mainColor: UIColor = UIColor(
            hue: hue,
            saturation: 1.0,
            brightness: 1.0,
            alpha: 1.0)
        
        hueSlider.minColor = mainColor
        hueSlider.thumbColor = mainColor
        brightnessSlider.maxColor = mainColor
        saturationSlider.maxColor = mainColor
        
        hueSlider.value = hue
        saturationSlider.value = saturation
        brightnessSlider.value = brightness
        
        updateColorView()
        
        self.selection = selection
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Log("preferredHeight = \(preferredHeight)")
        
        saturationSlider.minColor = .white
        brightnessSlider.minColor = .black
        hueSlider.hasRainbow = true
        
        hueSlider.actionBlock = { [unowned self] slider, newValue in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            
            self.hue = newValue
            let mainColor: UIColor = UIColor(
                hue: newValue,
                saturation: 1.0,
                brightness: 1.0,
                alpha: 1.0)
            
            self.hueSlider.thumbColor = mainColor
            self.brightnessSlider.maxColor = mainColor
            self.saturationSlider.maxColor = mainColor
            
            self.updateColorView()
            
            CATransaction.commit()
        }
        
        brightnessSlider.actionBlock = { [unowned self] slider, newValue in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            
            self.brightness = newValue
            self.updateColorView()
            
            CATransaction.commit()
        }
        
        saturationSlider.actionBlock = { [unowned self] slider, newValue in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            
            self.saturation = newValue
            self.updateColorView()
            
            CATransaction.commit()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredHeight = mainStackView.frame.maxY
    }
    
    func updateColorView() {
        colorView.backgroundColor = color
        selection?(color)
        Log("set color = \(color.hexString)")
    }
}

