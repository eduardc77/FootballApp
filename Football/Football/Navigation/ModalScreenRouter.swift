//
//  ModalCoordinator.swift
//  FootballApp
//

import SwiftUI

public final class AnyIdentifiable: Identifiable {
    public let destination: any Identifiable
    
    public init(destination: any Identifiable) {
        self.destination = destination
    }
}

@Observable
final class ModalScreenRouter {
    var presentedSheet: AnyIdentifiable?
    var presentedFullScreenCover: AnyIdentifiable?
    var presentedPopover: Popover = Popover()
    
    var alert: Alert?
    var confirmationDialog: Alert?
    
    init() {}
    
    func presentSheet(destination: any Identifiable) {
        presentedSheet = AnyIdentifiable(destination: destination)
    }
    
    func presentFullScreenCover(destination: any Identifiable) {
        presentedFullScreenCover = AnyIdentifiable(destination: destination)
    }
    
    func presentPopover(destination: any Identifiable,
                        attachmentAnchor: PopoverAttachmentAnchor = .point(.top),
                        arrowEdge: Edge = .bottom) {
        presentedPopover.content = AnyIdentifiable(destination: destination)
        presentedPopover.attachmentAnchor = attachmentAnchor
        presentedPopover.arrowEdge = arrowEdge
    }
    
    func presentAlert<Buttons: View>(title: String, message: String? = nil, @ViewBuilder buttons: @escaping () -> Buttons) where Buttons: View {
        guard self.alert == nil else { return }
        alert = Alert(title: title, message: message, buttons: buttons())
    }
    
    func presentConfirmationDialog<Buttons: View>(title: String, message: String? = nil, @ViewBuilder buttons: @escaping () -> Buttons) where Buttons: View {
        guard self.confirmationDialog == nil else { return }
        confirmationDialog = Alert(title: title, message: message, buttons: buttons())
    }
}

struct Popover {
    var content: AnyIdentifiable?
    var attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds)
    var arrowEdge: Edge = .top
}

struct Alert: Identifiable {
    let id = UUID().uuidString
    let title: String
    let message: String?
    let buttons: AnyView
    
    init<Buttons: View>(title: String, message: String? = nil, buttons: Buttons) {
        self.title = title
        self.message = message
        self.buttons = AnyView(buttons)
    }
}

struct AlertViewModifier: ViewModifier {
    var option: AlertOption = .alert
    let alert: Binding<Alert?>
    
    func body(content: Content) -> some View {
        content
            .alert(alert.wrappedValue?.title ?? "", isPresented: Binding(ifNotNil: Binding(if: option, is: .alert, value: alert))) {
                alert.wrappedValue?.buttons
            } message: {
                if let message = alert.wrappedValue?.message {
                    Text(message)
                }
            }
    }
}

struct ConfirmationDialogViewModifier: ViewModifier {
    var option: AlertOption = .confirmationDialog
    let confirmationDialog: Binding<Alert?>
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog(confirmationDialog.wrappedValue?.title ?? "", isPresented: Binding(ifNotNil: Binding(if: option, is: .confirmationDialog, value: confirmationDialog)), titleVisibility: confirmationDialog.wrappedValue?.title.isEmpty ?? true ? .hidden : .visible) {
                confirmationDialog.wrappedValue?.buttons
            } message: {
                if let message = confirmationDialog.wrappedValue?.message {
                    Text(message)
                }
            }
    }
}

extension View {
    func alert(_ alert: Binding<Alert?>) -> some View {
        self.modifier(AlertViewModifier(alert: alert))
    }
    
    func confirmationDialog(_ confirmationDialog: Binding<Alert?>) -> some View {
        self.modifier(ConfirmationDialogViewModifier(confirmationDialog: confirmationDialog))
    }
}

public enum AlertOption {
    case alert, confirmationDialog
}

extension Binding where Value == Bool {
    
    init<Alert: Identifiable>(ifNotNil value: Binding<Alert?>) {
        self.init {
            value.wrappedValue != nil
        } set: { _ in
            value.wrappedValue = nil
        }
    }
}

extension Binding where Value == Alert? {
    
    init(if selected: AlertOption, is option: AlertOption, value: Binding<Alert?>) {
        self.init {
            selected == option ? value.wrappedValue : nil
        } set: { newValue in
            value.wrappedValue = newValue
        }
    }
}
