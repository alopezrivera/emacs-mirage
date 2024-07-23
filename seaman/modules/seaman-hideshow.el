(require 'hideshow)

(add-hook 'prog-mode-hook #'hs-minor-mode)

(defun mirage/hs-cycle (&optional level)
  (interactive "p")
  (save-excursion
    (let (message-log-max (inhibit-message t))
      (if (= level 1)
	  (pcase last-command
	    ('hs-cycle
	     (hs-hide-level 1)
	   (setq this-command 'hs-cycle-children))
	    ('hs-cycle-children
	     ;; TODO: Fix this case. `hs-show-block' needs to be
	     ;; called twice to open all folds of the parent
	     ;; block.
	     (save-excursion (hs-show-block))
	     (hs-show-block)
	     (setq this-command 'hs-cycle-subtree))
	    ('hs-cycle-subtree
	     (hs-hide-block))
	    (_
	     (if (not (hs-already-hidden-p))
		 (hs-hide-block)
	       (hs-hide-level 1)
	       (setq this-command 'hs-cycle-children))))
	(hs-hide-level level)
	(setq this-command 'hs-hide-level)))))

(defun mirage/hs-global-cycle ()
  (interactive)
  (pcase last-command
    ('hs-global-cycle
     (save-excursion (hs-show-all))
     (setq this-command 'hs-global-show))
    (_ (hs-hide-all))))

(define-key hs-minor-mode-map (kbd "C-\\") #'mirage/hs-cycle)

(provide 'mirage-module-hideshow)
;;; mirage-hideshow.el ends here
