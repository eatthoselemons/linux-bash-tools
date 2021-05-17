# usage: this script then follow with the device id number and the desired
# accelleration
source ~/git/linux-bash-tools/libs/error-handling.shlib
xinput set-prop $1 "Coordinate Transformation Matrix" $2 0 0 0 $2 0 0 0 1
