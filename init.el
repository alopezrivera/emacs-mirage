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

;; Customize names displayed in mode line
(use-package delight)
(require 'delight)

;; Customize interface code blocks
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

;; Retrieve active region
(defun custom/active-region (beg end)
  (set-mark beg)
  (goto-char end)
  (activate-mark)
)

(setq initial-buffer-choice "~/.emacs.d/init.org")

;; Inhibit startup message
(setq inhibit-startup-message t)

;; Disable visible scroll bar
(scroll-bar-mode -1)

;; Disable toolbar
(tool-bar-mode -1)

;; Disable tooltips
(tooltip-mode -1)

;; Disable menu bar
(menu-bar-mode -1)

;; Theme
(use-package doom-themes
  :init (load-theme 'doom-palenight t))

;; Symbol library
(use-package all-the-icons
  :if (display-graphic-p))

;; Enable visual bell
(setq visible-bell t)

;; Set width of side fringes
(set-fringe-mode 7)

;; Set fringe color
(set-face-background 'fringe "#30f295")

;; Line numbers: display globally
(global-display-line-numbers-mode t)

;; Display column number
(column-number-mode)

;; Exceptions
(dolist (mode '(org-mode-hook
		  term-mode-hook
		  shell-mode-hook
		  eshell-mode-hook
		  undo-tree-visualizer-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Highlight HTML color strings in their own color
(use-package rainbow-mode)
(require 'rainbow-mode)

;; Install doom-modeline
(use-package doom-modeline
  :hook (after-init . doom-modeline-mode))

;; Remove default modes from mode line
(delight '((visual-line-mode nil "simple")
	   (buffer-face-mode nil "simple")
   	   (eldoc-mode       nil "eldoc")
	   ;; Major modes
	   (emacs-lisp-mode "EL" :major)))

;; Mode line font
(set-face-attribute 'mode-line nil :height 110)

;; Initial frame size
(add-to-list 'default-frame-alist '(height . 40))
(add-to-list 'default-frame-alist '(width  . 100))

;; Make keyboard ESC quit dialogs, equivalent to C-g
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Replace description key bindings by their helpful equivalents
(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . helpful-function)
  ([remap describe-command]  . helpful-command)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key]      . helpful-key))

;; Create new frame
(global-set-key (kbd "C-S-n") 'make-frame-command)

;; Default face
(set-face-attribute 'default nil :font "Fira Code Retina" :height 110)

;; Fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height 110)

;; Variable pitch face
(set-face-attribute 'variable-pitch nil :font "Cantarell" :height 110 :weight 'regular)

;; Unset secondary overlay key bindings
(global-unset-key [M-mouse-1])
(global-unset-key [M-drag-mouse-1])
(global-unset-key [M-down-mouse-1])
(global-unset-key [M-mouse-3])
(global-unset-key [M-mouse-2])

;; Unset mouse bindings
(global-unset-key [C-mouse-1])
(global-unset-key [C-down-mouse-1])

(global-set-key (kbd "C-`") 'widen)

;; Undo Tree
(use-package undo-tree
  :bind (:map undo-tree-visualizer-mode-map
	      ("RET" . undo-tree-visualizer-quit)))
(require 'undo-tree)
(global-undo-tree-mode)

;; Visualize in side buffer
(defun custom/undo-tree-split-side-by-side (original-function &rest args)
  "Split undo-tree side-by-side"
  (let ((split-height-threshold nil)
        (split-width-threshold 0))
    (apply original-function args)))

(advice-add 'undo-tree-visualize :around #'custom/undo-tree-split-side-by-side)

;; Undo tree command
(defun custom/undo-tree ()
  (interactive)
  (undo-tree-visualize))

(global-set-key (kbd "M-/") #'custom/undo-tree)

;; Copy region with S-left click
(global-set-key (kbd "S-<mouse-1>")      'mouse-save-then-kill)
(global-set-key (kbd "S-<down-mouse-1>")  nil)

;; Paste with mouse right click
(global-set-key (kbd "<mouse-3>")        'yank)
(global-set-key (kbd "<down-mouse-3>")    nil)

;; Multiple cursors
(use-package multiple-cursors
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
(define-key rectangular-region-mode-map (kbd "<mouse-3>") 'kill-ring-save)

;; Yank rectangle
(global-set-key (kbd "S-<mouse-3>") 'yank-rectangle)

(defun custom/smart-comment ()
  "Comments out the current line if no region is selected.
If the cursor stands on an opening parenthesis and Emacs Lisp 
mode is active, the region of the corresponding s expression 
is selected and commented out.
If a region is selected, it comments out the region, from 
the start of the top line of the region, to the end to its 
last line."
  (interactive)
  (let (beg end)
    (if (region-active-p)

	;; If the beginning and end of the region are in
	;; the same line, select entire line
	(if (= (count-lines (region-beginning) (region-end)) 1)
	    (setq beg (line-beginning-position) end (line-end-position))
	  ;; Else, select region from the start of its first
	  ;; line to the end of its last.
          (setq beg (save-excursion (goto-char (region-beginning)) (line-beginning-position))
		end (save-excursion (goto-char (region-end)) (line-end-position))))
      
      ;; Else, select line
      (setq beg (line-beginning-position) end (line-end-position)))

    ;; Comment/uncomment region
    (if (org-in-src-block-p)
	;; Manage Org Babel misbehavior with comment-or-uncomment-region
	(org-comment-dwim (custom/active-region beg end))
      (comment-or-uncomment-region beg end))

    ;; Move to the beginning of the next line
    (move-beginning-of-line 2)))

(global-set-key (kbd "M-;") 'custom/smart-comment)

;; Load Swiper
(use-package swiper)

(require 'swiper)

;; Smart search
(defun custom/search-region (beg end)
  "Search selected region with swiper-isearch."
  (swiper-isearch (buffer-substring-no-properties beg end)))

(defun custom/smart-search (beg end)
  "Search for selected regions. If none are, call swiper-isearch."
  (interactive (if (use-region-p)
                   (list (region-beginning) (region-end))
                 (list nil nil)))
  (deactivate-mark)
  (if (and beg end)
      (custom/search-region beg end)
    (swiper-isearch)))

(define-key global-map (kbd "C-s") 'custom/smart-search)

(defun custom/narrow-and-search (beg end)
  (narrow-to-region beg end)
  (deactivate-mark)
  (swiper-isearch))

(defun custom/search-in-region (beg end)
  (interactive (if (use-region-p)
                   (list (region-beginning) (region-end))
                 (list nil nil)))
  (if (and beg end)
      (custom/narrow-and-search beg end)
    (swiper-isearch)))

(define-key global-map (kbd "C-x C-x") 'custom/search-in-region)

;; M-RET: multiple-cursors-mode
(define-key swiper-map (kbd "M-<return>") 'swiper-mc)

;; Command suggestions
(use-package which-key
  :delight which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.3))

;; Completion framework
(use-package counsel)
(use-package ivy
  :delight ivy-mode
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
  :config (ivy-mode 1))

;; Completion candidate descriptions
(use-package ivy-rich
  :config 
  (ivy-rich-mode 1)
  :bind
  (("<menu>" . counsel-M-x)))

(use-package command-log-mode
  :delight command-log-mode)
(global-command-log-mode)

;; Create binding for evaluating buffer
(global-set-key (kbd "C-x e") 'eval-buffer)

;; Enable rainbow delimiters on all programming modes
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Org hook
(defun custom/org-mode-setup ()

  ;; Enter variable pitch mode
  (variable-pitch-mode 1)

  ;; Enter visual line mode:  wrap long lines at the end of the buffer, as opposed to truncating them
  (visual-line-mode    1)
  ;; Move through lines as they are displayed in visual-line-mode, as opposed to how they are stored.
  (setq line-move-visual t)

  ;; Enter indent mode: indent truncated lines appropriately
  (org-indent-mode     1))

;; Load Org Mode
(use-package org
  :hook (org-mode . custom/org-mode-setup)
  :delight org-indent-mode
)

;; Hide #+TITLE:
(setq org-hidden-keywords '(title))

;; Change ellipsis ("...") to remove clutter
(setq org-ellipsis " ▾")

;; Refrain from repositioning text when cycling visibility
(remove-hook 'org-cycle-hook #'org-optimize-window-after-visibility-change)

;; Install org-superstar
(use-package org-superstar)

(require 'org-superstar)

;; Hook to Org Mode
(add-hook 'org-indent-mode-hook (lambda () (org-superstar-mode 1)))

;; Headers
(setq org-superstar-headline-bullets-list
      '("◉" "▷" "○" "●" "○" "●" "○" "●"))

;; Do not cycle header markers
(setq org-superstar-cycle-headline-bullets nil)

;; Set custom bullet points
(setq
 org-superstar-item-bullet-alist
 '((42 . ">")
   (43 . "○")
   (45 . "●")))

;; Set custom bullet point height
(set-face-attribute 'org-superstar-item nil :inherit 'fixed-pitch :height 90)

;; Center text
(use-package olivetti
  :delight olivetti-mode
  )

(add-hook 'olivetti-mode-on-hook (lambda () (olivetti-set-width 0.9)))

(add-hook 'org-mode-hook 'olivetti-mode)

;; Title face

(defun custom/org-title-setup () 
  (with-eval-after-load 'org-faces
    (set-face-attribute 'org-document-title nil :height 2.074 :foreground 'unspecified :inherit 'org-level-8)))

(add-hook 'org-mode-hook 'custom/org-title-setup)

;; Use levels 1 through 4
(setq org-n-level-faces 4)

;; Do not cycle header style after 4th level
(setq org-cycle-level-faces nil)

;; Hide leading stars
(setq org-hide-leading-starts t)

;; Font sizes
(defun custom/org-header-setup () 
  (with-eval-after-load 'org-faces

    ;; Header font sizes
    (dolist (face '((org-level-1 . 1.5)
                    (org-level-2 . 1.2)
                    (org-level-3 . 1.1)
                    (org-level-4 . 1.0)
                    (org-level-5 . 1.0)
                    (org-level-6 . 1.0)
                    (org-level-7 . 1.0)
                    (org-level-8 . 1.0)))
      (set-face-attribute (car face) nil :weight 'bold :height (cdr face)))))

(add-hook 'org-mode-hook 'custom/org-header-setup)

(defun custom/org-pitch-setup ()
  (with-eval-after-load 'org-faces

      ;; Code
      (set-face-attribute 'org-block                 nil :foreground nil :inherit 'fixed-pitch)
      (set-face-attribute 'org-code                  nil                 :inherit '(shadow fixed-pitch))
      (set-face-attribute 'org-verbatim              nil                 :inherit '(shadow fixed-pitch))

      ;; Tables
      (set-face-attribute 'org-table                 nil                 :inherit '(shadow fixed-pitch))

      ;; Lists
      (set-face-attribute 'org-checkbox              nil                 :inherit 'fixed-pitch)
      (set-face-attribute 'org-indent                nil                 :inherit '(org-hide fixed-pitch))

      ;; Meta
      (set-face-attribute 'org-meta-line             nil                 :inherit 'fixed-pitch)
      (set-face-attribute 'org-document-info         nil                 :inherit 'fixed-pitch)
      (set-face-attribute 'org-document-info-keyword nil                 :inherit 'fixed-pitch)
      (set-face-attribute 'org-special-keyword       nil                 :inherit 'fixed-pitch)))

  (add-hook 'org-indent-mode-hook 'custom/org-pitch-setup)

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

;; Hide markup symbols
(setq org-hide-emphasis-markers t)

(setq org-agenda-files '("~/.emacs.d/test/tasks.org"))

;; Language packages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python     . t)))

;; Set indentation of code blocks to 0
(setq org-edit-src-content-indentation 0)

;; Indent code blocks appropriately when inside headers
(setq org-src-preserve-indentation     nil)

;; Make code indentation reasonable
(setq org-src-tab-acts-natively        t)

;; Suppress security confirmation when evaluating code
(defun my-org-confirm-babel-evaluate (lang body)
  (not (member lang '("emacs-lisp" "python"))))

(setq org-confirm-babel-evaluate 'my-org-confirm-babel-evaluate)

;; Trigger org-babel-tangle when saving init.org
(defun custom/org-babel-tangle-config()
(when (string-equal (buffer-file-name)
		          (expand-file-name "~/.emacs.d/init.org")))
  ;; Dynamic scoping
  (let ((org-confirm-babel-evaluate nil))
    (org-babel-tangle)))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'custom/org-babel-tangle-config)))

;; Conclude initialization file
(provide 'init)
