(shapes-module "tablist")

(straight-use-package '(pdf-tools :type git :host github :repo "alopezrivera/pdf-tools"))
(pdf-tools-install)
(pdf-loader-install)
(require 'pdf-tools)

;; replace swiper
(define-key pdf-view-mode-map (kbd "C-s") #'isearch-forward)

;; page display size
(setq-default pdf-view-display-size 'fit-page)
;; automatically annotate highlights
(setq pdf-annot-activate-created-annotations t)

;; [c]enter
(define-key pdf-view-mode-map (kbd "c") #'pdf-view-center-in-window)
;; [j]ump 
(define-key pdf-view-mode-map (kbd "d") #'pdf-view-goto-label)
;; [h]highlight
(define-key pdf-view-mode-map (kbd "h") #'pdf-annot-add-highlight-markup-annotation)
;; [t]ext annotation
(define-key pdf-view-mode-map (kbd "t") #'pdf-annot-add-text-annotation)
;; [d]elete annotation
(define-key pdf-view-mode-map (kbd "d") #'pdf-annot-delete)

;; themed view
(add-hook 'pdf-view-mode-hook (lambda () (pdf-view-themed-minor-mode)))
(define-key pdf-view-mode-map (kbd "C-c C-r t") #'pdf-view-themed-minor-mode)
;; fine-grained zooming
(setq pdf-view-resize-factor 1.1)

(provide 'shapes-module-pdf-tools)
;;; shapes-pdf-tools.el ends here
