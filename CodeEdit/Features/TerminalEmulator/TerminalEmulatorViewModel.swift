//
//  TerminalEmulatorViewModel.swift
//  CodeEdit
//
//  Created by Johnathan Baird on 3/8/23.
//

import Foundation
import SwiftUI
import SwiftTerm

class TerminalEmulatorViewModel: ObservableObject {
    public var prefs: AppPreferencesModel = .shared

    public var themeModel: ThemeModel = .shared

    public var url: URL

    @State
    var terminal: LocalProcessTerminalView

    let id = UUID()

    public let systemFont: NSFont = .monospacedSystemFont(ofSize: 11, weight: .medium)

    public var font: NSFont {
        if !prefs.preferences.terminal.font.customFont {
            return systemFont
        }
        return NSFont(
            name: prefs.preferences.terminal.font.name,
            size: CGFloat(prefs.preferences.terminal.font.size)
        ) ?? systemFont
    }

    init(url: URL) {
        self.url = url
        self._terminal = State(initialValue: TerminalEmulatorView.lastTerminal[url.path] ?? .init(frame: .zero))
    }

    /// Returns a string of a shell path to use
    ///
    /// Default implementation pulled from Example app from "SwiftTerm":
    /// ```swift
    ///    let bufsize = sysconf(_SC_GETPW_R_SIZE_MAX)
    ///    guard bufsize != -1 else { return "/bin/bash" }
    ///    let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: bufsize)
    /// defer {
    ///        buffer.deallocate()
    ///    }
    ///    var pwd = passwd()
    ///    var result: UnsafeMutablePointer<passwd>? = UnsafeMutablePointer<passwd>.allocate(capacity: 1)
    ///
    /// if getpwuid_r(getuid(), &pwd, buffer, bufsize, &result) != 0 { return "/bin/bash" }
    ///    return String(cString: pwd.pw_shell)
    /// ```
    public func getShell() -> String {
        switch prefs.preferences.terminal.shell {
        case .system:
            return autoDetectDefaultShell()
        case .bash:
            return "/bin/bash"
        case .zsh:
            return "/bin/zsh"
        }
    }

    /// Gets the default shell from the current user and returns the string of the shell path.
    public func autoDetectDefaultShell() -> String {
        let bufsize = sysconf(_SC_GETPW_R_SIZE_MAX)
        guard bufsize != -1 else { return "/bin/bash" }
        let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: bufsize)
        defer {
            buffer.deallocate()
        }
        var pwd = passwd()
        var result: UnsafeMutablePointer<passwd>? = UnsafeMutablePointer<passwd>.allocate(capacity: 1)

        if getpwuid_r(getuid(), &pwd, buffer, bufsize, &result) != 0 { return "/bin/bash" }
        return String(cString: pwd.pw_shell)
    }

    /// Returns true if the `option` key should be treated as the `meta` key.
    public var optionAsMeta: Bool {
        prefs.preferences.terminal.optionAsMeta
    }

    /// Returns the mapped array of `SwiftTerm.Color` objects of ANSI Colors
    public var colors: [SwiftTerm.Color] {
        if let selectedTheme = themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return themeModel.themes[index].terminal.ansiColors.map { color in
                SwiftTerm.Color(hex: color)
            }
        }
        return []
    }

    /// Returns the `cursor` color of the selected theme
    public var cursorColor: NSColor {
        if let selectedTheme = themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.cursor.swiftColor)
        }
        return NSColor(.accentColor)
    }

    /// Returns the `selection` color of the selected theme
    public var selectionColor: NSColor {
        if let selectedTheme = themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.selection.swiftColor)
        }
        return NSColor(.accentColor)
    }

    /// Returns the `text` color of the selected theme
    public var textColor: NSColor {
        if let selectedTheme = themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.text.swiftColor)
        }
        return NSColor(.primary)
    }

    /// Returns the `background` color of the selected theme
    public var backgroundColor: NSColor {
        if let selectedTheme = themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.background.swiftColor)
        }
        return .windowBackgroundColor
    }

    /// returns a `NSAppearance` based on the user setting of the terminal appearance,
    /// `nil` if app default is not overriden
    public var colorAppearance: NSAppearance? {
        if prefs.preferences.terminal.darkAppearance {
            return .init(named: .darkAqua)
        }
        return nil
    }
    
    public var scroller: NSScroller? {
        for subView in terminal.subviews {
            if let scroller = subView as? NSScroller {
                return scroller
            }
        }
        return nil
    }
    
    func setupSession() {
        terminal.getTerminal().silentLog = true
        if TerminalEmulatorView.lastTerminal[url.path] == nil {
            let shell = getShell()
            let shellIdiom = "-" + NSString(string: shell).lastPathComponent

            // changes working directory to project root
            // TODO: Get rid of FileManager shared instance to prevent problems
            // using shared instance of FileManager might lead to problems when using
            // multiple workspaces. This works for now but most probably will need
            // to be changed later on
            FileManager.default.changeCurrentDirectoryPath(url.path)
            terminal.startProcess(executable: shell, execName: shellIdiom)
            terminal.font = font
            terminal.configureNativeColors()
            terminal.installColors(self.colors)
            terminal.caretColor = cursorColor
            terminal.selectedTextBackgroundColor = selectionColor
            terminal.nativeForegroundColor = textColor
            terminal.nativeBackgroundColor = prefs.preferences.terminal.useThemeBackground ? backgroundColor : .clear
            terminal.layer?.backgroundColor = .clear
            terminal.optionAsMetaKey = optionAsMeta
        }
        terminal.appearance = colorAppearance
        scroller?.isHidden = true
        TerminalEmulatorView.lastTerminal[url.path] = terminal
    }

}
