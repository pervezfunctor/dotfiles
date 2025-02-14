;;; emacs configuration

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

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
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
(set-face-attribute 'default nil :font "JetbrainsMono Nerd Font" :height 120)

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


;; (custom-set-faces
;;  '(default ((t (:background "unspecified-bg")))))  ;; Keep terminal transparency


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

(setq straight-use-package-by-default t)  ;; Ensures all use-package statements use straight.el

(straight-use-package 'use-package)  ;; Install use-package via straight.el


;; (use-package catppuccin-theme)
;; (load-theme 'catppuccin t)

;; (use-package xdg
;;   :config
;;   (setq user-emacs-directory (xdg-config-home "emacs/"))
;;   (setq package-user-dir (xdg-data-home "emacs/elpa/"))
;;   (setq backup-directory-alist `(("." . ,(xdg-cache-home "emacs/backups/"))))
;;   (setq auto-save-file-name-transforms `((".*" ,(xdg-cache-home "emacs/auto-save/") t))))

(use-package diminish)


;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

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
  (set-frame-font (concat font " 13")))

(use-package server
  :config
  (if (not (server-running-p))
      (server-start)))

(use-package savehist
  :init
  (setq enable-recursive-minibuffers  t    ; Allow commands in minibuffers
        history-length                1000
        kill-ring-max                 19
        savehist-autosave-interval    60
        savehist-additional-variables '(mark-ring
                                        global-mark-ring
                                        kill-ring
                                        search-ring
                                        regexp-search-ring
                                        extended-command-history))

  :config
  (savehist-mode t))

(setq save-place-file "~/.emacs.d/saved-places")
(save-place-mode 1)

(use-package recentf
  :init
  (setq recentf-max-saved-items 100
        recentf-auto-save-timer (run-with-idle-timer 600 t 'recentf-save-list)
        recentf-exclude '("/tmp/" "/ssh:"))

  :config
  (add-to-list 'recentf-exclude
               (file-truename (concat user-emacs-directory "elpa/")))

  (recentf-mode +1))

;; (use-package consult
;;   :bind
;;   (("C-s" . consult-line)  ;; Search in buffer (like Telescope live_grep)
;;    ("C-x b" . consult-buffer)  ;; Switch buffers (like Telescope buffers)
;;    ("M-y" . consult-yank-pop)  ;; Search kill-ring
;;    ("M-g g" . consult-goto-line)  ;; Jump to line
;;    ("C-x C-r" . consult-recent-file)  ;; Open recent files
;;    ("M-g f" . consult-find)  ;; Fuzzy find files
;;    ("M-g r" . consult-ripgrep)))  ;; Project-wide search

;; (use-package fzf
;;   :bind
;;     ;; Don't forget to set keybinds!
;;   :config
;;   (setq fzf/args "-x --color bw --print-query --margin=1,0 --no-hscroll"
;;         fzf/executable "fzf"
;;         fzf/git-grep-args "-i --line-number %s"
;;         ;; command used for `fzf-grep-*` functions
;;         ;; example usage for ripgrep:
;;         ;; fzf/grep-command "rg --no-heading -nH"
;;         fzf/grep-command "grep -nrH"
;;         ;; If nil, the fzf buffer will appear at the top of the window
;;         fzf/position-bottom t
;;         fzf/window-height 15))

(use-package vertico
  :init
  (vertico-mode))

;; (use-package dirvish
;;   :init (dirvish-override-dired-mode))

;; (use-package marginalia
;;   :after vertico
;;   :init
;;   (marginalia-mode))

;; (use-package orderless
;;   :init
;;   (setq completion-styles '(orderless basic)))

;; (use-package ivy
;;   :bind
;;   ;; ivy-resume resumes the last Ivy-based completion.
;;   (("C-c C-r" . ivy-resume)
;;    ("C-x B" . ivy-switch-buffer-other-window)
;;    ("C-'" . avy-goto-char-2)
;;    ("C-c '" . avy-goto-char-2)
;;    ("M-'" . avy-goto-word-or-subword-1))

;;   :diminish
;;   :custom
;;   (setq
;;         enable-recursive-minibuffers t
;;         ivy-use-virtual-buffers t
;;         ivy-use-selectable-prompt t
;;         ivy-count-format "(%d/%d) ")

;;   :config
;;   ;; Use C-j for immediate termination with the current value, and RET
;;   ;; for continuing completion for that directory. This is the ido behaviour.
;;   (define-key ivy-minibuffer-map (kbd "C-j") #'ivy-immediate-done)
;;   (define-key ivy-minibuffer-map (kbd "RET") #'ivy-alt-done)
;;   (ivy-mode))

;; (use-package counsel
;;   :after ivy
;;   :diminish
;;   :config
;;     (counsel-mode)
;;     (setq ivy-initial-inputs-alist nil)) ;; removes starting ^ regex in M-x

;; ;; Example configuration for Consult
;; (use-package consult
;;   ;; Replace bindings. Lazily loaded by `use-package'.
;;   :bind (;; C-c bindings in `mode-specific-map'
;;          ("C-c M-x" . consult-mode-command)
;;          ("C-c h" . consult-history)
;;          ("C-c k" . consult-kmacro)
;;          ("C-c m" . consult-man)
;;          ("C-c i" . consult-info)
;;          ([remap Info-search] . consult-info)
;;          ;; C-x bindings in `ctl-x-map'
;;          ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
;;          ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
;;          ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
;;          ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
;;          ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
;;          ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
;;          ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
;;          ;; Custom M-# bindings for fast register access
;;          ("M-#" . consult-register-load)
;;          ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
;;          ("C-M-#" . consult-register)
;;          ;; Other custom bindings
;;          ("M-y" . consult-yank-pop)                ;; orig. yank-pop
;;          ;; M-g bindings in `goto-map'
;;          ("M-g e" . consult-compile-error)
;;          ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
;;          ("M-g g" . consult-goto-line)             ;; orig. goto-line
;;          ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
;;          ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
;;          ("M-g m" . consult-mark)
;;          ("M-g k" . consult-global-mark)
;;          ("M-g i" . consult-imenu)
;;          ("M-g I" . consult-imenu-multi)
;;          ;; M-s bindings in `search-map'
;;          ("M-s d" . consult-find)                  ;; Alternative: consult-fd
;;          ("M-s c" . consult-locate)
;;          ("M-s g" . consult-grep)
;;          ("M-s G" . consult-git-grep)
;;          ("M-s r" . consult-ripgrep)
;;          ("M-s l" . consult-line)
;;          ("M-s L" . consult-line-multi)
;;          ("M-s k" . consult-keep-lines)
;;          ("M-s u" . consult-focus-lines)
;;          ;; Isearch integration
;;          ("M-s e" . consult-isearch-history)
;;          :map isearch-mode-map
;;          ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
;;          ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
;;          ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
;;          ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
;;          ;; Minibuffer history
;;          :map minibuffer-local-map
;;          ("M-s" . consult-history)                 ;; orig. next-matching-history-element
;;          ("M-r" . consult-history))                ;; orig. previous-matching-history-element

;;   ;; Enable automatic preview at point in the *Completions* buffer. This is
;;   ;; relevant when you use the default completion UI.
;;   :hook (completion-list-mode . consult-preview-at-point-mode)

;;   ;; The :init configuration is always executed (Not lazy)
;;   :init

;;   ;; Tweak the register preview for `consult-register-load',
;;   ;; `consult-register-store' and the built-in commands.  This improves the
;;   ;; register formatting, adds thin separator lines, register sorting and hides
;;   ;; the window mode line.
;;   (advice-add #'register-preview :override #'consult-register-window)
;;   (setq register-preview-delay 0.5)

;;   ;; Use Consult to select xref locations with preview
;;   (setq xref-show-xrefs-function #'consult-xref
;;         xref-show-definitions-function #'consult-xref)

;;   ;; Configure other variables and modes in the :config section,
;;   ;; after lazily loading the package.
;;   :config

;;   ;; Optionally configure preview. The default value
;;   ;; is 'any, such that any key triggers the preview.
;;   ;; (setq consult-preview-key 'any)
;;   ;; (setq consult-preview-key "M-.")
;;   ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
;;   ;; For some commands and buffer sources it is useful to configure the
;;   ;; :preview-key on a per-command basis using the `consult-customize' macro.
;;   (consult-customize
;;    consult-theme :preview-key '(:debounce 0.2 any)
;;    consult-ripgrep consult-git-grep consult-grep consult-man
;;    consult-bookmark consult-recent-file consult-xref
;;    consult--source-bookmark consult--source-file-register
;;    consult--source-recent-file consult--source-project-recent-file
;;    ;; :preview-key "M-."
;;    :preview-key '(:debounce 0.4 any))

;;   ;; Optionally configure the narrowing key.
;;   ;; Both < and C-+ work reasonably well.
;;   (setq consult-narrow-key "<") ;; "C-+"

;;   ;; Optionally make narrowing help available in the minibuffer.
;;   ;; You may want to use `embark-prefix-help-command' or which-key instead.
;;   ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
;; )

;; ;; Enable vertico
;; (use-package vertico
;;   :custom
;;   ;; (vertico-scroll-margin 0) ;; Different scroll margin
;;   ;; (vertico-count 20) ;; Show more candidates
;;   ;; (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
;;   ;; (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
;;   :init
;;   (vertico-mode))

;; ;; A few more useful configurations...
;; (use-package emacs
;;   :custom
;;   ;; Support opening new minibuffers from inside existing minibuffers.
;;   (enable-recursive-minibuffers t)
;;   ;; Hide commands in M-x which do not work in the current mode.  Vertico
;;   ;; commands are hidden in normal buffers. This setting is useful beyond
;;   ;; Vertico.
;;   (read-extended-command-predicate #'command-completion-default-include-p)
;;   :init
;;   ;; Emacs bug#76028: Add prompt indicator to `completing-read-multiple'.
;;   ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
;;   (defun crm-indicator (args)
;;     (cons (format "[CRM%s] %s"
;;                   (replace-regexp-in-string
;;                    "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
;;                    crm-separator)
;;                   (car args))
;;           (cdr args)))
;;   (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

;;   ;; Do not allow the cursor in the minibuffer prompt
;;   (setq minibuffer-prompt-properties
;;         '(read-only t cursor-intangible t face minibuffer-prompt))
;;   (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode))

;; ;; Enable rich annotations using the Marginalia package
;; (use-package marginalia
;;   ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
;;   ;; available in the *Completions* buffer, add it to the
;;   ;; `completion-list-mode-map'.
;;   :bind (:map minibuffer-local-map
;;          ("M-A" . marginalia-cycle))

;;   ;; The :init section is always executed.
;;   :init

;;   ;; Marginalia must be activated in the :init section of use-package such that
;;   ;; the mode gets enabled right away. Note that this forces loading the
;;   ;; package.
;;   (marginalia-mode))

;; (use-package marginalia
;;   :ensure t
;;   :config
;;   (marginalia-mode))

;; (use-package embark
;;   :ensure t

;;   :bind
;;   (("C-." . embark-act)         ;; pick some comfortable binding
;;    ("C-;" . embark-dwim)        ;; good alternative: M-.
;;    ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

;;   :init

;;   ;; Optionally replace the key help with a completing-read interface
;;   (setq prefix-help-command #'embark-prefix-help-command)

;;   ;; Show the Embark target at point via Eldoc. You may adjust the
;;   ;; Eldoc strategy, if you want to see the documentation from
;;   ;; multiple providers. Beware that using this can be a little
;;   ;; jarring since the message shown in the minibuffer can be more
;;   ;; than one line, causing the modeline to move up and down:

;;   ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
;;   ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

;;   :config

;;   ;; Hide the mode line of the Embark live/completions buffers
;;   (add-to-list 'display-buffer-alist
;;                '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
;;                  nil
;;                  (window-parameters (mode-line-format . none)))))

;; ;; Consult users will also want the embark-consult package.
;; (use-package embark-consult
;;   :ensure t ; only need to install it, embark loads it after consult if found
;;   :hook
;;   (embark-collect-mode . consult-preview-at-point-mode))

;; (use-package orderless
;;   :ensure t
;;   :custom
;;   (completion-styles '(orderless basic))
;;   (completion-category-overrides '((file (styles basic partial-completion)))))

;; (use-package wgrep)

(use-package avy
  :init
  (setq avy-keys (number-sequence ?a ?z))
  (setq avy-background t)

  :config
  (avy-setup-default))

(use-package swiper)

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

;; (use-package undo-fu
;;   :straight t
;;   :bind (("C-." . undo-fu-only-undo)   ;; Jump to last change (backward)
;;          ("C-," . undo-fu-only-redo)   ;; Jump to newer change (forward)
;;          ("C-c ." . undo-fu-only-undo)
;;          ("C-c ," . undo-fu-only-redo)))

;; (use-package undo-fu-session
;;   :straight t
;;   :config
;;   (undo-fu-session-global-mode))

;; (global-set-key (kbd "C-c u") 'undo-fu-only-undo)
;; (global-set-key (kbd "C-c r") 'undo-fu-only-redo)

;; (use-package undo-tree
;;   :defer t
;;   :diminish undo-tree-mode

;;   :init
;;   (setq undo-tree-auto-save-history t)
;;   (add-hook 'after-init-hook 'global-undo-tree-mode))

;; (use-package iedit
;;   :diminish iedit-mode)

;; (use-package zop-to-char
;;   :bind (("M-z" . zop-up-to-char)
;;          ("M-Z" . zop-to-char)))

;; (use-package super-save
;;   :diminish super-save-mode

;;   :config
;;   (super-save-mode +1))

(use-package magit
  :bind (("C-x g" . magit-status)
         ("C-x M-g" . magit-dispatch-popup)
         :map magit-status-mode-map
         ("C-M-<up>" . magit-section-up))

  :init
  (setq   magit-log-arguments '("--graph" "--show-signature")
          magit-completing-read-function 'ivy-completing-read
          magit-process-popup-time 10
          magit-diff-refine-hunk t
          magit-push-always-verify nil)

  :config
  (global-git-commit-mode))

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

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
   (load-theme 'doom-one t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)

  (doom-themes-neotree-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-major-mode-icon t))

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

(use-package company
  :defer 2
  :diminish
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay .1)
  (company-minimum-prefix-length 2)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t))

(use-package company-box
  :after company
  :diminish
  :hook (company-mode . company-box-mode))

(use-package flycheck
  :ensure t
  :defer t
  :diminish
  :init (global-flycheck-mode))

(use-package vterm
:config
(setq shell-file-name "/bin/bash"
      vterm-max-scrollback 5000))

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

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-tokyo-night t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)

  (doom-themes-neotree-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-major-mode-icon t))

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

(use-package flycheck
  :ensure t
  :defer t
  :diminish
  :init (global-flycheck-mode))

(use-package company
  :defer 2
  :diminish
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay .1)
  (company-minimum-prefix-length 2)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t))

(use-package company-box
  :after company
  :diminish
  :hook (company-mode . company-box-mode))

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

;; ;; (use-package yasnippet
;; ;;   :diminish yas-minor-mode
;; ;;   :defer t

;; ;;   :init
;; ;;   (add-hook 'prog-mode-hook #'yas-minor-mode)

;; ;;   :config
;; ;;   (yas-reload-all))

;; (use-package eldoc
;;   :diminish eldoc-mode
;;   :defer t

;;   :init
;;   (add-hook 'eval-expression-minibuffer-setup-hook #'eldoc-mode)
;;   (add-hook 'ielm-mode-hook #'eldoc-mode)
;;   (add-hook 'emacs-lisp-mode-hook #'eldoc-mode))

;; (use-package exec-path-from-shell
;;   :config
;;   (custom-set-variables '(exec-path-from-shell-check-startup-files nil))
;;   (exec-path-from-shell-initialize)
;;   (dolist (var '("SSH_AUTH_SOCK" "SSH_AGENT_PID" "GPG_AGENT_INFO"
;;                  "LANG" "LC_CTYPE" "JAVA_HOME" "JDK_HOME"))
;;     (add-to-list 'exec-path-from-shell-variables var)))

;; (use-package projectile
;;   :diminish projectile-mode

;;   :init
;;   (setq projectile-enable-caching t
;;         projectile-completion-system 'ivy
;;         projectile-sort-order 'recentf)

;;   :config
;;   (projectile-mode)
;;   (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

;; ;; from distrotube dotfiles

;; (use-package dired-open
;;   :config
;;   (setq dired-open-extensions '(("gif" . "imv")
;;                                 ("jpg" . "imv")
;;                                 ("png" . "imv")
;;                                 ("mkv" . "mpv")
;;                                 ("mp4" . "mpv"))))

;; (use-package peep-dired
;;   :after dired
;;   :hook (evil-normalize-keymaps . peep-dired-hook)
;;   :config
;;     (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
;;     (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
;;     (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
;;     (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file)
;; )

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

;; (use-package nerd-icons
;;   :custom
;;   ;; The Nerd Font you want to use in GUI
;;   ;; "Symbols Nerd Font Mono" is the default and is recommended
;;   ;; but you can use any other Nerd Font if you want
;;   ;; (nerd-icons-font-family "Symbols Nerd Font Mono")
;;   (nerd-icons-font-family "JetbrainsMono Nerd Font Mono")
;;   )

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
