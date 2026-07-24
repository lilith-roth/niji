{
  pkgs ? import <nixpkgs> { },
  stdenv ? pkgs.stdenv,
  lib ? pkgs.lib,
}:
pkgs.rustPlatform.buildRustPackage {
  pname = "niji";
  version = "main";
  meta = {
    description = "A customizable tool for theming linux systems";
    longDescription = ''
      	Niji is an extensible theming framework that brings uniform, responsive and
      	comfortable theming to the tinkerer's desktop. It currently comes with builtin
      	support for GTK apps, sway, hyprland, kitty, and others, but it also allows you
      	to easily add custom modules for anything you desire.
    '';
    homepage = "https://github.com/lina-roether/niji";
    licenses = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    downloadPage = "https://github.com/lina-roether/niji/releases";
    mainProgram = "niji";
  };
  cargoLock.lockFile = ./Cargo.lock;
  src = pkgs.lib.cleanSource ./.;

  nativeBuildInputs = with pkgs; [
    pkg-config
    makeWrapper
    installShellFiles
    just
    clippy
  ];
  dontUseJustCheck = true;
  dontUseJustBuild = true;
  dontUseJustInstall = true;
  postInstall = ''
        	  substituteInPlace justfile --replace-fail "target/release" "target/${stdenv.hostPlatform.rust.cargoShortTarget}/$cargoBuildType"
        	  substituteInPlace justfile --replace-fail "{{base_dir}}/usr/share/niji" "$out/share/niji"
        	  substituteInPlace justfile --replace-fail "chown -R root:root" "#"

        	  just install-modules-themes

        	  wrapProgram $out/bin/niji --prefix XDG_DATA_DIRS : "$out/share" 
    		  #--prefix PATH: $ {lib.makeBinPath [ pkgs.luajit ]}

        	  installShellCompletion --bash target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/completions/niji.bash
        	  installShellCompletion --fish target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/completions/niji.fish
        	  installShellCompletion --zsh target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/completions/_niji
  '';
  buildInputs = with pkgs; [ luajit ];
  checkFlags = [
    "--skip=managed_fs::tests::write_existing_managed"
    "--skip=managed_fs::tests::write_new"
    "--skip=module::tests::apply"
    "--skip=module::tests::apply_error"
    "--skip=module::tests::check_can_reload_true"
    "--skip=module::tests::check_can_reload_false"
    "--skip=module::tests::load"
    "--skip=module::tests::load_not_a_module_error"
    "--skip=module::tests::reload"
    "--skip=module::tests::reload_error"
    "--skip=module::tests::call_function"
    "--skip=module_manager::tests::apply_module"
    "--skip=lua::runtime::tests::has_function"
    "--skip=lua::runtime::tests::load_module"
    "--skip=lua::runtime::tests::call_function"
    "--skip=lua::api::os::tests::is_accessible"
    "--skip=lua::api::util::tests::is_accessible"
    "--skip=lua::api::filesystem::tests::is_accessible"
    "--skip=lua::api::xdg::tests::is_accessible"
    "--skip=lua::api::console::tests::is_accessible"
    "--skip=lua::api::module_meta::tests::is_correct"
    "--skip=lua::api::module_meta::tests::is_accessible"
    "--skip=list_themes_global"
    "--skip=list_themes_local"
    "--skip=preview_themes"
  ];
  PKG_CONFIG_PATH = "${pkgs.luajit}/lib/pkgconfig";
}
