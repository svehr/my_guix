(define-module (system bootloader)
 #:use-module (guix build utils)
 #:use-module (gnu bootloader)
 #:use-module (gnu bootloader grub)
 #:export (grub-efi-removable-bootloader-no-cryptomount))

(define grub-efi-removable-bootloader-configuration-file
  (bootloader-configuration-file grub-efi-removable-bootloader))

(define grub-efi-removable-bootloader-configuration-file-generator
  (bootloader-configuration-file-generator grub-efi-removable-bootloader))

(define (grub-efi-removable-bootloader-no-cryptomount-configuration-file-generator . args)
  ;; TODO: does not work
  (let ((file (apply grub-efi-removable-bootloader-configuration-file-generator args)))
    ;; (substitute* (computed-file-name file)
    ;;   ;; comment out cryptomount line
    ;;   (("^cryptomount -u .*$" all)
    ;;    (string-append "# " all)))
    (substitute* grub-efi-removable-bootloader-configuration-file
      ;; comment out cryptomount line
      (("^cryptomount -u .*$" all)
       (string-append "# " all)))
    file))

(define grub-efi-removable-bootloader-no-cryptomount
  (bootloader
   (inherit grub-efi-removable-bootloader)
   (name 'grub-efi-removable-bootloader-no-cryptomount)
   (configuration-file-generator grub-efi-removable-bootloader-no-cryptomount-configuration-file-generator)))
