## Notes

- You could install extensions using xargs

  ```bash
  cat <extensions-file> | xargs -L 1 code --install-extension # or
  cat <extensions-file> | xargs -L 1 flatpak run com.visualstudio.code --install-extension
  ```

- Windows setup

```powershell
iwr -useb https://dub.sh/yourwindowssetup | iex
```
