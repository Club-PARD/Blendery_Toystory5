import SwiftUI
import UIKit

private final class SecureTextField: UITextField {
    override var canBecomeFirstResponder: Bool { false }   // 본체는 키보드 못 띄우게
}

struct ScreenshotShield<Content: View>: UIViewRepresentable {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.isUserInteractionEnabled = true

        // 1) secure text field
        let secureField = SecureTextField()
        secureField.isSecureTextEntry = true
        secureField.backgroundColor = .clear
        secureField.textColor = .clear
        secureField.tintColor = .clear
        secureField.borderStyle = .none

        // ✅ 여기 절대 false로 하면 안 됨 (터치/스크롤 다 죽는 원인)
        secureField.isUserInteractionEnabled = true

        container.addSubview(secureField)
        secureField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secureField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            secureField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            secureField.topAnchor.constraint(equalTo: container.topAnchor),
            secureField.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        // 2) SwiftUI hosting view
        let host = UIHostingController(rootView: content)
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.isUserInteractionEnabled = true

        // secureField 내부 렌더링 뷰(버전에 따라 다름)
        let secureRenderView = secureField.subviews.first ?? secureField
        secureRenderView.isUserInteractionEnabled = true
        secureRenderView.addSubview(host.view)

        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: secureRenderView.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: secureRenderView.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: secureRenderView.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: secureRenderView.bottomAnchor)
        ])

        context.coordinator.host = host
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.host?.rootView = content
    }

    final class Coordinator {
        var host: UIHostingController<Content>?
    }
}
