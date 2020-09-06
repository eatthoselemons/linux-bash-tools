# source for a file and it will catch errors and report them

trap_msg='s=${?}; echo "${0}: Error on line "${LINENO}": ${BASH_COMMAND}"; exit ${s}'    
set -uo pipefail    
trap "${trap_msg}" ERR    
