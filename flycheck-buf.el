;;; flycheck-buf.el --- Flycheck checker using buf lint -*- lexical-binding: t; -*-

;; URL: https://github.com/gleek/flycheck-buf
;; Keywords: tools, convenience
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1") (flycheck "0.22"))

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Flycheck syntax checker for Protocol Buffers using buf lint.
;;
;; Setup:
;;   (with-eval-after-load 'flycheck
;;     (flycheck-buf-setup))
;;
;; Set `flycheck-buf-lint-root' via .dir-locals.el to control
;; where buf resolves imports from:
;;
;;   ((protobuf-mode . ((flycheck-buf-lint-root . "~/projects/myrepo"))))

;;; Code:

(require 'flycheck)

(defgroup flycheck-buf nil
  "Flycheck checker for buf lint."
  :group 'flycheck
  :prefix "flycheck-buf-")

(flycheck-def-executable-var protobuf-buf-lint "buf")

(flycheck-def-option-var flycheck-buf-lint-root nil protobuf-buf-lint
  "Root directory for buf lint.
When set, buf runs from this directory so it can find buf.yaml
and resolve imports correctly.  Set via .dir-locals.el."
  :safe #'stringp
  :type '(choice (const :tag "Default" nil)
                 (string :tag "Root directory")))

(flycheck-define-checker protobuf-buf-lint
  "A Protocol Buffers linter using buf lint.
See URL `https://buf.build'."
  :command ("buf" "lint" "--error-format" "text" "--path" source-inplace)
  :error-patterns
  ((error line-start (file-name) ":" line ":" column ":" (message) line-end))
  :modes protobuf-mode
  :enabled (lambda () (flycheck-buf-lint-executable))
  :working-directory (lambda (_checker)
                       (when flycheck-buf-lint-root
                         (expand-file-name flycheck-buf-lint-root))))

;;;###autoload
(defun flycheck-buf-setup ()
  "Set up Flycheck for buf lint.
Adds `protobuf-buf-lint' to `flycheck-checkers' and chains it
after `protobuf-protoc'."
  (interactive)
  (add-to-list 'flycheck-checkers 'protobuf-buf-lint)
  (flycheck-add-next-checker 'protobuf-protoc '(warning . protobuf-buf-lint)))

(provide 'flycheck-buf)
;;; flycheck-buf.el ends here
