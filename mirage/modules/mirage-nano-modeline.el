;; nano-modeline
(straight-use-package 'nano-modeline)

;; mode line initialization hook
(add-hook 'after-init-hook #'nano-modeline-mode)

(provide 'mirage-module-nano-modeline)
;;; mirage-nano-modeline.el ends here
