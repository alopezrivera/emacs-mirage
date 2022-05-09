(defgroup custom/org-diary-mode-group nil
  "Group for customization"
  :prefix "custom/org-diary-")

(define-minor-mode custom/org-diary-mode
  "Org Diary minor mode."
  :init-value 1
  :lighter " Diary"
  :group 'custom/org-diary-mode-group

  (when (bound-and-true-p custom/org-diary-mode)
    (custom/org-diary-typeset))
  (when (not (bound-and-true-p custom/org-diary-mode))
    (custom/org-diary-font-lock-remove)))

(define-globalized-minor-mode custom/org-diary-global-minor-mode custom/org-diary-mode custom/org-diary-mode :group 'custom/org-diary-mode-group)

(defcustom custom/org-diary-directory "/home/journal/diary/"
  "Org Diary directory."
  :group 'custom/org-diary-mode-group)

(defcustom custom/org-diary-time-format-file  "%d.%m.%Y"
  "Org Diary time format: file names."
  :group 'custom/org-diary-mode-group)

(defcustom custom/org-diary-time-format-title "%d/%m/%Y"
  "Org Diary time format: entry titles."
  :group 'custom/org-diary-mode-group)

(defcustom custom/org-diary-file-format (concat custom/org-diary-directory
					  custom/org-diary-time-format-file
					  ".org")
  "Org Diary file name format."
  :group 'custom/org-diary-mode-group)

(defcustom custom/org-diary-visit-in-new-window t
  "Open diary entries in new window."
  :group 'custom/org-diary-mode-group)

(defcustom custom/org-diary-new-window-fraction 0.3
  "New Org Diary window width as a fraction of the frame width."
  :group 'custom/org-diary-mode-group)

(defun custom/org-diary-typeset ()
  (variable-pitch-mode)
  (custom/org-diary-font-lock-add)
  (custom/org-diary-line-padding))

(defface custom/org-diary-typeface-hhmm
  '((nil :foreground "#eb07b6" :inherit 'fixed-pitch))
  "Org Diary typeface for hh:mm time stamps."
  :group 'custom/org-diary-mode-group)

(defcustom custom/org-diary-keyword-hhmm '("[0-9]\\{2\\}:[0-9]\\{2\\}.*$" . 'custom/org-diary-typeface-hhmm)
  "Org Diary hh:mm typeface keyword."
  :group 'custom/org-diary-mode-group)

(defcustom custom/org-diary-keywords (list custom/org-diary-keyword-hhmm)
  "Org Diary font-lock keywords.")

(defun custom/org-diary-font-lock-add ()
  (font-lock-add-keywords nil custom/org-diary-keywords)
  (font-lock-fontify-buffer))

(defun custom/org-diary-font-lock-remove ()
  (font-lock-remove-keywords nil custom/org-diary-keywords)
  (font-lock-fontify-buffer))

(defcustom custom/org-diary-line-padding 2
  "Org Diary line padding factor."
  :group 'custom/org-diary-mode-group)

(defun custom/org-diary-line-padding ()
  "Set padding between Org Diary entry lines."
  ;; remove padding overlays if they already exist
  (let ((overlays (overlays-at (point-min))))
    (while overlays
      (let ((overlay (car overlays)))
        (if (overlay-get overlay 'is-padding-overlay)
            (delete-overlay overlay)))
      (setq overlays (cdr overlays))))
  ;; add a new padding overlay
  (let ((padding-overlay (make-overlay (point-min) (point-max))))
    (overlay-put padding-overlay 'is-padding-overlay t)
    (overlay-put padding-overlay 'line-spacing (* .1 custom/org-diary-line-padding))
    (overlay-put padding-overlay 'line-height (+ 1 (* .1 custom/org-diary-line-padding))))
  (setq mark-active nil))

(defun custom/org-diary-parse-time (string)
  "Parse time string. Currently hardcoded to parse time
strings in the format `%d/%m/%Y'."
  (let ((dmy (cl-loop for n in (split-string string "/")
		            collect (string-to-number n))))
    (encode-time (list 0 0 0 (nth 0 dmy) (nth 1 dmy) (nth 2 dmy) nil nil nil))))

(defun custom/org-diary-time-string-file (time)
  (format-time-string custom/org-diary-file-format time))

(defun custom/org-diary-time-string-title (time)
  (format-time-string custom/org-diary-time-format-title time))

(defun custom/org-diary-buffer-entry (buffer)
  (string-match-p "^[0-9]\\{2\\}\\.[0-9]\\{2\\}\\.[0-9]\\{4\\}\\.org" (file-name-nondirectory buffer)))

(defun custom/org-diary-in-entry ()
  "Return t if current buffer is an `custom/org-diary-buffer-entry'."
  (ignore-errors (custom/org-diary-buffer-entry buffer-file-name)))

(defun custom/org-diary-entry-time ()
  (let ((title (custom/org-get-title-current-buffer)))
    (custom/org-diary-parse-time title)))

(defun custom/org-diary-entry-date ()
  "Retrieve the time of the current Org Diary
file in `custom/org-diary-time-format-file'."
  (custom/org-diary-time-string-file (custom/org-diary-entry-time)))

(defun custom/org-diary-entry-unsaved-buffer (time)
  "Return t if the Org Diary entry for TIME exists
in an unsaved buffer."
  (let ((file (custom/org-diary-time-string-file time)))
    (cl-loop for buffer in (buffer-list)
	           if (and (buffer-file-name buffer)
			   (string-equal file (buffer-file-name buffer))) return t
		   finally return nil)))

(defun custom/org-diary-browse ()
  "Org Agenda-like list of diary entries.
Options:
- org-recenter -> show diary at point in side by side window
- enter -> jump to diary entry at point
- quit -> quit and return to previous window config, buffer and visibility
  - org-agenda -> save current window config, visibility"
  (interactive))

(defun custom/org-diary-visit (time &optional arg)
  "Open the Org Diary entry corresponding to the specified time.
-             '(0):  noselect
- C-u         '(4):  visit in current buffer
- C-u C-u     '(16): save new entry after initialiation
- C-u C-u C-u '(64): visit in current buffer and save new entry after initialization"
  (interactive)
  (let ((entry          (custom/org-diary-time-string-file time))
	    (save           (or (equal arg '(16)) (equal arg '(64))))
	    (noselect       (equal arg '(1)))
	    (current-buffer (if arg
				(or (equal arg '(4)) (equal arg '(64)))
			      (not custom/org-diary-visit-in-new-window))))
       ;; Whether to initialize the diary entry
       (setq init (not (or (file-exists-p entry) (custom/org-diary-entry-unsaved-buffer time))))
       ;; Open entry
       (if noselect
	       (find-file-noselect entry)
	     (if current-buffer
		 (find-file entry)
	       (progn (find-file-other-window entry)
	              (if (not (ignore-errors (custom/window-resize-fraction custom/org-diary-new-window-fraction)))
			  (delete-other-windows)))))
       ;; Initialize
       (if init (custom/org-diary-init time))
       ;; Save buffer
       (if (and init save) (save-buffer))
       ;; Enable `org-diary-mode'
       (custom/org-diary-mode)
       ;; Go to end of buffer
       (end-of-buffer)))

(defun custom/org-diary-today (&optional arg)
  "Open the Org Diary entry for today, creating it if
it does not exist."
  (interactive)
  (custom/org-diary-visit (current-time) arg))

(defun custom/org-diary-jump (number)
  (interactive)
  (let ((custom/org-diary-visit-in-new-window (not (custom/org-diary-in-entry)))
	  (time-jump (time-add (custom/org-diary-entry-time) (days-to-time number))))
       (custom/org-diary-visit time-jump '(4))))

(defun custom/org-diary-prior ()
  (interactive)
  (custom/org-diary-jump -1))

(defun custom/org-diary-next ()
  (interactive)
  (custom/org-diary-jump 1))

(defun custom/org-diary-init (time)
  "Set up Org Diary entry."
  (interactive)
  (insert (concat "#+title:" (custom/org-diary-time-string-title time) "\n"))
  (insert "#+CREATED: ")
  (org-time-stamp-inactive '(16))
  (insert "\n\n\n"))

(defun custom/org-diary-insert-time (format)
  "Insert current time using the given FORMAT."
  (insert (format-time-string format (current-time))))

(defun custom/org-diary-insert-time-hhmm ()
  "Insert current time using the given FORMAT."
  (interactive)
  (custom/org-diary-insert-time "%H:%M"))

(defun custom/org-diary (&optional arg)
  "Org Diary entry point.

Activate when visiting files matching pattern.

Bindings:
- C-<up>   -> previous entry if it exists
- C-<down> -> next entry if it exists
- C-n      -> new entry"
  (interactive)
  (if (custom/org-diary-in-entry)
      (progn (custom/org-diary-mode 0)
	       (delete-window))
    (progn (custom/org-diary-today arg)
	     (custom/org-diary-mode 1))))

(add-hook 'after-init-hook (lambda () (custom/org-diary '(4))))

(global-set-key (kbd "C-c d") 'custom/org-diary)

(define-key org-mode-map (kbd "C-d")     'custom/org-diary-insert-time-hhmm)
(define-key org-mode-map (kbd "C-<prior>") 'custom/org-diary-prior)
(define-key org-mode-map (kbd "C-<next>")  'custom/org-diary-next)

(provide 'org-diary)
