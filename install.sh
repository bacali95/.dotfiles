#!/bin/sh

runOrFail() {
    sh -c "$1 $2"
    EXIT_CODE=$?
    [ $EXIT_CODE -ne 0 ] && exit $EXIT_CODE
}

echo "Installing useful tools..."
runOrFail "sudo apt update"
runOrFail "sudo apt install -y zsh git curl wget nano"

OH_MY_ZSH_DIRECTORY="$HOME/.oh-my-zsh"

echo "Installing Oh-My-Zsh"
if [ ! -d "$OH_MY_ZSH_DIRECTORY" ]; then
    runOrFail "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "--unattended"
fi

echo "Installing Powerlevel10k custom theme..."
if [ -d "$OH_MY_ZSH_DIRECTORY/custom/themes/powerlevel10k" ]; then
    runOrFail "rm -rf $OH_MY_ZSH_DIRECTORY/custom/themes/powerlevel10k"
fi
runOrFail "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $OH_MY_ZSH_DIRECTORY/custom/themes/powerlevel10k"

echo "Installing Oh-My-Zsh Custom Plugins..."
for pluginRepo in "zsh-users/zsh-autosuggestions" "zsh-users/zsh-completions" "zsh-users/zsh-syntax-highlighting" "bacali95/cf-submit-completion" "jscutlery/nx-completion"
do
    pluginPath="$OH_MY_ZSH_DIRECTORY/custom/plugins/${pluginRepo##*/}"
    runOrFail "rm -rf $pluginPath"
    runOrFail "git clone https://github.com/$pluginRepo $pluginPath"
done

echo "Creating symbolic links for config files..."
for filename in "gitconfig" "zshrc" "p10k.zsh"
do
    rm -rf $HOME/.$filename
    ln -sf $(pwd)/config/$filename $HOME/.$filename
done

echo "Installing Volta..."
runOrFail "$(curl https://get.volta.sh | bash)"
runOrFail "mkdir -p $OH_MY_ZSH_DIRECTORY/custom/plugins/volta"
runOrFail "$HOME/.volta/bin/volta completions zsh -f -o $OH_MY_ZSH_DIRECTORY/custom/plugins/volta/_volta"

exit 0
