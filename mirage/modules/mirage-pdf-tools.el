;; requirements
(mirage-module 'tablist)

(straight-use-package 'pdf-tools)
(pdf-tools-install)
(pdf-loader-install)
(require 'pdf-tools)

;; page switching
(define-key pdf-view-mode-map (kbd "<up>")    #'pdf-view-previous-line-or-previous-page)
(define-key pdf-view-mode-map (kbd "<down>")  #'pdf-view-next-line-or-next-page)
(define-key pdf-view-mode-map (kbd "<left>")  #'pdf-view-previous-page)
(define-key pdf-view-mode-map (kbd "<right>") #'pdf-view-next-page)

;; replace swiper
(define-key pdf-view-mode-map (kbd "C-s") #'isearch-forward)

;; page display size
(setq-default pdf-view-display-size 'fit-page)
;; automatically annotate highlights
(setq pdf-annot-activate-created-annotations t)

;; [c]enter
(define-key pdf-view-mode-map (kbd "c") #'pdf-view-center-in-window)
;; [j]ump 
(define-key pdf-view-mode-map (kbd "j") #'pdf-view-goto-label)
;; [h]highlight
(define-key pdf-view-mode-map (kbd "h") #'pdf-annot-add-highlight-markup-annotation)
;; [t]ext annotation
(define-key pdf-view-mode-map (kbd "t") #'pdf-annot-add-text-annotation)
;; [d]elete annotation
(define-key pdf-view-mode-map (kbd "d") #'pdf-annot-delete)
;; lateral scrolling
(define-key pdf-view-mode-map (kbd "S-<wheel-up>")   #'image-forward-hscroll)
(define-key pdf-view-mode-map (kbd "S-<wheel-down>") #'image-backward-hscroll)

;; themed view
(define-key pdf-view-mode-map (kbd "C-c C-r t") #'pdf-view-themed-minor-mode)
;; fine-grained zooming
(setq pdf-view-resize-factor 1.1)

(provide 'mirage-module-pdf-tools)
;;; mirage-pdf-tools.el ends here
