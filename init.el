;;; -*- lexical-binding: t; -*-

;; Initial frame size
(add-to-list 'default-frame-alist '(height . 50))
(add-to-list 'default-frame-alist '(width  . 70))

;; Initial buffer
(setq initial-buffer-choice nil)

;; Buffers opened at startup
(defvar custom/background-buffers
  '("~/.emacs.d/init.org" "/home/emacs/test.org"))

(defun custom/spawn-background-buffers ()
  (cl-loop for buffer in custom/background-buffers
	   collect (find-file-noselect buffer)))

(add-hook 'after-init-hook #'custom/spawn-background-buffers)

;; Default directory
(setq default-directory "~/.emacs.d/")

;; Config directory
(setq config-directory "~/.emacs.d/")

;; straight
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

;; Customize interface code blocks
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

(setq debug-on-error t)

(defun custom/at-point (go-to-point &optional position)
  (let ((position (or position (point))))
    (save-excursion
      (funcall go-to-point)
      (= position (point)))))

(defun custom/at-eol (&optional position)
  (custom/at-point 'end-of-line position))

(defun custom/at-bol (&optional position)
  (custom/at-point 'beginning-of-line position))

(defun custom/at-indent (&optional position)
  (custom/at-point 'back-to-indentation position))

(defun custom/org-at-ellipsis (&optional position)
  (and (custom/relative-line-org-heading-folded) (custom/at-point 'end-of-visual-line)))

(defun custom/relative-line (query &optional number &rest args)
  "Return the result of a boolean query at the current
line or another specified by its relative position to the
current line.
Optionally, `args' may be given as input to be passed
to the query at execution."
  (let ((number (or number 0)))
    (save-excursion
      (beginning-of-visual-line (+ number 1))
      (apply query args))))

(defun custom/relative-line-regex (pattern &optional number)
  (custom/relative-line 'looking-at-p number pattern))

(defun custom/relative-line-empty (&optional number)
  (custom/relative-line-regex "[[:blank:]]*$" number))

(defun custom/relative-line-indented (&optional number)
  (custom/relative-line-regex "[[:blank:]]+.*$" number))

(defun custom/relative-line-org-list (&optional number)
  (interactive)
  (custom/relative-line 'org-at-item-p number))

(defun custom/relative-line-org-list-folded (&optional number)
  "Returns non-nil if `point-at-eol' of current visual line
is on a folded list item."
  (interactive)
  (custom/relative-line (lambda () (and (org-at-item-p) (invisible-p (point-at-eol)))) number))

(defun custom/relative-line-org-list-empty (&optional number)
  (custom/relative-line-regex "[[:blank:]]*[-+1-9.)]+[[:blank:]]*$" number))

(defun custom/relative-line-org-heading (&optional number)
  (interactive)
  (custom/relative-line 'org-at-heading-p number))

(defun custom/relative-line-org-heading-folded (&optional number)
  "Returns non-nil if `point-at-eol' of current visual line
is on a folded heading."
  (interactive)
  (custom/relative-line (lambda () (and (org-at-heading-p) (invisible-p (point-at-eol)))) number))

(defun custom/relative-line-org-heading-empty (&optional number)
  (custom/relative-line-regex "[[:blank:]]*[*]+[[:blank:]]*$" number))

(defun custom/relative-line-org-heading-or-list ()
  (or (custom/relative-line-org-heading) (custom/relative-line-org-list)))

(defun custom/match-regexs (string patterns)
  "Return t if all provided regex PATTERNS
(provided as a list) match STRING."
  (cl-loop for pattern in patterns
	   if (not (string-match pattern string))
	   return nil
	   finally return t))

(defun custom/in-mode (mode)
  "Return t if mode is currently active."
  (string-equal major-mode mode))

(defun custom/in-org (cond)
  "Return t if cond is t and Org Mode is active."
  (and cond (custom/in-mode "org-mode")))

;; Retrieve current theme
(defun custom/current-theme ()
  (substring (format "%s" (nth 0 custom-enabled-themes))))

(defun custom/current-window-number ()
  "Retrieve the current window's number."
  (setq window (prin1-to-string (get-buffer-window (current-buffer))))
  (string-match "^[^0-9]*\\([0-9]\{1-4\}\\).*$" window)
  (match-string 1 window))

(defun custom/get-point (command)
  (interactive)
  (save-excursion
    (funcall command)
    (point)))

;; Retrieve active region
(defun custom/active-region (beg end)
  (set-mark beg)
  (goto-char end)
  (activate-mark)
  )

(defun custom/beginning-of-item ()
  "Conditional move to beginning of item.

Default: `beginning-of-line-text' of the current visual line.

If a region is active, move to `beginning-of-visual-line'."
  (interactive)
  (if (not (region-active-p))
      (progn (beginning-of-visual-line)
	           (beginning-of-line-text))
    (beginning-of-visual-line)))

(defun <> (a b c)
  (and (> b a) (> c b)))

;; Transform all files in directory from DOS to Unix line breaks
(defun custom/dos2unix (&optional dir)
  (let ((dir (or dir (file-name-directory buffer-file-name)))
	      (default-directory dir))
    (shell-command "find . -maxdepth 1 -type f -exec dos2unix \\{\\} \\;")))

;; Frame name
(setq-default frame-title-format '("Emacs [%m] %b"))

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

;; Enable visual bell
(setq visible-bell t)

(advice-add 'yes-or-no-p :override 'y-or-n-p)

(defun custom/hide-modeline ()
  (interactive)
  (if mode-line-format
      (setq mode-line-format nil)
    (doom-modeline-mode)))

(global-set-key (kbd "M-m") #'custom/hide-modeline)

;; Center text
(use-package olivetti
  :delight olivetti-mode
  )

(add-hook 'olivetti-mode-on-hook (lambda () (olivetti-set-width 0.9)))

;; Normal modes
(dolist (mode '(org-mode-hook
		    magit-mode-hook))
  (add-hook mode 'olivetti-mode))

;; Programming modes
(add-hook 'prog-mode-hook 'olivetti-mode)

;; Set width of side fringes
(set-fringe-mode 0)

;; Swiper
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

(define-key global-map (kbd "C-s") #'custom/smart-search)

(defun custom/narrow-and-search (beg end)
  "Narrow to region and trigger swiper search."
  (narrow-to-region beg end)
  (deactivate-mark)
  (swiper-isearch))

(defun custom/search-in-region (beg end)
  "Narrow and search active region. If the current
buffer is already narrowed, widen buffer."
  (interactive (if (use-region-p)
                   (list (region-beginning) (region-end))
                 (list nil nil)))
  (if (not (buffer-narrowed-p))
      (if (and beg end)
	  (progn (custom/narrow-and-search beg end)))
    (progn (widen)
	   (if (bound-and-true-p multiple-cursors-mode)
	       (mc/disable-multiple-cursors-mode)))))

(defun custom/swiper-exit-narrow-search ()
  (interactive)
  (minibuffer-keyboard-quit)
  (if (buffer-narrowed-p)
      (widen)))

;; Narrow search
(define-key global-map (kbd "C-r") #'custom/search-in-region)

;; Exit narrow search from swiper
(define-key swiper-map (kbd "C-e") #'custom/swiper-exit-narrow-search)

(defun custom/swiper-multiple-cursors ()
  (interactive)
  (swiper-mc)
  (minibuffer-keyboard-quit))

;; M-RET: multiple-cursors-mode
(define-key swiper-map (kbd "M-<return>") 'custom/swiper-multiple-cursors)

;; Ivy completion framework
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
  :init (ivy-mode 1))

;; Completion candidate descriptions
(use-package ivy-rich
  :bind
  (("<menu>" . counsel-M-x))
  :init (ivy-rich-mode 1))

;; Command suggestions
(use-package which-key
  :delight which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1.0))

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

(use-package command-log-mode
  :delight command-log-mode)
(global-command-log-mode)

(defun custom/home ()
  "Conditional homing. 

Default: `back-to-indentation'

Conditional:
`beginning-of-visual-line'
  - Org Mode headers
  - Empty indented lines
  - Wrapped visual lines"
  (interactive)
  (cond ((custom/in-org (custom/relative-line-org-heading-or-list))                               (custom/beginning-of-item))
	      ((custom/relative-line-empty)                                                             (custom/beginning-of-item))
	      ((> (custom/get-point 'beginning-of-visual-line) (custom/get-point 'back-to-indentation)) (beginning-of-visual-line))
	      (t                                                                                        (back-to-indentation))))

(defvar custom/double-home-timeout 0.4)

(defun custom/dynamic-home ()
  "Dynamic homing command with a timeout of `custom/double-home-timeout' seconds.
- Single press: `custom/home' 
- Double press: `beginning-of-visual-line'"
  (interactive)
  (let ((last-called (get this-command 'custom/last-call-time)))
    (if (and (eq last-command this-command)	     
             (<= (time-to-seconds (time-since last-called)) custom/double-home-timeout))
        (beginning-of-visual-line)
      (custom/home)))
  (put this-command 'custom/last-call-time (current-time)))

(global-set-key (kbd "<home>") 'custom/dynamic-home)

;; Double end to go to the beginning of line
(defvar custom/double-end-timeout 0.4)

(defun custom/dynamic-end ()
  "Move to end of visual line. If the command is repeated 
within `custom/double-end-timeout' seconds, move to end
of line."
  (interactive)
  (let ((last-called (get this-command 'custom/last-call-time)))
    (if (and (eq last-command this-command)
             (<= (time-to-seconds (time-since last-called)) custom/double-end-timeout))
        (progn (beginning-of-visual-line) (end-of-line))
      (end-of-visual-line)))
  (put this-command 'custom/last-call-time (current-time)))

(global-set-key (kbd "<end>") 'custom/dynamic-end)

;; Counsel buffer switching
(global-set-key (kbd "C-x b") 'counsel-switch-buffer)

;; Split and follow
(defun split-and-follow-horizontally ()
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 2") 'split-and-follow-horizontally)

(defun split-and-follow-vertically ()
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 3") 'split-and-follow-vertically)

;; Create new frame
(global-set-key (kbd "C-S-n") 'make-frame-command)

;; Record last sent message
(defvar last-message nil)
(defadvice message (after my-message pre act) (setq last-message ad-return-value))

(defun custom/undefined-override (orig-fun &rest args)
  "Override `undefined' function to suppress
undefined key binding messages when interrupting
key binding input with C-g."
  (let ((inhibit-message t)
	      (message-log-max nil))
    (progn (apply orig-fun args)
	         (setq _message last-message)))
  (if (string-match-p (regexp-quote "C-g is undefined") _message)
      (keyboard-quit)
    (message _message)))

;; Override the undefined key binding notice with a keyboard-quit
(advice-add 'undefined :around #'custom/undefined-override)

(defun custom/escape-window-or-region ()
  "Set course of action based current window.

If the window is dedicated, `quit-window'.
If the dedicated window is not deleted by 
`quit-window' (such as for `command-log-mode'),
proceed to `delete-window'.

If the window is not dedicated, deactivate
mark if a region is active."
  (interactive)
  (setq escaped-window (custom/current-window-number))  
  (if (window-dedicated-p (get-buffer-window (current-buffer)))
      (progn (quit-window)
	           (if (string-equal escaped-window (custom/current-window-number))
		       (delete-window)))
    (if (region-active-p)
	      (deactivate-mark))))

;; Minibuffer escape
(add-hook 'minibuffer-setup-hook (lambda () (local-set-key (kbd "<escape>") 'minibuffer-keyboard-quit)))

;; Global double escape
(defvar custom/double-escape-timeout 1)

(defun custom/escape ()
  "Execute `custom/escape-window-or-region'. If the command 
is repeated within `custom/double-escape-timeout' seconds, 
kill the current buffer and delete its window."
  (interactive)
  (let ((last-called (get this-command 'custom/last-call-time)))
    (if (and (eq last-command this-command)
             (<= (time-to-seconds (time-since last-called)) custom/double-escape-timeout))
        (if (kill-buffer)
	          (delete-window))
      (custom/escape-window-or-region)))
  (put this-command 'custom/last-call-time (current-time)))

(global-set-key (kbd "<escape>") 'custom/escape)

(defun custom/delete-region ()
  "Conditional region deletion.

Default: `delete-region'

If region starts at indented line, delete
region and indent plus one character."
  (interactive)
  (save-excursion
    (progn (setq beg (region-beginning) end (region-end))
	         (if (custom/at-indent beg)
		     (progn (beginning-of-visual-line)
			    (if (not (custom/at-point 'beginning-of-buffer))
				(left-char))
			    (delete-region (point) end))
		   (delete-region beg end)))))

(defun custom/nimble-delete-forward ()
  "Conditional forward deletion.

Default: `delete-forward-char' 1

If next line is empty, forward delete indent of 
next line plus one character."
  (interactive)
  (if (and (custom/at-eol) (custom/relative-line-indented 1))
      (progn (save-excursion
	             (next-line)
		     (back-to-indentation)
		     (delete-region (point) (line-beginning-position)))
	           (delete-forward-char 1))
    (delete-forward-char 1)))

(global-set-key (kbd "<deletechar>") 'custom/nimble-delete-forward)

(defun custom/nimble-delete-backward (orig-fun &rest args)
  "Conditional forward deletion.

Default: `delete-backward-char' 1

If `multiple-cursors-mode' is active, `delete-backward-char' 1.

Else, if region is active, delete region. If Org Mode is active and 
the previous line if not empty, `custom/nimble-delete-forward' from 
the `end-of-visual-line' of the previous line.

Else, if cursor lies either `custom/at-indent' level or is preceded only 
by whitespace, delete region from `point' to `line-beginning-position'.

Else, if cursor lies at the `end-of-visual-line' of a folded Org Mode
heading, unfold heading and `delete-backward-char' 1."
  (if (not multiple-cursors-mode)
      (if (region-active-p)
	        (custom/delete-region)
	      (if (and (or (custom/at-indent) (custom/relative-line-empty)) (not (custom/at-bol)))
		  (delete-region (point) (custom/get-point 'beginning-of-visual-line))
		(if (and (custom/relative-line-org-heading-folded) (custom/at-point 'end-of-visual-line))
		    (progn (beginning-of-visual-line) (end-of-line) (apply orig-fun args))
		  (apply orig-fun args))))
    (apply orig-fun args)))

(advice-add 'delete-backward-char :around #'custom/nimble-delete-backward)

;; Increase kill ring size
(setq kill-ring-max 200)

;; Undo Tree
(use-package undo-tree
  :bind (("M-/" . undo-tree-visualize)
         :map undo-tree-visualizer-mode-map
         ("RET" . undo-tree-visualizer-quit)
         ("ESC" . undo-tree-visualizer-quit))
  :config
  (global-undo-tree-mode))

;; Visualize in side buffer
(defun custom/undo-tree-split-side-by-side (orig-fun &rest args)
  "Split undo-tree side-by-side"
  (let ((split-height-threshold nil)
        (split-width-threshold 0))
    (apply orig-fun args)))

(advice-add 'undo-tree-visualize :around #'custom/undo-tree-split-side-by-side)

;; Copy region with S-left click
(global-set-key (kbd "S-<mouse-1>")      'mouse-save-then-kill)
(global-set-key (kbd "S-<down-mouse-1>")  nil)

;; Paste with mouse right click
(global-set-key (kbd "<mouse-3>")        'yank)
(global-set-key (kbd "<down-mouse-3>")    nil)

;; IELM
(global-set-key (kbd "C-l") 'ielm)

;; Exit IELM
(with-eval-after-load 'ielm
  (define-key ielm-map (kbd "C-l") 'kill-this-buffer))

;; Buffer evaluation
(global-set-key (kbd "C-x e") 'eval-buffer)

;; Unset secondary overlay key bindings
(global-unset-key [M-mouse-1])
(global-unset-key [M-drag-mouse-1])
(global-unset-key [M-down-mouse-1])
(global-unset-key [M-mouse-3])
(global-unset-key [M-mouse-2])

;; Unset mouse bindings
(global-unset-key [C-mouse-1])
(global-unset-key [C-down-mouse-1])

;; Multiple cursors
(use-package multiple-cursors
  :bind (("C-."         . mc/mark-next-like-this)
	       ("C-;"         . mc/mark-previous-like-this)
	       ("C-<mouse-1>" . mc/add-cursor-on-click))
  )
(require 'multiple-cursors)

;; Unknown commands file
(setq mc/list-file "~/.emacs.d/mc-lists.el")

;; Return as usual
(define-key mc/keymap (kbd "<return>")       'electric-newline-and-maybe-indent)

;; Exit multiple-cursors-mode
(define-key mc/keymap (kbd "<escape>")       'multiple-cursors-mode)
(define-key mc/keymap (kbd "<mouse-1>")      'multiple-cursors-mode)
(define-key mc/keymap (kbd "<down-mouse-1>")  nil)

(defun custom/smart-comment ()
  "If a region is active, comment out all lines in the
region. Otherwise, comment out current line if it is
not empty. In any case, advance to next line."
  (interactive)
  (let (beg end)

    ;; If a region is active
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

    ;; Comment or uncomment region
    ;; If Org Mode is active
    (if (not (custom/relative-line-empty))
	      (if (custom/in-mode "org-mode")
		  (if (org-in-src-block-p)
		      ;; Manage Org Babel misbehavior with comment-or-uncomment-region
		      (org-comment-dwim (custom/active-region beg end))
		    (comment-or-uncomment-region beg end))
		;; Else, proceed regularly
		(comment-or-uncomment-region beg end)))

    ;; Move to the beginning of the next line
    (move-beginning-of-line 2)))

(global-set-key (kbd "M-;") #'custom/smart-comment)

;; Ensure rectangular-region-mode is loaded
(require 'rectangular-region-mode)

;; Save rectangle to kill ring
(define-key rectangular-region-mode-map (kbd "<mouse-3>") 'kill-ring-save)

;; Yank rectangle
(global-set-key (kbd "S-<mouse-3>") 'yank-rectangle)

;; Enter multiple-cursors-mode
(defun custom/rectangular-region-multiple-cursors ()
  (interactive)
  (rrm/switch-to-multiple-cursors)
  (deactivate-mark))

(define-key rectangular-region-mode-map (kbd "<return>") #'custom/rectangular-region-multiple-cursors)

;; Exit rectangular-region-mode
(define-key rectangular-region-mode-map (kbd "<escape>") 'rrm/keyboard-quit)
(define-key rectangular-region-mode-map (kbd "<mouse-1>") 'rrm/keyboard-quit)

;; Multiple cursor rectangle definition mouse event
(defun custom/smart-mouse-rectangle (start-event)
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

(global-set-key (kbd "M-<down-mouse-1>") #'custom/smart-mouse-rectangle)

;; Enable rainbow delimiters on all programming modes
(use-package rainbow-delimiters)

(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

;; yasnippet
(use-package yasnippet)

(yas-global-mode 1)

(defun custom/<-snippet (orig-fun &rest args)
  "Require < before snippets."
  (interactive)
  (setq line (buffer-substring-no-properties (line-beginning-position) (line-end-position)))
	(if (not (string-equal line ""))
	    (if (string-equal (substring line 0 1) "<")
		(progn (save-excursion (move-beginning-of-line nil)
				       (right-char 1)
				       (delete-region (line-beginning-position) (point)))
		       (apply orig-fun args)))))

(advice-add 'yas-expand :around #'custom/<-snippet)

;; yasnippet-snippets
(use-package yasnippet-snippets)

(use-package magit)

;; Org Mode
(straight-use-package 'org)
(require 'org)

;; Delight
(delight 'org-indent-mode)

;; Startup with inline images
(setq org-startup-with-inline-images t)

(defun custom/org-edit-at-ellipsis (orig-fun &rest args)
  "Execute commands invoked at an Org Mode heading's
ellipsis in the first line under the heading."
  (if (custom/org-at-ellipsis)
      (progn (beginning-of-visual-line)
	           (org-show-subtree)
		   (end-of-line)
		   (org-return)
		   (apply orig-fun args))
    (apply orig-fun args)))

(dolist (fn '(org-yank
	            org-self-insert-command
		    custom/nimble-delete-forward))
  (advice-add fn :around #'custom/org-edit-at-ellipsis))

;; org-return
(defun custom/org-return ()
  "Conditional `org-return'."
  (interactive)
  (cond ((custom/relative-line-org-list-empty)        (progn (org-return) (move-beginning-of-line nil)))
	      ((custom/relative-line-org-list)              (progn (org-return) (org-cycle)))
	      ((custom/org-at-ellipsis)                     (progn (beginning-of-visual-line) (org-show-subtree) (end-of-line) (org-return)))
	      ((custom/relative-line-indented)              (progn (org-return) (org-cycle)))
	      ((org-in-src-block-p)                         (progn (org-return) (org-cycle)))
	      (t                                            (org-return))))

(define-key org-mode-map (kbd "<return>") #'custom/org-return)

;; org-meta-return
(defun custom/org-meta-return ()
  "Conditional `org-meta-return'."
  (interactive)
  (cond ((custom/relative-line-org-list-empty) (progn (org-meta-return) (next-line) (end-of-line)))
	      ((custom/relative-line-org-heading)    (custom/heading-respect-content))
	      ((custom/relative-line-org-list)       (progn (end-of-line) (org-meta-return)))
	      ((org-in-src-block-p)                  (custom/heading-respect-content))
	      (t                                     (org-meta-return))))

(define-key org-mode-map (kbd "C-<return>") #'custom/org-meta-return)

(defun custom/org-insert-subheading ()
  "Insert subheading respecting content."
  (interactive)
  (if (custom/org-at-ellipsis)
      (progn (beginning-of-visual-line)
	           (org-show-subtree)))
  (custom/org-insert-heading-respect-content)
  (org-cycle))

(define-key org-mode-map (kbd "S-<return>") 'custom/org-insert-subheading)

(defun custom/org-insert-heading-respect-content ()
  "Conditional `org-insert-heading-respect-content'."
  (interactive)
  (if (org-current-level)
      (progn (if (not (= 1 (org-current-level)))
	               (outline-up-heading 0))
             (org-insert-heading-respect-content))
    (org-insert-heading-respect-content)))

;; Insert heading after current tree
(define-key org-mode-map (kbd "M-<return>") 'custom/org-insert-heading-respect-content)

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

(defun custom/org-cycle (orig-fun &rest args)
  "Conditional `org-cycle'.

Default: `org-cycle'

If cursor lies at `end-of-visual-line' of folded heading or list,
move cursor to `end-of-line' of the current visual line and then
call `org-cycle'.

If cursor lies at a paragraph directly under a list item and not
indented at the level of the previous list item, indent the paragraph."
  (interactive)
  (if (or (custom/relative-line-org-list-folded) (custom/relative-line-org-heading-folded))
      (if (= (point) (custom/get-point 'end-of-visual-line))
	      (progn (beginning-of-visual-line)
		     (end-of-line)
		     (apply orig-fun args))
	    (apply orig-fun args))
    (apply orig-fun args)))

(advice-add 'org-cycle :around #'custom/org-cycle)

(defun custom/org-metaright (orig-fun &rest args)
  (if (and (not (custom/relative-line-org-list)) (custom/relative-line-org-list -1))
      (progn
	      (end-of-line 0)
	      (custom/org-return)
	      (custom/nimble-delete-forward))
    (apply orig-fun args)))

(advice-add 'org-metaright :around #'custom/org-metaright)

;; Required as of Org 9.2
(require 'org-tempo)

;; LaTeX structure templates
(tempo-define-template "org-tempo-"
		             '("#+NAME: eq:1" p "\n\\begin{equation}\n\\end{equation}" >)
			     "<eq"
			     "LaTeX equation template")

;; Code block structure templates
(add-to-list 'org-structure-template-alist '("sh" . "src shell"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))

;; Justify equation labels - [fleqn]
;; Preview page width      - \\setlength{\\textwidth}{10cm}
(setq org-format-latex-header
      "\\documentclass[fleqn]{article}\n\\usepackage[usenames]{color}\n[PACKAGES]\n[DEFAULT-PACKAGES]\n\\pagestyle{empty}             % do not remove\n% The settings below are copied from fullpage.sty\n\\setlength{\\textwidth}{10cm}\n\\addtolength{\\textwidth}{-3cm}\n\\setlength{\\oddsidemargin}{1.5cm}\n\\addtolength{\\oddsidemargin}{-2.54cm}\n\\setlength{\\evensidemargin}{\\oddsidemargin}\n\\setlength{\\textheight}{\\paperheight}\n\\addtolength{\\textheight}{-\\headheight}\n\\addtolength{\\textheight}{-\\headsep}\n\\addtolength{\\textheight}{-\\footskip}\n\\addtolength{\\textheight}{-3cm}\n\\setlength{\\topmargin}{1.5cm}\n\\addtolength{\\topmargin}{-2.54cm}")

;; SVG LaTeX equation preview
(setq org-latex-create-formula-image-program 'dvisvgm)

;; Theme-specific LaTeX preview directory
(defun custom/latex-preview-directory ()
  (setq org-preview-latex-image-directory
   (concat config-directory "tmp/" "ltximg/" (custom/current-theme) "/")))

;; Reload LaTeX equation previews
(defun custom/latex-preview-reload ()
  "Reload all LaTeX previews in buffer,
ensuring the LaTeX preview directory
matches the current theme."
  (if (custom/in-mode "org-mode")
      (progn (org-latex-preview '(64))
	           (custom/latex-preview-directory)
		   (org-latex-preview '(16)))))

(add-hook 'org-mode-hook #'custom/latex-preview-reload)

;; Continuous numbering of Org Mode equations
(defun org-renumber-environment (orig-fun &rest args)
  (let ((results '()) 
        (counter -1)
        (numberp))

    (setq results (cl-loop for (begin .  env) in 
                        (org-element-map (org-element-parse-buffer) 'latex-environment
                          (lambda (env)
                            (cons
                             (org-element-property :begin env)
                             (org-element-property :value env))))
                        collect
                        (cond
                         ((and (string-match "\\\\begin{equation}" env)
                               (not (string-match "\\\\tag{" env)))
                          (cl-incf counter)
                          (cons begin counter))
                         ((string-match "\\\\begin{align}" env)
                          (prog2
                              (incf counter)
                              (cons begin counter)                          
                            (with-temp-buffer
                              (insert env)
                              (goto-char (point-min))
                              ;; \\ is used for a new line. Each one leads to a number
                              (incf counter (count-matches "\\\\$"))
                              ;; unless there are nonumbers.
                              (goto-char (point-min))
                              (decf counter (count-matches "\\nonumber")))))
                         (t
                          (cons begin nil)))))

    (when (setq numberp (cdr (assoc (point) results)))
      (setf (car args)
            (concat
             (format "\\setcounter{equation}{%s}\n" numberp)
             (car args)))))
  
  (apply orig-fun args))

(advice-add 'org-create-formula-image :around #'org-renumber-environment)

;; org-fragtog
(use-package org-fragtog)

(add-hook 'org-mode-hook 'org-fragtog-mode)

;; Language packages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python     . t)))

;; Trigger org-babel-tangle when saving any org files in the config directory
(setq source-regex (list ".org" (replace-regexp-in-string "~" "/root" config-directory)))

(defun custom/org-babel-tangle-config()
  "Call org-babel-tangle when the Org  file in the current buffer is located in the config directory"
     (if (custom/match-regexs (expand-file-name buffer-file-name) source-regex)
     ;; Tangle ommitting confirmation
     (let ((org-confirm-babel-evaluate nil)) (org-babel-tangle)))
)
(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'custom/org-babel-tangle-config)))

(defun custom/org-fix-bleed-end-line-block (from to flag spec)
  "Toggle fontification of last char of block end lines when cycling.

This avoids the bleeding of `org-block-end-line' when block is
folded."
  (when (and (eq spec 'org-hide-block)
             (/= (point-max) to))
    (save-excursion
      (if flag
          (font-lock-unfontify-region to (1+ to))
        (font-lock-flush to (1+ to))))))

(advice-add 'org-flag-region :after #'custom/org-fix-bleed-end-line-block)

(defun custom/org-fix-bleed-end-line-cycle (state)
  "Toggle fontification of last char of block lines when cycling.

This avoids the bleeding of `org-block-end-line' when outline is
folded."
  (save-excursion
    (when org-fontify-whole-block-delimiter-line
      (let ((case-fold-search t)
            beg end)
        (cond ((memq state '(overview contents all))
               (setq beg (point-min)
                     end (point-max)))
              ((memq state '(children folded subtree))
               (setq beg (point)
                     end (org-end-of-subtree t t))))
        (when beg           ; should always be true, but haven't tested enough
          (goto-char beg)
          (while (search-forward "#+end" end t)
            (end-of-line)
            (unless (= (point) (point-max))
              (if (org-invisible-p (1- (point)))
                  (font-lock-unfontify-region (point) (1+ (point)))
                (font-lock-flush (point) (1+ (point)))))))))))

(add-hook 'org-cycle-hook #'custom/org-fix-bleed-end-line-cycle)

(global-set-key (kbd "C-x C-x") 'org-babel-execute-src-block)

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

;; Org Roam
(straight-use-package 'org-roam)

;; Directory
(setq org-roam-directory "/home/roam")

(org-roam-db-autosync-mode)

;; Org Roam UI
(straight-use-package 'org-roam-ui)

(setq org-roam-ui-follow t)

;; Sync theme and UI
(setq org-roam-ui-sync-theme nil)

(setq org-roam-ui-open-on-start nil)

(setq org-roam-ui-update-on-save t)

;; Org Roam timestamps
(straight-use-package 'org-roam-timestamps)

;; Org Agenda log mode
(setq org-agenda-start-with-log-mode t)
(setq org-log-done 'time)
(setq org-log-into-drawer t)

;; Org Agenda week view key binding
(global-set-key (kbd "C-c a") (lambda () (interactive) (org-agenda)))

;; Restart Org Agenda
(defun custom/org-agenda-restart ()
  (interactive)
  (org-agenda-quit) 
  (org-agenda))

;; Mark items as done
(defun custom/org-agenda-todo-done ()
  (interactive)
  (org-agenda-todo 'done))

;; Set custom Org Agenda key bindings
(defun custom/org-agenda-custom-bindings ()
  ;; (local-set-key (kbd "<escape>") 'org-agenda-quit)
  (local-set-key (kbd "C-a") #'custom/org-agenda-restart)
  (local-set-key (kbd "d")   #'custom/org-agenda-todo-done))

(add-hook 'org-agenda-mode-hook 'custom/org-agenda-custom-bindings)

;; Set Org Agenda files
(setq org-agenda-files '("/home/tasks.org"))

(setq org-tag-alist
      '((:startgroup)
	;; Put mutually exclusive tags here
	(:endgroup)
	("@errand"  . ?E)
	("@home"    . ?H)
	("@work"    . ?W)
	("agenda" . ?a)
	("planning" . ?p)
	("publish"  . ?P)
	("batch"    . ?b)
	("note"     . ?n)
	("idea"     . ?i)))

;; Define TODO keyword sequences
(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
	(sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(r)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

;; Configure custom agenda views
(setq org-agenda-custom-commands
      
      '(("d" "Dashboard"
	 ((agenda "" ((org-deadline-warning-days 7)))
	  (todo "NEXT"
		((org-agenda-overriding-header "Next Tasks")))
	  (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))
	
	("n" "Next Tasks"
	 ((todo "NEXT"
		((org-agenda-overriding-header "Next Tasks")))))

 	("W" "Work Tasks" tags-todo "+work-email")

	("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
	 ((org-agenda-overriding-header "Low Effort Tasks")
	  (org-agenda-max-todos 20)
	  (org-agenda-files org-agenda-files)))

	("w" "Workflow Status"
	 ((todo "WAIT"
		((org-agenda-overriding-header "Waiting on External")
		 (org-agenda-files org-agenda-files)))
	  (todo "REVIEW"
		((org-agenda-overriding-header "In Review")
		 (org-agenda-files org-agenda-files)))
	  (todo "PLAN"
		((org-agenda-overriding-header "In Planning")
		 (org-agenda-todo-list-sublevels nil)
		 (org-agenda-files org-agenda-files)))
	  (todo "BACKLOG"
		((org-agenda-overriding-header "Project Backlog")
		 (org-agenda-todo-list-sublevels nil)
		 (org-agenda-files org-agenda-files)))
	  (todo "READY"
		((org-agenda-overriding-header "Ready for Work")
		 (org-agenda-files org-agenda-files)))
	  (todo "ACTIVE"
		((org-agenda-overriding-header "Active Projects")
		 (org-agenda-files org-agenda-files)))
	  (todo "COMPLETED"
		((org-agenda-overriding-header "Completed Projects")
		 (org-agenda-files org-agenda-files)))
	  (todo "CANC"
		((org-agenda-overriding-header "Cancelled Projects")
		 (org-agenda-files org-agenda-files)))))))

(require 'theme (concat config-directory "theme.el"))

;; Theme-agnostic enabling hook
(defvar after-enable-theme-hook nil
   "Normal hook run after enabling a theme.")

(defun run-after-enable-theme-hook (&rest _args)
   "Run `after-enable-theme-hook'."
   (run-hooks 'after-enable-theme-hook))

;; enable-theme
(advice-add 'enable-theme :after #'run-after-enable-theme-hook)

;; Reload Org Mode
(defun custom/org-theme-reload ()
  (if (custom/in-mode "org-mode")
      (org-mode)))

(add-hook 'after-enable-theme-hook #'custom/org-theme-reload)

;; Conclude initialization file
(provide 'init)
