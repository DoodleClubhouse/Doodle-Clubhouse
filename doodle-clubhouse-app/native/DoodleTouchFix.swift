// ---------- Doodle Clubhouse: Apple Pencil fix (added by Codemagic, see codemagic.yaml) ----------
// 1. The web view inside the app listens for "double tap" and "tap / long press" gestures of its own. When you write or poke
//    very fast with the Apple Pencil, those gesture listeners can grab a touch, so a dot or letter never reaches the drawing.
//    We tell those listeners to never hold back or cancel touches, and turn off the double-tap ones.
// 2. A Pencil watcher (the same way Procreate gets its touches): it sees EVERY Apple Pencil touch straight from iPadOS and
//    tells the drawing about it. The drawing checks whether it already got that touch; if the web view dropped it, the
//    drawing replays it, so three quick pokes are always three dots.
import WebKit
import UIKit
import UIKit.UIGestureRecognizerSubclass

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
                if g is DoodlePencilWatcher { continue }
                g.delaysTouchesBegan = false
                g.delaysTouchesEnded = false
                if g is UITapGestureRecognizer || g is UILongPressGestureRecognizer { g.cancelsTouchesInView = false }
                if let tap = g as? UITapGestureRecognizer, tap.numberOfTapsRequired >= 2 { tap.isEnabled = false }
            }
        }
        web.scrollView.delaysContentTouches = false
        if !(web.gestureRecognizers ?? []).contains(where: { $0 is DoodlePencilWatcher }) {
            web.addGestureRecognizer(DoodlePencilWatcher(web: web))
        }
    }
}

// Watches Apple Pencil touches only. It never "wins", never cancels or delays anything: it just reports each finished
// Pencil touch (its points, pressure and timing) to the page as window.__nativePen({ pts: [[x, y, pressure, seconds], ...] }).
final class DoodlePencilWatcher: UIGestureRecognizer, UIGestureRecognizerDelegate {
    private weak var web: WKWebView?
    private var strokes: [ObjectIdentifier: [[Double]]] = [:]

    init(web: WKWebView) {
        self.web = web
        super.init(target: nil, action: nil)
        cancelsTouchesInView = false
        delaysTouchesBegan = false
        delaysTouchesEnded = false
        allowedTouchTypes = [NSNumber(value: UITouch.TouchType.pencil.rawValue)]
        delegate = self
    }

    func gestureRecognizer(_ g: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }
    func gestureRecognizer(_ g: UIGestureRecognizer, shouldRequireFailureOf other: UIGestureRecognizer) -> Bool { false }
    func gestureRecognizer(_ g: UIGestureRecognizer, shouldBeRequiredToFailBy other: UIGestureRecognizer) -> Bool { false }

    private func sample(_ t: UITouch) -> [Double] {
        guard let web = web else { return [0, 0, 0.5, t.timestamp] }
        let p = t.location(in: web)
        let inset = web.scrollView.adjustedContentInset
        let z = max(0.01, web.scrollView.zoomScale)
        let x = (Double(p.x) - Double(inset.left)) / Double(z)
        let y = (Double(p.y) - Double(inset.top)) / Double(z)
        let f = t.maximumPossibleForce > 0 ? Double(t.force / t.maximumPossibleForce) : 0.5
        return [x, y, f, t.timestamp]
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        for t in touches where t.type == .pencil { strokes[ObjectIdentifier(t)] = [sample(t)] }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        for t in touches where t.type == .pencil {
            let key = ObjectIdentifier(t)
            guard strokes[key] != nil else { continue }
            let all = event.coalescedTouches(for: t) ?? [t]
            for c in all { strokes[key]?.append(sample(c)) }
            if (strokes[key]?.count ?? 0) > 1500 { strokes[key]?.removeFirst(500) }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) { finish(touches) }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) { finish(touches) }

    private func finish(_ touches: Set<UITouch>) {
        for t in touches {
            let key = ObjectIdentifier(t)
            guard var pts = strokes.removeValue(forKey: key) else { continue }
            pts.append(sample(t))
            send(pts)
        }
        if strokes.isEmpty { state = .failed }   // done watching: reset for the next touch (never blocks anything)
    }
    override func reset() { super.reset(); strokes.removeAll() }

    private func send(_ pts: [[Double]]) {
        guard let web = web,
              let data = try? JSONSerialization.data(withJSONObject: ["pts": pts]),
              let json = String(data: data, encoding: .utf8) else { return }
        web.evaluateJavaScript("window.__nativePen && window.__nativePen(\(json))", completionHandler: nil)
    }
}
