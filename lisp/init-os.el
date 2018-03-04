;;; init-os.el --- Emacs is an operating system, right?
;;; Commentary:

;; Emacs the operating system configuration

;;; Code:

;; Book marks are surprisingly useful when I actually use them
(setq-default bookmark-default-file (expand-file-name ".bookmarks.el" user-emacs-directory))

(add-to-list 'default-frame-alist '(font . "Monaco-9"))
(set-face-attribute 'default t :font "Monaco-9")

(define-key 'help-command (kbd "f") #'helpful-callable)
(define-key 'help-command (kbd "v") #'helpful-variable)
(define-key 'help-command (kbd "k") #'helpful-key)
(define-key 'help-command (kbd "C-f") #'helpful-function)
(define-key 'help-command (kbd "C-k") #'helpful-function-on-key)
(define-key 'help-command (kbd "C-v") #'helpful-variable)
(define-key 'help-command (kbd "C-l") #'helpful-library)
(define-key 'help-command (kbd "C") #'helpful-command)

;; Undo/redo window configuration with C-c <left>/<right>
(winner-mode 1)

(setq desktop-path (list user-emacs-directory)
      desktop-dirname user-emacs-directory
      desktop-base-file-name ".emacs-directory"
      desktop-auto-save-timeout 30)

;; remove desktop after it's been read
(add-hook 'desktop-after-read-hook
	  '(lambda ()
	     ;; desktop-remove clears desktop-dirname
	     (setq desktop-dirname-tmp desktop-dirname)
	     (desktop-remove)
	     (setq desktop-dirname desktop-dirname-tmp)))

(defun saved-session ()
  "this is taken from somewhere"
  (file-exists-p (concat desktop-dirname "/" desktop-base-file-name)))

;; use session-restore to restore the desktop manually
(defun session-restore ()
  "Restore a saved emacs session."
  (interactive)
  (if (saved-session)
      (desktop-read)
    (message "No desktop found.")))

;; use session-save to save the desktop manually
(defun session-save ()
  "Save an emacs session."
  (interactive)
  (if (saved-session)
      (if (y-or-n-p "Overwrite existing desktop? ")
	  (desktop-save-in-desktop-dir)
	(message "Session not saved."))
    (desktop-save-in-desktop-dir)))

;; ask user whether to restore desktop at start-up
(add-hook 'after-init-hook
	  '(lambda ()
	     (if (saved-session)
		 (if (y-or-n-p "Restore desktop? ")
		     (session-restore)))))

(setq-default history-length 1000)
(add-hook 'after-init-hook 'savehist-mode)

;; save a bunch of variables to the desktop file
;; for lists specify the len of the maximal saved data also
(defvar desktop-globals-to-save
  (append '((comint-input-ring        . 50)
            (compile-history          . 30)
            (dired-regexp-history     . 20)
            (extended-command-history . 30)
            (face-name-history        . 20)
            (file-name-history        . 100)
            (grep-find-history        . 30)
            (grep-history             . 30)
            (ido-buffer-history       . 100)
            (ido-last-directory-list  . 100)
            (ido-work-directory-list  . 100)
            (ido-work-file-list       . 100)
            (ivy-history              . 100)
            (magit-read-rev-history   . 50)
            (minibuffer-history       . 50)
            (org-clock-history        . 50)
            (org-refile-history       . 50)
            (org-tags-history         . 50)
            (query-replace-history    . 60)
            (read-expression-history  . 60)
            (regexp-history           . 60)
            (regexp-search-ring       . 20)
            (search-ring              . 20)
            (shell-command-history    . 50))))


(setq is-a-mac (eq system-type 'darwin))

;; Loads newest version of a file
(setq load-prefer-newer t)

(defconst savefile-dir (expand-file-name "savefile" user-emacs-directory))

;; Toggle buffer size display in the mode line
(size-indication-mode t)

;; obvious, don't know why I need fset though
(fset 'yes-or-no-p 'y-or-n-p)

;; Set default tabbing behavior
(setq-default indent-tabs-mode nil)
(setq-default tab-width 8)

;; Looks prettier
(setq require-final-newline t)


;; I don't want your backups cluttering my working directory
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; gives a pretty buffer switcher
(global-set-key (kbd "C-x C-b") #'ibuffer)

;; I don't need escape bound to this
(define-key input-decode-map [?\C-\[] (kbd "<C-[>"))

(use-package which-key
  :ensure t
  :diminish
  :config
  (which-key-mode +1))

(use-package buffer-move
  :ensure t
  :config
  (global-set-key (kbd "<C-S-up>")     'buf-move-up)
  (global-set-key (kbd "<C-S-down>")   'buf-move-down)
  (global-set-key (kbd "<C-S-left>")   'buf-move-left)
  (global-set-key (kbd "<C-S-right>")  'buf-move-right))

;; What did my change do?
(use-package restart-emacs
  :ensure t)


;; Save the place I last was in the buffer
(use-package saveplace
  :config
  (setq save-place-file (expand-file-name "saveplace" savefile-dir))
  ;; activate it for all buffers
  (setq-default save-place t))

;; Save minibuffer history
(use-package savehist
  :config
  (setq savehist-additional-variables
        ;; search entries
        '(search-ring regexp-search-ring)
        ;; save every minute
        savehist-autosave-interval 60
        ;; keep the home clean
        savehist-file (expand-file-name "savehist" savefile-dir))
  (savehist-mode +1))

(use-package recentf
  :config
  (setq recentf-save-file (expand-file-name "recentf" savefile-dir)
        recentf-max-saved-items 500
        recentf-max-menu-items 15)
  (recentf-mode +1))

;; Shift-{left,right,up,down}
(use-package windmove
  :config
  ;; use shift + arrow keys to switch between visible buffers
  (windmove-default-keybindings))

;; Dired is the one true way of navigating through directories
(use-package dired
  :config
  ;; dired - reuse current buffer by pressing 'a'
  (put 'dired-find-alternate-file 'disabled nil)

  ;; always delete and copy recursively
  (setq dired-recursive-deletes 'always)
  (setq dired-recursive-copies 'always)

  ;; if there is a dired buffer displayed in the next window, use its
  ;; current subdir, instead of the current subdir of this dired buffer
  (setq dired-dwim-target t)

  ;; enable some really cool extensions like C-x C-j(dired-jump)
  ;; C-x C-j (dired-jump): Jump to Dired buffer corresponding to current buffer.
  (require 'dired-x))

(use-package alert
  :ensure t)

(use-package switch-window
  :ensure t
  :bind ("C-x o" . 'switch-window)
  :config
  (setq-default switch-window-shortcut-style 'alphabet)
  (setq-default switch-window-timeout nil))

(provide 'init-os)

(provide 'init-os)

;;; init-os.el ends here
