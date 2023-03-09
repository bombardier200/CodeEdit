//
//  StatusBarSplitTerminalButton.swift
//  CodeEditModules/StatusBar
//
//  Created by Stef Kors on 14/04/2022.
//

import SwiftUI

struct StatusBarSplitTerminalButton: View {
    @EnvironmentObject
    private var model: StatusBarViewModel
    
    @EnvironmentObject
    private var workspace: WorkspaceDocument
    @State var testing = 0
    var body: some View {
        Button {
            var combo = "~/Documents" + String(testing)
            workspace.terminalArray.append(TerminalEmulatorViewModel(url:URL(string:combo)!))
        } label: {
            Image(systemName: "square.split.2x1")
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
    }
}
