;;;; irish.el -- support for Irish-language text
;;; Time-stamp: <2006-01-25 10:40:33 jcgs>

;;  This program is free software; you can redistribute it and/or modify it
;;  under the terms of the GNU General Public License as published by the
;;  Free Software Foundation; either version 2 of the License, or (at your
;;  option) any later version.

;;  This program is distributed in the hope that it will be useful, but
;;  WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;  General Public License for more details.

;;  You should have received a copy of the GNU General Public License along
;;  with this program; if not, write to the Free Software Foundation, Inc.,
;;  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

(provide 'irish)

(defvar irish-uru-regexp "bhf\\|ng\\|dt\\|mb\\|gc" ;; todo: have I missed any of these?
  "Pattern for uru (eclipsis) in Irish.")

(defvar irish-text-mode nil
  "Flag for Irish text mode.
This modifies capitalization, and allows easy typing of the accented letters needed.")

(defadvice capitalize-word (before irish-capitalization first (nwords) activate)
  "Apply Irish capitalization rules."
  ;; todo: make this handle multiple words
  (if irish-text-mode
      (save-match-data
	(if (looking-at irish-uru-regexp)
	    (goto-char (1- (match-end 0)))))))

;; todo: capitalize
;; todo: capitalize-region

(make-variable-buffer-local 'irish-text-mode)

(or (assoc 'irish-text-mode minor-mode-alist)
    (setq minor-mode-alist
	  (cons '(irish-text-mode " Gaeilge")
		minor-mode-alist)))

(defvar irish-prefix-char "'"
  "*String containing the character we use to mark an accent.")

(defvar irish-prefix-keymap (make-sparse-keymap "Irish")
  "Keymap for inserting Irish characters.")
(define-key irish-prefix-keymap "a" 'iso-transl-a-acute)
(define-key irish-prefix-keymap "e" 'iso-transl-e-acute)
(define-key irish-prefix-keymap "i" 'iso-transl-i-acute)
(define-key irish-prefix-keymap "o" 'iso-transl-o-acute)
(define-key irish-prefix-keymap "u" 'iso-transl-u-acute)
(define-key irish-prefix-keymap "A" 'iso-transl-A-acute)
(define-key irish-prefix-keymap "E" 'iso-transl-E-acute)
(define-key irish-prefix-keymap "I" 'iso-transl-I-acute)
(define-key irish-prefix-keymap "O" 'iso-transl-O-acute)
(define-key irish-prefix-keymap "U" 'iso-transl-U-acute)
(define-key irish-prefix-keymap "'" 'irish-insert-prefix)

(defvar old-binding-for-prime nil
  "The binding for the prime character, that we usurp as an accent.")

(defun irish-insert-prefix ()
  "Insert the character we usurped for an accent."
  (interactive)
  (if old-binding-for-prime
      (call-interactively old-binding-for-prime)))

(defun irish-text-mode ()
  "Toggle Irish text mode."
  (interactive)
  (if irish-text-mode
      (setq irish-text-mode nil)
    (setq irish-text-mode t)
    (require 'iso-transl)
    (if (null old-binding-for-prime)
	(setq old-binding-for-prime (key-binding irish-prefix-char)))
    (local-set-key irish-prefix-char irish-prefix-keymap)))

(defun irish-check-caol-leathan-region (begin end)
  "Check caol le caol agus leathan le leathan between BEGIN and END."
  (interactive "r")
  (let ((old-point (point)))
    (goto-char (region-beginning))
    (let ((found (re-search-forward "\\([aouáóú][bcdfghklmnpqrstvwxyz]+[eiéÂí]\\)\\|\\([eiéÂí][bcdfghklmnpqrstvwxyz]+[aouáóú]\\)"
				   (region-end) t)))
      (if found
	  (progn
	    (message "Found mismatch")
	    (goto-char found))
	(goto-char old-point)))))

;;; end of irish.el
