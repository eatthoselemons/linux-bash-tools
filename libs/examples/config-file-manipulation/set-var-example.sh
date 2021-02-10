source ../../config.shlib
item=stuff
# multiple item variable
myString="test string"
changeConfigVar example.cfg item=$item
changeConfigVar example.cfg myvar=foo
changeConfigVar example.cfg string="$myString"
