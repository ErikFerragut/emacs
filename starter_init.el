;; put this in (or as) ~/.emacs.d/init.el

;;;;;;;;;;;;;;;;;;;; Package Management
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("elpa" . "https://elpa.gnu.org/packages/")
			 ("nongnu" . "https://elpa.nongnu.org/nongnu/")
			 ))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; init use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; be sure to periodically do M-x package-list-packages then U then x

(use-package quelpa
	     :ensure t) ;; allows installs from github repos
(quelpa '(quelpa-use-package
	:fetcher git
	:url "https://github.com/quelpa/quelpa-use-package.git"))
(require 'quelpa-use-package)


;;;;;;;;;;;;;;;;;;;; Edits incl. undo tree, completions, key bindings
(use-package undo-tree
  :ensure t
  :init (global-undo-tree-mode))

(use-package vertico
  :ensure t
  :bind (:map minibuffer-local-map
	      ("M-h" . backward-fill-word))
  :custom (vertico-cycle t)
  :init (vertico-mode))

(use-package savehist
  :init (savehist-mode))

(use-package marginalia
  :after vertico
  :ensure t
  :custom (marginalia-annotators
	   '(marginalia-annotators-heavy
	     marginalia-annotators-light
	     nil))
  :init (marginalia-mode))

(setq-default indent-tabs-mode nil)

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config (setq which-key-idle-delay 0.3))

(global-set-key (kbd "C-x C-r") 'recentf-open-files)
(global-set-key (kbd "C-'") 'other-window)
(global-set-key (kbd "C-x p") 'previous-window-any-frame)

;; highlighting button clicks -- see meta emacs file

(use-package yaml-mode)

(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gmf-mode)
         ("\\.md\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

;; linux: /usr/bin/aspell
;; max: /opt/homebrew/bin/aspell
(setq ispell-program-name "/usr/bin/aspell")

;;;;;;;;;;;;;;;;;;;; Org Mode
(use-package visual-fill-column
  :defer t)

(defalias 'console-mode 'shell-script-mode) ;; so console blocks fontify

;; update paths as necessary
(use-package org
  :custom
  ;; (org-agenda-files '("/home/suppbee/org/tasks.org"))
  ;; (org-default-notest-file '("/home/suppbee/org/notes.org"))
  (org-agenda-start-with-log-mode t)
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-ellipses " ↓ ") ; use C-x 8 RET to find this
  (org-hide-leading-stars t)
  (org-hide-emphasis-markers t) ;; can mess up tables
  (org-startup-indented t)
  (org-catch-invisible-edits 'smart)
  (org-fontify-whole-heading-line t)
  (org-context-in-file-links t)
  (org-confirm-babel-evaluate nil)
  (org-src-fontify-natively t)
  (org-src-tab-acts-natively t)
  (org-enforce-todo-dependencies t)
  (org-todo-keywords '((sequence "TODO(t/!)"
                                 "IN-PROGRESS(p/!)"
                                 "WAITING(w@/@)"
                                 "BLOCKED(b@/@)"
                                 "FUTURE(f/!)"
                                 "|"
                                 "DONE(d/!)"
                                 "CANCELED(c/@)"
                                 )))
  (org-capture-templates
   '(("i" "Ideas")))
  :init
  (defun org-custom-sort-parent-by-todo-order ()
    (interactive)
    (outline-up-heading 1)
    (org-sort-entries nil ?o)
    (org-sort-entries nil ?n)
    (org-cycle)
    (org-cycle))
  (defun efs/org-mode-visual-fill()
    ;; keep text from going too wide
    (interactive)
    (variable-pitch-mode 1)
    (auto-fill-mode 0)
    (visual-line-mode 1) ;; aka word wrap
    (display-line-numbers-mode 0)
    (set-face-attribute 'org-table nil :inherit 'fixed-pitch)
    (set-face-attribute 'org-link nil :inherit 'fixed-pitch))
  (define-skeleton org-insert-skeleton
    "Header info for an emacs-org file."
    "Title: "
    "#+TITLE:" str "\n"
    "#+AUTHOR: Erik M. Ferragut\n"
    "-----")
  :bind
  ("C-c s" . org-custom-sort-parent-by-todo-order) ;; def above
  ("C-c i" . org-insert-skeleton) ;; def above
  ("C-c l" . org-store-link)
  ("C-c c" . org-capture)
  ("C-c a" . org-agenda)
  ("C-c b" . org-iswitchb)
  :hook
  (org-mode . efs/org-mode-visual-fill)
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell . t)
     (emacs-lisp . t)
     (python . t)
     (sql . t)
     (latex . t)
     (org . t)))
  :ensure t
  ) ;; :pin "org ;; ?

;; if hook doesn't work can add here
;; (add-hook 'org-mode-hook 'efs/org-mode-visual-fill)

(setq org-image-actual-width nil) ;; so images appear correctly

;; header sizes
(require 'org-faces)
(dolist (face '((org-level-1 . 2.00)
                (org-level-2 . 1.75)
                (org-level-2 . 1.50)
                (org-level-2 . 1.25)
                (org-level-2 . 1.00)
                (org-level-2 . 1.00)
                (org-level-2 . 1.00)
                (org-level-2 . 1.00)))
  (set-face-attribute (car face) nil
                      :font "Cantarell"
                      :weight 'regular
                      :height (cdr face)))

(font-lock-add-keywords
 'org-mode '(("^ *\\([-]\\) "
              (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

;;;;;;;;;;;;;;;;;;;; Basic Visuals
;; quelpa load latest olivetti from https://github.com/rnkn/olivetti.git
(quelpa '(olivetti :repo "rnkn/olivetti" :fetcher github)) ;; center col writing

;;(use-package olivetti
;;  :config
;;  (setq olivetti-body-width 120)
;;  )

(use-package writeroom-mode) ;; distraction-free writing mode

(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(set-fringe-mode 25)
(setq visual-bell t)
(recentf-mode t)
(column-number-mode t)

(global-display-line-numbers-mode t)
(dolist (mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda() (display-line-numbers-mode 0))))

;; from fonts.google.com download Canatarell (or whatever other) font
(set-face-attribute 'variable-pitch nil :font "Cantarell" :height 160)

(use-package all-the-icons)
;; 1st time: M-x all-the-icons-install-fonts
(use-package doom-themes)
(load-theme 'doom-opera t)
;; good options are doom-[opera|gruvbox|zenburn|old-hope|horizon|solarized-light]
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom (doom-modeline-height 15))

(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
(set-face-attribute 'org-code nil :foreground nil :inherit '(shadow fixed-pitch))
;; for =something= but not for ~something~
;; formerly: (set-face-attribute 'org-verbatim nil :foreground nil :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-verbatim nil :foreground "OliveDrab3" :inherit 'fixed-pitch)
(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)

;; future

;; (1) use package pyvenv to select python env


