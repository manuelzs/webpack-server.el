;;; webpack-server.el --- Mode for running the webpack-dev-server in Emacs. -*- lexical-binding: t -*-

;; Copyright © 2016 Manuel Zapata <manuelzs@gmail.com>

;; Author: Manuel Zapata <manuelzs@gmail.com>
;; URL: https://github.com/manuelzs/webpack-server.el
;; Keywords: convenience, webpack, js
;; Version: 0.1.0
;; Created: 2016-04-26

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; This library provides an easy way to run the webpack-dev-server
;; inside Emacs.  See the README for more details.
;;
;;; Code:

;; Variables
(defgroup webpack-server nil
  "Webpack Dev Server for Emacs"
  :group 'programming
  :prefix "webpack-server-")

(defcustom webpack-server-host "localhost"
  "Host to run webpack dev server"
  :group 'webpack-server
  :type 'string)

(defcustom webpack-server-port "8080"
  "Port to run webpack dev server"
  :group 'webpack-server
  :type 'string)


;; Environment

(defun webpack-server-localise (var func)
  "Return buffer local varible or get & set it"
  (if (local-variable-p var)
      (symbol-value var)
    (let ((the-var (funcall func)))
      (if the-var
          (progn
            (make-local-variable var)
            (set var the-var))))))


(defun webpack-server-project-root ()
  "Return the root of the project(dir with webpack.config.js in) or nil"
  (webpack-server-localise
   'webpack-server-this-project-root
   '(lambda ()
      (let ((curdir default-directory)
            (max 10)
            (found nil))
        (while (and (not found) (> max 0))
          (progn
            (if (file-exists-p (concat curdir "webpack.config.js"))
                (progn
                  (setq found t))
              (progn
                (setq curdir (concat curdir "../"))
                (setq max (- max 1))))))
        (if found (expand-file-name curdir))))))

(defun webpack-server-cmd (root-dir)
  (concat root-dir "node_modules/.bin/" "webpack-dev-server"))

(defun webpack-server-args ()
  (list "-d"
        "--progress"
        (concat "--host " webpack-server-host)
        (concat "--port " webpack-server-port)))

;; Server

;;;###autoload
(defun webpack-server-run()
  "Start the Webpack development server.
If the server is currently running, just switch to the buffer.
If you are currently in the *webpack-dev-server* buffer, restart the server"
  (interactive)
  (let* ((buffname "*webpack-dev-server*")
         (proc (get-buffer-process buffname))
         (buff (get-buffer buffname))
         (working-dir default-directory))
    (if proc
        (progn
          (message "Webpack Dev Server already running")
          (if (and buff (eq buff (current-buffer)))
              (webpack-server-restart)
            (switch-to-buffer-other-window (get-buffer buffname))))
      (webpack-server-start))))

(defun webpack-server-start ()
  "Start the Webpack development server."
  (interactive)
  (let ((default-directory (webpack-server-project-root)))
    (apply 'make-comint "webpack-dev-server"
           (webpack-server-cmd default-directory)
           nil
           (webpack-server-args)))
  (get-buffer "*webpack-dev-server*"))

;;;###autoload
(defun webpack-server-stop()
  "Stop the dev server"
  (interactive)
  (let ((proc (get-buffer-process "*webpack-dev-server*")))
    (when proc (kill-process proc t))))

;;;###autoload
(defun webpack-server-restart ()
  "Restart the webpack dev server."
  (interactive)
  (webpack-server-stop)
  (run-with-timer 1 nil 'webpack-server-start))

;; View server

;;;###autoload
(defun webpack-server-browse()
  "Open a tab at the development server"
  (interactive)
  (let ((url (concat "http://" webpack-server-host ":"  webpack-server-port)))
    (run-with-timer 2 nil 'browse-url url)))


(provide 'webpack-server)
