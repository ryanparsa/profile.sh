Installing
```sh
curl -o ~/.profile.sh https://raw.githubusercontent.com/ryanparsa/profile.sh/main/profile.sh
```


Add to Shell Configuration: To make the script available in your terminal, add the following to your .bashrc or .zshrc:
```sh
source ~/.profile.sh
alias p=profile
```


add this three files to: 
- `profile` to `~/.profiles/local`
- `pre_load.sh` to `~/.profiles/pre_load.sh`
- `post_load.sh` to `~/.profiles/post_load.sh`


and now if you call 
```
p local
```
or 

```
profile local
```


your current shell, will call, `pre_load.sh` `local` and `post_load.sh` in order
you can check new env using 

```
env | sort | nl
```

and for alias:
```
alias | sort | nl
```
