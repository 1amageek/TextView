//
//  SwiftUIView.swift
//
//
//  Created by nori on 2020/12/27.
//

import SwiftUI

public class _UITextView: UITextView {

    public override var intrinsicContentSize: CGSize {
        let fixedWidth: CGFloat = self.frame.width
        return self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    }
}

struct _TextView: UIViewRepresentable {

    typealias UIViewType = _UITextView

    @Binding var text: String

    @Binding var isFirstResponder: Bool

    @Binding var size: CGSize

    var keyboardType: UIKeyboardType

    var isScrollEnabled: Bool

    var isEditable: Bool

    var textAlignment: NSTextAlignment

    var font: UIFont

    var maximumNumberOfLines: Int

    var lineBreakMode: NSLineBreakMode

    var textContainerInset: UIEdgeInsets

    init(
        _ text: Binding<String>,
        isFirstResponder: Binding<Bool> = .constant(false),
        size: Binding<CGSize> = .constant(.zero),
        keyboardType: UIKeyboardType = .default,
        isScrollEnabled: Bool = false,
        isEditable: Bool = true,
        textAlignment: NSTextAlignment = .left,
        font: UIFont = .systemFont(ofSize: 16, weight: .medium),
        maximumNumberOfLines: Int = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        textContainerInset: UIEdgeInsets = .zero
    ) {
        self._text = text
        self._isFirstResponder = isFirstResponder
        self._size = size
        self.keyboardType = keyboardType
        self.isScrollEnabled = isScrollEnabled
        self.isEditable = isEditable
        self.textAlignment = textAlignment
        self.font = font
        self.maximumNumberOfLines = maximumNumberOfLines
        self.lineBreakMode = lineBreakMode
        self.textContainerInset = textContainerInset
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> _UITextView {
        let view: _UITextView = _UITextView()
        view.backgroundColor = UIColor.clear
        view.isScrollEnabled = self.isScrollEnabled
        view.isEditable = self.isEditable
        view.textAlignment = self.textAlignment
        view.font = self.font
        view.textContainer.maximumNumberOfLines = self.maximumNumberOfLines
        view.textContainer.lineBreakMode = self.lineBreakMode
        view.keyboardType = self.keyboardType
        view.inputAccessoryView = nil
        view.delegate = context.coordinator
        view.textContainerInset = textContainerInset
        return view
    }

    func updateUIView(_ uiView: _UITextView, context: Context) {
        uiView.text = text
        uiView.keyboardType = keyboardType
        uiView.isScrollEnabled = isScrollEnabled
        uiView.isEditable = isEditable
        uiView.textAlignment = textAlignment
        uiView.font = font
        uiView.textContainer.maximumNumberOfLines = maximumNumberOfLines
        uiView.textContainer.lineBreakMode = lineBreakMode
        uiView.keyboardType = keyboardType
        uiView.textContainerInset = textContainerInset
        if !uiView.isFirstResponder, isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        }
        if uiView.isFirstResponder, !isFirstResponder {
            DispatchQueue.main.async {
                uiView.resignFirstResponder()
            }
        }
    }

    class Coordinator : NSObject, UITextViewDelegate {

        var textView: _TextView

        public init(_ view: _TextView) {
            self.textView = view
        }

        public func textViewDidBeginEditing(_ textView: UITextView) {
            self.textView.$isFirstResponder.wrappedValue = true
        }

        public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
            self.textView.$isFirstResponder.wrappedValue = false
            return true
        }

        public func textViewDidChange(_ textView: UITextView) {
            if textView.markedTextRange == nil {
                self.textView.text = textView.text
            }

//            print(textView.frame.size)
//            print(textView.textContainer.size)

            self.textView.size = textView.textContainer.size
        }
    }
}

extension NSTextAlignment {
    var alignment: Alignment {
        switch self {
            case .left: return .leading
            case .center: return .center
            case .right: return .trailing
            case .justified: return .leading
            case .natural: return .leading
            @unknown default: fatalError()
        }
    }
}

