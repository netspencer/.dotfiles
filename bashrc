#!/bin/sh

[ -n "$PS1" ] && source ~/.bash_profile;

# tabtab source for yarn package
# uninstall by removing these lines or running `tabtab uninstall yarn`
[ -f /Users/spencer/.config/yarn/global/node_modules/tabtab/.completions/yarn.bash ] && . /Users/spencer/.config/yarn/global/node_modules/tabtab/.completions/yarn.bash
# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[ -f /Users/spencer/.config/yarn/global/node_modules/tabtab/.completions/serverless.bash ] && . /Users/spencer/.config/yarn/global/node_modules/tabtab/.completions/serverless.bash
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[ -f /Users/spencer/.config/yarn/global/node_modules/tabtab/.completions/sls.bash ] && . /Users/spencer/.config/yarn/global/node_modules/tabtab/.completions/sls.bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
