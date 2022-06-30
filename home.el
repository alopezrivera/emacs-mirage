;;; -*- lexical-binding: t; -*-

;; Initial frame size
(add-to-list 'default-frame-alist '(height . 50))
(add-to-list 'default-frame-alist '(width  . 70))

;; background buffers
  (defvar background-buffers
    (list (concat config-directory "local.el")
	      (concat config-directory "demo.org")
	      (concat config-directory "ui.org")
	      (concat config-directory "wild.el")
	      (concat config-directory "org.org")
	      (concat config-directory "ide.org")
	      (concat config-directory "init.org")
	      (concat config-directory "home.org")
	      (concat config-directory "theme.org")
	      (concat config-directory "system.org")
	      (concat config-directory "dotfiles.org")
	      (concat config-directory "backlog.org")
	      (concat config-directory "org-diary.org")
	      (concat config-directory "org-paragraph.org")))

(defvar spawn-startup-buffers t
  "Whether to spawn spawn the buffers in the `startup-buffers' list after initialization")

(defvar spawn-background-buffers nil
  "Whether to spawn spawn the buffers in the `background-buffers' list after initialization")
  
  (defun custom/spawn-buffers (buffer-list)
    "Spawn buffers in buffer list"
    (cl-loop for buffer in buffer-list
	     collect (find-file-noselect buffer)))

  (defun custom/spawn-startup-buffers ()
    (custom/spawn-buffers startup-buffers))

  (defun custom/spawn-background-buffers ()
    (custom/spawn-buffers background-buffers))

  (if spawn-startup-buffers
      (add-hook 'after-init-hook #'custom/spawn-startup-buffers))

  (if spawn-background-buffers
      (add-hook 'after-init-hook #'custom/spawn-background-buffers))

;; Inhibit startup message
(setq inhibit-startup-message t)

;; Config directory
(setq config-directory "~/.emacs.d/")

;; straight.el
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

