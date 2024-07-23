(straight-use-package 'calfw)
(straight-use-package 'calfw-org)
(straight-use-package 'calfw-ical)

;; org-agenda configuration is lost otherwise
(with-eval-after-load 'org-agenda
  (require 'calfw-org)
  (require 'calfw-ical))

(defun mirage/org-calendar ()
  "Open `calfw' Org Agenda calendar."
  (interactive)
  (require 'org-agenda)
  (let ((inhibit-message t))
       (cfw:open-org-calendar)))

(global-set-key (kbd "C-c c") #'mirage/org-calendar)

(provide 'mirage-module-org-calendar)
;;; mirage-org-calendar.el ends here
