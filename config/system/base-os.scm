;; external dependencies
;; /etc/wpa_supplicant.conf
(define-module (config system base-os)
 ;; local imports
 #:use-module (packages st)
 ;; guix imports
 #:use-module (gnu)
 #:use-module (gnu packages admin)
 #:use-module (gnu packages android)
 #:use-module (gnu packages audio)
 ;; #:use-module (gnu packages chromium)
 #:use-module (gnu packages code)
 #:use-module (gnu packages compression)
 #:use-module (gnu packages commencement)
 #:use-module (gnu packages cryptsetup)
 #:use-module (gnu packages cups)
 #:use-module (gnu packages curl)
 #:use-module (gnu packages cpio)
 #:use-module (gnu packages emacs)
 #:use-module (gnu packages fonts)
 #:use-module (gnu packages freedesktop)
 #:use-module (gnu packages glib)
 #:use-module (gnu packages gnupg)
 #:use-module (gnu packages image-viewers)
 #:use-module (gnu packages inkscape)
 #:use-module (gnu packages librewolf)
 #:use-module (gnu packages linux)
 #:use-module (gnu packages lisp)
 #:use-module (gnu packages lisp-xyz)
 #:use-module (gnu packages moreutils)
 #:use-module (gnu packages package-management)
 #:use-module (gnu packages pdf)
 #:use-module (gnu packages python)
 #:use-module (gnu packages rsync)
 #:use-module (gnu packages rust-apps)
 #:use-module (gnu packages search)
 #:use-module (gnu packages shells)
 #:use-module (gnu packages ssh)
 #:use-module (gnu packages suckless)
 #:use-module (gnu packages text-editors)
 #:use-module (gnu packages tmux)
 #:use-module (gnu packages version-control)
 #:use-module (gnu packages video)
 #:use-module (gnu packages vim)
 #:use-module (gnu packages virtualization)
 #:use-module (gnu packages wget)
 #:use-module (gnu packages wm)
 #:use-module (gnu packages xdisorg)
 #:use-module (gnu packages xorg)
 #:use-module (gnu services)
 #:use-module (gnu services base)
 #:use-module (gnu services cups)
 #:use-module (gnu services desktop)
 #:use-module (gnu services networking)
 #:use-module (gnu services guix)
 #:use-module (gnu services pm)
 #:use-module (gnu services ssh)
 #:use-module (gnu services virtualization)
 #:use-module (gnu services xorg)
 #:use-module (gnu system)
 #:use-module (gnu system install)
 #:use-module (gnu system nss)
 #:use-module (gnu system shadow)
 #:use-module (guix build utils)
 #:use-module (guix channels)
 #:use-module (nongnu packages chrome)
 #:use-module (nongnu packages compression)
 #:use-module (nongnu packages linux)
 #:use-module (nongnu packages mozilla)
 #:use-module (nongnu system linux-initrd)
 #:export (base-os))

(define my-channels
  ;; Channels that should be available to
  ;; /run/current-system/profile/bin/guix.
  (append
   (list (channel
          (name 'nonguix)
          (url "https://gitlab.com/nonguix/nonguix")
          ;; Enable signature verification:
          (introduction
           (make-channel-introduction
            "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
            (openpgp-fingerprint
             "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5")))))
   %default-channels))

(define %tty-permissions-udev-rule
  (udev-rule
    "99-tty_permissions.rules"
    "SUBSYSTEM==\"tty\", KERNEL==\"tty[0-9]\", GROUP=\"tty\", MODE=\"0660\""))

(define %sudoers-file
  (plain-file
   "sudoers"
   (string-join
    '("# Aliases:"
      "Cmnd_Alias  POWER = /bin/halt.sh, /bin/reboot.sh, /bin/suspend.sh"

      "# Allow `sudo` for root."
      "Defaults !root_sudo"

      "Defaults passprompt = \"[sudo] Password for %p:\""

      "# Every time the password is entered correctly a timestamp file is created."
      "# The timestamps can be used to cache successful sudo attempts for future attempts."

      "# A successful attempt is \"cached\" for 10 minutes."
      "Defaults:slim timestamp_timeout = 10"
      "# A successful attempt is  \"cached\" globally (and not per tty or parent process id)."
      "Defaults:slim timestamp_type = global"

      "# Allow sudo for root user and users in `wheel` group."
      "root ALL=(ALL) ALL"
      "%wheel ALL=(ALL) ALL"

      "# Allow access to POWER commands without password."
      "%wheel ALL= NOPASSWD: POWER")
    "\n")))

(define %keyboard-layout
  (keyboard-layout "us" "altgr-intl"))

(define base-os
  (operating-system
   (kernel linux)
   (initrd microcode-initrd)
   (firmware (list linux-firmware))

   (host-name "sliook")
   (timezone "Europe/Berlin")
   (locale "en_US.utf8")
   (name-service-switch %mdns-host-lookup-nss)

   (keyboard-layout %keyboard-layout)

   (bootloader
    (bootloader-configuration
     (bootloader grub-efi-removable-bootloader)
     (targets '("/boot"))
     (keyboard-layout %keyboard-layout)
     (menu-entries
      (list
       (menu-entry
        (label "Guix (/boot edit)")
        (device (uuid "E10E-A388" 'fat))
        (linux "/bzImage")
        (linux-arguments '("root=/dev/mapper/root"))
        (initrd "/initrd.img"))))))

   (mapped-devices
    (list
     (mapped-device
      (source (uuid "df734b11-22b2-43d8-8661-1117aaad7078"))
      (target "root")
      (type luks-device-mapping))))

   (file-systems (cons* (file-system
                         (mount-point "/")
                         (device "/dev/mapper/root")
                         (type "btrfs")
                         (flags '(no-atime))
                         (options "space_cache=v2")
                         (needed-for-boot? #t)
                         (dependencies mapped-devices))
                        (file-system
                         (mount-point "/boot")
                         (device (uuid "E10E-A388" 'fat))
                         (type "vfat"))
                        %base-file-systems))

   (users
    (append
     (list
      (user-account
       (name "slim")
       (group "users")
       (supplementary-groups
        '("adbusers"  ;; adb (android)
          "audio"
          "input"
          "kvm"
          "libvirt"
          "lp"
          "netdev"
          "tty"
          "video"
          "wheel"))))  ;; 'wheel' makes user a sudoer
     %base-user-accounts))

   (sudoers-file %sudoers-file)

   (services
    (cons*
     ;; NOPASSWD sudo; see `%sudoers-file`
     (extra-special-file "/bin/halt.sh"
                         (local-file "halt.sh" "halt.sh" #:recursive? #t))
     (extra-special-file "/bin/reboot.sh"
                         (local-file "reboot.sh" "reboot.sh" #:recursive? #t))
     (extra-special-file "/bin/suspend.sh"
                         (local-file "suspend.sh" "suspend.sh" #:recursive? #t))

     ;; networking / bluetooth
     (service wpa-supplicant-service-type
              (wpa-supplicant-configuration
               (interface "wlp2s0")
               (config-file "/etc/wpa_supplicant.conf")))
     (service bluetooth-service-type
              (bluetooth-configuration (auto-enable? #t)))
     (service dhcpcd-service-type)

     ;; allow non-root to modify brightness
     (udev-rules-service 'brightnessctl brightnessctl)

     ;; time-sync
     (service ntp-service-type)

     ;; power management
     (service tlp-service-type
              (tlp-configuration
               (cpu-scaling-governor-on-ac (list "performance"))
               (cpu-scaling-governor-on-bat (list "powersave"))
               (sched-powersave-on-bat? #t)))
     (service thermald-service-type)

     ;; Xorg / desktop
     (service xorg-server-service-type) ;; use with `sx` or `xinit`
     ;; `#:recursive` keeps permissions
     (extra-special-file "/bin/startx_custom"
                         (local-file "startx_custom" "startx_custom" #:recursive? #t))
     (udev-rules-service 'tty-group-rw %tty-permissions-udev-rule
                         #:groups '("tty"))

     ;; screen lock
     (service screen-locker-service-type
              (screen-locker-configuration
               (name "slock")
               (program (file-append slock "/bin/slock"))))

     ;; greeter; for PAM / XDG_RUNTIME_DIR
     (service greetd-service-type
              (greetd-configuration
               (terminals
                (list
                 (greetd-terminal-configuration
                  (terminal-vt "7")
                  (terminal-switch #t))
                 (greetd-terminal-configuration
                  (terminal-vt "8"))
                 (greetd-terminal-configuration
                  (terminal-vt "9"))))))

     ;; virtualization
     (service libvirt-service-type
              (libvirt-configuration
               (unix-sock-group "libvirt")
               (tls-port "16514")))
     (service virtlog-service-type)
     (service qemu-guest-agent-service-type
              (qemu-guest-agent-configuration
               (qemu qemu-minimal)))

     ;; printing
     (service cups-service-type
              (cups-configuration
               (web-interface? #t)
               (default-paper-size "A4")))

     ;; android
     (udev-rules-service 'android android-udev-rules
                         #:groups '("adbusers"))

     ;; base
     (modify-services %base-services
                      ;; TODO:?: switch to greetd for terminals 1-6 too? Or make login/mingetty the 7+
                      ;; (delete login-service-type)
                      ;; (delete mingetty-service-type)
                      (guix-service-type
                       config => (guix-configuration
                                  (inherit config)
                                  (substitute-urls
                                   (append (list "https://substitutes.nonguix.org")
                                           %default-substitute-urls))
                                  (authorized-keys
                                   (append (list (plain-file "nonguix.pub"
                                                             "(public-key
                                                             (ecc
                                                              (curve Ed25519)
                                                              (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
                                           %default-authorized-guix-keys))
                                  (channels my-channels)
                                  (guix (guix-for-channels my-channels)))))))

   (packages
    (append
     (list
      bluez
      brightnessctl
      cpio
      cups
      curl
      cryptsetup
      dmenu
      emacs
      feh
      firefox
      fish
      flatpak
      font-awesome
      font-dejavu
      font-juliamono
      gcc-toolchain
      git
      gnupg
      google-chrome-stable
      librewolf
      libxcursor
      htop
      inkscape
      lem
      lshw
      moreutils
      mpv
      myrepos
      neovim
      openssh
      pastel
      plocate
      pipewire
      pinentry
      python
      radeon-firmware
      rsync
      sbcl
      sbcl-stumpwm-battery-portable
      sbcl-stumpwm-cpu
      sbcl-stumpwm-mem
      sbcl-stumpwm-ttf-fonts
      sbcl-stumpwm-wifi
      slock
      st-configured
      stumpish
      stumpwm+slynk
      sxiv
      tlp
      tmux
      the-silver-searcher
      ;; ungoogled-chromium  ;; package is unmaintained
      unrar
      unzip
      util-linux
      wireplumber
      xclip
      xev
      xcursor-themes
      xdg-desktop-portal
      xdg-utils
      xdg-dbus-proxy
      shared-mime-info
      xf86-input-libinput
      xf86-video-fbdev
      xf86-video-amdgpu
      xinit
      xkbset
      xkeyboard-config
      xmodmap
      xorg-server
      xrandr
      xrdb
      xsel
      xsetroot
      xterm
      zathura
      zathura-pdf-mupdf
      zip)
     %base-packages))))
