fun main () : transaction page =
    (if 1 > 0 then error <xml>Do not eliminate me</xml> else return ());
    return <xml><body>Hello, DCE!</body></xml>
