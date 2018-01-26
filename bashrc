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