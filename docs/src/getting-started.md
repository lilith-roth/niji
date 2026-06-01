# Getting Started

## Installation

### AUR

Arch Linux users can install niji from the AUR using the `niji-git` package.

### Nix

On Unix systems using Nix, niji can be easily installed, as well as configured
with Home Manager if desired.

niji can be installed and configured with or without the use of flakes, although
using flakes is recommended. Either case consists of first declaring niji as
a source to fetch, then configuring your nixpkgs to utilize the niji overlay,
importing the Home Manager module, and finally configuring your niji installation.

#### Nix Home Manager (recommended)

##### Home Manager Installation with Flakes

`flake.nix`

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niji = {
      url = "github:lina-roether/niji";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, niji, ...}:
    let
      pkgs = import nixpkgs {
        overlays = [ niji.overlays.default ];
      };
    in
    {
      homeConfigurations = {
        "your-username" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          modules = [
            ./home.nix
            # Without the following you may run into an infinite recursion error!
            home-manager.extraSpecialArgs = { inherit niji pkgs; };
          ];
        };
      };
  };
}
```

`default.nix`

```nix
{ pkgs, niji, ...}:
{
  imports = [
    ${niji}/home-module.nix
  ];
  programs.niji = {
    enable = true;
    settings = {
      modules = [
        "sway"
      ];
    };
  };
}
```

##### Home Manager Installation without Flakes

Example:

`default.nix`

```nix
{pkgs, ...}:
let
  niji = builtins.fetchGit {
    url = "https://github.com/lina-roether/niji";
    ref = "main";
  };
in {
  nixpkgs.overlays = [
    (import ("${niji}/overlay.nix"))
  ];
  imports = [
    "${niji}/home-module.nix"
  ];

  programs.niji = {
    enable = true;
    settings = {
      modules = [ "sway" ];
    };
  };
}
```

#### NixOS Package

On NixOS without Home Manager, niji can be installed by adding it to your system
packages. Note that this will require manually creating the `config.toml` for
niji to work.

```nix
{pkgs, ...}:
let
  niji = builtins.fetchGit {
    url = "https://github.com/lina-roether/niji";
    ref = "main";
  };
in {
  nixpkgs.overlays = [
    (import ("${niji}/overlay.nix"))
  ];
  environment.systemPackages = with pkgs; [
    niji
  ];
}
```

#### Nix Environment Installation

On non-NixOS systems without Home Manager, niji can be installed into the Nix
environment using `nix-env`. Note that this will require manually creating the
`config.toml` for niji to work, since `nix-env` can't use the niji Home Manager
module.

```sh
$ nix-env niji-main -i -f https://github.com/lina-roether/niji/archive/refs/heads/main.zip
```

### Manually

To install niji manually from source, do the following steps:

1. Make sure you have the rust toolchain and _just_ installed
2. Clone the git repository and enter the folder
3. Build the project using `just build`
4. Install niji using `sudo just install`

## Initial Configuration

Create the configuration file at `~/.config/niji/config.toml`. The first step is
to choose which modules to use. Take a look at [Built-in Modules](./modules/)
for a list of available modules. Simply set your desired modules using this
syntax:

```toml
modules = ["hyprland", "waybar"]
```

Afterwards, you should set `font_family`, `cursor_theme` and `cursor_size` as
basic preferences. Make sure you have the cursor theme installed that you
select.

```toml
modules = ["hyprland", "waybar"]

[global]
font_family = "Fira Sans"
cursor_theme = "Adwaita"
cursor_size = 22
```

Lastly, be sure to refer to the
[documentation of each of your selected modules](./modules/) and check for
available configuration options and additional necessary steps for activation.

You can now list available themes using `niji theme list`, and preview them
using `niji theme preview <name>`. You can also choose an accent color out of
`pink`, `red`, `orange`, `yellow`, `green`, `teal`, `blue`, `purple`, `black`
and `white`.

If you've picked a theme and accent color, apply it using:

```sh
niji theme set <theme> --accent <accent>
```

## Next Steps

After the initial setup, you may want to consider taking a look at
[Configuration](./configuration.md) for some advanced configuration options.

If you want to use a custom theme, refer to [Custom Themes](./custom-themes.md).

If you want to apply your theme to an application that isn't supported out of
the box, you can take a look at [Custom Modules](./custom-modules.md).
