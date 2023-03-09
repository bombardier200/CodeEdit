//
//  TerminalEmulatorView.swift
//  CodeEditModules/TerminalEmulator
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI
import SwiftTerm

/// # TerminalEmulatorView
///
/// A terminal emulator view.
///
/// Wraps a `LocalProcessTerminalView` from `SwiftTerm` inside a `NSViewRepresentable`
/// for use in SwiftUI.
///
struct TerminalEmulatorView: NSViewRepresentable {

    static var lastTerminal: [String: LocalProcessTerminalView] = [:]

    @ObservedObject
    var model: TerminalEmulatorViewModel

    /// Inherited from NSViewRepresentable.makeNSView(context:).
    func makeNSView(context: Context) -> LocalProcessTerminalView {
        model.terminal.processDelegate = context.coordinator
        model.setupSession()
        return model.terminal
    }

    func updateNSView(_ view: LocalProcessTerminalView, context: Context) {
        if view.font != model.font { // Fixes Memory leak
            view.font = model.font
        }
        view.configureNativeColors()
        view.installColors(model.colors)
        view.caretColor = model.cursorColor
        view.selectedTextBackgroundColor = model.selectionColor
        view.nativeForegroundColor = model.textColor
        view.nativeBackgroundColor = model.prefs.preferences.terminal.useThemeBackground ? model.backgroundColor : .clear
        view.layer?.backgroundColor = .clear
        view.optionAsMetaKey = model.optionAsMeta
        view.appearance = model.colorAppearance
//        if TerminalEmulatorView.lastTerminal[model.url.path] != nil {
//            TerminalEmulatorView.lastTerminal[model.url.path] = view
//        }
        view.getTerminal().softReset()
        model.setupSession()
        view.feed(text: "") // send empty character to force colors to be redrawn
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(url: model.url)
    }
}
