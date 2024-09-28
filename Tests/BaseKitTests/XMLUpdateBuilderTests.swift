import BaseKit
import Testing

struct XMLUpdateBuilderTests {
    
    func makeDatabase() throws -> XMLDatabase {
        let svgString = """
            <svg version="1.1"
                 width="300" height="200"
                 xmlns="http://www.w3.org/2000/svg">
            
              <rect width="100%" height="100%" fill="red" />
            
              <circle cx="150" cy="100" r="80" fill="green" />
            
              <text x="150" y="125" font-size="60" text-anchor="middle" fill="white">SVG</text>
            
            </svg>
            """
        return try XMLDatabase(text: svgString)
    }

    @Test
    func testCommitAddObject() throws {
        let subject = try makeDatabase()
        let rootID = subject.rootValues.first?.id
        
        let addRect = XMLCommand("Add rect") {
            WithXML(id: rootID!) {
                InsertXML {
                    Element("rect") {
                        Attr("width", "50")
                        Attr("height", "25")
                        Attr("fill", "blue")
                    }
                }
            }
        }
        let (_, _) = try subject.perform(addRect)
        
        let output = try subject.text()
        
        let expected = """
            <svg height="200" version="1.1" width="300" xmlns="http://www.w3.org/2000/svg">
            
              <rect fill="red" height="100%" width="100%" />
            
              <circle cx="150" cy="100" fill="green" r="80" />
            
              <text fill="white" font-size="60" text-anchor="middle" x="150" y="125">SVG</text>
            
              <rect fill="blue" height="25" width="50" />
            </svg>
            """
        
        #expect(output == expected)
    }

}
