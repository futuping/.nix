{
  imports = [ ./modules/mas-list-fix.nix ];

  programs.mas = {
    enable = true;
    cleanup = true;
    update = false;

    packages = {
      # Infuse = 1136220934;
    };
  };
}
