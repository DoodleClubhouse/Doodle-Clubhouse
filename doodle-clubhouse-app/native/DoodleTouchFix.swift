
// ---------- Doodle Clubhouse: Apple Pencil fix (added by Codemagic, see codemagic.yaml) ----------
// The web view inside the app listens for "double tap" and "tap / long press" gestures of its own. When you write or poke
// very fast with the Apple Pencil, those gesture listeners can grab a touch and cancel it, so a dot or letter never reaches
// the drawing. Procreate doesn't have that layer, which is why it never misses. Here we tell those listeners to never hold
// back or cancel touches, and turn off the double-tap ones (the app never zooms the whole screen anyway).
import WebKit

enum DoodleTouchFix {
    static func install() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in apply() }
        for delay in [0.3, 1.0, 2.5, 6.0] { DispatchQueue.main.asyncAfter(deadline: .now() + delay) { apply() } }
    }
    static func apply() {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows { walk(window) }
        }
    }
    private static func walk(_ view: UIView) {
        if let web = view as? WKWebView { fix(web); return }
        for sub in view.subviews { walk(sub) }
    }
    private static func fix(_ web: WKWebView) {
        var views: [UIView] = [web, web.scrollView]
        views.append(contentsOf: web.scrollView.subviews)          // the page itself (WKContentView)
        for v in views {
            for g in v.gestureRecognizers ?? [] {
                g.delaysTouchesBegan = false
                g.delaysTouchesEnded = false
                if g is UITapGestureRecognizer || g is UILongPressGestureRecognizer { g.cancelsTouchesInView = false }
                if let tap = g as? UITapGestureRecognizer, tap.numberOfTapsRequired >= 2 { tap.isEnabled = false }
            }
        }
        web.scrollView.delaysContentTouches = false
    }
}
