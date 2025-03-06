//
//  DynamicTextView.swift
//  Shortcut
//
//  Created by 和田 優斗 on 2025/03/04.
//

import Foundation
import SwiftUI

/*struct DynamicHeightTextview: NSViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    
    let textView = NSTextView()
    
    func makeUIView(context: Context) -> NSTextView {
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 15)
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateNSView(_ view: NSTextView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(dynamicHeightTextView: self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        let dynamicHeightTextView: DynamicHeightTextview
        let textView: NSTextView
        
        init(dynamicHeightTextView: DynamicHeightTextview) {
            self.dynamicHeightTextView = dynamicHeightTextView
            self.textView = dynamicHeightTextView.textView
        }
        
        func textViewDidChange(_ textView: NSTextView) {
            dynamicHeightTextView.text = textView.string
            let textViewSize = textView.sizeThatFits(textView.bounds.size)
            dynamicHeightTextView.height = textViewSize.height
        }
    }
}*/
