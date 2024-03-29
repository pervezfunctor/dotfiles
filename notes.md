## Notes

- Fix locale issues on Ubuntu with the following command.

  ```bash
  sudo dpkg-reconfigure locales
  ```

- Use `imwheel` to fix mouse-scroll speed on Ubuntu.

  ```bash
  imwheel -b "4 5" > /dev/null 2>&1
  ```

- To get all extensions installed on your system

  ```bash
  code --list-extensions > extensions.txt
  ```

- You could install extensions using xargs

  ```bash
  cat extensions.txt | xargs -L 1 code --install-extension
  ```
