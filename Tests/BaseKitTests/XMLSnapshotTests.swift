import Foundation
@testable import BaseKit
import Testing

struct XMLSnapshotTests {
    @Test
    func builder() throws {
        let snapshot = XMLPartialSnapshot(parentID: nil, createContext: XMLCreateContext(indent: 0, isFirst: false, isLast: false, variables: [:])) {
            Element(.svg) {
                Attr(.version, "1.1")
                Attr(.width, "300")
                Attr(.height, "200")
                Attr(.xmlns, "http://www.w3.org/2000/svg")
                
                Element(.defs) {
                    Element(.linearGradient) {
                        Attr(.id, "myGradient")
                        
                        Element(.stop) {
                            Attr(.stopOffset, "0.0")
                            Attr(.stopColor, "#000")
                        }
                        
                        Element(.stop) {
                            Attr(.stopOffset, "1.0")
                            Attr(.stopColor, "#FFF")
                        }
                    }
                }
                
                Element(.rect) {
                    Attr(.width, "100%")
                    Attr(.height, "100%")
                    Attr(.fill, "red")
                }
                
                Element(.circle) {
                    Attr(.cx, "150")
                    Attr(.cy, "100")
                    Attr(.r, "80")
                    Attr(.fill, "green")
                }
                
                Element(.text) {
                    Attr(.x, "150")
                    Attr(.y, "125")
                    Attr(.fontSize, "60")
                    Attr(.textAnchor, "middle")
                    Attr(.fill, "white")
                    
                    Text("SVG")
                }
            }
        }
        let fullSnapshot = XMLSnapshot(roots: snapshot.roots, values: snapshot.values)
        let got = try fullSnapshot.text()
        let expected = """
            <svg height="200" version="1.1" width="300" xmlns="http://www.w3.org/2000/svg">
              <defs>
                <linearGradient id="myGradient">
                  <stop stop-color="#000" stop-offset="0.0" />
                  <stop stop-color="#FFF" stop-offset="1.0" />
                </linearGradient>
              </defs>
              <rect fill="red" height="100%" width="100%" />
              <circle cx="150" cy="100" fill="green" r="80" />
              <text fill="white" font-size="60" text-anchor="middle" x="150" y="125">SVG</text>
            </svg>
            """
        #expect(got == expected)
    }
}
