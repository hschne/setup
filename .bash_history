ls
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.3
sudo pacman -S git
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.3
  local asdf_root="$HOME/.asdf"
asdf_root="$HOME/.asdf"
  cat "$asdf_root/asdf.sh" >> "$asdf" && echo "asdf \"\$@\"" >> "$asdf" && chmod +x "$asdf"
  local asdf; asdf="$asdf_root/asdf"
asdf; asdf="$asdf_root/asdf"
asdf="$asdf_root/asdf"
  cat "$asdf_root/asdf.sh" >> "$asdf" && echo "asdf \"\$@\"" >> "$asdf" && chmod +x "$asdf"
cat ~/.asdf/asdf
  "$asdf" plugin-add ruby
  latest=$("$asdf" list-all ruby | setup::highest_version)
exit
