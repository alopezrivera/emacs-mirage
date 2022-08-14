;; required as of Org 9.2
(require 'org-tempo)

;; navigation
(global-set-key (kbd "C-<tab>")         'tempo-forward-mark)
(global-set-key (kbd "C-<iso-lefttab>") 'tempo-backward-mark)

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
(tempo-define-template "figure"
		          '("#+NAME: fig:" p n
			    "#+CAPTION: " p n
			    "#+ATTR_ORG: :width 450" n
			    "[[./" p "]]" >)
			  "<f"
			  "Org Mode figure template")

(defun custom/tempo-code-block (key language)
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
		   ("<bash" "bash")))
  (apply 'custom/tempo-code-block pair))

(provide 'shapes-module-org-tempo)
;;; shapes-org-tempo.el ends here
