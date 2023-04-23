# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib,... }:


{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  #boot.loader.grub.enable = true;
  #boot.loader.grub.version = 2;
  #boot.loader.grub.efiSupport = true;
  #boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader.grub.device = "nodev";
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

   networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
   time.timeZone = "Asia/Tokyo";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  #  i18n.defaultLocale = "en_US.UTF-8";
  #  console = {
  #    font = "Lat2-Terminus16";
  #    keyMap = "jp";
  #  };

  # Configure Sway
#  systemd.user.targets.sway-session={
#    description = "Sway compositor session";
#    documentation = ["man:systemd.special(7)"];
#    bindsTo = ["graphical-session.target"];
#    wants = ["graphical-session-pre.target"];
#    after =["graphical-session-pre.target"];
#  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      i3pystatus (python38.withPackages(ps: with ps; [ i3pystatus keyring ]))
      brightnessctl
      swaylock
      swayidle
      xwayland
      kanshi
      grim
      slurp
      wl-clipboard
      wf-recorder
      (python38.withPackages(ps: with ps; [ i3pystatus keyring ]))      swaylock
      mako # notification daemon
      alacritty # Alacritty is the default terminal in the config
      dmenu # Dmenu is the default in the config but i recommend wofi since its wayland native
      waybar
      autotiling
      gammastep
      wofi
      flashfocus
      ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export WLR_NO_HARDWARE_CURSORS=1
      export WLR_RENDERER_ALLOW_SOFTWARE=1
    '';
  };


  # configuring kanshi
  systemd.user.services.kanshi = {
    description = "Kanshi output autoconfig ";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    environment = { XDG_CONFIG_HOME="/home/mschwaig/.config"; };
    serviceConfig = {
      # kanshi doesn't have an option to specifiy config file yet, so it looks
      # at .config/kanshi/config
      ExecStart = ''
      ${pkgs.kanshi}/bin/kanshi
      '';
      RestartSec = 5;
      Restart = "always";
    };
  };

  # Autostart Sway
  environment.loginShellInit = ''
    if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec sway
    fi
  '';

  # Enable the X11 windowing system.
   #services.xserver.enable = true;
   #services.xserver.displayManager.defaultSession = "sway";
   #services.xserver.displayManager.sddm.enable = true;
   #services.xserver.libinput.enable = true;


  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;
  

  # Configure keymap in X11
   services.xserver.layout = "jp";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
   sound.enable = true;
   hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.kyle = {
     isNormalUser = true;
     extraGroups = [ "wheel" "video" "networkmanager" ]; # Enable ‘sudo’ for the user.
     home = "/home/kyle";
     initialPassword = "test";
     shell = pkgs.zsh;
   };

   #fonts
   fonts.fonts = with pkgs; [
     noto-fonts
     noto-fonts-cjk
     noto-fonts-emoji
     (nerdfonts.override { fonts = [ "FiraCode" ]; })
   ];

   # Enable installation of unfree packages
   #nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
   #$ nix search wget
   environment.systemPackages = with pkgs; [
     #system
     wget
     git
     polkit_gnome
     zsh
     neofetch
     gopass
    #browserpass
     # fonts
     meslo-lgs-nf
     # Japanese
     anki
     mpv
     #text editor
     vscodium
     neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     # browsers
     brave
     chromium
     firefox
   ];

  programs.browserpass.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
  #   enableSSHSupport = true;
   };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

