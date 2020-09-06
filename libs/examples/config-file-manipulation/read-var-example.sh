source ../../config.shlib
val=$(getConfigVar example.cfg myvar)
val2=$(getConfigVar example.cfg item)
echo $val
echo $val2
