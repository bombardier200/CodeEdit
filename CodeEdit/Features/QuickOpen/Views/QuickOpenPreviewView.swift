//
//  QuickOpenPreviewView.swift
//  CodeEditModules/QuickOpen
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI

struct QuickOpenPreviewView: View {

    private let queue = DispatchQueue(label: "austincondiff.CodeEdit.quickOpen.preview")
    private let item: CEWorkspaceFile

    @ObservedObject
    var document: CodeFileDocument

    init(
        item: CEWorkspaceFile
    ) {
        self.item = item
        let doc = try? CodeFileDocument(
            for: item.url,
            withContentsOf: item.url,
            ofType: "public.source-code"
        )
        self._document = .init(wrappedValue: doc ?? .init())
    }

    var body: some View {
        CodeFileView(codeFile: document, isEditable: false)
    }
}
