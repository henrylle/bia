# INSTALANDO UI
sudo apt update -y && \
sudo apt upgrade -y && \
sudo apt install xfce4 xfce4-goodies -y 

# INSTALANDO CHROME REMOTE DESKTOP
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb && \
  sudo apt install ./chrome-remote-desktop_current_amd64.deb -y
  
# DANDO PERMISSÕES NA PASTA  
sudo chmod 777 /home/ubuntu/.config/