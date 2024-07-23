;; required as of Org 9.2
(require 'org-tempo)

;; navigation
(define-key org-mode-map (kbd "C-c f") #'tempo-forward-mark)
(define-key org-mode-map (kbd "C-c b") #'tempo-backward-mark)

;; inhibit electric-pair completion of <
(add-hook 'org-mode-hook
          (lambda () (setq-local electric-pair-inhibit-predicate
                                 `(lambda (c) (if (char-equal c ?<) t (,electric-pair-inhibit-predicate c))))))

;; equations
(tempo-define-template "latex-equation"
		          '("#+NAME: eq:" p n
			    "\\begin{equation}" n
			    p n
			    "\\end{equation}" >)
			  "<eq"
			  "LaTeX equation template")

(tempo-define-template "latex-derivation"
		          '("#+NAME: eq:" p n
			    "\\begin{equation}" n
			    "\\arraycolsep=3pt\\def\\arraystretch{2.25}" n
			    "\\begin{array}{lll}" n
			    p n
			    "\\end{array}" n
			    "\\end{equation}" >)
			  "<de"
			  "LaTeX derivation template")

;; figures
(tempo-define-template "fig"
		       '("#+NAME: fig:" p n
			 "#+CAPTION: " p n
			 "#+ATTR_ORG: :width 450" n
			 "[[./" p "]]" >)
		       "<fig"
		       "Org Mode figure template")

(defun mirage/tempo-code-block (key language)
  (tempo-define-template language
		         `("#+begin_src " ,language n
			   n
			   p n
			   n
			   "#+end_src" >)
			 key
			 language))

(dolist (pair '(("<sh"   "shell")
		("<el"   "emacs-lisp")
		("<py"   "python")
                ("<rs"   "rust")
                ("<cpp"  "C++")
		("<bash" "bash")
                ("<tx"   "latex")))
  (apply 'mirage/tempo-code-block pair))

(provide 'mirage-module-org-tempo)
;;; mirage-org-tempo.el ends here
