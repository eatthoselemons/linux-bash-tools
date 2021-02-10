source ../../config.shlib
val=$(getConfigVar example.cfg myvar)
val2=$(getConfigVar example.cfg item)
myStringVal=$(getConfigVar example.cfg string)

printf -- "%s\n" "echoing the values from the config file"
echo $val
echo $val2
echo $myStringVal
echo

printf -- "%s\n" "looping through the values in the config file"
for val in $myStringVal
do
  printf -- "%s\n" $val
done
