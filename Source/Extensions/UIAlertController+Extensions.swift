import UIKit
import AudioToolbox
import Photos


// MARK: - Methods
extension UIAlertController {
    
    /// Present alert view controller in the current view controller.
    ///
    /// - Parameters:
    ///   - animated: set true to animate presentation of alert controller (default is true).
    ///   - vibrate: set true to vibrate the device while presenting the alert (default is false).
    ///   - completion: an optional completion handler to be called after presenting alert controller (default is nil).
    public func show(animated: Bool = true, vibrate: Bool = false, style: UIBlurEffect.Style? = nil, completion: (() -> Void)? = nil) {
        
        /// TODO: change UIBlurEffectStyle
        if let style = style {
            for subview in view.allSubViewsOf(type: UIVisualEffectView.self) {
                subview.effect = UIBlurEffect(style: style)
            }
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: animated, completion: completion)
            if vibrate {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
        }
    }
    
    /// Add an action to Alert
    ///
    /// - Parameters:
    ///   - title: action title
    ///   - style: action style (default is UIAlertActionStyle.default)
    ///   - isEnabled: isEnabled status for action (default is true)
    ///   - handler: optional action handler to be called when button is tapped (default is nil)
    public func addAction(image: UIImage? = nil, title: String, color: UIColor? = nil, style: UIAlertAction.Style = .default, isEnabled: Bool = true, handler: ((UIAlertAction) -> Void)? = nil) {
        //let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
        //let action = UIAlertAction(title: title, style: isPad && style == .cancel ? .default : style, handler: handler)
        let action = UIAlertAction(title: title, style: style, handler: handler)
        action.isEnabled = isEnabled
        
        // button image
        if let image = image {
            action.setValue(image, forKey: "image")
        }
        
        // button title color
        if let color = color {
            action.setValue(color, forKey: "titleTextColor")
        }
        
        addAction(action)
    }
    
    /// Set alert's title, font and color
    ///
    /// - Parameters:
    ///   - title: alert title
    ///   - font: alert title font
    ///   - color: alert title color
    public func set(title: String?, font: UIFont, color: UIColor) {
        if title != nil {
            self.title = title
        }
        setTitle(font: font, color: color)
    }
    
    public func setTitle(font: UIFont, color: UIColor) {
        guard let title = self.title else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let attributedTitle = NSMutableAttributedString(string: title, attributes: attributes)
        setValue(attributedTitle, forKey: "attributedTitle")
    }
    
    /// Set alert's message, font and color
    ///
    /// - Parameters:
    ///   - message: alert message
    ///   - font: alert message font
    ///   - color: alert message color
    public func set(message: String?, font: UIFont, color: UIColor) {
        if message != nil {
            self.message = message
        }
        setMessage(font: font, color: color)
    }
    
    public func setMessage(font: UIFont, color: UIColor) {
        guard let message = self.message else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let attributedMessage = NSMutableAttributedString(string: message, attributes: attributes)
        setValue(attributedMessage, forKey: "attributedMessage")
    }
    
    /// Set alert's content viewController
    ///
    /// - Parameters:
    ///   - vc: ViewController
    ///   - height: height of content viewController
    public func set(vc: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
        guard let vc = vc else { return }
        setValue(vc, forKey: "contentViewController")
        if let height = height {
            vc.preferredContentSize.height = height
            preferredContentSize.height = height
        }
    }
    
    /// Add a Text Viewer
    ///
    /// - Parameters:
    ///   - text: text kind
    public func addTextViewer(text: Kind) {
        let textViewer = TextViewerViewController(text: text)
        set(vc: textViewer)
    }
    
