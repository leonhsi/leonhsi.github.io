---
title: How to change icons in AstroNvim on Ubuntu
date: 2023-04-16 15:28:25
tags: 
- nvim
categories:
- tech
---

If you are new to [AstroNvim](https://github.com/AstroNvim/AstroNvim), and haven't installed any fonts on you linux, the default icons in AstroNvim might not be recongnized.

<img style="display: block; margin: auto;" src="https://i.imgur.com/rauPWx3.png" />


## Install Nerd Fonts on Linux

Choose the font you like (I choose DejaVuSansMono), download it on [Nerd Fonts](https://www.nerdfonts.com/font-downloads) and unzip the compressed file.

Then, install the fonts on linux:
```bash
unzip DejaVuSansMono.zip
cp -r DejaVuSansMono/* ~/.local/share/fonts/
```

Update the font-cache:
```
fc-cache -fv
```

Change the fonts for terminal:

<img style="display: block; margin: auto;" src="https://i.imgur.com/BYnpgVJ.png"/>

## Change Config File in Nvim

Go to nvim config directory:
```bash
cd ~/.config/nvim/user
```

Change `icons_enabled` to `true` in the `init.lua` file:
```lua
return {
  options = {
    g = {
      icons_enabled = true,
    },
  },
}
```

Since nerd fonts is installed, the icons should be working right now.

See the official [Doc](https://astronvim.com/Recipes/icons) for more details.

