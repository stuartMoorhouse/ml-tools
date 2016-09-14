xquery version "1.0-ml"; 

module namespace ml = "http://stonetide-software.co.uk/xquery-libraries/ml-tools";

declare function ml:filename($uri) {
fn:tokenize($uri, '/')[fn:last()] 
} ;