    /// Create new alert view controller.
    ///
    /// - Parameters:
    ///   - style: alert controller's style.
    ///   - title: alert controller's title.
    ///   - message: alert controller's message (default is nil).
    ///   - defaultActionButtonTitle: default action button title (default is "OK")
    ///   - tintColor: alert controller's tint color (default is nil)
    public convenience init(style: UIAlertController.Style, source: UIView? = nil, title: String? = nil, message: String? = nil, tintColor: UIColor? = nil) {
        self.init(title: title, message: message, preferredStyle: style)
        
        // TODO: for iPad or other views
        let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
        let root = UIApplication.shared.keyWindow?.rootViewController?.view
        
        //self.responds(to: #selector(getter: popoverPresentationController))
        if let source = source {
            Log("----- source")
            popoverPresentationController?.sourceView = source
            popoverPresentationController?.sourceRect = source.bounds
        } else if isPad, let source = root, style == .actionSheet {
            Log("----- is pad")
            popoverPresentationController?.sourceView = source
            popoverPresentationController?.sourceRect = CGRect(x: source.bounds.midX, y: source.bounds.midY, width: 0, height: 0)
            //popoverPresentationController?.permittedArrowDirections = .down
            popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        }
        
        if let color = tintColor {
            self.view.tintColor = color
        }
    }
    
    /// Add a Color Picker
    ///
    /// - Parameters:
    ///   - color: input color
    ///   - action: for selected color
    open func addColorPicker(color: UIColor = .black, selection: ColorSelection?) {
        let selection: ColorSelection? = selection
        var color: UIColor = color
        
        let buttonSelection = UIAlertAction(title: "Select", style: .default) { action in
            selection?(color)
        }
        buttonSelection.isEnabled = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ColorPicker") as? ColorPickerViewController else { return }
        set(vc: vc)
        
        set(title: color.hexString, font: .systemFont(ofSize: 17), color: color)
        vc.set(color: color) { new in
            color = new
            self.set(title: color.hexString, font: .systemFont(ofSize: 17), color: color)
        }
        addAction(buttonSelection)
    }
    
    /// Add Contacts Picker
    ///
    /// - Parameters:
    ///   - selection: action for selection of contact
    public func addContactsPicker(selection: @escaping ContactsSelection) {
        let selection: ContactsSelection = selection
        var contact: Contact?
        
        let addContact = UIAlertAction(title: "Add Contact", style: .default) { action in
            selection(contact)
        }
        addContact.isEnabled = false
        
        let vc = ContactsPickerViewController { new in
            addContact.isEnabled = new != nil
            contact = new
        }
        
        set(vc: vc)
        addAction(addContact)
    }
    
    /// Add a date picker
    ///
    /// - Parameters:
    ///   - mode: date picker mode
    ///   - date: selected date of date picker
    ///   - minimumDate: minimum date of date picker
    ///   - maximumDate: maximum date of date picker
    ///   - action: an action for datePicker value change
    public func addDatePicker(mode: UIDatePicker.Mode, date: Date?, minimumDate: Date? = nil, maximumDate: Date? = nil, action: DatePickerAction?) {
        let datePicker = DatePickerViewController(mode: mode, date: date, minimumDate: minimumDate, maximumDate: maximumDate, action: action)
        set(vc: datePicker, height: 217)
    }
    
    /// Add Image Picker
    ///
    /// - Parameters:
    ///   - flow: scroll direction
    ///   - pagging: pagging
    ///   - images: for content to select
    ///   - selection: type and action for selection of image/images
    public func addImagePicker(flow: UICollectionView.ScrollDirection, paging: Bool, images: [UIImage], selection: SelectionType? = nil) {
        let vc = ImagePickerViewController(flow: flow, paging: paging, images: images, selection: selection)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            vc.preferredContentSize.height = vc.preferredSize.height * 0.9
            vc.preferredContentSize.width = vc.preferredSize.width * 0.9
        } else {
            vc.preferredContentSize.height = vc.preferredSize.height
        }

