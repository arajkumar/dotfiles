Dotfiles
========

Contains configuration files for various tools like Vim, Mercurial, Git,..

Tools
=====

- vim
- ripgrep / ag
- fzf

Pi agent
========

Run `bash pi/install.sh` to install the Pi config files into `~/.pi`.
Bash and Node.js must be available.
Keep `tiger` on PATH for the Tiger MCP server.
The installer preserves existing files as `.bak` backups.
Run the installer again to check the config without a change.
If a backup exists and the live config differs from the expected config, the installer stops.

`pi/.gitignore` permits only the selected config files and the installer.
Do not add credentials to these files.
Keep credentials in Pi's untracked auth files or environment variables.
Session data, caches, installed packages, and local skill sources remain outside this repository.
The MCP OAuth client ID is public metadata, not a secret.

Most config files use symlinks.
For Warden, the installer expands `$HOME` in `pi/agent/pi-warden/config.json` and writes a private local config file.
Warden does not expand environment variables itself.
Edit the tracked template for a permanent change.
Warden commands change the local config, not the tracked template.
If the template changes, preserve the live Warden config.
Move that file aside before you run the installer.