(straight-use-package 'el-patch)

;; Buffer evaluation
(global-set-key (kbd "C-x e") 'eval-buffer)

(setq debug-on-error t)

;; Enable rainbow delimiters on all programming modes
(straight-use-package 'rainbow-delimiters)

(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

(defun custom/window-resize (width)
  (window-resize nil (- width (window-width)) t))

(defun custom/window-resize-fraction (fr &optional min)
  "Resize window to a fraction of the frame width."
  (interactive)
  (let ((width (max (if min min 0) (truncate (* fr (frame-width))))))
    (window-resize nil (- width (window-width)) t)))

(defun custom/regex-match-count (regexp str)
  (loop with start = 0
        for count from 0
        while (string-match regexp str start)
        do (setq start (match-end 0))
        finally return count))

(defun custom/eolp (orig-fun &rest args)
  (interactive)
  (or (apply orig-fun args) (looking-at-p "[[:blank:]]*$")))

(advice-add 'eolp :around #'custom/eolp)

(defun custom/at-point (go-to-point &optional point)
  (let ((point (or point (point))))
    (save-excursion
      (funcall go-to-point)
      (= point (point)))))

(defun custom/at-indent (&optional point)
  (and (custom/relative-line-indented) (custom/at-point 'back-to-indentation point)))

(defun custom/relative-line (query &optional number &rest args)
  "Return the result of a boolean query at the beginning
of the current visual line, or another specified by its
relative position to the current line.
Optionally, `args' may be given as input to be passed
to the query at execution."
  (let ((number (or number 0)))
    (save-excursion
      (beginning-of-visual-line)
      (beginning-of-line-text (+ number 1))
      (apply query args))))

(defun custom/relative-line-regex (pattern &optional number)
  (let ((number (or number 0)))
    (save-excursion
      (beginning-of-line-text (+ number 1))
      (setq line (buffer-substring-no-properties (custom/get-point 'beginning-of-line) (custom/get-point 'end-of-line))))
    (string-match-p pattern line)))

(defun custom/relative-line-list (&optional number)
  (custom/relative-line-regex "^[[:blank:]]*\\([0-9]+[.\\)]\\{1\\}\\|[-+*]\\{1\\}\\)[[:blank:]]+.*$" number))

(defun custom/relative-line-empty (&optional number)
  (custom/relative-line-regex "^[[:space:]]*$" number))

(defun custom/relative-line-wrapped ()
  (> (custom/get-point 'beginning-of-visual-line) (custom/get-point 'beginning-of-line-text)))

(defun custom/relative-line-indented (&optional number)
  (custom/relative-line-regex "^[[:blank:]]+.*$" number))

(defun custom/relative-line-list-ordered (&optional number)
  (custom/relative-line-regex "^[[:blank:]]*[0-9]+[.\\)]\\{1\\}[[:blank:]]+.*$" number))

(defun custom/relative-line-list-unordered (&optional number)
  (custom/relative-line-regex "^[[:blank:]]*[-+*]\\{1\\}[[:blank:]]+.*$" number))

(defun custom/region-blank (&optional beg end)
  (let ((beg (or beg (region-beginning)))
	      (end (or end (region-end))))
    (setq region (buffer-substring-no-properties beg end))
    (string-match "\\`[[:space:]]*\\'$" region)))

(defun custom/region-multiline-visual ()
  "Return t if a region is active and spans more than one visual line."
  (and (region-active-p) (> (custom/region-count-visual-lines) 1)))

(defun custom/region-count-visual-lines ()
  "Count visual lines in an active region."
  (interactive)
  (save-excursion 
    (beginning-of-visual-line)
    (count-screen-lines (region-beginning) (region-end))))

(defun custom/in-mode (mode)
  "Return t if mode is currently active."
  (string-equal major-mode mode))

;; Retrieve current theme
(defun custom/current-theme ()
  (substring (format "%s" (nth 0 custom-enabled-themes))))

(defun custom/current-window-number ()
  "Retrieve the current window's number."
  (setq window (prin1-to-string (get-buffer-window (current-buffer))))
  (string-match "^[^0-9]*\\([0-9]+\\).*$" window)
  (match-string 1 window))

(defun custom/find-buffer-by-file-name (file)
  (cl-loop for buffer in (buffer-list)
	        if (string-equal (buffer-name buffer) (file-name-nondirectory file))
	           return buffer
		finally return nil))

(defun custom/get-point (command &rest args)
  (interactive)
  (save-excursion
    (apply command args)
    (point)))

(defun custom/last-change ()
  "Retrieve last change in current buffer."
  (setq last-change (nth 1 buffer-undo-list))
  (let ((beg (car last-change))
        (end (cdr last-change)))
    (buffer-substring-no-properties beg end)))

(defun custom/visible-buffers ()
  (cl-delete-duplicates (mapcar #'window-buffer (window-list))))

(defun custom/get-keyword-key-value (kwd)
   (let ((data (cadr kwd)))
     (list (plist-get data :key)
           (plist-get data :value))))

(defun <> (a b c)
  (and (> b a) (> c b)))

(defmacro custom/@buffers (command)
  `(cl-loop for buffer in (buffer-list)
               collect (save-window-excursion (switch-to-buffer buffer)
                                              ,command)))

;; no tabs
(setq-default indent-tabs-mode nil)

;; vundo
(straight-use-package 'vundo)

(global-set-key (kbd "C-v") #'vundo)

(defun custom/delete-line ()
  (delete-region (custom/get-point 'beginning-of-line) (custom/get-point 'end-of-line)))

(defun custom/@delete-hungry (query)
  "Conditional region deletion.

Default: `delete-region'

If region starts at the beginning of an
indented line, delete region and indent.

If `query', delete the region and its indent 
plus one character."
  (setq beg (region-beginning) end (region-end))
  (if (custom/at-indent beg)
	    (save-excursion (beginning-of-visual-line)
                      (if (and query (not (bobp)) (not (custom/relative-line-empty -1)))
                          (left-char))
                      (delete-region (point) end))
    (delete-region beg end)))

(defun custom/delete-hungry ()
  "If the region starts at the beginning of an 
indented line and the current mode is derived from 
`prog-mode',  delete the region and its indent plus 
one character."
  (interactive)
  (custom/@delete-hungry (derived-mode-p 'prog-mode)))

(defun custom/nimble-delete-forward ()
  "Conditional forward deletion.

Default: `delete-forward-char' 1

If next line is empty, forward delete indent of 
next line plus one character."
  (interactive)
  (cond ((and (eolp) (custom/relative-line-indented 1)) (progn (setq beg (point)) (next-line) (back-to-indentation) (delete-region beg (point))))
	    ((custom/relative-line-empty)                   (delete-region (point) (custom/get-point 'next-line)))
	    (t                                              (delete-forward-char 1))))

(global-set-key (kbd "<deletechar>") 'custom/nimble-delete-forward)

(defun custom/nimble-delete-backward ()
  "Conditional forward deletion.

Default: `delete-backward-char' 1

If `multiple-cursors-mode' is active, `delete-backward-char' 1.

If region is active, delete region.

If cursor lies either `custom/at-indent' or is preceded only by
whitespace, delete region from `point' to `beginning-of-visual-line'."
  (interactive)
  (if (not (bound-and-true-p multiple-cursors-mode))
      (cond ((and (region-active-p) (not (custom/region-blank))) (custom/delete-hungry))
	        ((custom/at-indent)                                  (delete-region (point) (custom/get-point 'beginning-of-visual-line)))
		(t                                                   (delete-backward-char 1)))
    (delete-backward-char 1)))

(global-set-key (kbd "<backspace>") 'custom/nimble-delete-backward)

;; Increase kill ring size
(setq kill-ring-max 200)

(defun custom/kill-ring-mouse ()
  "If a region is active, save the region to the
kill ring. Otherwise, yank the last entry in the
kill ring."
  (interactive)
  (if (region-active-p)
      (kill-ring-save (region-beginning) (region-end))
    (yank)))

(global-set-key (kbd "<mouse-3>")        'custom/kill-ring-mouse)
(global-set-key (kbd "<down-mouse-3>")    nil)

;; Unset secondary overlay key bindings
(global-unset-key [M-mouse-1])
(global-unset-key [M-drag-mouse-1])
(global-unset-key [M-mouse-3])
(global-unset-key [M-mouse-2])

(global-set-key (kbd "C-a") 'mark-whole-buffer)

;; Multiple cursors
(straight-use-package 'multiple-cursors)
(require 'multiple-cursors)

;; mc-lists
(setq mc/list-file (concat config-directory "mc-lists.el"))

;; Create cursors
(global-set-key (kbd "C-.")         #'mc/mark-next-like-this)
(global-set-key (kbd "C-;")         #'mc/mark-previous-like-this)
(global-set-key (kbd "C-<mouse-1>") #'mc/add-cursor-on-click)
(global-unset-key [C-down-mouse-1]) ; necessary

;; Return as usual
(define-key mc/keymap (kbd "<return>")       #'electric-newline-and-maybe-indent)

;; Exit multiple-cursors-mode
(define-key mc/keymap (kbd "<escape>")       #'multiple-cursors-mode)
(define-key mc/keymap (kbd "<mouse-1>")      #'multiple-cursors-mode)
(define-key mc/keymap (kbd "<down-mouse-1>")   nil) ; necessary

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
	      (comment-or-uncomment-region beg end))
    ;; Move to the beginning of the next line
    (beginning-of-line-text 2)))

(global-set-key (kbd "C-x ;") #'custom/smart-comment)

;; Ensure rectangular-region-mode is loaded
(require 'rectangular-region-mode)

;; Multiple cursor rectangle definition mouse event
(defun custom/mouse-rectangle (start-event)
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

(global-set-key (kbd "M-<down-mouse-1>") #'custom/mouse-rectangle)

;; Enter multiple-cursors-mode
(defun custom/rectangular-region-multiple-cursors ()
  (interactive)
  (rectangular-region-mode 0)
  (multiple-cursors-mode 1)
  (deactivate-mark)
  (mc/for-each-fake-cursor
   (if (invisible-p (marker-position (overlay-get cursor 'point)))
       (mc/remove-fake-cursor cursor))))

(define-key rectangular-region-mode-map (kbd "<return>") #'custom/rectangular-region-multiple-cursors)

;; Exit rectangular-region-mode
(define-key rectangular-region-mode-map (kbd "<escape>") #'rrm/keyboard-quit)
(define-key rectangular-region-mode-map (kbd "<mouse-1>") #'rrm/keyboard-quit)

(tab-bar-mode 1)

;; Disable visible scroll bar
(scroll-bar-mode -1)

;; Disable toolbar
(tool-bar-mode -1)

;; Disable tooltips
(tooltip-mode -1)

;; Disable menu bar
(menu-bar-mode -1)

;; Frame name
(setq-default frame-title-format '("Emacs [%m] %b"))

;; Fringe mode
(set-fringe-mode nil)

;; Enable visual bell
(setq visible-bell t)

(advice-add 'yes-or-no-p :override #'y-or-n-p)

(if (version< "29.0" emacs-version)
    (pixel-scroll-precision-mode))

;; Center text
(straight-use-package 'olivetti)

(add-hook 'olivetti-mode-on-hook (lambda () (olivetti-set-width 0.9)))

;; Normal modes
(dolist (mode '(org-mode-hook
		   magit-mode-hook
		   shell-mode-hook
		   markdown-mode-hook))
  (add-hook mode 'olivetti-mode))

;; Programming modes
(add-hook 'prog-mode-hook 'olivetti-mode)

(defcustom custom/mode-line nil
  "Variable containing the format of the hidden mode line")

(defcustom custom/header-line nil
  "Variable containing the format of the hidden header line")

(defun custom/hide-modeline ()
  "Hide `modeline' in current buffer"
  (interactive)
  (let ((m mode-line-format)
        (h header-line-format))
       (custom/@buffers (if (or m h)
                            (progn (setq custom/mode-line   m)
                                   (setq custom/header-line h)
                                   (setq mode-line-format   nil)
                                   (setq header-line-format nil))
                          (progn (setq mode-line-format custom/mode-line)
                                 (setq header-line-format custom/header-line))))))

(global-set-key (kbd "M-m") #'custom/hide-modeline)

(defun custom/variable-replace (a b)
  "Set the value of `b' to that of `a', and
that of `a' to nil in all buffers"
  (let ((line (symbol-value a)))
    (custom/@buffers (progn (set b line)
                            (set a nil)))))

(defun custom/mode-line-invert ()
  (interactive)
  (let ((m 'mode-line-format)
        (h 'header-line-format))
    (if mode-line-format
        (custom/variable-replace m h)
      (custom/variable-replace h m))))

(global-set-key (kbd "M-t") #'custom/mode-line-invert)

;; Display line numbers by side
(global-set-key (kbd "C-c l") #'display-line-numbers-mode)

;; Display column number
(column-number-mode)

(straight-use-package 'workgroups)
(require 'workgroups)

(setq wg-prefix-key (kbd "C-c w"))

;; save commands
(define-key wg-map (kbd "s")   #'wg-save)
(define-key wg-map (kbd "C-s") #'wg-update-all-workgroups-and-save)

;; suppress animation
(setq wg-morph-on nil)

(workgroups-mode 1)

(desktop-save-mode 1)

;; Swiper
(straight-use-package 'swiper)
(require 'swiper)

(defun custom/swiper-isearch (orig-fun &rest args)
  "`swiper-isearch' the selected region. If none are, `swiper-isearch'."
  (if (region-active-p)
      (let ((beg (region-beginning))
	    (end (region-end)))
	(deactivate-mark)
	(apply orig-fun (list (buffer-substring-no-properties beg end))))
    (apply orig-fun args)))

(advice-add 'swiper-isearch :around #'custom/swiper-isearch)

(define-key global-map (kbd "C-s") #'swiper-isearch)

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
(define-key swiper-map (kbd "M-<return>") #'custom/swiper-multiple-cursors)

(global-set-key (kbd "C-c SPC") #'whitespace-mode)

;; ivy
(straight-use-package 'ivy)
(require 'ivy)

(ivy-mode 1)

;; minibuffer bindings
(let ((map ivy-minibuffer-map))
  (cl-loop for binding in '(("<tab>"       . ivy-alt-done)
			        ("<up>"        . ivy-previous-line-or-history)
				("C-l"         . ivy-alt-done)
				("C-j"         . ivy-next-line)
				("C-k"         . ivy-previous-line)
				("<backspace>" . ivy-backward-delete-char))
            collect (define-key map (kbd (car binding)) (cdr binding))))

;; switch-buffer bindings
(let ((map ivy-switch-buffer-map))
  (cl-loop for binding in '(("C-k"   . ivy-previous-line)
 			        ("C-l"   . ivy-done)
				("C-d"   . ivy-switch-buffer-kill))
            collect (define-key map (kbd (car binding)) (cdr binding))))

;; reverse-i-search bindings
(let ((map ivy-reverse-i-search-map))
  (cl-loop for binding in '(("C-k"   . ivy-previous-line)
			        ("C-d"   . ivy-reverse-i-search-kill))
            collect (define-key map (kbd (car binding)) (cdr binding))))

(straight-use-package 'counsel)
(require 'counsel)

(global-set-key (kbd "<menu>") #'counsel-M-x)

;; Command suggestions
(straight-use-package 'which-key)
(require 'which-key)

(setq which-key-idle-delay 1.0)

(which-key-mode)

;; Replace description key bindings by their helpful equivalents
(straight-use-package 'helpful)

(setq counsel-describe-function-function  #'helpful-callable)
(setq counsel-describe-variable-function  #'helpful-variable)

(global-set-key [remap describe-function] #'helpful-function)
(global-set-key [remap describe-command]  #'helpful-command)
(global-set-key [remap describe-variable] #'helpful-variable)
(global-set-key [remap describe-key]      #'helpful-key)

;; command-log-mode
(straight-use-package 'command-log-mode)
(require 'command-log-mode)

(global-command-log-mode)

;; yasnippet
(straight-use-package 'yasnippet)

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
(straight-use-package 'yasnippet-snippets)

;; Double end to go to the beginning of line
(defvar custom/double-end-timeout 0.4)

(defun custom/double-end ()
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

(global-set-key (kbd "<end>") #'custom/double-end)

(defun custom/home ()
  "Conditional homing. 

Default: `beginning-of-line-text'

If the current line is empty, home to `beginning-of-line'.

If the current line holds a list item, home back to `beginning-of-line-text'.

If the current line is indented, home `back-to-indentation'.

If the current mode is derived from `prog-mode', home `back-to-indentation'.

If the current line is a wrapped visual line, home to
`beginning-of-visual-line'."
  (interactive)
  (cond ((custom/relative-line-empty)    (beginning-of-line))
	    ((custom/relative-line-list)     (beginning-of-line-text))
	    ((custom/relative-line-indented) (back-to-indentation))
	    ((custom/relative-line-wrapped)  (beginning-of-visual-line))
	    ((derived-mode-p 'prog-mode)     (back-to-indentation))
	    ((custom/relative-line-wrapped)  (beginning-of-visual-line))
        (t                               (beginning-of-line-text))))

(defvar custom/double-home-timeout 0.4)

(defun custom/double-home ()
  "Dynamic homing command with a timeout of `custom/double-home-timeout' seconds.
- Single press: `custom/home' 
- Double press: `beginning-of-visual-line'"
  (interactive)
  (let ((last-called (get this-command 'custom/last-call-time)))
    (if (and (eq last-command this-command)
	           (<= (time-to-seconds (time-since last-called)) custom/double-home-timeout))
	      (progn (beginning-of-visual-line)
		     (beginning-of-line-text))
      (custom/home)))
  (put this-command 'custom/last-call-time (current-time)))

(global-set-key (kbd "<home>") #'custom/double-home)

(defun custom/previous-line (cond)
  "If a region is active and the current mode is derived 
from `prog-mode', arrow-up to `end-of-visual-line' of
`previous-line'."
  (interactive)
  (if (and (region-active-p) cond)
      (progn (previous-line)
	           (point-to-register 'region-up-register)
	           (end-of-visual-line))
    (previous-line)))

(global-set-key (kbd "<up>") (lambda () (interactive) (custom/previous-line (derived-mode-p 'prog-mode))))

(defun custom/region-up-register ()
  "Move cursor to `region-up-register', defined in
`custom/previous-line'."
  (interactive)
  (let ((end (region-end)))
    (ignore-errors (jump-to-register 'region-up-register))
    (set-register 'region-up-register nil)
    (push-mark end)))

(global-set-key (kbd "S-<home>") #'custom/region-up-register)

(defun custom/beginning-of-line-text (orig-fun &rest args)
  "Correctly go to `beginning-of-line-text' in numbered lists."
  (interactive)
  (let ((ordered-line-regex "^[[:blank:]]*[0-9]+[.\\)]\\{1\\}[[:blank:]]\\{1\\}"))
    (if (save-excursion (beginning-of-line)
			    (looking-at-p ordered-line-regex))
	    (progn (beginning-of-line)
		   (re-search-forward ordered-line-regex))
      (apply orig-fun args))))

(advice-add 'beginning-of-line-text :around #'custom/beginning-of-line-text)

;; Split and follow
(defun split-and-follow-horizontally ()
  (interactive)
  (split-window-below)
  (other-window 1))
(global-set-key (kbd "C-x 2") #'split-and-follow-horizontally)

(defun split-and-follow-vertically ()
  (interactive)
  (split-window-right)
  (other-window 1))
(global-set-key (kbd "C-x 3") #'split-and-follow-vertically)

;; ace-window
(straight-use-package 'ace-window)
(require 'ace-window)

(global-set-key (kbd "C-x o") 'ace-window)

;; winner mode
(winner-mode)

(global-set-key (kbd "C-x -") #'balance-windows)

(setq split-width-threshold 70)

(defvar custom/window-previous nil
  "Selected window before the last window change.")

(defvar custom/window-pre-command nil
  "Auxiliary variable containing the `selected-window'
before the execution of any command.")

(defun custom/record-window-pre-command ()
  (setq custom/window-pre-command (selected-window)))
(add-hook 'pre-command-hook #'custom/record-window-pre-command)

(defun custom/record-window-previous ()
  (let ((window-post (selected-window)))
    (if (not (eq window-post custom/window-pre-command))
	      (setq custom/window-previous custom/window-pre-command))))
(add-hook 'post-command-hook #'custom/record-window-previous)

(defun custom/goto-window-previous ()
  (interactive)
  (let ((target  custom/window-previous)
	      (current (selected-window)))
    (if target
	      (progn (select-window target)
		     (setq custom/window-previous current)))))

(global-set-key (kbd "C-c p") #'custom/goto-window-previous)

;; Create new frame
(global-set-key (kbd "C-S-n") #'make-frame-command)

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

(defun custom/double-escape ()
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

(global-set-key (kbd "<escape>") #'custom/double-escape)

;; projectile
(straight-use-package 'projectile)
(require 'projectile)

(projectile-mode)

;; command map prefix
(define-key projectile-mode-map (kbd "M-p") 'projectile-command-map)

(straight-use-package 'treemacs)
(require 'treemacs)

(defvar custom/treemacs-ignored '(".*__pycache__.*")
  "Files and directories ignored by treemacs")

(defun custom/treemacs-ignore-filter (file _)
  (cl-loop for ignored in custom/treemacs-ignored
	   if (string-match ignored file)
	      return t
	   finally return nil))
(push #'custom/treemacs-ignore-filter treemacs-ignored-file-predicates)

(cl-loop for binding in '(("M-0"       . treemacs-select-window)
			      ("C-x t 1"   . treemacs-delete-other-windows)
			      ("C-x t t"   . treemacs)
			      ("C-x t d"   . treemacs-select-directory)
			      ("C-x t B"   . treemacs-bookmark)
			      ("C-x t C-t" . treemacs-find-file)
			      ("C-x t M-t" . treemacs-find-tag))
	 collect (global-set-key (kbd (car binding)) (cdr binding)))

(setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
      treemacs-deferred-git-apply-delay        0.5
      treemacs-directory-name-transformer      #'identity
      treemacs-display-in-side-window          t
      treemacs-eldoc-display                   'simple
      treemacs-file-event-delay                5000
      treemacs-file-extension-regex            treemacs-last-period-regex-value
      treemacs-file-follow-delay               0.2
      treemacs-file-name-transformer           #'identity
      treemacs-follow-after-init               t
      treemacs-expand-after-init               t
      treemacs-find-workspace-method           'find-for-file-or-pick-first
      treemacs-git-command-pipe                ""
      treemacs-goto-tag-strategy               'refetch-index
      treemacs-indentation                     2
      treemacs-indentation-string              " "
      treemacs-is-never-other-window           nil
      treemacs-max-git-entries                 5000
      treemacs-missing-project-action          'ask
      treemacs-move-forward-on-expand          nil
      treemacs-no-png-images                   nil
      treemacs-no-delete-other-windows         t
      treemacs-project-follow-cleanup          nil
      treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
      treemacs-position                        'left
      treemacs-read-string-input               'from-child-frame
      treemacs-recenter-distance               0.1
      treemacs-recenter-after-file-follow      nil
      treemacs-recenter-after-tag-follow       nil
      treemacs-recenter-after-project-jump     'always
      treemacs-recenter-after-project-expand   'on-distance
      treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
      treemacs-show-cursor                     nil
      treemacs-show-hidden-files               t
      treemacs-silent-filewatch                nil
      treemacs-silent-refresh                  nil
      treemacs-sorting                         'alphabetic-asc
      treemacs-select-when-already-in-treemacs 'move-back
      treemacs-space-between-root-nodes        t
      treemacs-tag-follow-cleanup              t
      treemacs-tag-follow-delay                1.5
      treemacs-text-scale                      nil
      treemacs-user-mode-line-format           nil
      treemacs-user-header-line-format         nil
      treemacs-wide-toggle-width               70
      treemacs-width                           35
      treemacs-width-increment                 1
      treemacs-width-is-initially-locked       t
      treemacs-workspace-switch-cleanup        nil)

;; The default width and height of the icons is 22 pixels. If you are
;; using a Hi-DPI display, uncomment this to double the icon size.
;; (treemacs-resize-icons 44)

(treemacs-follow-mode t)
(treemacs-filewatch-mode t)
(treemacs-fringe-indicator-mode 'always)

(pcase (cons (not (null (executable-find "git")))
             (not (null treemacs-python-executable)))
  (`(t . t)
   (treemacs-git-mode 'deferred))
  (`(t . _)
   (treemacs-git-mode 'simple)))

(treemacs-hide-gitignored-files-mode nil)

(straight-use-package 'treemacs-icons-dired)

(straight-use-package 'treemacs-projectile)

(straight-use-package 'treemacs-tab-bar)

(straight-use-package 'treemacs-magit)

(straight-use-package 'magit)

(global-set-key (kbd "C-x g") #'magit-status)

(require 'ide (concat config-directory "ide.el"))

;; remove duplicates in shell history
(setq comint-input-ignoredups t)

(require 'org (concat config-directory "org.el"))

;; Transform all files in directory from DOS to Unix line breaks
(defun custom/dos2unix (&optional dir)
  (let ((default-directory (or dir (file-name-directory buffer-file-name))))
    (shell-command "find . -maxdepth 1 -type f -exec dos2unix \\{\\} \\;")))

(defun custom/reload-from-disk (&optional buffer)
  "Revert BUFFER contents to the contents of its
file saved on disk, ignoring the auto-save file.
If the buffer has unsaved modifications, prompt
the user for confirmation."
  (interactive)
  (let ((buffer (or buffer (current-buffer))))
    (save-window-excursion
      (switch-to-buffer buffer)
      (if (not (buffer-modified-p))
	     (revert-buffer t t)
	   (revert-buffer t nil)))))

(global-set-key (kbd "C-c r") #'custom/reload-from-disk)

(require 'ui (concat config-directory "ui.el"))

(require 'theme (concat config-directory "theme.el"))

;; Theme load hook
(defvar custom/load-theme-hook nil
   "`load-theme' hook.")

(defun custom/load-theme-hook (&rest _args)
   "Run `load-theme-hook'."
   (run-hooks 'custom/load-theme-hook))

(advice-add 'load-theme :after #'custom/load-theme-hook)

;; Reload Org Mode
(defun custom/org-theme-reload ()
  (if (custom/in-mode "org-mode")
      (org-mode)
    (progn
      (setq window (get-buffer-window (current-buffer)))
      (cl-loop for buffer in (custom/visible-buffers)
	             collect (select-window (get-buffer-window buffer))
	 	     if (custom/in-mode "org-mode")
		        collect (org-mode))
      (select-window window))))

(add-hook 'custom/load-theme-hook #'custom/org-theme-reload)

;; Conclude initialization file
(provide 'home)