public struct TextView: View {

    @Binding public var text: String

    public var placeholder: String?

    public var isFirstResponder: Binding<Bool>?

    @State private var isFirstResponder_: Bool = false

    public var keyboardType: UIKeyboardType

    public var isScrollEnabled: Bool

    public var isEditable: Bool

    public var textAlignment: NSTextAlignment

    public var font: UIFont

    public var maximumNumberOfLines: Int

    public var lineBreakMode: NSLineBreakMode

    public var textContainerInset: UIEdgeInsets

    @Binding public var size: CGSize

    public init(
        _ text: Binding<String>,
        placeholder: String? = nil,
        isFirstResponder: Binding<Bool>? = nil,
        keyboardType: UIKeyboardType = .default,
        isScrollEnabled: Bool = false,
        isEditable: Bool = true,
        textAlignment: NSTextAlignment = .left,
        font: UIFont = .systemFont(ofSize: 16, weight: .medium),
        maximumNumberOfLines: Int = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        textContainerInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
        size: Binding<CGSize> = .constant(.zero)
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isFirstResponder = isFirstResponder
        self.keyboardType = keyboardType
        self.isScrollEnabled = isScrollEnabled
        self.isEditable = isEditable
        self.textAlignment = textAlignment
        self.font = font
        self.maximumNumberOfLines = maximumNumberOfLines
        self.lineBreakMode = lineBreakMode
        self.textContainerInset = textContainerInset
        self._size = size
    }

    public var body: some View {
        ZStack {
            _TextView(
                $text,
                isFirstResponder: isFirstResponder ?? self.$isFirstResponder_,
                size: $size,
                keyboardType: keyboardType,
                isScrollEnabled: isScrollEnabled,
                isEditable: isEditable,
                textAlignment: textAlignment,
                font: font,
                maximumNumberOfLines: maximumNumberOfLines,
                lineBreakMode: lineBreakMode,
                textContainerInset: textContainerInset
            )
            .background(
                VStack {
                    if let placeholder = self.placeholder,
                       self.text.isEmpty {
                        Text(placeholder)
                            .font(.system(size: font.pointSize))
                            .foregroundColor(Color(UIColor.placeholderText))
                            .frame(maxWidth: .infinity,
                                   alignment: textAlignment.alignment)
                            .padding(EdgeInsets(
                                        top: textContainerInset.top,
                                        leading: textContainerInset.left,
                                        bottom: textContainerInset.bottom,
                                        trailing: textContainerInset.right
                            ))
                        Spacer()
                    }
                }
                .padding(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
            )
        }
    }
}

struct TextView_Previews: PreviewProvider {

    struct ContentView: View {

        @State var text: String = "g"

        @State var isFirstResponder: Bool = false

        var body: some View {
            TextView($text, placeholder: "aaaaa")
        }
    }

    static var previews: some View {
        VStack {
            Group {
                TextView(.constant(""), placeholder: "placeholder")
                TextView(.constant("text"), placeholder: "placeholder")
                TextView(.constant(""), placeholder: "placeholder", textAlignment: .left)
                TextView(.constant("text"), placeholder: "placeholder", textAlignment: .left)
                TextView(.constant(""), placeholder: "placeholder", textAlignment: .center)
                TextView(.constant("text"), placeholder: "placeholder", textAlignment: .center)
                TextView(.constant(""), placeholder: "placeholder", textAlignment: .right)
                TextView(.constant("text"), placeholder: "placeholder", textAlignment: .right)
                TextView(.constant(""), placeholder: "placeholder", font: UIFont.systemFont(ofSize: 20))
                TextView(.constant("text"), placeholder: "placeholder", font: UIFont.systemFont(ofSize: 20))
            }

            Group {
                TextView(.constant(""), placeholder: "placeholder", font: UIFont.systemFont(ofSize: 20), textContainerInset: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
                TextView(.constant("text"), placeholder: "placeholder", font: UIFont.systemFont(ofSize: 20), textContainerInset: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
            }
        }

    }
}
