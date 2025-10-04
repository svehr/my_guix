(define-module (config home home)
 #:use-module (gnu home services desktop)
 #:use-module (gnu home services gnupg)
 #:use-module (gnu home services shells)
 #:use-module (gnu home services shepherd)
 #:use-module (gnu home services sound)
 #:use-module (gnu home services ssh)
 #:use-module (gnu home services xdg)
 #:use-module (gnu home services)
 #:use-module (gnu home)
 #:use-module (gnu packages gnupg)
 #:use-module (gnu packages)
 #:use-module (gnu services)
 #:use-module (gnu system shadow)
 #:use-module (guix gexp))

(define (append-string-to-HOME string)
  (string-append (getenv "HOME") string))

(define (path-to-zk-store string)
  (string-append (getenv "HOME") "/zk/store/" string))

(define (path-to-files string)
  (string-append (getenv "HOME") "/my_guix/files/" string))

(home-environment
 (packages
  (specifications->packages
   (list
    ;; "st-configured"  ;; TODO: done in system currently
    "ausweisapp"
    "dunst"  ;; notifications
    "file"
    "flameshot"
    "font-awesome"
    "font-dejavu"
    "font-juliamono"
    "font-latin-modern"
    "font-mathjax"
    "font-stix-two"
    "font-google-material-design-icons"
    "font-google-noto"
    "font-google-noto-emoji"
    "font-google-noto-sans-cjk"
    "font-google-noto-serif-cjk"
    "imagemagick"
    "lm-sensors"
    "node"
    "pandoc"
    "python-rich"
    "rust"
    "rust:tools"
    "rust:cargo"
    "rust:rust-src"
    "rust-analyzer"
    "setxkbmap"
    "sbcl-stumpwm-stumptray"
    "sbcl-stumpwm-battery-portable"
    "sbcl-stumpwm-cpu"
    "sbcl-stumpwm-mem"
    "sbcl-stumpwm-ttf-fonts"
    "sbcl-stumpwm-wifi"
    "scsh"
    "steam"
    "strace"
    "texlive"
    "tmux"
    "units"
    "xkbset"
    "xset"
    "yarn")))

 ;; search for home services `guix home search KEYWORD`
 (services
  (append
   (list
    (service home-shepherd-service-type)

    (simple-service 'some-useful-env-vars-service
                    home-environment-variables-service-type
                    ;; NOTE: / TODO: broken ; I put it into .bash_profile
                    `(("PATH" . "${HOME}/.local/bin:${PATH}")
                      ("BROWSER" . "firefox")))

    (service home-files-service-type
             ;; NOTE: `#:recursive? #t` to keep the executable permissions
             `(;; generated files
               (".guile" ,%default-dotguile)
               (".Xdefaults" ,%default-xdefaults)
               (".Xresources"
                ,(local-file (path-to-files ".Xresources")
                             "Xresources"))
               (".xinitrc"
                ,(local-file (path-to-files ".xinitrc")
                             "xinitrc"))
               (".stumpwmrc"
                ,(local-file (path-to-files ".stumpwmrc")
                             "stumpwmrc"))
               (".tmux.conf"
                ,(local-file (path-to-files ".tmux.conf")
                             "tmux.conf"))
               (".mrtrust"
                ,(local-file (path-to-files ".mrtrust")
                             "mrtrust"))
               (".gitconfig"
                ,(local-file (path-to-files ".gitconfig")
                             "gitconfig"))
               (".local/bin/poweroff"
                ,(local-file (path-to-files "poweroff")
                             "poweroff" #:recursive? #t))
               (".local/bin/bluetoothctl-connect.sh"
                ,(local-file (path-to-files "bluetoothctl-connect.sh")
                             "bluetoothctl-connect.sh" #:recursive? #t))
               (".local/bin/bluetoothctl-disconnect.sh"
                ,(local-file (path-to-files "bluetoothctl-disconnect.sh")
                             "bluetoothctl-disconnect.sh" #:recursive? #t))
               (".local/bin/guix-repl.sh"
                ,(local-file (path-to-files "guix-repl.sh")
                             "guix-repl.sh" #:recursive? #t))
               (".local/bin/guix-home-reconfigure.sh"
                ,(local-file (path-to-files "guix-home-reconfigure.sh")
                             "guix-home-reconfigure.sh" #:recursive? #t))
               (".local/bin/guix-system.sh"
                ,(local-file (path-to-files "guix-system.sh")
                             "guix-system.sh" #:recursive? #t))
               (".local/bin/keyboard_setup.sh"
                ,(local-file (path-to-files "keyboard_setup.sh")
                             "keyboard_setup.sh" #:recursive? #t))
               (".local/bin/monitor_setup.sh"
                ,(local-file (path-to-files "monitor_setup.sh")
                             "monitor_setup.sh" #:recursive? #t))
               (".local/bin/guix_reprofile.sh"
                ,(local-file (path-to-files "guix_reprofile.sh")
                             "guix_reprofile.sh" #:recursive? #t))
               (".local/bin/slock.sh"
                ,(local-file (path-to-files "slock.sh")
                             "slock.sh" #:recursive? #t))
               ;; TODO: npm; rather make a package or proper symlink?
               ;; (".local/bin/tsserver"
               ;;  ,(local-file (path-to-files "tsserver")
               ;;               "tsserver" #:recursive? #t))
               (".local/bin/tsc"
                ,(program-file
                  "tsc"
                  (let ((path-to-exe (path-to-zk-store "2023-04-06_10.45.33.435_UTC--mirs@wrucon.org/node_modules/.bin/tsc")))
                    (with-imported-modules
                        '((guix build utils))
                      #~(begin
                          (use-modules (guix build utils))
                          (apply invoke #$path-to-exe (cdr (command-line))))))))
               (".local/bin/tsserver"
                ,(program-file
                  "tsserver"
                  (let ((path-to-exe (path-to-zk-store "2023-04-06_10.45.33.435_UTC--mirs@wrucon.org/node_modules/.bin/tsserver")))
                    (with-imported-modules
                        '((guix build utils))
                      #~(begin
                          (use-modules (guix build utils))
                          (apply invoke #$path-to-exe (cdr (command-line))))))))
               (".local/bin/typescript-language-server"
                ,(program-file
                  "typescript-language-server"
                  (let ((path-to-exe (path-to-zk-store "2023-04-06_10.45.33.435_UTC--mirs@wrucon.org/node_modules/.bin/typescript-language-server")))
                    (with-imported-modules
                        '((guix build utils))
                      #~(begin
                          (use-modules (guix build utils))
                          (apply invoke #$path-to-exe (cdr (command-line))))))))
               ;; zk files
               (".local/bin/wget1.sh"
                ,(local-file (path-to-zk-store "2021-01-07_13.46.33.585_UTC--mirs@wrucon.org/wget1.sh")
                             "wget1.sh" #:recursive? #t))
               (".local/bin/openi.sh"
                ,(local-file (path-to-zk-store "2021-01-10_18.05.06.208_UTC--mirs@wrucon.org/openi.sh")
                             "openi.sh" #:recursive? #t))
               (".local/bin/dmenu-select-prog.sh"
                ,(local-file (path-to-zk-store "2021-01-07_15.54.39.786_UTC--mirs@wrucon.org/dmenu-select-prog.sh")
                             "dmenu-select-prog.sh" #:recursive? #t))
               (".local/bin/tmux-shell.sh"
                ,(local-file (path-to-zk-store "2021-01-08_09.51.21.023_UTC--mirs@wrucon.org/tmux-shell.sh")
                             "tmux-shell.sh" #:recursive? #t))
               (".local/bin/tmux-gsn.sh"
                ,(local-file (path-to-zk-store "2021-01-07_17.27.00.981_UTC--mirs@wrucon.org/tmux-gsn.sh")
                             "tmux-gsn.sh" #:recursive? #t))
               (".local/bin/annex+mr-register_repo.sh"
                ,(local-file (path-to-zk-store "2020-02-26_07.59.37.197_UTC--mirs@wrucon.org/annex+mr-register_repo.sh")
                             "annex+mr-register_repo.sh" #:recursive? #t))))

    (service home-gpg-agent-service-type
             (home-gpg-agent-configuration
              (pinentry-program
               (file-append pinentry-gtk2 "/bin/pinentry-gtk-2"))
              (ssh-support? #t)))

    (service home-openssh-service-type
             (home-openssh-configuration
              (add-keys-to-agent "yes")
              (hosts
               (list (openssh-host
                      (name "svehr.github")
                      (host-name "github.com")
                      (user "git")
                      (identity-file (string-append (getenv "HOME") "/.ssh/slim@sliook_->_svehr@github.com")))))))

    (service home-dbus-service-type)
    (service home-pipewire-service-type
             (home-pipewire-configuration
              (enable-pulseaudio? #t)))

    (service home-bash-service-type
             (home-bash-configuration
              (aliases '(("grep" . "grep --color=auto")
                         ("ip" . "ip -color=auto")
                         ("ll" . "ls -alFh --color=auto --time-style=long-iso")
                         ("ls" . "ls -p --color=auto")))
              (bashrc (list (local-file (path-to-files ".bashrc") "bashrc")))
              (bash-profile (list (local-file
                                   (path-to-files ".bash_profile")
                                   "bash_profile"))))))
   %base-home-services)))
