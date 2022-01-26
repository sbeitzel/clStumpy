import ArgumentParser
import Foundation
import Logging
import NIO
import StumpyLib

@main
struct Stumpy: ParsableCommand {
    @Option(name: .long, help: "The port on which to listen for SMTP requests")
    var smtpPort: Int

    @Option(name: .long, help: "The port on which to listen for POP3 requests")
    var popPort: Int

    @Option(name: .long, help: "The number of threads to assign to each server")
    var threads: Int

    @Option(name: .long, help: "The maximum number of messages to hold in the mail store")
    var storeSize: Int

    func run() {
        LoggingSystem.bootstrap(StreamLogHandler.standardOutput)
        let smtpGroup = MultiThreadedEventLoopGroup(numberOfThreads: threads)
        let popGroup = MultiThreadedEventLoopGroup(numberOfThreads: threads)

        let store = FixedSizeMailStore(size: storeSize)

        let smtp = NSMTPServer(group: smtpGroup, port: smtpPort, store: store)
        let pop = NPOPServer(group: popGroup, port: popPort, store: store)

        pop.run()
        defer {
            smtp.stop()
            pop.stop()
        }
        do {
            try smtp.runReturning().wait()
        } catch {
            print("Error running SMTP server: \(error.localizedDescription)")
        }
    }
}
