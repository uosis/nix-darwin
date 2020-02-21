{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.fonts;
in

{
  options = {
    fonts.enableFontDir = mkOption {
      default = false;
      description = ''
        Whether to enable font management and install configured fonts to
        <filename>/Library/Fonts</filename>.

        NOTE: removes any manually-added fonts.
      '';
    };

    fonts.fonts = mkOption {
      type = types.listOf types.path;
      default = [];
      example = literalExample "[ pkgs.dejavu_fonts ]";
      description = "List of fonts to install.";
    };
  };

  config = {

    system.build.fonts = pkgs.runCommandNoCC "fonts"
      { paths = cfg.fonts; preferLocalBuild = true; }
      ''
        mkdir -p $out/Library/Fonts
        for path in $paths; do
            find -L $path/share/fonts -type f -print0 | while IFS= read -rd "" f; do
                ln -s "$f" $out/Library/Fonts
            done
        done
      '';

    system.activationScripts.fonts.text = optionalString cfg.enableFontDir ''
      # Set up fonts.
      echo "configuring fonts..." >&2
      rsync -rL --progress --delete-after --size-only "$systemConfig/Library/Fonts/" /Library/Fonts
    '';

  };
}
