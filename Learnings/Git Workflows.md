git stash 
git switch -c \<branch-name>
git stash pop
git add .
git commit -m "git message"
git push -u origin \<branch-name>