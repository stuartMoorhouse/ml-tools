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

declare function ml:key-value-reverse($map as map:map) {
   let $new-map := map:map()
   let $fill-map := 
      for $old-key in map:keys($map) 
          let $old-value := map:get($map, $old-key)
          let $add-to-map := map:put($new-map, $old-value, (map:get($new-map, $old-value), $old-key))
          return $old-key
   return $new-map
} ;

(: convert a fraction to a percentage :)
declare function ml:fraction-to-percentage($denominator as xs:float, $numerator as xs:float) as xs:float {
    ($denominator div $numerator) * 100
} ; 


declare function ml:fraction-to-percentage($denominator as xs:float, $numerator as xs:float, $places) as xs:float {
   math:trunc((($denominator div $numerator) * 100), $places)
} ; 

(: evaluate an XPath against a Node :)
declare function ml:xpath($node, $path) {
     let $query :=  
      fn:concat(
         "xquery version '1.0-ml';  declare variable $node := " ,  $node , " ;" , $node, $path
        )
      return xdmp:eval($query)
  (: takes a (non-nested) map and returns a map with the keys/ values reversed :)
declare function ml:key-value-reverse($map as map:map) {
   let $new-map := map:map()
   let $fill-map := 
      for $old-key in map:keys($map) 
          let $old-value := map:get($map, $old-key)
          let $add-to-map := map:put($new-map, $old-value, (map:get($new-map, $old-value), $old-key))
          let $add-to-map := local:add-to-value-sequence($new-map, $old-value, $old-key)
          return $old-key
   return $new-map
} ;
 
 declare function ml:document-rename(
   $old-uri as xs:string, $new-uri as xs:string)
  as empty-sequence()
{
    xdmp:document-delete($old-uri)
    ,
    let $permissions := xdmp:document-get-permissions($old-uri)
    let $collections := xdmp:document-get-collections($old-uri)
    return xdmp:document-insert(
      $new-uri, doc($old-uri),
      if ($permissions) then $permissions
      else xdmp:default-permissions(),
      if ($collections) then $collections
      else xdmp:default-collections(),
      xdmp:document-get-quality($old-uri)
    )
    ,
    let $prop-ns := namespace-uri(<prop:properties/>)
    let $properties :=
      xdmp:document-properties($old-uri)/node()
        [ namespace-uri(.) ne $prop-ns ]
    return xdmp:document-set-properties($new-uri, $properties)
};
 
     