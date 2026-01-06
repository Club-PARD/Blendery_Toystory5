import SwiftUI
import UIKit

private final class SecureTextField: UITextField {

    override var canBecomeFirstResponder: Bool { false } // 키보드 방지

    // ✅ 핵심: TextField "본체"가 터치를 먹지 않도록
    // - subview(= 우리가 올린 host.view)가 hit 되면 그대로 반환
    // - 본체(self)가 hit 되면 nil 반환 -> SwiftUI 쪽 제스처(TabView 스와이프 등) 살아남
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result === self { return nil }
        return result
    }
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

        // ✅ true 유지 (secure container 역할)
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
