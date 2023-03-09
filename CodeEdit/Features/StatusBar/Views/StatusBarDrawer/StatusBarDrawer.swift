//
//  StatusBarDrawer.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI
import SwiftTerm

struct StatusBarDrawer: View {
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @Environment(\.colorScheme)
    private var colorScheme

    @State
    private var searchText = ""

    var body: some View {
        if let url = workspace.workspaceClient?.folderURL() {
            VStack(spacing: 0) {
                SplitView(axis: .horizontal) {
                    ForEach(workspace.terminalArray, id: \.id) {terminal in
                        TerminalEmulatorView(model: terminal)
                    }
                }
                HStack(alignment: .center, spacing: 10) {
                    FilterTextField(title: "Filter", text: $searchText)
                        .frame(maxWidth: 300)
                    Spacer()
                    StatusBarClearButton()
                    Divider()
                    StatusBarSplitTerminalButton()
                    StatusBarMaximizeButton()
                }
                .padding(10)
                .frame(maxHeight: 29)
                .background(.bar)
            }
        }
    }
}
