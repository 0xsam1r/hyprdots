#!/usr/bin/env bash

echo -e "\033[1;40m"  # Start green (bold)
cat << 'EOF'
    ____ _   __   _       __              __    _                              
   /  _// | / /  | |     / /____   _____ / /__ (_)____   ____ _                
   / / /  |/ /   | | /| / // __ \ / ___// //_// // __ \ / __ `/                
 _/ / / /|  /    | |/ |/ // /_/ // /   / ,<  / // / / // /_/ /_  _  _  _  _  _ 
/___//_/ |_/     |__/|__/ \____//_/   /_/|_|/_//_/ /_/ \__, /(_)(_)(_)(_)(_)(_)
                                                      /____/                   

EOF
echo -e "\033[0m"  # Reset color

ln -s ~/dotfiles/hyprdots/scripts ~/.config/scripts

# mkdir -p ~/Pictures/wallpapers
# stow -t ~/Pictures/wallpapers wallpapers

mkdir -p ~/.config/mako
stow -t ~/.config config

mkdir -p ~/.icons
stow -t ~/.icons icons

mkdir -p ~/.font
cp -rf fonts/midorima ~/.fonts
fc-cache -fv

echo -e "\033[1;32m"  # Start green (bold)
cat << 'EOF'
   ______               ____ _                                __     
  / ____/____   ____   / __/(_)____ _ __  __ _____ ___   ____/ /     
 / /    / __ \ / __ \ / /_ / // __ `// / / // ___// _ \ / __  /      
/ /___ / /_/ // / / // __// // /_/ // /_/ // /   /  __// /_/ /       
\____/ \____//_/ /_//_/  /_/ \__, / \__,_//_/    \___/ \__,_/        
                            /____/                                   

EOF
echo -e "\033[0m"  # Reset color

