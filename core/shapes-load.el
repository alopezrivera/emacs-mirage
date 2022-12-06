(defcustom shapes-debug-on-error t
  "Whether to enter the debugger if a shapes module, layer or
extension fails to load.")

(defun shapes-load (type component)
  "Load a shapes COMPONENT of the given TYPE"
  (condition-case err
      (require (intern (concat "shapes-" type "-" component)) (concat config-directory type "s" "/shapes-" component ".el"))
    (error (progn (message "ERROR: shapes-%s %s load failed" component type)
		     (if shapes-debug-on-error
		         (debug err))))))

;; shapes modules
(defun shapes-module (module)
  "Load a shapes MODULE by name"
  (shapes-load "module" module))

;; shapes layers
(defun shapes-layer (layer)
  "Load a shapes LAYER by name"
  (shapes-load "layer" layer))

;; shapes extensions
(defun shapes-extend (extension)
  "Load a shapes EXTENSION by name"
  (shapes-load "extension" extension))

(provide 'shapes-core-load)
;;; shapes-load.el ends here
