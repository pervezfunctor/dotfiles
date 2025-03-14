alias git-unstage = git reset HEAD
alias git-discard = git checkout --
alias gst = git status
alias gsu = git status -u
def tsgfm [] {
    git stash
    do { git pull --rebase } catch { git pull }
    git stash pop
}

alias gun = git-unstage
alias gur = git-discard
alias gcm = git commit -m
alias gcne = git commit --no-edit
alias gca = git commit --amend
alias gcan = git commit --amend --no-edit

alias Gcm = git commit --no-verify -m
alias Gp = git push --no-verify
alias Gcan = git commit --amend --no-edit --no-verify

alias g = git
alias gs = git stash -u
alias gst = git status
alias gsu = git status -u
alias gcan = git commit --amend --no-edit
alias gsa = git stash apply
alias gfm = git pull
alias gp = git push
alias gcm = git commit --message
alias gia = git add
alias gl = git log --topo-order --pretty=format:"%C(yellow)%h%C(reset)%C(black)%d%C(reset) %C(cyan)%ar%C(reset) %C(green)%an%C(reset)%n%C(white)%s%C(reset)"
alias gco = git checkout
alias gb = git branch
alias gbc = git checkout -b
alias gsl = git stash list
alias clone = gh repo clone
alias glog = git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit
