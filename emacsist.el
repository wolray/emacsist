;;; emacsist.el --- produce articles list in REAEME.org  -*- lexical-binding: t; -*-

;; Copyright (C) 2016 Aborn Jiang

;; Author: Aborn Jiang <aborn.jiang@gmail.com>
;; Version: 0.1
;; Package-Requires: ((emacs "24.4") (f "0.19.0"))
;; Keywords: utils, convenience

;; This file is NOT part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package is used to produce articles list to REAEME.org
;; in repo emacsist.

;;; Code:

(require 'f)

(defgroup emacsist nil
  "leanote mini group"
  :prefix "emacsist-"
  :group 'org)

(defcustom emacsist-repo-root "~/github/emacsist"
  "the emacsist repo root path"
  :group 'emacsist
  :type 'string)

;;;###autoload
(defun emacsist ()
  (interactive)
  (emacsist-append-articles-list)
  (message "生成文章列表成功!"))

(defun emacsist-articles-list-content ()
  (let* ((apath (expand-file-name "articles" emacsist-repo-root)))
    (mapcar
     #'(lambda (item)
         (format "+ [[./articles/%s][%s]]  "
                 (f-filename item)
                 (f-base item)))
     (f-files apath
              (lambda (file) (f-ext? file "org"))))))

(defun emacsist-append-articles-list ()
  "Find the correct position"
  (let* ((fname (expand-file-name "README.org" emacsist-repo-root)))
    (find-file fname)
    (goto-char (point-min))
    (let ((spos (search-forward "** 往期文章")))
      (when spos
        (kill-region spos (point-max))
        (insert "\n")
        (mapc #'(lambda (item)
                  (insert item)
                  (insert "\n"))
              (emacsist-articles-list-content))
        (save-buffer)))))

;;;###autoload
(defun emacsist-publish ()
  "Publish current file (in tougao dir) to article."
  (interactive)
  (let* ((fname (buffer-file-name))
         (sname (if fname (f-filename fname) ""))
         des-name)
    (if (and fname
             (string= (expand-file-name "tougao" emacsist-repo-root)
                      (f-dirname fname)))
        (when (yes-or-no-p (format "确定将当前文章:%s发布？" sname))
          (setq des-name (expand-file-name
                          (format "articles/%s%s" (format-time-string "%Y-%m-%d" (current-time))
                                  sname)
                          emacsist-repo-root))
          (f-move fname des-name)
          (kill-buffer)
          (find-file des-name)
          (message "原稿件:%s, 已经发布到:%s" fname des-name))
      (message "当前文件 %s 不在目录tougao/下，不能发布！" fname))))

(provide 'emacsist)
;;; emacsist.el ends here
