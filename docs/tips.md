
# Tips

1. [Don’t change your login shell, use a modern terminal emulator](https://tim.siosm.fr/blog/2023/12/22/dont-change-defaut-login-shell/)

2. Fix locale issues on Ubuntu with the following command.

  ```bash
  sudo dpkg-reconfigure locales
  ```

3. Use `imwheel` to fix mouse-scroll speed on Ubuntu in VMware.

  ```bash
  imwheel -b "4 5" > /dev/null 2>&1
  ```

4. In `opensuse` you could use the following command to get all the patterns(group for dnf)

  ```bash
  zypper search --type pattern
  ```


