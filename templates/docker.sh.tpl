echo "=== Getting Docker TEST ==="

sleep 30
sudo apt-get -yqq update
sudo apt-get -yqq install apt-transport-https ca-certificates curl gnupg-agent software-properties-common unzip
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -yqq update
sudo apt-get -yqq install docker-ce
