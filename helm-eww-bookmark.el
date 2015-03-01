;;; helm-eww-bookmark -*- lexical-binding: t; coding: utf-8; -*-

;;; Code:

(require 'cl-lib)
(require 'seq)

(defface helm-eww-bookmark-title
  '((t :inherit font-lock-preprocessor-face))
  "face for bookmark title"
  :group 'eww
  :group 'helm)

(defface helm-eww-bookmark-url
  '((t :inherit font-lock-builtin-face))
  "face for bookmark title"
  :group 'eww
  :group 'helm)

(defcustom helm-eww-bookmark-title-width
  40
  "Max width for bookmark title"
  :type 'integer)

(cl-defun helm-eww-bookmark-init ()
  (eww-read-bookmarks)
  (unless eww-bookmarks
    (user-error "No bookmarks are defined"))
  (setq helm-eww-bookmark-candidates
        (helm-eww-bookmark-create-candidates)))

(cl-defun helm-eww-bookmark-create-candidates ()
  (seq-map
   (lambda (b)
     (cons
      (format
       (seq-concatenate 'string
                        "%-"
                        (number-to-string helm-eww-bookmark-title-width)
                        "." (number-to-string helm-eww-bookmark-title-width)
                        "s"
                        "  "
                        "%s")
       (propertize (cl-getf b :title)
                   'face 'helm-eww-bookmark-title)
       (propertize (cl-getf b :url)
                   'face 'helm-eww-bookmark-url))
      b))
   eww-bookmarks))

(cl-defun helm-eww-bookmark-action-browse (candidate)
  (eww-browse-url (cl-getf candidate :url)))

(cl-defun helm-eww-bookmark-action-copy-url (candidate)
  (cl-letf ((url (cl-getf candidate :url)))
    (kill-new url)
    (message "copied %s" url)))

(defclass helm-eww-bookmark-source (helm-source-sync)
  ((init :initform #'helm-eww-bookmark-init)
   (candidates :initform 'helm-eww-bookmark-candidates)
   (action :initform
           (helm-make-actions
            "Browse bookmark" #'helm-eww-bookmark-action-browse
            "Copy url" #'helm-eww-bookmark-action-copy-url))))

(defvar helm-source-eww-bookmark
  (helm-make-source "Bookmark"
      'helm-eww-bookmark-source))

;;;###autoload
(cl-defun helm-eww-bookmark ()
  "helm source for eww bookmarks"
  (interactive)
  (helm :sources '(helm-source-eww-bookmark)
        :buffer "*helm eww bookmark*"
        :prompt "Bookmark: "))

(provide 'helm-eww-bookmark)

;;; helm-eww-bookmark.el ends here
