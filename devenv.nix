{ pkgs, lib, config, inputs, ... }:

{
  packages = with pkgs; [ 
    git
    pkg-config
    libyaml.dev
    openssl.dev
  ];

  languages.ruby = {
    enable = true;
    bundler.enable = true;
    versionFile = ./.ruby-version;
  };

  languages.javascript = {
    enable = true;
    corepack.enable = true;
    yarn.enable = true;
  };

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
