(global-set-key "\C-cll" 'lookup-pattern) ; C-c l ?? lookup-pattern ??????????
(global-set-key "\C-clw" 'all-lookup-phrase)
(global-set-key "\C-clp" 'all-lookup-pronunciation)
(global-set-key "\C-cls" 'all-speak-text)
(global-set-key "\C-clS" 'all-speak-text-choose-language)
(global-set-key "\C-clt" 'all-translate-text)
(global-set-key "\C-clT" 'all-translate-and-speak-text)
(global-set-key "\C-clL" 'dictionary-lookup-definition)

;; functionality for querying our knowledge base.

;; do most of the work in perl.

;; interface with the nice ALL oo architecture I'm developing

;; This is an interesting idea, if there are no results, stem it, etc
;; have a cascading filter

;; add the ability to stem the word etc if it fails

(defun all-lookup-phrase ()
 "Look up the phrase at point"
 (interactive)
 (if (not (lookup-word (thing-at-point 'symbol)))
  (message "hi")))

(setq festival-configuration 
 (shell-command-to-string "cat /etc/clear/fest.conf"))

(defun all-lookup-pronunciation ()
 "Lookup the pronunciation of the word or phrase at point"
 (interactive)
 (all-speak-text (thing-at-point 'symbol))
 ;; we'll just use the speech synthesizer for now
 )

(defun all-speak-text (&optional text)
 "Lookup the pronunciation of the word or phrase at point"
 (interactive)
 ;; we'll just use the speech synthesizer for now
 (let ((contents (if text
		  text
		  (buffer-substring-no-properties (mark) (point)))))
  (uea-send-contents "" "ALL"
   (freekbs2-util-data-dumper
    (list
     (cons "Command" "Speak")
     (cons "Text" contents)
     )
    ))))

(defun all-speak-text-choose-language (&optional text)
 "Lookup the pronunciation of the word or phrase at point"
 (interactive)
 ;; we'll just use the speech synthesizer for now
 (let ((contents (if text
		  text
		  (buffer-substring-no-properties (mark) (point))))
       (source-language (if (boundp 'all-source-language)
			 all-source-language
			 (completing-read "Source Lang: " all-languages))))
  (uea-send-contents "" "ALL"
   (freekbs2-util-data-dumper
    (list
     (cons "Command" "Speak")
     (cons "Text" contents)
     (cons "SourceLanguage" (cdr (assoc source-language all-languages)))
     )
    ))))

(defvar all-languages
 (list
  '("Afrikaans" . "af")
  '("American English" . "us")
  '("Brazilian Portuguese" . "br")
  '("British English" . "en")
  '("Croatian" . "cr")
  '("Czech" . "cz")
  '("Dutch" . "nl")
  '("European Portuguese" . "pt")
  '("French" . "fr")
  '("German" . "de")
  '("Greek" . "gr")
  '("Hungarian" . "hu")
  '("Indonesian" . "id")
  '("Irish" . "ga")
  '("Italian" . "it")
  '("Latin" . "la")
  '("Polish" . "pl")
  '("Romanian" . "ro")
  '("Spanish" . "es")
  '("Swedish" . "sw")
  ))

(defun all-translate-text (&optional text)
 "Lookup the pronunciation of the word or phrase at point"
 (interactive)
 ;; we'll just use the speech synthesizer for now
 (let ((contents (if text
		  text
		  (buffer-substring-no-properties (mark) (point))))
       (destination-language (if (boundp 'all-destination-language)
			      all-destination-language
			      (completing-read "Dest Lang: " all-languages))))
  (uea-send-contents "" "ALL"
   (freekbs2-util-data-dumper
    (list
     (cons "Command" '"Translate")
     (cons "Text" contents)
     (cons "DestinationLanguage" (cdr (assoc destination-language all-languages)))
     )
    ))))

(defun all-translate-and-speak-text (&optional text)
 "Lookup the pronunciation of the word or phrase at point"
 (interactive)
 ;; we'll just use the speech synthesizer for now
 (let ((contents (if text
		  text
		  (buffer-substring-no-properties (mark) (point))))
       (destination-language (if (boundp 'all-destination-language)
			      all-destination-language
			      (completing-read "Dest Lang: " all-languages))))
  ;; (uea-send-contents "" "ALL"
  (see
   (freekbs2-util-data-dumper
    (list
     (cons "Command" "Translate And Speak")
     (cons "Text" contents)
     (cons "DestinationLanguage" (cdr (assoc destination-language all-languages)))
     )
    ))))

(defun transliterate-region ()
 ""
 (interactive)
 (let (
       (text (buffer-substring-no-properties (mark) (point)))
       (mybuffer
	(get-buffer-create (generate-new-buffer-name "*shell*")))
       )
  (shell mybuffer)
  (switch-to-buffer mybuffer)
  (insert
   (concat "/var/lib/myfrdcsa/codebases/internal/all/scripts/translator/transliterate.pl -db german-english -t \"" 
    (shell-quote-argument text) "\""))
  (ignore-errors
   (comint-send-input))))

(defun translate-email-message ()
 ""
 (interactive)
 ;; first copy the email message to a new buffer
 ;; (get-buffer-create "all-mew-translate-message")

 ;; make sure this is an email message
 )

(setq lookup-search-agents '((ndic "/usr/share/dictd"))
 lookup-enable-splash nil)

(autoload 'lookup "lookup" nil t)	; lookup ?? autoload ????
(autoload 'lookup-word "lookup" nil t)
(autoload 'lookup-pattern "lookup" nil t) ; lookup-pattern ?? autoload ????

(load "/var/lib/myfrdcsa/codebases/internal/all/frdcsa/emacs/text-translator/text-translator-load.el")
(load "/var/lib/myfrdcsa/codebases/internal/all/frdcsa/emacs/text-translator/text-translator-vars.el")
(load "/var/lib/myfrdcsa/codebases/internal/all/frdcsa/emacs/text-translator/text-translator.el")

(require 'text-translator-load)
(global-set-key "\C-x\M-t" 'text-translator)
(global-set-key "\C-x\M-T" 'text-translator-translate-last-string)
(setq text-translator-default-engine "google.com_enga")

;; some text with segments of arbitrary language

;;   pronounce word, phrase or segment (thing-at-point or region)
;;      general reading

;;   translate some portion (and possibly read it)
;;      identify language it consists of
;;      identify target language (C-u will be used if the default language is not what the variable is set to)

;;  keep a profile of the language proficiency of the user, and know
;;  which languages he should want to know, furthermore, know what
;;  words he already knows
;;  record which phrases and how often, and when they are read into some kind of language database, per user
;;  use the TTS for CLEAR also, use the foreign language stuff as well that we developed for language-learn


;;  eventually add a speech recognition component

(load "/var/lib/myfrdcsa/codebases/internal/all/frdcsa/emacs/lang/irish/irish.el")

;; (defun all-read-text-festival (text)
;;  "Lookup the pronunciation of the word or phrase at point"
;;  (interactive)
;;  ;; we'll just use the speech synthesizer for now
;;  (festival-start-process)
;;  (process-send-string festival-process "(voice_kal_diphone)")
;;  (process-send-string festival-process festival-configuration)
;;  (process-send-string festival-process 
;;   (concat "(SayText " (format "%S" (erc-string-no-properties text)) ")\n")))

;; (defun all-read-irish ()
;;  ""
;;  (interactive)
;;  (start-process-shell-command "read-shell" 
;;   (get-buffer-create "read-irish") "/var/lib/myfrdcsa/codebases/internal/all/scripts/pronounce-irish.pl" 
;;   (shell-quote-argument 
;;    (buffer-substring-no-properties (mark) (point)))))

;; (defun all-read-mbrola ()
;;  ""
;;  (interactive)
;;  (start-process-shell-command "read-shell" 
;;   (get-buffer-create "read-irish") "/var/lib/myfrdcsa/codebases/internal/all/scripts/pronounce-irish.pl" 
;;   (shell-quote-argument 
;;    (buffer-substring-no-properties (mark) (point)))))

(defun all-translate-irish-to-english (text)
 (interactive)
 (google-translate-translate "Irish" "English" text))

(defun all-translate-english-to-irish (text)
 (interactive)
 (google-translate-translate "English" "Irish" text))
