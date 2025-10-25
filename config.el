;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Carlos Vaz"
      user-mail-address "carlos@carjorvaz.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 18))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'modus-operandi)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type nil)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; An evil mode indicator is redundant with cursor shape
(setq doom-modeline-modal nil)

;; Focus new window after splitting
(setq evil-split-window-below t
      evil-vsplit-window-right t)

(setq +doom-dashboard-functions '(doom-dashboard-widget-shortmenu doom-dashboard-widget-loaded))

;; Prevents some cases of Emacs flickering
(add-to-list 'default-frame-alist '(inhibit-double-buffering . t))

(setq delete-by-moving-to-trash t)

;; Make the Sly REPL pop-up on the side instead of on the bottom
(after! sly
    (set-popup-rules!
        '(("^\\*sly-mrepl"
            :side right
            :width 100
            :quit nil
            :ttl nil))))

;; Improve syntax highlighting on org-mode exports to PDF
(use-package! engrave-faces-latex
  :after ox-latex
  :config
  (setq org-latex-src-block-backend 'engraved))

;; Use system Julia LSP
(setq lsp-julia-package-dir nil)

(after! lsp-julia
  (setq lsp-julia-default-environment "~/.julia/environments/v1.11"))

(use-package! auto-dark
  :defer t
  :init
  ;; Configure themes
  (setq! auto-dark-themes '((doom-gruvbox) (modus-operandi-tritanopia)))
  ;; Disable doom's theme loading mechanism (just to make sure)
  (setq! doom-theme nil)
  ;; Declare that all themes are safe to load.
  ;; Be aware that setting this variable may have security implications if you
  ;; get tricked into loading untrusted themes (via auto-dark-mode or manually).
  ;; See the documentation of custom-safe-themes for details.
  (setq! custom-safe-themes t)
  ;; Enable auto-dark-mode at the right point in time.
  ;; This is inspired by doom-ui.el. Using server-after-make-frame-hook avoids
  ;; issues with an early start of the emacs daemon using systemd, which causes
  ;; problems with the DBus connection that auto-dark mode relies upon.
  (defun my-auto-dark-init-h ()
    (auto-dark-mode)
    (remove-hook 'server-after-make-frame-hook #'my-auto-dark-init-h)
    (remove-hook 'after-init-hook #'my-auto-dark-init-h))
  (let ((hook (if (daemonp)
                  'server-after-make-frame-hook
                'after-init-hook)))
    ;; Depth -95 puts this before doom-init-theme-h, which sounds like a good
    ;; idea, if only for performance reasons.
    (add-hook hook #'my-auto-dark-init-h -95)))
