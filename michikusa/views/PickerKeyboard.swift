import UIKit

class PickerKeyboard: UIControl {
    
    var data: [String] = ["Mon.", "Tue.", "Wed.", "Thu.", "Fri.", "Sut.", "Sun."]
    let button: UIButton = UIButton(type: .system)
    var textStore: String = ""
    
    override func draw(_ rect: CGRect) {
        UIColor.black.set()
        UIRectFrame(rect)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attrs: [NSAttributedStringKey: AnyObject] = [.font: UIFont.systemFont(ofSize: 20), .paragraphStyle: paragraphStyle]
        NSString(string: textStore).draw(in: rect, withAttributes: attrs)
    }
    
    func addData(d: [String]) {
        self.data = d
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addTarget(self, action: #selector(PickerKeyboard.didTap(sender:)), for: .touchUpInside)
    }
    
    @objc func didTap(sender: PickerKeyboard) {
        becomeFirstResponder()
    }
    
    @objc func didTapDone(sender: UIButton) {
        resignFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputView: UIView? {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        let row = data.index(of: textStore) ?? -1
        pickerView.selectRow(row, inComponent: 0, animated: false)
        return pickerView
    }
    
    override var inputAccessoryView: UIView? {
        button.setTitle("Done", for: .normal)
        button.addTarget(self, action: #selector(didTapDone(sender:)), for: .touchUpInside)
        button.sizeToFit()
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 44))
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.backgroundColor = .groupTableViewBackground
        
        button.frame.origin.x = 16
        button.center.y = view.center.y
        button.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin, .flexibleTopMargin]
        view.addSubview(button)
        
        return view
    }
}

extension PickerKeyboard: UIKeyInput {
    // It is not necessary to store text in this situation.
    var hasText: Bool {
        return !textStore.isEmpty
    }
    
    func insertText(_ text: String) {
        textStore += text
        setNeedsDisplay()
    }
    
    func deleteBackward() {
        textStore.remove(at: textStore.index(before: textStore.endIndex))
        setNeedsDisplay()
    }
}

extension PickerKeyboard: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textStore = data[row]
        setNeedsDisplay()
    }
}
