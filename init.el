;; Set default directory
(setq default-directory "~/.emacs.d/")

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org"   . "https://orgmode.org/elpa/")
			 ("elpa"  . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Ensure use-package is installed
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

;; If true, Emacs will attempt to download packages in use-package declarations
(setq use-package-always-ensure t)

;; Customize interface code blocks
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

(setq initial-buffer-choice "~/.emacs.d/init.org")

;; Inhibit startup message
(setq inhibit-startup-message t)

;; Disable visible scroll bar
(scroll-bar-mode -1)

;; Disable toolbar
(tool-bar-mode -1)

;; Disable tooltips
(tooltip-mode -1)

;; Set width of side fringes
(set-fringe-mode 10)

;; Disable menu bar
(menu-bar-mode -1)

;; Enable visual bell
(setq visible-bell t)

;; Initial frame size
(add-to-list 'default-frame-alist '(height . 40))
(add-to-list 'default-frame-alist '(width  . 100))

;; Default face
(set-face-attribute 'default nil :font "Fira Code Retina" :height 110)

;; Fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height 110)

;; Variable pitch face
(set-face-attribute 'variable-pitch nil :font "Cantarell" :height 110 :weight 'regular)

;; Modeline font
(set-face-attribute 'mode-line nil :font "Fira Code Retina" :height 100)

;; Theme
(use-package doom-themes
  :init (load-theme 'doom-dracula t))

;; Make keyboard ESC quit dialogs, equivalent to C-g
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Create new frame
(global-set-key (kbd "C-S-n") 'make-frame-command)

;; Unset secondary overlay key bindings
(global-unset-key [M-mouse-1])
(global-unset-key [M-drag-mouse-1])
(global-unset-key [M-down-mouse-1])
(global-unset-key [M-mouse-3])
(global-unset-key [M-mouse-2])

;; Unset manu key bindings
(global-unset-key [C-mouse-1])
(global-unset-key [C-down-mouse-1])

;; Copy with mouse right click
(global-set-key (kbd "<mouse-3>")      #'kill-ring-save)
(global-set-key (kbd "<down-mouse-3>")              nil)

;; Multiple cursors
(use-package multiple-cursors
  :ensure t
  :bind (("C-."         . mc/mark-next-like-this)
	 ("C-;"         . mc/mark-previous-like-this)
	 ("C-<mouse-1>" . mc/add-cursor-on-click))
)

;; Load package
(require 'multiple-cursors)

;; Unknown commands file
(setq mc/list-file "~/.emacs.d/mc-lists.el")

;; Multiple cursor rectangle definition mouse event
(defun mouse-start-rectangle (start-event)
  (interactive "e")
  (deactivate-mark)
  (mouse-set-point start-event)
  (set-rectangular-region-anchor)
  (rectangle-mark-mode +1)
  (let ((drag-event))
    (track-mouse
      (while (progn
               (setq drag-event (read-event))
               (mouse-movement-p drag-event))
        (mouse-set-point drag-event)))))

(global-set-key (kbd "M-<down-mouse-1>")     #'mouse-start-rectangle)

;; RET: newline
(define-key mc/keymap (kbd "<return>")       'electric-newline-and-maybe-indent)
;; Exit multiple-cursors-mode: ESC, right mouse click
(define-key mc/keymap (kbd "<escape>")       'multiple-cursors-mode)
(define-key mc/keymap (kbd "<mouse-1>")      'multiple-cursors-mode)
(define-key mc/keymap (kbd "<down-mouse-1>")  nil)

;; Ensure rectangular-region-mode is loaded
(require 'rectangular-region-mode)

;; Save rectangle to kill ring
(define-key rectangular-region-mode-map (kbd "<mouse-3>") 'copy-rectangle-as-kill)

;; Yank rectangle
(global-set-key (kbd "C-M-y") 'yank-rectangle)

;; Load Swiper
(use-package swiper
  :bind ("C-s" . swiper))

(require 'swiper)

;; M-RET: multiple-cursors-mode
(define-key swiper-map (kbd "M-<return>") 'swiper-mc)

;; Completion framework
(use-package counsel)
(use-package ivy
  :diminish
  :bind (:map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done)
	 ("C-l" . ivy-alt-done)
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 :map ivy-switch-buffer-map
	 ("C-k" . ivy-previous-line)
	 ("C-l" . ivy-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-k" . ivy-previous-line)
	 ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package command-log-mode)
(global-command-log-mode)

;; Create binding for evaluating buffer
(global-set-key (kbd "C-x e") 'eval-buffer)

;; Face setup
(defun custom/org-face-setup ()
  ;;  Headers variable font sizes
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :weight 'bold :height (cdr face)))
  ;; Set fixed and variable faces
  (progn (set-face-attribute 'org-block            nil :foreground nil :inherit 'fixed-pitch)
	 (set-face-attribute 'org-code             nil                 :inherit '(shadow fixed-pitch))
	 (set-face-attribute 'org-table            nil                 :inherit '(shadow fixed-pitch))
	 (set-face-attribute 'org-verbatim         nil                 :inherit '(shadow fixed-pitch))
	 (set-face-attribute 'org-special-keyword  nil                 :inherit '(font-lock-comment-face fixed-pitch))
	 (set-face-attribute 'org-meta-line        nil                 :inherit '(font-lock-comment-face fixed-pitch))
	 (set-face-attribute 'org-checkbox         nil                 :inherit 'fixed-pitch)
	 (set-face-attribute 'org-indent           nil                 :inherit '(org-hide fixed-pitch))))

;; Org hook
(defun custom/org-mode-setup ()

  ;; Enter variable pitch mode
  (variable-pitch-mode 1)

  ;; Enter visual line mode:  wrap long lines at the end of the buffer, as opposed to truncating them
  (visual-line-mode    1)

  ;; Enter indent mode: indent truncated lines appropriately
  (org-indent-mode      )

  ;; Face setup
  (custom/org-face-setup))

;; Load Org Mode
(use-package org
  :hook (org-mode . custom/org-mode-setup)
  :config

  ;; Change ellipsis ("...") to remove clutter
  (setq org-ellipsis " ▾")

  ;; Hide markup symbols
  (setq org-hide-emphasis-markers t)
)

;; Custom header bullets
(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;; Replace list hyphens with dots
(font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

;; Center text
(use-package olivetti
  :diminish
  )

(add-hook 'olivetti-mode-on-hook (lambda () (olivetti-set-width 0.9)))

(add-hook 'org-mode-hook 'olivetti-mode)

;; Required as of Org 9.2
(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("sh"  . "src shell"))
(add-to-list 'org-structure-template-alist '("el"  . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("py"  . "src python"))

(defun custom/with-mark-active (&rest args)
  "Keep mark active after command. To be used as advice AFTER any
function that sets `deactivate-mark' to t."
  (setq deactivate-mark nil))

(advice-add 'org-metaright      :after #'custom/with-mark-active)
(advice-add 'org-metaleft       :after #'custom/with-mark-active)
(advice-add 'org-metaup         :after #'custom/with-mark-active)
(advice-add 'org-metadown       :after #'custom/with-mark-active)

(advice-add 'org-shiftmetaright :after #'custom/with-mark-active)
(advice-add 'org-shiftmetaleft  :after #'custom/with-mark-active)
(advice-add 'org-shiftmetaup    :after #'custom/with-mark-active)
(advice-add 'org-shift-metadown :after #'custom/with-mark-active)

;; Trigger org-babel-tangle when saving init.org
(defun custom/org-babel-tangle-config()
(when (string-equal (buffer-file-name)
		    (expand-file-name "~/.emacs.d/init.org")))
  ;; Dynamic scoping
  (let ((org-confirm-babel-evaluate nil))
    (org-babel-tangle)))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'custom/org-babel-tangle-config)))

;; Set indentation of code blocks to 0
(setq org-edit-src-content-indentation 0)

;; Indent code blocks appropriately when inside headers
(setq org-src-preserve-indentation     nil)

;; Make code indentation reasonable
(setq org-src-tab-acts-natively        t)

;; Language packages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python     . t)))

;; Suppress security confirmation when evaluating code
(defun my-org-confirm-babel-evaluate (lang body)
  (not (member lang '("emacs-lisp" "python"))))

(setq org-confirm-babel-evaluate 'my-org-confirm-babel-evaluate)

;; Conclude initialization file
(provide 'init)
