import Foundation
import BaseKit
import Testing

struct XMLSnapshotTests {
    @Test
    func builder() throws {
        let snapshot = XMLSnapshot(parentID: nil) {
            Element("svg") {
                Attr("version", "1.1")
                Attr("width", "300")
                Attr("height", "200")
                Attr("xmlns", "http://www.w3.org/2000/svg")
                
                Element("rect") {
                    Attr("width", "100%")
                    Attr("height", "100%")
                    Attr("fill", "red")
                }
                
                Element("circle") {
                    Attr("cx", "150")
                    Attr("cy", "100")
                    Attr("r", "80")
                    Attr("fill", "green")
                }
                
                Element("text") {
                    Attr("x", "150")
                    Attr("y", "125")
                    Attr("font-size", "60")
                    Attr("text-anchor", "middle")
                    Attr("fill", "white")
                    
                    Text("SVG")
                }
            }
        }
        let got = try snapshot.text()
        let expected = """
            <svg height="200" version="1.1" width="300" xmlns="http://www.w3.org/2000/svg">
              <rect fill="red" height="100%" width="100%" />
              <circle cx="150" cy="100" fill="green" r="80" />
              <text fill="white" font-size="60" text-anchor="middle" x="150" y="125">SVG</text>
            </svg>
            """
        #expect(got == expected)
    }
}