        set(vc: vc)
    }
    
    /// Add Locale Picker
    ///
    /// - Parameters:
    ///   - type: country, phoneCode or currency
    ///   - action: for selected locale
    public func addLocalePicker(type: LocalePickerKind, selection: @escaping LocalePickerSelection) {
        var info: LocaleInfo?
        let selection: LocalePickerSelection = selection
        let buttonSelect: UIAlertAction = UIAlertAction(title: "Select", style: .default) { action in
            selection(info)
        }
        buttonSelect.isEnabled = false
        
        let vc = LocalePickerViewController(type: type) { new in
            info = new
            buttonSelect.isEnabled = new != nil
        }
        set(vc: vc)
        addAction(buttonSelect)
    }
    
    /// Add PhotoLibrary Picker
    ///
    /// - Parameters:
    ///   - selection: type and action for selection of asset/assets
    public func addLocationPicker(location: Location? = nil, completion: @escaping LocationPickerCompletionHandler) {
        let vc = LocationPickerViewController()
        vc.location = location
        vc.completion = completion
        set(vc: vc)
    }
    
    /// Add PhotoLibrary Picker
    ///
    /// - Parameters:
    ///   - flow: scroll direction
    ///   - pagging: pagging
    ///   - images: for content to select
    ///   - selection: type and action for selection of image/images
    public func addPhotoLibraryPicker(flow: UICollectionView.ScrollDirection, paging: Bool, selection: PhotoLibrarySelection) {
        let selection: PhotoLibrarySelection = selection
        var asset: PHAsset?
        var assets: [PHAsset] = []
        
        let buttonAdd = UIAlertAction(title: "Add", style: .default) { action in
            switch selection {
                
            case .single(let action):
                action?(asset)
                
            case .multiple(let action):
                action?(assets)
            }
        }
        buttonAdd.isEnabled = false
        
        let vc = PhotoLibraryPickerViewController(flow: flow, paging: paging, selection: {
            switch selection {
            case .single(_):
                return .single(action: { new in
                    buttonAdd.isEnabled = new != nil
                    asset = new
                })
            case .multiple(_):
                return .multiple(action: { new in
                    buttonAdd.isEnabled = new.count > 0
                    assets = new
                })
            }
        }())
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            vc.preferredContentSize.height = vc.preferredSize.height * 0.9
            vc.preferredContentSize.width = vc.preferredSize.width * 0.9
        } else {
            vc.preferredContentSize.height = vc.preferredSize.height
        }
        
        addAction(buttonAdd)
        set(vc: vc)
    }
    
    /// Add a picker view
    ///
    /// - Parameters:
    ///   - values: values for picker view
    ///   - initialSelection: initial selection of picker view
    ///   - action: action for selected value of picker view
    public func addPickerView(values: PickerViewValues,  initialSelection: PickerViewIndex? = nil, action: PickerViewAction?) {
        let pickerView = PickerViewViewController(values: values, initialSelection: initialSelection, action: action)
        set(vc: pickerView, height: 216)
    }
    
    /// Add Telegram Picker
    ///
    /// - Parameters:
    ///   - selection: type and action for selection of asset/assets
    public func addTelegramPicker(selection: @escaping TelegramSelection) {
        let vc = TelegramPickerViewController(selection: selection)
        set(vc: vc)
    }
    
    /// Add two textField
    ///
    /// - Parameters:
    ///   - height: textField height
    ///   - hInset: right and left margins to AlertController border
    ///   - vInset: bottom margin to button
    ///   - textFieldOne: first textField
    ///   - textFieldTwo: second textField
    public func addTwoTextFields(height: CGFloat = 58, hInset: CGFloat = 0, vInset: CGFloat = 0, textFieldOne: TextField.Config?, textFieldTwo: TextField.Config?) {
        let textField = TwoTextFieldsViewController(height: height, hInset: hInset, vInset: vInset, textFieldOne: textFieldOne, textFieldTwo: textFieldTwo)
        set(vc: textField, height: height * 2 + 2 * vInset)
    }
    
    /// Add a textField
    ///
    /// - Parameters:
    ///   - height: textField height
    ///   - hInset: right and left margins to AlertController border
    ///   - vInset: bottom margin to button
    ///   - configuration: textField
    public func addOneTextField(configuration: TextField.Config?) {
        let textField = OneTextFieldViewController(vInset: preferredStyle == .alert ? 12 : 0, configuration: configuration)
        let height: CGFloat = OneTextFieldViewController.ui.height + OneTextFieldViewController.ui.vInset
        set(vc: textField, height: height)
    }
}

