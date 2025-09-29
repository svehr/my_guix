(define-module (packages st)
 #:use-module (guix gexp)
 #:use-module (guix packages)
 #:use-module (guix utils)
 #:use-module (gnu packages)
 #:use-module (gnu packages fonts)
 #:use-module (gnu packages suckless))

(define-public st-configured
  (package
    (inherit st)
    (name "st-configured")
    (propagated-inputs
     (modify-inputs (package-propagated-inputs st)
       (append font-juliamono)))
    (arguments
     (substitute-keyword-arguments
         (package-arguments st)
       ((#:phases phases)
        #~(modify-phases
              #$phases
            (add-before 'build 'adjust-config
              (lambda _
                (substitute* "config.def.h"
                  ;; (("Liberation Mono:pixelsize=12:antialias=true:autohint=true")
                  ;;  "DejaVu Sans Mono:pixelsize=24:antialias=true:autohint=true")
                  (("Liberation Mono:pixelsize=12:antialias=true:autohint=true")
                   "JuliaMono:pixelsize=24:antialias=true:autohint=true")
                  (("wchar_t \\*worddelimiters = L\" \";")
                   "wchar_t *worddelimiters = L\" _-`'\\\"()[]{}\";")
                  (("unsigned int tabspaces = 8;")
                   "unsigned int tabspaces = 4;"))))))))))
