(define-module (config system slimbook)
 #:use-module (config system base-os)
 #:use-module (system bootloader)
 #:use-module (gnu)
 #:use-module (gnu bootloader)
 #:use-module (gnu system)
 #:use-module (gnu system file-systems)
 #:use-module (guix build utils)
 #:export (base-os-kernel-on-boot-partition))

(define kernel-target "/boot/bzImage")
(define initrd-target "/boot/initrd.img")

(define copy-to-boot-gexp
  (let* ((timestamp (strftime "%Y-%m-%d_%H.%M.%S" (localtime (current-time))))
         (kernel (operating-system-kernel-file base-os))
         (initrd (operating-system-initrd-file base-os))
         (bootloader-configuration (operating-system-bootloader base-os))
         (bootloader (bootloader-configuration-bootloader bootloader-configuration))
         (grub-cfg (bootloader-configuration-file bootloader)))
    (with-imported-modules '((guix build utils))
      #~(begin
          (use-modules (guix build utils))
          (copy-file #$kernel-target #$(string-append kernel-target "_" timestamp))
          (copy-file #$initrd-target #$(string-append initrd-target "_" timestamp))
          (copy-file #$kernel #$kernel-target)
          (copy-file #$initrd #$initrd-target)
          (substitute* #$grub-cfg
            ;; comment out cryptomount line; the /boot partition including the kernel and initram is not encrypted
            (("^cryptomount -u .*$" all)
             (string-append "# " all)))))))

(define base-os-kernel-on-boot-partition
  (operating-system
   (inherit base-os)

   (bootloader
    (bootloader-configuration
     ;; NOTE: / TODO:
     ;; `grub-efi-removable-bootloader-no-cryptomount` does not really work right now;
     ;; it is supposed to uncomment the `cryptomount` line;
     ;; WORKAROUND: done in script `guix-copy-to-boot` (see `copy-to-boot-gexp`)
     (bootloader grub-efi-removable-bootloader-no-cryptomount)
     (targets '("/boot"))
     (keyboard-layout (operating-system-keyboard-layout base-os))
     (menu-entries
      (list
       (menu-entry
        (label "Guix (/boot edit)")
        (device (uuid "E10E-A388" 'fat))
        (linux "/bzImage")
        (linux-arguments '("root=/dev/mapper/root"))
        (initrd "/initrd.img"))
       (menu-entry
        (label "Guix (/boot edit operating-system-kernel-arguments)")
        (device (uuid "E10E-A388" 'fat))
        (linux "/bzImage")
        ;; NOTE: / TODO: not the same kernel arguments as for the "normal" entry (since we refer to `base-os`)
        (linux-arguments (operating-system-kernel-arguments base-os "/dev/mapper/root"))
        (initrd "/initrd.img"))))
     (default-entry 2)))


   (services ;; operating-system-user-services
    (cons*
     ;; script to copy kernel and initram to /boot
     ;;   TODO: do here somehow (w/o the script)
     (extra-special-file "/bin/guix-copy-to-boot"
                         (program-file "guix-copy-to-boot" copy-to-boot-gexp))
     ;; base
     (operating-system-user-services base-os)))))

base-os-kernel-on-boot-partition
