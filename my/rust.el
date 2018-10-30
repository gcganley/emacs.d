(use-package rust-mode
  :mode ("\\.rs\\'" . rust-mode)
  :hook electric-pair
  :config
  (use-package lsp-mode
    :config
    (use-package lsp-rust
      :hook ((rust-mode . lsp-rust-enable)
	     (rust-mode . flycheck-mode))
      :config
      (setq lsp-rust-rls-command '("rustup" "run" "nightly" "rls"))))
  (use-package company-racer
    :requires company
    :bind ("M-TAB" . company-complete)
    :config
    (setq company-tooltip-align-annotations t))
  
  (use-package flycheck-rust
    :hook ((rust-mode . flycheck-mode)
	   (flycheck-mode . flycheck-rust-setup)))
  
  (use-package cargo
    :hook ((rust-mode . cargo-minor-mode)))
  
  (use-package racer
    :hook ((racer-mode . eldoc-mode)
	   (racer-mode . company-mode)
	   (rust-mode . racer-mode))
    :bind (("M-." . racer-find-definition))))

(provide 'my-rust)
