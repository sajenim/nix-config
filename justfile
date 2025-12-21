default:
    @just --list

build *ARGS:
  nixos-rebuild build --flake .#{{ARGS}}

switch *ARGS:
  sudo nixos-rebuild switch --flake .#{{ARGS}}

deploy *ARGS:
  nixos-rebuild switch -S --flake .#{{ARGS}} --target-host {{ARGS}}

update:
  nix flake update

update-input INPUT:
  nix flake update {{INPUT}}
