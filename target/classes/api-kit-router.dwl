%dw 2.0
output application/json

var inputUrl = payload.requestPath
var inputSegments = inputUrl splitBy "/"
var endpoint = [
  {"/api/orders/{clientType}/{clientId}":[3,4]}, 
  {"/supplier-parcels/{ucs}/status":[2]}, 
  {"/api/asns/{clientId}":[3]}, 
  {"/api/asns/status": []}
]

---
endpoint map (item) -> do {
    // Get the URL template string out of the object keys safely
    var templateKey = (keysOf(item))[0] as String
    var templateSegments = templateKey splitBy "/"
    var indices = item[templateKey]

    var valuesArray = indices map (idx) -> do {
        // Step A: Grab the parameter name (e.g., "{clientId}")
        var rawName = templateSegments[idx]
        // Step B: Clean it up using basic string replacements
        var cleanName = rawName replace "{" with "" replace "}" with ""
        // Step C: Match it to the value in the exact same position of the input URL
        var realValue = inputSegments[idx]
        ---
        // Output a simple key-value pair
        { (cleanName): realValue }
    }

    var finalValuesObject = {(valuesArray)}

    var rebuiltSegments = templateSegments map (segment, currentIdx) -> {
        value: if (indices contains currentIdx) inputSegments[currentIdx] else segment
    }.value

    ---
    {
        "url": templateKey,
        "values": finalValuesObject,
        "resultSet": rebuiltSegments joinBy "/"
    }
}