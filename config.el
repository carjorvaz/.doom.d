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

(setq delete-by-moving-to-trash t)

;; Auto-refresh buffers when files change on disk
(global-auto-revert-mode 1)

;; Make the Sly REPL pop-up on the side instead of on the bottom
(after! sly
  (set-popup-rules!
    '(("^\\*sly-mrepl"
       :side right
       :width 100
       :quit nil
       :ttl nil)))

  ;; Adjust these because of not using quicklisp on NixOS 
  (setq sly-contribs '(sly-mrepl
                       sly-autodoc
                       sly-fancy-inspector
                       sly-fancy-trace
                       sly-scratch
                       sly-package-fu
                       sly-fontifying-fu
                       sly-trace-dialog
                       sly-indentation
                       sly-tramp)))

;; Improve syntax highlighting on org-mode exports to PDF
(use-package! engrave-faces-latex
  :after ox-latex
  :config
  (setq org-latex-src-block-backend 'engraved))


;;; --- GTD System ---

(after! org
  ;; GTD TODO states
  (setq org-todo-keywords
        '((sequence
           "TODO(t)"     ; Inbox: needs clarifying
           "NEXT(n)"     ; Next action: defined, ready to do
           "STRT(s)"     ; Started: actively working on it now
           "WAIT(w@/!)"  ; Waiting: blocked on someone/something (log note)
           "HOLD(h@/!)"  ; On hold: paused by choice (log note)
           "PROJ(p)"     ; Project: multi-step outcome
           "IDEA(i)"     ; Someday/Maybe
           "|"
           "DONE(d!)"    ; Completed (log timestamp)
           "KILL(k@)"))  ; Cancelled (log reason)
        org-todo-keyword-faces
        '(("NEXT" . (:inherit success :weight bold))
          ("STRT" . +org-todo-active)
          ("WAIT" . +org-todo-onhold)
          ("HOLD" . +org-todo-onhold)
          ("PROJ" . +org-todo-project)
          ("IDEA" . (:inherit shadow :weight bold))
          ("KILL" . +org-todo-cancel)))

  ;; GTD agenda files
  (setq org-agenda-files '("~/org/inbox.org"
                           "~/org/gtd.org"
                           "~/org/tickler.org"
                           "~/org/habits.org"
                           "~/org/someday.org"))

  ;; GTD capture templates
  (setq +org-capture-todo-file "inbox.org"
        +org-capture-notes-file "inbox.org")

  (setq org-capture-templates
        '(("i" "Inbox" entry
           (file "inbox.org")
           "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :prepend t :empty-lines 1)
          ("t" "Todo (with link)" entry
           (file "inbox.org")
           "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n%a\n"
           :prepend t :empty-lines 1)
          ("n" "Note (fleeting)" entry
           (file+headline "inbox.org" "Notes")
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :prepend t :empty-lines 1)
          ("w" "Waiting For" entry
           (file+headline "gtd.org" "Waiting For")
           "* WAIT %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :prepend t :empty-lines 1)
          ("s" "Someday / Maybe" entry
           (file "someday.org")
           "* IDEA %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :prepend t :empty-lines 1)
          ("r" "Tickler (future reminder)" entry
           (file "tickler.org")
           "* TODO %?\nSCHEDULED: %^{When?}t\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :prepend t :empty-lines 1)))

  ;; Refile: inbox items -> gtd.org or someday.org headings
  (setq org-refile-targets '(("~/org/gtd.org" :maxlevel . 2)
                             ("~/org/someday.org" :maxlevel . 1)
                             ("~/org/tickler.org" :maxlevel . 1))
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil
        org-refile-allow-creating-parent-nodes 'confirm)

  ;; GTD agenda views
  (setq org-agenda-custom-commands
        '(("g" "GTD Dashboard"
           ((agenda "" ((org-agenda-span 7)
                        (org-agenda-start-day nil)))
            (todo "NEXT"
                  ((org-agenda-overriding-header "Next Actions")
                   (org-agenda-sorting-strategy '(tag-up priority-down))))
            (todo "STRT"
                  ((org-agenda-overriding-header "In Progress")))
            (todo "WAIT"
                  ((org-agenda-overriding-header "Waiting For")))
            (tags "inbox"
                  ((org-agenda-overriding-header "Inbox (process me!)")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'nottodo '("TODO")))))))
          ("n" "Next Actions (by context)"
           ((tags-todo "+@deep+TODO=\"NEXT\""
                       ((org-agenda-overriding-header "Deep Work")))
            (tags-todo "+@shallow+TODO=\"NEXT\""
                       ((org-agenda-overriding-header "Shallow Tasks")))
            (tags-todo "+@errand+TODO=\"NEXT\""
                       ((org-agenda-overriding-header "Errands")))
            (tags-todo "+@phone+TODO=\"NEXT\""
                       ((org-agenda-overriding-header "Phone Calls")))
            (tags-todo "-@deep-@shallow-@errand-@phone+TODO=\"NEXT\""
                       ((org-agenda-overriding-header "No Context")))))
          ("p" "Projects"
           ((todo "PROJ"
                  ((org-agenda-overriding-header "Active Projects")))))
          ("S" "Stuck Projects (no NEXT action)"
           ((stuck ""
                   ((org-stuck-projects
                     '("+TODO=\"PROJ\"" ("NEXT" "STRT") nil ""))))))
          ("W" "Weekly Review"
           ((tags "inbox"
                  ((org-agenda-overriding-header "Inbox (process to zero)")))
            (stuck ""
                   ((org-agenda-overriding-header "Stuck Projects (need NEXT action)")
                    (org-stuck-projects
                     '("+TODO=\"PROJ\"" ("NEXT" "STRT") nil ""))))
            (todo "WAIT"
                  ((org-agenda-overriding-header "Waiting For (follow up?)")))
            (todo "NEXT"
                  ((org-agenda-overriding-header "All Next Actions (still valid?)")))
            (todo "IDEA"
                  ((org-agenda-overriding-header "Someday/Maybe (promote or kill?)")))))))

  ;; Predefined tags
  (setq org-tag-alist '((:startgroup . nil)
                        ("@deep" . ?d)
                        ("@shallow" . ?s)
                        ("@errand" . ?e)
                        ("@phone" . ?p)
                        (:endgroup . nil)
                        ;; Areas of focus
                        ("thesis" . ?T)
                        ("kubestronaut" . ?K)
                        ("ecommerce" . ?E)
                        ("blog" . ?B)
                        ("nixos" . ?N)
                        ("selfhost" . ?S)
                        ("home" . ?H)
                        ("fitness" . ?F)
                        ("personal" . ?P)))

  ;; Log state changes into LOGBOOK drawer
  (setq org-log-into-drawer t
        org-log-done 'time)

  ;; Archive to per-file archive
  (setq org-archive-location "archive/archive_%s::datetree/"))

(after! org-roam
  (setq org-roam-dailies-capture-templates
        '(("d" "default" entry
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :target (file+head "%<%Y-%m-%d>.org"
                              "#+title: %<%Y-%m-%d %A>\n\n")))))

(use-package! auto-dark
  :defer t
  :init
  ;; Configure themes
  (setq! auto-dark-themes '((doom-gruvbox) (doom-gruvbox-light)))
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
