# usage: this script then pass in the bash script to run the '.sh' will be
# striped off automatically
# the directory to the script is the current working directory


scriptName=$(sed 's/\.sh//g' <<< $1)
echo $scriptName
echo $1
sudo bash -c "cat << EOF > /etc/systemd/system/$scriptName.service 
[Unit]
Description=User Script Start $1

[Service]
ExecStart=$PWD/$1

[Install]
WantedBy=multi-user.target
EOF"
