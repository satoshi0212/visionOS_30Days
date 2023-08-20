import SwiftUI

struct TimerView: View, Identifiable {

    var id = UUID()

    @State private var countdown: Int = 60
    @State private var timer: Timer? = nil

    var body: some View {
        ZStack {
            ClockFaceCanvas()
            ClockHandsCanvas(countdown: countdown)
        }
        .frame(width: targetSize.width, height: targetSize.height)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.countdown > 0 {
                self.countdown += 1
            } else {
                self.stopTimer()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct ClockFaceCanvas: View {
    var body: some View {
        Canvas { context, size in
            drawFace(context: context, size: size)
            drawTicks(context: context, size: size)
            drawNumbers(context: context, size: size)
        }
    }

    func drawFace(context: GraphicsContext, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size).insetBy(dx: size.width * 0.04, dy: size.width * 0.04)
        let circle_path = Circle().path(in: rect)
        context.stroke(circle_path, with: .color(.black), lineWidth: size.width * 0.02)
        context.fill(circle_path, with: .color(.white))
    }

    func drawTicks(context: GraphicsContext, size: CGSize) {
        let thin_width = size.width * 0.004
        let thin = Path(CGRect(origin: CGPoint(x: -thin_width/2, y: size.height * 0.41),
                               size: CGSize(width: thin_width, height: size.height * 0.025)))
        for tick in 0...59 {
            var context = context
            context.translateBy(x: size.width/2.0, y: size.height/2.0)
            context.rotate(by: .degrees(Double(tick) * (360 / 60) + 180))
            context.fill(thin, with: .color(.black))
        }
    }

    func drawNumbers(context: GraphicsContext, size: CGSize) {
        for i in 0...3 {
            let value = i == 0 ? 0 : Double(60 - 15 * i)
            let angle: Angle = .degrees(360 / (4 / (4 - value)) + 180)
            let number = Text("\(Int(value))")
                .font(.custom("Futura", size: size.width * 0.1))
                .foregroundColor(.black)
            let offset = CGPoint(x: size.width/2 + sin(Double(angle.radians)) * size.width * 0.33,
                                 y: size.height/2 + cos(angle.radians) * size.width * 0.33)
            context.draw(number, at: offset, anchor: .center)
        }
    }
}

struct ClockHandsCanvas: View {

    let countdown: Int

    var body: some View {
        Canvas { context, size in
            drawHands(context: context, size: size)
            drawOverlay(context: context, size: size)
        }
    }

    func drawHands(context: GraphicsContext, size: CGSize) {
        let s = Double(countdown)
        let s_angle = s / 60 * 360
        let midpoint = CGPoint(x: size.width/2, y: size.height/2)

        context.drawLayer { context in
            let w = size.width * 0.02
            let o: CGFloat = size.width * 0.0

            let path = Path(CGRect(origin: CGPoint(x: -w/2, y: -o),
                                   size: CGSize(width: w, height: size.height/2.0 * 0.92 + o)))

            context.translateBy(x: size.width/2.0, y: size.height/2.0)
            context.rotate(by: .degrees(s_angle + 180))
            context.addFilter(.shadow(radius: 3))
            context.fill(path, with: .color(.blue))
        }

        let dot1_d = size.width * 0.048
        let dot1_s = CGSize(width: dot1_d, height: dot1_d)
        let dot1_o = CGPoint(x: midpoint.x - dot1_d/2, y: midpoint.y - dot1_d/2)
        let dot1_p = Circle().path(in: CGRect(origin: dot1_o, size: dot1_s))
        context.fill(dot1_p, with: .color(.black))
    }

    func drawOverlay(context: GraphicsContext, size: CGSize) {
        let s = Double(countdown)
        var path = Path()
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        path.move(to: center)
        path.addArc(center: center,
                    radius: min(size.width, size.height) / 2 - 20,
                    startAngle: .degrees(s / 60 * 360 - 90),
                    endAngle: .degrees(-90),
                    clockwise: false)
        context.fill(path, with: .color(Color(red: 0.0, green: 0.0, blue: 1.0, opacity: 0.7)))
    }
}

#Preview {
    TimerView()
        .previewLayout(.sizeThatFits)
}
