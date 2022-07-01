;; Default face
(set-face-attribute 'default nil        :font "Fira Code Retina" :height 93)

;; Fixed pitch face
(set-face-attribute 'fixed-pitch nil    :font "Fira Code Retina" :height 93)

;; Variable pitch face
(set-face-attribute 'variable-pitch nil :font "PT Sans"  :height 100 :weight 'regular)

;; Italic
(defface custom/italic
  '((t :font "Victor Mono" :height  90 :weight  bold :slant italic))
  "Italic typeface")

;; accent typefaces
(defvar custom/accents '(custom/italic))

(defun custom/theme-accents (orig-fun &rest args)
  "Many themes will override certain face *attributes*, such as `italic'. To prevent
this, this function loops over all accent typefaces in `custom/accents', which contains
faces (defined with `defface') named ~custom/<attribute>~, and makes the ~<attribute>~
inherit from ~custom/<attribute>~.

As such, when this function is run, the `italic' face attribute will be made to
inherit from `custom/italic' as in the expression below.

   (set-face-attribute 'italic nil :inherit 'custom/italic)

Thus, our preferred accent typefaces will stand whatever harassment they may be put
through as a theme loads."
  ;; load theme
  (apply orig-fun args)
  ;; restore accents
  (cl-loop for accent in custom/accents
	   collect (let ((face (intern (car (last (split-string (symbol-name accent) "/"))))))
		     (set-face-attribute face nil :inherit accent))))

(advice-add 'load-theme :around #'custom/theme-accents)

;; Titles
(setq typeface-title "Ringbearer")

;; Heading face
(setq typeface-heading "Century Gothic")

;; Mode line
(set-face-attribute 'mode-line nil :height 85 :inherit 'fixed-pitch)

;; Symbol library
(straight-use-package 'all-the-icons)

;; Title face

(defun custom/org-typeface-title ()
  (with-eval-after-load 'org-faces
    (set-face-attribute 'org-document-title nil :font typeface-title :height 300 :weight 'regular :foreground 'unspecified)))

(add-hook 'org-mode-hook #'custom/org-typeface-title)

(defun custom/org-typefaces-body ()
  (with-eval-after-load 'org-faces

    ;; Code
    (set-face-attribute 'org-block                 nil :foreground nil :inherit 'fixed-pitch)
    (set-face-attribute 'org-code                  nil                 :inherit '(shadow fixed-pitch))
    (set-face-attribute 'org-verbatim              nil                 :inherit '(shadow fixed-pitch))

    ;; Tables
    (set-face-attribute 'org-table                 nil                 :inherit '(shadow fixed-pitch))

    ;; Lists
    (set-face-attribute 'org-checkbox              nil                 :inherit 'fixed-pitch)

    ;; Meta
    (set-face-attribute 'org-meta-line             nil                 :inherit 'fixed-pitch)
    (set-face-attribute 'org-document-info         nil                 :inherit 'fixed-pitch)
    (set-face-attribute 'org-document-info-keyword nil                 :inherit 'fixed-pitch)
    (set-face-attribute 'org-special-keyword       nil                 :inherit 'fixed-pitch)))

(add-hook 'org-mode-hook #'custom/org-typefaces-body)

(defun custom/org-typeface-indent ()
  "Indent typeface used in `org-indent-mode' and `visual-line-mode'."
  (with-eval-after-load 'org-indent-mode
    (set-face-attribute 'org-indent                nil                 :inherit '(org-hide fixed-pitch))))

(add-hook 'org-mode-hook #'custom/org-typeface-indent)

;; Use levels 1 through 8
(setq org-n-level-faces 8)

;; Do not cycle header style after 8th level
(setq org-cycle-level-faces nil)

;; Hide leading stars
(setq org-hide-leading-starts t)

;; Font sizes
(defun custom/org-header-setup () 
  (with-eval-after-load 'org-faces

    ;; Heading font sizes
    (dolist (face '((org-level-1 . 1.6)
                    (org-level-2 . 1.4)
                    (org-level-3 . 1.3)
                    (org-level-4 . 1.2)
                    (org-level-5 . 1.15)
                    (org-level-6 . 1.10)
                    (org-level-7 . 1.05)
                    (org-level-8 . 1.00)))
         (set-face-attribute (car face) nil :font typeface-heading :weight 'bold :height (cdr face)))))

(add-hook 'org-mode-hook #'custom/org-header-setup)

(straight-use-package 'svg-tag-mode)

(defconst date-re "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}")
(defconst time-re "[0-9]\\{2\\}:[0-9]\\{2\\}")
(defconst day-re "[A-Za-z]\\{3\\}")
(defconst day-time-re (format "\\(%s\\)? ?\\(%s\\)?" day-re time-re))

(defun svg-progress-percent (value)
  (svg-image (svg-lib-concat
              (svg-lib-progress-bar (/ (string-to-number value) 100.0)
                                nil :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
              (svg-lib-tag (concat value "%")
                           nil :stroke 0 :margin 0)) :ascent 'center))

(defun svg-progress-count (value)
  (let* ((seq (mapcar #'string-to-number (split-string value "/")))
         (count (float (car seq)))
         (total (float (cadr seq))))
  (svg-image (svg-lib-concat
              (svg-lib-progress-bar (/ count total) nil
                                    :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
              (svg-lib-tag value nil
                           :stroke 0 :margin 0)) :ascent 'center)))

(setq svg-tag-tags
      `(
        ;; Org tags
        (":\\([A-Za-z0-9]+\\)" . ((lambda (tag) (svg-tag-make tag))))
        (":\\([A-Za-z0-9]+[ \-]\\)" . ((lambda (tag) tag)))
        
        ;; Task priority
        ("\\[#[A-Z]\\]" . ( (lambda (tag)
                              (svg-tag-make tag :face 'org-priority 
                                            :beg 2 :end -1 :margin 0))))

        ;; Progress
        ("\\(\\[[0-9]\\{1,3\\}%\\]\\)" . ((lambda (tag)
                                            (svg-progress-percent (substring tag 1 -2)))))
        ("\\(\\[[0-9]+/[0-9]+\\]\\)" . ((lambda (tag)
                                          (svg-progress-count (substring tag 1 -1)))))
        
        ;; TODO / DONE
        ("TODO" . ((lambda (tag) (svg-tag-make "TODO" :face 'org-todo :inverse t :margin 0))))
        ("DONE" . ((lambda (tag) (svg-tag-make "DONE" :face 'org-done :margin 0))))


        ;; Citation of the form [cite:@Knuth:1984]
        ("\\(\\[cite:@[A-Za-z]+:\\)" . ((lambda (tag)
                                          (svg-tag-make tag
                                                        :inverse t
                                                        :beg 7 :end -1
                                                        :crop-right t))))
        ("\\[cite:@[A-Za-z]+:\\([0-9]+\\]\\)" . ((lambda (tag)
                                                (svg-tag-make tag
                                                              :end -1
                                                              :crop-left t))))
        
        ;; Active date (with or without day name, with or without time)
        (,(format "\\(<%s>\\)" date-re) .
         ((lambda (tag)
            (svg-tag-make tag :beg 1 :end -1 :margin 0))))
        (,(format "\\(<%s \\)%s>" date-re day-time-re) .
         ((lambda (tag)
            (svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0))))
        (,(format "<%s \\(%s>\\)" date-re day-time-re) .
         ((lambda (tag)
            (svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0))))

        ;; Inactive date  (with or without day name, with or without time)
         (,(format "\\(\\[%s\\]\\)" date-re) .
          ((lambda (tag)
             (svg-tag-make tag :beg 1 :end -1 :margin 0 :face 'org-date))))
         (,(format "\\(\\[%s \\)%s\\]" date-re day-time-re) .
          ((lambda (tag)
             (svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0 :face 'org-date))))
         (,(format "\\[%s \\(%s\\]\\)" date-re day-time-re) .
          ((lambda (tag)
             (svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0 :face 'org-date))))))

;; Highlight HTML color strings in their own color
(straight-use-package 'rainbow-mode)

(display-time-mode t)

;; Customize names displayed in mode line
(straight-use-package 'delight)
(require 'delight)

;; Remove default modes from mode line
(delight '((global-command-log-mode nil "")
	      (olivetti-mode           nil "")
	      (which-key-mode          nil "")
	      (visual-line-mode        nil "simple")
	      (buffer-face-mode        nil "simple")
	      (org-indent-mode         nil "org")
	      (eldoc-mode              nil "eldoc")
	      ;; Major modes
	      (emacs-lisp-mode "EL" :major)))

(setq org-hide-emphasis-markers t)

;; org-appear
(straight-use-package '(org-appear :type git :host github :repo "awth13/org-appear"))
(add-hook 'org-mode-hook 'org-appear-mode)

(setq org-appear-autolinks t)

(setq org-hidden-keywords '(title))

(add-hook 'org-mode-hook (lambda () (progn (visual-line-mode 1) (setq line-move-visual t))))

(add-hook 'org-mode-hook (lambda () (org-indent-mode 1)))

(plist-put org-format-latex-options :scale 1.5)

;; Change ellipsis ("...") to remove clutter
(setq org-ellipsis " ♢")

(straight-use-package 'org-modern)

(add-hook 'org-mode-hook #'org-modern-mode)
(add-hook 'org-agenda-finalize-hook #'org-modern-agenda)

(setq org-modern-list '((?+ . "-")
 		  	     (?- . "•")
 			     (?* . "▶")))

(setq org-modern-checkbox nil)

;; Vertical table line width
(setq org-modern-table-vertical 1)

;; Horizontal table line width
(setq org-modern-table-horizontal 1)

;; Tags
(setq org-modern-tag nil)

;; Priorities
(setq org-modern-priority nil)

;; Provide theme
(provide 'ui)