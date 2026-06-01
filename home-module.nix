{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.niji;
  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "niji.toml" cfg.settings;
in
{
  options.programs.niji = {
    package = lib.mkPackageOption pkgs "niji" { };
    enable = lib.mkEnableOption { type = lib.types.bool; };
    settings = lib.mkOption {
      default = { };
      description = "Niji configuration file";
      inherit (settingsFormat) type;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.file.".config/niji/config.toml" = {
      source = "${configFile}";
      force = true;
    };
  };
}
