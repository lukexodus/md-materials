`reset` removes commits. `revert` just goes back but just adds another commit, does not remove commits.

***

When a commit has unfinished feature or code changes, label it with `unstable`. So that it will not be used when rewinding.

***

When setting the remote origin, use the ssh form of the url, not the https one.

---

### GitHub Flow

```
git stash 
git switch -c \<branch-name>
git stash pop
git add .
git commit -m "git message"
git push -u origin \<branch-name>
```