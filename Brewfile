cask_args appdir: '/Applications'

#----------------------------------------------------------------------------------------#
# Brews
#----------------------------------------------------------------------------------------#

brew 'mas'

brew 'bash'
brew 'bash-completion'
brew 'git'
brew 'git-lfs'
brew 'wget'
brew 'pkg-config'
brew 'cairo'
brew 'libpng'
brew 'jpeg'
brew 'giflib'
brew 'thefuck'

# Install more recent versions of some OS X tools.
tap 'homebrew/dupes'
brew 'grep'
brew 'openssh'
brew 'screen'
brew 'vim', args: ['with-override-system-vi']
brew 'emacs'
brew 'tmux'
brew 'z'
brew 'hub'
brew 'parallel'
brew 'postgresql'
brew 'sqlite'
brew 'youtube-dl'
brew 'python3'
brew 'yarn' # also install Node.js
brew 'go'
brew 'rbenv'
brew 'ruby-build'

tap 'thoughtbot/formulae'
brew 'rcm'

#----------------------------------------------------------------------------------------#
# Casks
#----------------------------------------------------------------------------------------#

cask 'google-chrome'
cask 'firefox'

cask 'java' unless system '/usr/libexec/java_home --failfast'
cask 'eclipse-java'

cask 'postgres'
cask 'spotify'
cask 'vlc'

cask 'xquartz'
cask 'atom'
cask 'dropbox'
