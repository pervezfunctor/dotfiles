;;; init --- emacs configuration

;; emacs configuration that works in terminal

;;; Code:

(setq package-enable-at-startup nil)
(setq initial-major-mode 'text-mode)


;;;; prefer UTF8

(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;;;; detect operating system

(defconst *is-a-mac* (eq system-type 'darwin))
(defconst *is-a-linux* (eq system-type 'gnu/linux))
(defconst *is-a-windows* (eq system-type 'windows-nt))

;;;; essential settings

(when *is-a-mac*
  (setq mac-option-modifier 'meta)
  (custom-set-variables '(ns-use-srgb-colorspace nil)))

(when *is-a-windows*
  (setq default-directory "~/")

  (setq inhibit-compacting-font-caches t)

  (setq w32-pass-lwindow-to-system nil)
  (setq w32-lwindow-modifier 'super)

  (setq w32-pass-rwindow-to-system nil)
  (setq w32-rwindow-modifier 'super)

  (setq w32-pass-apps-to-system nil)
  (setq w32-apps-modifier 'hyper))

;;;; store custom settings in ~/.emacs.d/custom.el
(setq custom-file (expand-file-name ".custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;;; sensible defaults

(setq-default
 buffers-menu-max-size 30
 case-fold-search t
 column-number-mode t
 delete-selection-mode t
 indent-tabs-mode nil
 mouse-yank-at-point t
 save-interprogram-paste-before-kill t
 scroll-preserve-screen-position 'always
 set-mark-command-repeat-pop t
 tooltip-delay 1.5
 truncate-lines nil
 truncate-partial-width-windows nil
 visible-bell nil)

(setq use-file-dialog nil
      x-gtk-use-system-tooltips t
      use-dialog-box nil
      pop-up-windows nil
      inhibit-startup-screen t
      inhibit-startup-echo-area-message t
      require-final-newline t
      global-auto-revert-mode t
      global-visual-line-mode t
      create-lockfiles nil
      indicate-empty-lines t)

;; do not ask to follow link
(customize-set-variable 'find-file-visit-truename t)

(customize-set-variable 'dired-dwim-target t)
(customize-set-variable 'dired-auto-revert-buffer t)
(customize-set-variable 'eshell-scroll-to-bottom-on-input 'this)
(customize-set-variable 'switch-to-buffer-in-dedicated-window 'pop)
(customize-set-variable 'switch-to-buffer-obey-display-actions t)
(customize-set-variable 'switch-to-buffer-obey-display-actions t)
(customize-set-variable 'ibuffer-old-time 24)

(keymap-global-set "<remap> <list-buffers>" #'ibuffer-list-buffers)

(unless (version< emacs-version "28")
  (repeat-mode 1))

;; Better support for files with long lines
(setq-default bidi-paragraph-direction 'left-to-right)
(setq-default bidi-inhibit-bpa t)
(global-so-long-mode 1)

;; modes

(if (fboundp 'tool-bar-mode)
    (tool-bar-mode -1))

(if (fboundp 'set-scroll-bar-mode)
    (set-scroll-bar-mode nil))

(if (fboundp 'menu-bar-mode)
    (menu-bar-mode -1))

(global-hl-line-mode +1)
(transient-mark-mode t)
(global-prettify-symbols-mode t)
(electric-indent-mode t)
(electric-quote-mode t)
(electric-pair-mode t)
(show-paren-mode t)
(cua-selection-mode t)
(winner-mode t)
(windmove-default-keybindings)

(fset 'yes-or-no-p 'y-or-n-p)

;; Don't disable narrowing commands
(put 'narrow-to-region 'disabled nil)
(put 'narrow-to-page 'disabled nil)
(put 'narrow-to-defun 'disabled nil)

;; Don't disable case-change functions
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

(setq tramp-ssh-controlmaster-options
      "-o ControlMaster=auto -o ControlPath='tramp.%%C' -o ControlPersist=no")

(global-unset-key (kbd "C-z"))

;;;; IDO

;; (setq ido-enable-prefix                         nil
;;       ido-enable-flex-matching                  t
;;       ido-everywhere                            t
;;       ido-create-new-buffer                     'always
;;       ido-use-filename-at-point                 'guess
;;       ido-max-prospects                         10
;;       ido-default-file-method                   'selected-window
;;       ido-auto-merge-work-directories-length    -1)

;; (ido-mode +1)

;; (if (version< emacs-version "28")
;;     (if (locate-library "icomplete-vertical")
;;         (icomplete-vertical-mode 1)
;;       (icomplete-mode 1))
;;   (fido-vertical-mode 1))

;; Disable startup message
(setq inhibit-startup-message t)

;; use relative line numbers
(setq display-line-numbers-type 'relative)

;; Enable line numbers
(global-display-line-numbers-mode t)

;; Highlight current line
(global-hl-line-mode t)

;; Enable syntax highlighting
(global-font-lock-mode t)

;; Set default font (change if needed)
;; (set-face-attribute 'default nil :font "JetbrainsMono Nerd Font" :height 120)

;; Better scrolling
(setq scroll-margin 8
      scroll-conservatively 100)

;; Clipboard integration (use system clipboard)
(setq select-enable-clipboard t)

;; Smooth scrolling
(pixel-scroll-precision-mode t)

;; Tab & Indentation Settings
(setq-default indent-tabs-mode nil)  ;; Use spaces instead of tabs
(setq-default tab-width 4)
(setq-default c-basic-offset 4)
(electric-indent-mode t)

;; Parenthesis Matching
(show-paren-mode 1)
(setq show-paren-delay 0)

(setq search-highlight t)
(setq query-replace-highlight t)

;; Auto-save & Backups
(setq auto-save-default t)
(setq make-backup-files t)

;; allow system clipboard
(setq select-enable-primary nil)
(setq select-enable-clipboard t)
(setq x-select-enable-primary nil)
(setq x-select-enable-clipboard t)
(setq xclip-select-enable-clipboard t)

;; Auto-refresh buffers when files change externally
(global-auto-revert-mode t)

;; Highlight trailing whitespace
(setq-default show-trailing-whitespace t)

;; Don't show startup screen
(setq initial-scratch-message nil)

;; (set-frame-parameter (selected-frame) 'alpha '(85 . 85))
;; (add-to-list 'default-frame-alist '(alpha . (85 . 85)))

(when (not (display-graphic-p))
  (custom-set-faces
   '(default ((t (:background "unspecified-bg"))))))  ;; Keep terminal transparency

(unless (display-graphic-p)
  (require 'mouse)
  (xterm-mouse-mode 1)
  ;;(global-set-key [mouse-4] (lambda () (interactive) (scroll-down 1)))
  ;;(global-set-key [mouse-5] (lambda () (interactive) (scroll-up 1)))
  )

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Ensures all use-package statements use straight.el
(setq straight-use-package-by-default t)

(straight-use-package 'use-package)  ;; Install use-package via straight.el


(use-package catppuccin-theme)
(load-theme 'catppuccin t)
(setq catppucin-flavor 'frappe)
(catppuccin-reload)

(use-package kkp
  :ensure t
  :config
  ;; macOS-style keybindings
  (global-set-key (kbd "s-c") 'kill-ring-save)   ;; ⌘ C - Copy
  (global-set-key (kbd "s-x") 'kill-region)      ;; ⌘ X - Cut
  (global-set-key (kbd "s-v") 'yank)             ;; ⌘ V - Paste
  (global-set-key (kbd "s-z") 'undo)             ;; ⌘ Z - Undo
  (global-set-key (kbd "s-a") 'mark-whole-buffer) ;; ⌘ A - Select All
  (global-set-key (kbd "s-s") 'save-buffer)      ;; ⌘ S - Save
  (global-set-key (kbd "s-w") 'kill-this-buffer) ;; ⌘ W - Close Buffer
  (global-set-key (kbd "s-q") 'save-buffers-kill-terminal) ;; ⌘Q - Quit Emacs
  (global-set-key (kbd "s-n") 'make-frame-command) ;; ⌘ N - New Window
  (global-set-key (kbd "s-t") 'tab-new)          ;; ⌘ T - New Tab (Emacs 28+)
  (global-set-key (kbd "s-o") 'find-file)        ;; ⌘ O - Open File
  (global-set-key (kbd "s-f") 'isearch-forward)  ;; ⌘ F - Search

  ;; to map the Alt keyboard modifier to Alt in Emacs (and not to Meta)
  ;; (setq kkp-alt-modifier 'alt)
  ;;(global-kkp-mode +1)
  )

(use-package diminish)

;; (use-package minions
;;   :ensure t
;;   :config
;;   (minions-mode))  ;; Groups minor modes into a single menu

(use-package no-littering
  :ensure t
  :init
  (eval-and-compile ; Ensure values don't differ at compile time.
    (setq no-littering-etc-directory
          (expand-file-name "etc/" user-emacs-directory))
    (setq no-littering-var-directory
          (expand-file-name "var/" user-emacs-directory)))
    (require 'no-littering))

(use-package xdg
  :after no-littering
  :ensure t
  :config
  ;; Set user-emacs-directory to XDG-compliant location
  (setq user-emacs-directory (expand-file-name "emacs/" (xdg-config-home)))
  (setq tmp-dir (expand-file-name "name/" user-emacs-directory))
  (setq package-user-dir (expand-file-name "elpa/" tmp-dir))
  (setq backup-directory-alist `(("." . ,(concat tmp-dir "/backups/"))))
  (setq auto-save-file-name-transforms
        `((".*" ,(concat tmp-dir "/auto-save/") t)))
  (let ((dir (no-littering-expand-var-file-name "lock-files/")))
    (make-directory dir t)
    (setq lock-file-name-transforms `((".*" ,dir t))))
  )

;; Ensure `recentf` doesn’t track temporary Emacs-generated files
(use-package recentf
  :init

  (setq recentf-max-saved-items 100
        recentf-auto-save-timer (run-with-idle-timer 600 t 'recentf-save-list)
        recentf-exclude '("/tmp/" "/ssh:"))

  :ensure t
  :config
  (setq recentf-save-file (no-littering-expand-var-file-name "recentf"))
  (add-to-list 'recentf-exclude
               (recentf-expand-file-name no-littering-var-directory))
  (add-to-list 'recentf-exclude
               (recentf-expand-file-name no-littering-etc-directory))
  (recentf-mode +1))

(when (and (fboundp 'startup-redirect-eln-cache)
           (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name  "eln-cache/" no-littering-var-directory))))

(use-package which-key
  :diminish which-key-mode

  :init
  (which-key-mode))

(use-package bind-key)

(use-package dash)
(use-package s)

(defun seartipy/font-available-p (font)
  "Check if FONT available on the system."
  (-contains? (font-family-list) font))

(defconst *seartipy-default-fonts*
  '("JetbrainsMono Nerd Font"
    "MonaspiceRn Nerd Font"
    "Jetbrains Mono"
    "Monaco"
    "Consolas"
    "Ubuntu Mono"
    "Source Code Pro"
    "mononoki"
    "Roboto Mono"
    "Fira Code"
    "Hack"
    "Dejavu Sans Mono"))

(-when-let (font (-first 'seartipy/font-available-p
                         *seartipy-default-fonts*))
  (set-frame-font (concat font " 11")))

(use-package server
  :config
  (if (not (server-running-p))
      (server-start)))

(use-package savehist
  :init
  ;; Allow commands in minibuffers
  (setq enable-recursive-minibuffers  t
        history-length                1000
        kill-ring-max                 19
        savehist-autosave-interval    60
        savehist-file (no-littering-expand-var-file-name "savehist")
        savehist-additional-variables '(mark-ring
                                        global-mark-ring
                                        kill-ring
                                        search-ring
                                        regexp-search-ring
                                        extended-command-history))

  :config
  (savehist-mode t))

(use-package saveplace
  :init
  (setq save-place-file (no-littering-expand-var-file-name "saveplace"))
  (save-place-mode 1))

(use-package restart-emacs
  :bind ("C-x M-c" . restart-emacs))

 ;; Ensure Straight does not install it
(straight-use-package 'project)

(use-package avy
  :init
  (setq avy-keys (number-sequence ?a ?z))
  (setq avy-background t)

  :config
  (avy-setup-default))

(use-package ace-window
  :bind ("C-x o" . ace-window)
  :init
  (setq aw-dispatch-always t))

(winner-mode)
(windmove-default-keybindings)

(use-package winum
  :init
  (setq winum-auto-setup-mode-line nil)

  :config
  (winum-mode))

(use-package buffer-move
  :bind (("<C-S-up>" . buf-move-up)
         ("<C-S-down>" . buf-move-down)
         ("<C-S-left>" . buf-move-left)
         ("<C-S-right>" . buf-move-right)))

(bind-key [remap just-one-space] 'cycle-spacing)
(bind-key "RET" 'newline-and-indent)

(use-package whitespace
  :diminish whitespace-mode
  :defer t

  :init
  (dolist (hook '(prog-mode-hook text-mode-hook))
    (add-hook hook #'whitespace-mode))
  (add-hook 'before-save-hook #'whitespace-cleanup)

  :config
  (setq whitespace-line-column 80) ;; limit line length
  (setq whitespace-style '(face tabs empty trailing lines-tail)))

(use-package move-dup
  :bind (("M-S-<down>" . md/move-lines-down)
         ("M-s-<down>" . md/duplicate-down)
         ("M-s-<up>" . md/duplicate-up)
         ("M-S-<up>" . md/move-lines-up)))

(use-package easy-kill
  :defer t

  :init
  (global-set-key [remap kill-ring-save] 'easy-kill)
  (global-set-key [remap mark-sexp] 'easy-mark))

(use-package expand-region
  :bind (("C-=" . er/expand-region)
         ("C-c =" . er/expand-region)))

(use-package multiple-cursors
  :bind (("C-c C-c" . mc/edit-lines)
         ("C-c C-e" . mc/edit-ends-of-lines)
         ("C-c C-a" . mc/edit-beginnings-of-lines)
         ("C-c >" . mc/mark-next-like-this)
         ("C-c <" . mc/mark-previous-like-this)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)))

(use-package goto-chg
  :bind(
        ("C-." . goto-last-change)
        ("C-," . goto-last-change-reverse)
        ("C-c ." . goto-last-change)
        ("C-c ," . goto-last-change-reverse)))

(use-package undo-fu
  :straight t
  :bind (("C-." . undo-fu-only-undo)   ;; Jump to last change (backward)
         ("C-," . undo-fu-only-redo)   ;; Jump to newer change (forward)
         ("C-c ." . undo-fu-only-undo)
         ("C-c ," . undo-fu-only-redo)))

(use-package undo-fu-session
  :straight t
  :config
  (undo-fu-session-global-mode))

(global-set-key (kbd "C-c u") 'undo-fu-only-undo)
(global-set-key (kbd "C-c r") 'undo-fu-only-redo)

(use-package wgrep)

;; ;; macOS-style redo
;; (when (fboundp 'undo-redo)
;;   (global-set-key (kbd "s-Z") 'undo-redo)) ;; ⌘⇧Z - Redo (Emacs 28+)

(use-package iedit
  :straight t)

(use-package zop-to-char
  :bind (("M-z" . zop-up-to-char)
         ("M-Z" . zop-to-char)))

(use-package super-save
  :diminish super-save-mode

  :config
  (super-save-mode +1))

(use-package ediff
  :defer t
  :init
  (setq  ediff-window-setup-function 'ediff-setup-windows-plain
         ediff-split-window-function 'split-window-horizontally
         ediff-merge-split-window-function 'split-window-horizontally))

(use-package diff-hl
  :init
  (add-hook 'dired-mode-hook 'diff-hl-dired-mode)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  :config
  (global-diff-hl-mode +1))

(use-package drag-stuff
  :init
  (drag-stuff-global-mode 1)
  (drag-stuff-define-keys))

(use-package nerd-icons
  ;; :custom
  ;; The Nerd Font you want to use in GUI
  ;; "Symbols Nerd Font Mono" is the default and is recommended
  ;; but you can use any other Nerd Font if you want
  ;; (nerd-icons-font-family "Symbols Nerd Font Mono")
  )

(use-package sudo-edit)
(use-package tldr)

(use-package rainbow-mode
  :diminish
  :hook org-mode prog-mode)

(use-package rainbow-delimiters
  :hook ((emacs-lisp-mode . rainbow-delimiters-mode)
         (clojure-mode . rainbow-delimiters-mode)))


(use-package neotree
  :init
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow))
  :config
  (setq neo-smart-open t
        neo-show-hidden-files t
        neo-window-width 55
        neo-window-fixed-size nil
        inhibit-compacting-font-caches t
        projectile-switch-project-action 'neotree-projectile-action)
        ;; truncate long file names in neotree
        (add-hook 'neo-after-create-hook
           #'(lambda (_)
               (with-current-buffer (get-buffer neo-buffer-name)
                 (setq truncate-lines t)
                 (setq word-wrap nil)
                 (make-local-variable 'auto-hscroll-mode)
                 (setq auto-hscroll-mode nil)))))

(use-package yasnippet
  :diminish yas-minor-mode
  :defer t

  :init
  (add-hook 'prog-mode-hook #'yas-minor-mode)

  :config
  (yas-reload-all))

(use-package eldoc
  :diminish eldoc-mode
  :defer t

  :init
  (add-hook 'eval-expression-minibuffer-setup-hook #'eldoc-mode)
  (add-hook 'ielm-mode-hook #'eldoc-mode)
  (add-hook 'emacs-lisp-mode-hook #'eldoc-mode))

(use-package exec-path-from-shell
  :config
  (custom-set-variables '(exec-path-from-shell-check-startup-files nil))
  (exec-path-from-shell-initialize)
  (dolist (var '("SSH_AUTH_SOCK" "SSH_AGENT_PID" "GPG_AGENT_INFO"
                 "PATH" "PYTHONPATH" "GOPATH" "GOROOT" "GOBIN"
                 "GO111MODULE" "GOMODCACHE" "GOCACHE"
                 "LANG" "LC_CTYPE" "JAVA_HOME" "JDK_HOME"))
    (add-to-list 'exec-path-from-shell-variables var)))


(use-package flycheck
  :ensure t
  :defer t
  :diminish
  :init (global-flycheck-mode))

(use-package vterm
:config
(setq shell-file-name "/bin/bash"
      vterm-max-scrollback 5000))

(defun my/project-vterm ()
  "Open a vterm in the project root."
  (interactive)
  (let ((default-directory (project-root (project-current t))))
    (vterm)))

(global-set-key (kbd "C-x p v") #'my/project-vterm)

(use-package vterm-toggle
  :config
  (global-set-key [f2] 'vterm-toggle)
  (global-set-key [C-f2] 'vterm-toggle-cd)

  ;; you can cd to the directory where your previous buffer file exists
  ;; after you have toggle to the vterm buffer with `vterm-toggle'.
  (define-key vterm-mode-map [(control return)]   #'vterm-toggle-insert-cd)

                                        ;Switch to next vterm buffer
  (define-key vterm-mode-map (kbd "s-n")   'vterm-toggle-forward)
                                        ;Switch to previous vterm buffer
  (define-key vterm-mode-map (kbd "s-p")   'vterm-toggle-backward))

(use-package nerd-icons
  ;; :custom
  ;; The Nerd Font you want to use in GUI
  ;; "Symbols Nerd Font Mono" is the default and is recommended
  ;; but you can use any other Nerd Font if you want
  ;; (nerd-icons-font-family "Symbols Nerd Font Mono")
  )

(use-package sudo-edit)
(use-package tldr)

(use-package project
  :ensure nil
  :bind (("C-x p f" . project-find-file)
         ("C-x p p" . project-switch-project)
         ("C-x p g" . project-find-regexp)
         ("C-x p r" . project-query-replace-regexp)
         ("C-x p e" . project-eshell)
         ("C-x p s" . project-shell)
         ("C-x p c" . project-compile))
  :config
  (setq project-switch-commands
        '((project-find-file "Find file")
          (magit-project-status "Magit" ?m)
          (project-eshell "Eshell" ?e)
          (project-shell "Shell" ?s)
          (project-compile "Compile" ?c)
          (project-find-regexp "Grep" ?g))))

(defun my/kill-project-buffers ()
  "Kill all buffers associated with the current project."
  (interactive)
  (when-let ((project (project-current)))
    (mapc #'kill-buffer (project-buffers project))
    (message "Killed all project buffers.")))

(global-set-key (kbd "C-x p k") #'my/kill-project-buffers)

(use-package rainbow-mode
  :diminish
  :hook org-mode prog-mode)

(use-package rainbow-delimiters
  :hook ((emacs-lisp-mode . rainbow-delimiters-mode)
         (clojure-mode . rainbow-delimiters-mode)))


(use-package neotree
  :config
  (setq neo-smart-open t
        neo-show-hidden-files t
        neo-window-width 55
        neo-window-fixed-size nil
        inhibit-compacting-font-caches t
        projectile-switch-project-action 'neotree-projectile-action)
        ;; truncate long file names in neotree
        (add-hook 'neo-after-create-hook
           #'(lambda (_)
               (with-current-buffer (get-buffer neo-buffer-name)
                 (setq truncate-lines t)
                 (setq word-wrap nil)
                 (make-local-variable 'auto-hscroll-mode)
                 (setq auto-hscroll-mode nil)))))

(use-package vertico
  :init
  (vertico-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

(use-package combobulate
  :hook ((python-mode rust-mode c++-mode c-mode yaml-mode toml-mode json-mode) . combobulate-mode))

;; Example configuration for Consult
(use-package consult
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
)

(use-package embark
  :ensure t

  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :ensure t ; only need to install it, embark loads it after consult if found
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package corfu
  ;; Optional customizations
  ;; :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches

  ;; Enable Corfu only for certain modes. See also `global-corfu-modes'.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :init
  (global-corfu-mode))

;; ;; A few more useful configurations...
;; (use-package emacs
;;   :custom
;;   ;; TAB cycle if there are only few candidates
;;   ;; (completion-cycle-threshold 3)

;;   ;; Enable indentation+completion using the TAB key.
;;   ;; `completion-at-point' is often bound to M-TAB.
;;   (tab-always-indent 'complete)

;;   ;; Emacs 30 and newer: Disable Ispell completion function.
;;   ;; Try `cape-dict' as an alternative.
;;   (text-mode-ispell-word-completion nil)

;;   ;; Hide commands in M-x which do not apply to the current mode.  Corfu
;;   ;; commands are hidden, since they are not used via M-x. This setting is
;;   ;; useful beyond Corfu.
;;   (read-extended-command-predicate #'command-completion-default-include-p))

;; Use Dabbrev with Corfu!
(use-package dabbrev
  ;; Swap M-/ and C-M-/
  :bind (("M-/" . dabbrev-completion)
          ;; Bind prefix keymap providing all Cape commands under a mnemonic key.
         ;; Press C-c p ? to for help.
         ;; ("C-c p" . cape-prefix-map) ;; Alternative key: M-<tab>, M-p, M-+
         ;; Alternatively bind Cape commands individually.
         ;; :bind (("C-c p d" . cape-dabbrev)
  ;;        ("C-c p h" . cape-history)
  ;;        ("C-c p f" . cape-file)
         ("C-M-/" . dabbrev-expand))
  :config
  (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
  ;; Since 29.1, use `dabbrev-ignored-buffer-regexps' on older.
  (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'tags-table-mode))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'cape-symbol))

(use-package apheleia
  :ensure t
  :config
  (straight-use-package 'apheleia))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

;; (use-package dirvish
;;   :init (dirvish-override-dired-mode))

(use-package tabspaces
  :hook (after-init . tabspaces-mode)
  :custom
  (tabspaces-keymap-prefix "C-c t")
  (tabspaces-use-filtered-buffers-as-default t)  ;; Only show buffers from the current workspace
  (tabspaces-default-tab "Default")             ;; Start in a default tab
  (tabspaces-remove-to-default t))

(with-eval-after-load 'dired
  (require 'dired-x)
  (setq dired-guess-shell-alist-user '(("gif" . "imv")
                                ("jpg" . "imv")
                                ("png" . "imv")
                                ("mkv" . "mpv")
                                ("mp4" . "mpv"))))

(setq image-dired-thumb-size 128)  ;; Set thumbnail size
(with-eval-after-load 'dired
  (require 'image-dired))

(use-package consult-todo
  :after consult
  :bind (("C-c t" . consult-todo)))  ;; Bind `C-c t` to search for TODOs

(use-package magit-todos
  :after magit
  :hook (magit-mode . magit-todos-mode)
  :config
  (setq magit-todos-keywords '("TODO" "FIXME" "HACK" "BUG" "REVIEW" "OPTIMIZE"))
  (setq magit-todos-depth 3)   ;; Search subdirectories up to depth 3
  (setq magit-todos-exclude-globs '("node_modules" "vendor" "dist"))  ;; Ignore these directories
  (setq magit-todos-group-by 'default))  ;; Group TODOs normally

(use-package mood-line
  :config
  (mood-line-mode)) ;; Automatically hides unnecessary mode-line info

(use-package eglot
  :hook ((prog-mode . eglot-ensure)
         (python-mode . eglot-ensure)
         (c++-mode . eglot-ensure)
         (rust-mode . eglot-ensure)
         (go-mode . eglot-ensure)
         (sh-mode . eglot-ensure))  ;; Covers Bash & Zsh
  :config
  (add-hook 'dired-mode-hook 'eglot-ensure)
  (setq eglot-autoshutdown t)  ;; Shut down servers when not in use
  (setq eglot-sync-connect nil) ;; Non-blocking startup
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)
  (setq eglot-send-changes-idle-time 0.5)) ;; Reduce latency

(use-package consult-eglot
  :ensure t
  :after (eglot consult)
  :bind (("C-c g" . consult-eglot-symbols)))

(use-package treesit-auto
  :config
  (global-treesit-auto-mode))
(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; (use-package company
;;   :defer 2
;;   :diminish
;;   :custom
;;   (company-begin-commands '(self-insert-command))
;;   (company-idle-delay .1)
;;   (company-minimum-prefix-length 2)
;;   (company-show-numbers t)
;;   (company-tooltip-align-annotations 't)
;;   (global-company-mode t))

;; (use-package company-box
;;   :after company
;;   :diminish
;;   :hook (company-mode . company-box-mode))

;; (use-package dashboard
;;   :ensure t
;;   :init
;;   (setq initial-buffer-choice 'dashboard-open)
;;   (setq dashboard-set-heading-icons t)
;;   (setq dashboard-set-file-icons t)
;;   (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
;;   (setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
;;   (setq dashboard-center-content nil) ;; set to 't' for centered content
;;   (setq dashboard-items '((recents . 5)
;;                           (agenda . 5 )
;;                           (bookmarks . 3)
;;                           (projects . 3)))
;;   :custom
;;   (dashboard-modify-heading-icons '((recents . "file-text")
;; 				      (bookmarks . "book")))
;;   :config
;;   (dashboard-setup-startup-hook))

;; (use-package imenu
;;   :demand t
;;   :bind(("M-i" . imenu)))

;; (use-package imenu-anywhere
;;   :bind(("M-I" . imenu-anywhere)))

;; ;; Expands to: (elpaca evil (use-package evil :demand t))
;; (use-package evil
;;     :init      ;; tweak evil's configuration before loading it
;;     (setq evil-want-integration t  ;; This is optional since it's already set to t by default.
;;           evil-want-keybinding nil
;;           evil-vsplit-window-right t
;;           evil-split-window-below t
;;           evil-undo-system 'undo-redo)  ;; Adds vim-like C-r redo functionality
;;     (evil-mode))

;; (use-package evil-collection
;;   :after evil
;;   :config
;;   ;; Do not uncomment this unless you want to specify each and every mode
;;   ;; that evil-collection should works with.  The following line is here
;;   ;; for documentation purposes in case you need it.
;;   ;; (setq evil-collection-mode-list '(calendar dashboard dired ediff info magit ibuffer))
;;   (add-to-list 'evil-collection-mode-list 'help) ;; evilify help mode
;;   (evil-collection-init))

;; (use-package evil-tutor)

;; ;; Using RETURN to follow links in Org/Evil
;; ;; Unmap keys in 'evil-maps if not done, (setq org-return-follows-link t) will not work
;; (with-eval-after-load 'evil-maps
;;   (define-key evil-motion-state-map (kbd "SPC") nil)
;;   (define-key evil-motion-state-map (kbd "RET") nil)
;;   (define-key evil-motion-state-map (kbd "TAB") nil))
;; ;; Setting RETURN key in org-mode to follow links
;;   (setq org-return-follows-link  t)

;; (use-package all-the-icons
;;   :ensure t
;;   :if (display-graphic-p))

;; (use-package all-the-icons-dired
;;   :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

;; (use-package git-timemachine
;;   :after git-timemachine
;;   :hook (evil-normalize-keymaps . git-timemachine-hook)
;;   :config
;;     (evil-define-key 'normal git-timemachine-mode-map (kbd "C-j") 'git-timemachine-show-previous-revision)
;;     (evil-define-key 'normal git-timemachine-mode-map (kbd "C-k") 'git-timemachine-show-next-revision)
;; )

;; (use-package hl-todo
;;   :hook ((org-mode . hl-todo-mode)
;;          (prog-mode . hl-todo-mode))
;;   :config
;;   (setq hl-todo-highlight-punctuation ":"
;;         hl-todo-keyword-faces
;;         `(("TODO"       warning bold)
;;           ("FIXME"      error bold)
;;           ("HACK"       font-lock-constant-face bold)
;;           ("REVIEW"     font-lock-keyword-face bold)
;;           ("NOTE"       success bold)
;;           ("DEPRECATED" font-lock-doc-face bold))))

;; (global-set-key [escape] 'keyboard-escape-quit)

;; (use-package general
;;   :config
;;   (general-evil-setup)

;;   ;; set up 'SPC' as the global leader key
;;   (general-create-definer dt/leader-keys
;;     :states '(normal insert visual emacs)
;;     :keymaps 'override
;;     :prefix "SPC" ;; set leader
;;     :global-prefix "M-SPC") ;; access leader in insert mode

;;   (dt/leader-keys
;;     "SPC" '(counsel-M-x :wk "Counsel M-x")
;;     "." '(find-file :wk "Find file")
;;     "=" '(perspective-map :wk "Perspective") ;; Lists all the perspective keybindings
;;     "TAB TAB" '(comment-line :wk "Comment lines")
;;     "u" '(universal-argument :wk "Universal argument"))

;;    (dt/leader-keys
;;     "a" '(:ignore t :wk "A.I.")
;;     "a a" '(ellama-ask-about :wk "Ask ellama about region")
;;     "a e" '(:ignore t :wk "Ellama enhance")
;;     "a e g" '(ellama-improve-grammar :wk "Ellama enhance wording")
;;     "a e w" '(ellama-improve-wording :wk "Ellama enhance grammar")
;;     "a i" '(ellama-chat :wk "Ask ellama")
;;     "a p" '(ellama-provider-select :wk "Ellama provider select")
;;     "a s" '(ellama-summarize :wk "Ellama summarize region")
;;     "a t" '(ellama-translate :wk "Ellama translate region"))

;;   (dt/leader-keys
;;     "b" '(:ignore t :wk "Bookmarks/Buffers")
;;     "b b" '(switch-to-buffer :wk "Switch to buffer")
;;     "b c" '(clone-indirect-buffer :wk "Create indirect buffer copy in a split")
;;     "b C" '(clone-indirect-buffer-other-window :wk "Clone indirect buffer in new window")
;;     "b d" '(bookmark-delete :wk "Delete bookmark")
;;     "b i" '(ibuffer :wk "Ibuffer")
;;     "b k" '(kill-current-buffer :wk "Kill current buffer")
;;     "b K" '(kill-some-buffers :wk "Kill multiple buffers")
;;     "b l" '(list-bookmarks :wk "List bookmarks")
;;     "b m" '(bookmark-set :wk "Set bookmark")
;;     "b n" '(next-buffer :wk "Next buffer")
;;     "b p" '(previous-buffer :wk "Previous buffer")
;;     "b r" '(revert-buffer :wk "Reload buffer")
;;     "b R" '(rename-buffer :wk "Rename buffer")
;;     "b s" '(basic-save-buffer :wk "Save buffer")
;;     "b S" '(save-some-buffers :wk "Save multiple buffers")
;;     "b w" '(bookmark-save :wk "Save current bookmarks to bookmark file"))

;;   (dt/leader-keys
;;     "d" '(:ignore t :wk "Dired")
;;     "d d" '(dired :wk "Open dired")
;;     "d f" '(wdired-finish-edit :wk "Writable dired finish edit")
;;     "d j" '(dired-jump :wk "Dired jump to current")
;;     "d n" '(neotree-dir :wk "Open directory in neotree")
;;     "d p" '(peep-dired :wk "Peep-dired")
;;     "d w" '(wdired-change-to-wdired-mode :wk "Writable dired"))

;;   (dt/leader-keys
;;     "e" '(:ignore t :wk "Ediff/Eshell/Eval/EWW")
;;     "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
;;     "e d" '(eval-defun :wk "Evaluate defun containing or after point")
;;     "e e" '(eval-expression :wk "Evaluate and elisp expression")
;;     "e f" '(ediff-files :wk "Run ediff on a pair of files")
;;     "e F" '(ediff-files3 :wk "Run ediff on three files")
;;     "e h" '(counsel-esh-history :which-key "Eshell history")
;;     "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
;;     "e n" '(eshell-new :wk "Create new eshell buffer")
;;     "e r" '(eval-region :wk "Evaluate elisp in region")
;;     "e R" '(eww-reload :which-key "Reload current page in EWW")
;;     "e s" '(eshell :which-key "Eshell")
;;     "e w" '(eww :which-key "EWW emacs web wowser"))

;;   (dt/leader-keys
;;     "f" '(:ignore t :wk "Files")
;;     "f c" '((lambda () (interactive)
;;               (find-file "~/.config/emacs/config.org"))
;;             :wk "Open emacs config.org")
;;     "f e" '((lambda () (interactive)
;;               (dired "~/.config/emacs/"))
;;             :wk "Open user-emacs-directory in dired")
;;     "f d" '(find-grep-dired :wk "Search for string in files in DIR")
;;     "f g" '(counsel-grep-or-swiper :wk "Search for string current file")
;;     "f i" '((lambda () (interactive)
;;               (find-file "~/.config/emacs/init.el"))
;;             :wk "Open emacs init.el")
;;     "f j" '(counsel-file-jump :wk "Jump to a file below current directory")
;;     "f l" '(counsel-locate :wk "Locate a file")
;;     "f r" '(counsel-recentf :wk "Find recent files")
;;     "f u" '(sudo-edit-find-file :wk "Sudo find file")
;;     "f U" '(sudo-edit :wk "Sudo edit file"))

;;   (dt/leader-keys
;;     "g" '(:ignore t :wk "Git")
;;     "g /" '(magit-displatch :wk "Magit dispatch")
;;     "g ." '(magit-file-displatch :wk "Magit file dispatch")
;;     "g b" '(magit-branch-checkout :wk "Switch branch")
;;     "g c" '(:ignore t :wk "Create")
;;     "g c b" '(magit-branch-and-checkout :wk "Create branch and checkout")
;;     "g c c" '(magit-commit-create :wk "Create commit")
;;     "g c f" '(magit-commit-fixup :wk "Create fixup commit")
;;     "g C" '(magit-clone :wk "Clone repo")
;;     "g f" '(:ignore t :wk "Find")
;;     "g f c" '(magit-show-commit :wk "Show commit")
;;     "g f f" '(magit-find-file :wk "Magit find file")
;;     "g f g" '(magit-find-git-config-file :wk "Find gitconfig file")
;;     "g F" '(magit-fetch :wk "Git fetch")
;;     "g g" '(magit-status :wk "Magit status")
;;     "g i" '(magit-init :wk "Initialize git repo")
;;     "g l" '(magit-log-buffer-file :wk "Magit buffer log")
;;     "g r" '(vc-revert :wk "Git revert file")
;;     "g s" '(magit-stage-file :wk "Git stage file")
;;     "g t" '(git-timemachine :wk "Git time machine")
;;     "g u" '(magit-stage-file :wk "Git unstage file"))

;;  (dt/leader-keys
;;     "h" '(:ignore t :wk "Help")
;;     "h a" '(counsel-apropos :wk "Apropos")
;;     "h b" '(describe-bindings :wk "Describe bindings")
;;     "h c" '(describe-char :wk "Describe character under cursor")
;;     "h d" '(:ignore t :wk "Emacs documentation")
;;     "h d a" '(about-emacs :wk "About Emacs")
;;     "h d d" '(view-emacs-debugging :wk "View Emacs debugging")
;;     "h d f" '(view-emacs-FAQ :wk "View Emacs FAQ")
;;     "h d m" '(info-emacs-manual :wk "The Emacs manual")
;;     "h d n" '(view-emacs-news :wk "View Emacs news")
;;     "h d o" '(describe-distribution :wk "How to obtain Emacs")
;;     "h d p" '(view-emacs-problems :wk "View Emacs problems")
;;     "h d t" '(view-emacs-todo :wk "View Emacs todo")
;;     "h d w" '(describe-no-warranty :wk "Describe no warranty")
;;     "h e" '(view-echo-area-messages :wk "View echo area messages")
;;     "h f" '(describe-function :wk "Describe function")
;;     "h F" '(describe-face :wk "Describe face")
;;     "h g" '(describe-gnu-project :wk "Describe GNU Project")
;;     "h i" '(info :wk "Info")
;;     "h I" '(describe-input-method :wk "Describe input method")
;;     "h k" '(describe-key :wk "Describe key")
;;     "h l" '(view-lossage :wk "Display recent keystrokes and the commands run")
;;     "h L" '(describe-language-environment :wk "Describe language environment")
;;     "h m" '(describe-mode :wk "Describe mode")
;;     "h r" '(:ignore t :wk "Reload")
;;     "h r r" '((lambda () (interactive)
;;                 (load-file "~/.config/emacs/init.el")
;;                 (ignore (elpaca-process-queues)))
;;               :wk "Reload emacs config")
;;     "h t" '(load-theme :wk "Load theme")
;;     "h v" '(describe-variable :wk "Describe variable")
;;     "h w" '(where-is :wk "Prints keybinding for command if set")
;;     "h x" '(describe-command :wk "Display full documentation for command"))

;;   (dt/leader-keys
;;     "m" '(:ignore t :wk "Org")
;;     "m a" '(org-agenda :wk "Org agenda")
;;     "m e" '(org-export-dispatch :wk "Org export dispatch")
;;     "m i" '(org-toggle-item :wk "Org toggle item")
;;     "m t" '(org-todo :wk "Org todo")
;;     "m B" '(org-babel-tangle :wk "Org babel tangle")
;;     "m T" '(org-todo-list :wk "Org todo list"))

;;   (dt/leader-keys
;;     "m b" '(:ignore t :wk "Tables")
;;     "m b -" '(org-table-insert-hline :wk "Insert hline in table"))

;;   (dt/leader-keys
;;     "m d" '(:ignore t :wk "Date/deadline")
;;     "m d t" '(org-time-stamp :wk "Org time stamp"))

;;   (dt/leader-keys
;;     "o" '(:ignore t :wk "Open")
;;     "o d" '(dashboard-open :wk "Dashboard")
;;     "o e" '(elfeed :wk "Elfeed RSS")
;;     "o f" '(make-frame :wk "Open buffer in new frame")
;;     "o F" '(select-frame-by-name :wk "Select frame by name"))

;;   ;; projectile-command-map already has a ton of bindings
;;   ;; set for us, so no need to specify each individually.
;;   (dt/leader-keys
;;     "p" '(projectile-command-map :wk "Projectile"))

;;   (dt/leader-keys
;;     "r" '(:ignore t :wk "Radio")
;;     "r p" '(eradio-play :wk "Eradio play")
;;     "r s" '(eradio-stop :wk "Eradio stop")
;;     "r t" '(eradio-toggle :wk "Eradio toggle"))


;;   (dt/leader-keys
;;     "s" '(:ignore t :wk "Search")
;;     "s d" '(dictionary-search :wk "Search dictionary")
;;     "s m" '(man :wk "Man pages")
;;     "s o" '(pdf-occur :wk "Pdf search lines matching STRING")
;;     "s t" '(tldr :wk "Lookup TLDR docs for a command")
;;     "s w" '(woman :wk "Similar to man but doesn't require man"))

;;   (dt/leader-keys
;;     "t" '(:ignore t :wk "Toggle")
;;     "t e" '(eshell-toggle :wk "Toggle eshell")
;;     "t f" '(flycheck-mode :wk "Toggle flycheck")
;;     "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
;;     "t n" '(neotree-toggle :wk "Toggle neotree file viewer")
;;     "t o" '(org-mode :wk "Toggle org mode")
;;     "t r" '(rainbow-mode :wk "Toggle rainbow mode")
;;     "t t" '(visual-line-mode :wk "Toggle truncated lines")
;;     "t v" '(vterm-toggle :wk "Toggle vterm"))

;;   (dt/leader-keys
;;     "w" '(:ignore t :wk "Windows/Words")
;;     ;; Window splits
;;     "w c" '(evil-window-delete :wk "Close window")
;;     "w n" '(evil-window-new :wk "New window")
;;     "w s" '(evil-window-split :wk "Horizontal split window")
;;     "w v" '(evil-window-vsplit :wk "Vertical split window")
;;     ;; Window motions
;;     "w h" '(evil-window-left :wk "Window left")
;;     "w j" '(evil-window-down :wk "Window down")
;;     "w k" '(evil-window-up :wk "Window up")
;;     "w l" '(evil-window-right :wk "Window right")
;;     "w w" '(evil-window-next :wk "Goto next window")
;;     ;; Move Windows
;;     "w H" '(buf-move-left :wk "Buffer move left")
;;     "w J" '(buf-move-down :wk "Buffer move down")
;;     "w K" '(buf-move-up :wk "Buffer move up")
;;     "w L" '(buf-move-right :wk "Buffer move right")
;;     ;; Words
;;     "w d" '(downcase-word :wk "Downcase word")
;;     "w u" '(upcase-word :wk "Upcase word")
;;     "w =" '(count-words :wk "Count words/lines for buffer"))
;; )

;; (global-set-key (kbd "C-=") 'text-scale-increase)
;; (global-set-key (kbd "C--") 'text-scale-decrease)
;; (global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
;; (global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

;; (use-package doom-themes
;;   :ensure t
;;   :config
;;   ;; Global settings (defaults)
;;   (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
;;         doom-themes-enable-italic t) ; if nil, italics is universally disabled
;;    (load-theme 'doom-one t)

;;   ;; Enable flashing mode-line on errors
;;   (doom-themes-visual-bell-config)

;;   (doom-themes-neotree-config)
;;   ;; Corrects (and improves) org-mode's native fontification.
;;   (doom-themes-org-config))

;; (use-package doom-modeline
;;   :ensure t
;;   :init (doom-modeline-mode 1)
;;   :config
;;   (setq doom-modeline-major-mode-icon t))

;; (use-package neotree
;;   :config
;;   (setq neo-smart-open t
;;         neo-show-hidden-files t
;;         neo-window-width 55
;;         neo-window-fixed-size nil
;;         inhibit-compacting-font-caches t
;;         projectile-switch-project-action 'neotree-projectile-action)
;;         ;; truncate long file names in neotree
;;         (add-hook 'neo-after-create-hook
;;            #'(lambda (_)
;;                (with-current-buffer (get-buffer neo-buffer-name)
;;                  (setq truncate-lines t)
;;                  (setq word-wrap nil)
;;                  (make-local-variable 'auto-hscroll-mode)
;;                  (setq auto-hscroll-mode nil)))))

;; (use-package company
;;   :defer 2
;;   :diminish
;;   :custom
;;   (company-begin-commands '(self-insert-command))
;;   (company-idle-delay .1)
;;   (company-minimum-prefix-length 2)
;;   (company-show-numbers t)
;;   (company-tooltip-align-annotations 't)
;;   (global-company-mode t))

;; (use-package company-box
;;   :after company
;;   :diminish
;;   :hook (company-mode . company-box-mode))

(provide 'init)

;;; init.el ends here
