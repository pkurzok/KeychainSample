//
//  View+Navigation.swift
//  Rolls-Royce Whispers
//
//  Created by Alexander Schmutz on 27.05.21.
//  Copyright © 2021 Rolls-Royce. All rights reserved.
//

import SwiftUI

extension View {
    /// Presents the destintaion view using the given item as a data source
    /// for the destination's view content.
    /// - Parameters:
    ///   - selection: A binding to an optional source of truth for the destination view.
    ///     When `selection` is non-`nil`, the system passes the item's content to
    ///     the modifier's closure. You display this content in a sheet that you
    ///     create that the system displays to the user. If `selection` changes,
    ///     the system dismisses the sheet and replaces it with a new one
    ///     using the same process.
    ///   - destination: A closure returning the content of the destination view.
    func navigation<Item: Equatable, Destination: View>(
        selection: Binding<Item?>,
        destination: @escaping (Item) -> Destination
    ) -> some View {
        background(NavigationLinkWrapper(item: selection, destination: destination))
    }
}

private struct NavigationLinkWrapper<Item: Equatable, Destination: View>: View {
    @Binding var item: Item?
    let destination: (Item) -> Destination

    @State private var isActive = false

    var body: some View {
        Group {
            if let item = item {
                NavigationLink(destination: destination(item), isActive: $isActive, label: { EmptyView() })
            }
        }
        .onChange(of: item) { item in
            isActive = item != nil
        }
        .onChange(of: isActive) { isActive in
            if !isActive {
                item = nil
            }
        }
    }
}
