%dw 2.0
output application/json

var inputUrl = yy.requestPath

var endpoint = [
  {"/api/orders/{clientType}/{clientId}":[3,4]}, 
  {"/supplier-parcels/{ucs}/status":[2]}, 
  {"/api/asns/{clientId}":[3]}, 
  {"/api/asns/status": []}
]

var inputSegments = inputUrl splitBy "/"

---
endpoint map (item) -> do {

    var templateKey = (keysOf(item))[0] as String
    var indices = item[templateKey]
    
    var templateSegments = templateKey splitBy "/"

    var extractedValues = indices reduce (index, acc = {}) -> do {
        var paramName = templateSegments[index] replace /[{}]/ with ""
        var paramValue = inputSegments[index]
        ---
        acc ++ { (paramName): paramValue }
    }

    var finalResultSet = (templateSegments map (segment, idx) -> 
        if (indices contains idx) inputSegments[idx] else segment
    ) joinBy "/"

    ---
    {
        "url": templateKey,
        "values": extractedValues,
        "resultSet": finalResultSet
    }
}