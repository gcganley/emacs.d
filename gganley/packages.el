(require 'package)
(require 'cl-lib)
(eval-when-compile (require 'cl))
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "https://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")))

(package-initialize)
(defvar gcg/packages
  '(haskell-mode
    rainbow-delimiters
    projectile
    which-key
    smartparens
    clj-refactor
    flycheck
    magit
    smex
    zenburn-theme
    cider
    clojure-mode
    company  
    exec-path-from-shell
    rainbow-mode))

;;; This is all C-w C-y from Prelude. I understand most of it but the rest is just
;;; Witch craft to me 

(defun packages-installed-p ()
  (every #'package-installed-p gcg/packages))
(defun require-package (package)
  (unless (memq package gcg/packages)
    (add-to-list 'gcg/packages package))
  (unless (package-installed-p package)
    (package-install package)))
(defun require-packages (packages)
  (mapc #'require-package packages))
(defun install-packages ()
  (unless (packages-installed-p)
    (package-refresh-contents)
    (require-packages gcg/packages)))

(install-packages)
(defun list-foreign-packages ()
  (interactive)
  (package-show-package-list
   (set-difference package-activated-list gcg/packages)))
(defmacro auto-install (extension package mode)
  `(add-to-list 'auto-mode-alist
		`(,extension . (lambda ()
				 (unless (package-installed-p ',package)
				   (package-install ',package))
				 (,mode)))))


(provide 'gganley-packages)
