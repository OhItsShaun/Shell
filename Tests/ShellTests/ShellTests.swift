import XCTest
@testable import Shell

class ShellTests: XCTestCase {
    
    func testShell() {
        let name = "shelltest_" + String(Date().timeIntervalSince1970) + ".txt"
        
        Shell.execute("echo \"shell test\" > /tmp/\(name)")
        let response = Shell.execute("cat /tmp/\(name)")
        
        XCTAssertEqual(response.trimmingCharacters(in: ["\n", "\r"]), "shell test")
    }

    static var allTests = [
        ("testShell", testShell),
    ]
}
