//
//  String+Ext.swift
//  VeroTask
//
//  Created by Yigit Ozdamar on 24.03.2023.
//

import Foundation
extension String {
    /// Using regular expressions is not a correct approach for converting HTML to text, there are many pitfalls, like handling <style> and <script> tags. On platforms that support Foundation, one alternative is to use NSAttributedString's basic HTML support. Care must be taken to handle extraneous newlines and object replacement characters left over from the conversion process. It is a good idea to cache complex generated NSAttributedStrings either through storage or NSCache.
    func strippingHTML() throws -> String?  {
        if isEmpty {
            return nil
        }
        
        if let data = data(using: .utf8) {
            let attributedString = try NSAttributedString(data: data,
                                                          options: [.documentType : NSAttributedString.DocumentType.html,
                                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                                          documentAttributes: nil)
            var string = attributedString.string
            
            // These steps are optional, and it depends on how you want handle whitespace and newlines
            string = string.replacingOccurrences(of: "\u{FFFC}",
                                                 with: "",
                                                 options: .regularExpression,
                                                 range: nil)
            string = string.replacingOccurrences(of: "(\n){3,}",
                                                 with: "\n\n",
                                                 options: .regularExpression,
                                                 range: nil)
            return string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return nil
    }
}
