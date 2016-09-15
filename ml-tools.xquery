xquery version "1.0-ml"; 

module namespace ml = "http://stonetide-software.co.uk/xquery-libraries/ml-tools";

declare function ml:filename($uri) {
fn:tokenize($uri, '/')[fn:last()] 
} ;

(: when given a map in the form of
    a map:map object
    a map:map XML node
    the uri of an XML document containing a map:map node
  return a map:map object 
  
  used so that other map functions can be supplied maps in either form :)
declare function ml:_map($map-ref) as map:map {
    if ($map-ref instance of map:map) then
           $map-ref
           else if ($map-ref instance of xs:string) then
              map:map(fn:doc($map-ref)/map:map)
              else if ($map-ref instance of element(map:map) then
                 map:map($map-ref)
              else()
} ;

(: adds a key-value pair to an existing map (supplied as a map or serialized to XML) and returns the new map as map:map object :)
declare function ml:map-put($map, $key, $value) {
  let $this-map := ml:_map($map)
  let $addkey := map:put($this-map, $key, $value)
  return $this-map
} ;

(: deletes a key-value pair to an existing map (supplied as a map or serialized to XML) and returns the new map as map:map object :)
declare function ml:map-delete($map, $key, $value) {
  let $this-map := ml:_map($map)
  let $addkey := map:delete($this-map, $key)
  return $this-map
} ;

(: iterates through a string of '>' separated values, and evaluates any XQuery statements or variable references :)
declare function ml:eval-expressions($values as xs:string) as item()* {
 let $_tokens := for $t in fn:tokenize($values, '>') return $t
 let $tokens := for $t in $_tokens 
                  return
                  if  (fn:matches($t, '\{.*?\}'))
                    then xdmp:value(fn:translate($t, '{}', ''))
                    else if (fn:matches($t, '\$.*?')) 
                      then xdmp:value($t)
                      else $t

 return $tokens
} ; 