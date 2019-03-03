;;; -*- lexical-binding: t -*-

(defun tangle-init ()
  "If the current buffer is 'init.org' the code-blocks are
tangled, and the tangled file is compiled."
  (when (equal (buffer-file-name)
               (expand-file-name (concat user-emacs-directory "init.org")))
    ;; Avoid running hooks when tangling.
    (let ((prog-mode-hook nil))
      (org-babel-tangle)
      (byte-compile-file (concat user-emacs-directory "init.el")))))

(add-hook 'after-save-hook 'tangle-init)

(add-hook
 'after-init-hook
 (lambda ()
   (let ((private-file (concat user-emacs-directory "private.el")))
     (when (file-exists-p private-file)
       (load-file private-file)))))

(require 'cl)
(require 'package)
(package-initialize)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
(add-to-list 'package-pinned-packages '(org . "org") t)

(let* ((package--builtins nil)
       (packages
        '(auto-compile         ; automatically compile Emacs Lisp libraries
          company              ; Modular text completion framework
          define-word          ; display the definition of word at point
          diminish             ; Diminished modes from modeline
          drag-stuff           ; Drag stuff around in Emacs
          expand-region        ; Increase selected region by semantic units
          focus                ; Dim color of text in surrounding sections
          idle-require         ; load elisp libraries while Emacs is idle
          git-gutter-fringe    ; Fringe version of git-gutter.el
          golden-ratio         ; Automatic resizing windows to golden ratio
          helm                 ; Incremental and narrowing framework
          helm-ag              ; the silver searcher with helm interface
          helm-company         ; Helm interface for company-mode
          helm-dash            ; Offline documentation using Dash docsets.
          helm-projectile      ; Helm integration for Projectile
          helm-swoop           ; Efficiently hopping squeezed lines
          magit                ; control Git from Emacs
          markdown-mode        ; Emacs Major mode for Markdown-formatted files
          multiple-cursors     ; Multiple cursors for Emacs
          olivetti             ; Minor mode for a nice writing environment
          org                  ; Outline-based notes management and organizer
          org-plus-contrib     ; contains these files plus all contribs files
          org-ref              ; citations bibliographies in org-mode
          org-brain            ; a personal knowledge management system
          paredit              ; minor mode for editing
          projectile           ; Manage and navigate projects in Emacs easily
          slime                ; Superior Lisp Interaction Mode for Emacs
          try                  ; Try out Emacs packages
          monokai-theme        ; monokai theme
          writeroom-mode       ; a mode that good for writing
          pocket-reader        ; a client for Pocket (getpocket.com)
          which-key)))         ; Display available keybindings in popup
  (ignore-errors ;; This package is only relevant for Mac OS X.
    (when (memq window-system '(mac ns))
      (push 'exec-path-from-shell packages)
      (push 'reveal-in-osx-finder packages))
    (let ((packages (remove-if 'package-installed-p packages)))
      (when packages
        ;; Install uninstalled packages
        (package-refresh-contents)
        (mapc 'package-install packages)))))

(require 'idle-require)             ; Need in order to use idle-require

(dolist (feature
         '(auto-compile             ; auto-compile .el files
           ox-latex                 ; the latex-exporter (from org)
           ox-md                    ; Markdown exporter (from org)
           recentf                  ; recently opened files
           tex-mode))               ; TeX, LaTeX, and SliTeX mode commands
  (idle-require feature))

(setq idle-require-idle-delay 5)
(idle-require-mode 1)

(setq auto-revert-interval 1            ; Refresh buffers fast
      custom-file (make-temp-file "")   ; Discard customization's
      default-input-method "TeX"        ; Use TeX when toggling input method
      echo-keystrokes 0.1               ; Show keystrokes asap
      inhibit-startup-message t         ; No splash screen please
      initial-scratch-message nil       ; Clean scratch buffer
      recentf-max-saved-items 100       ; Show more recent files
      ring-bell-function 'ignore        ; Quiet
      sentence-end-double-space nil)    ; No double space
;; Some mac-bindings interfere with Emacs bindings.
(when (boundp 'mac-pass-command-to-system)
  (setq mac-pass-command-to-system nil))

(setq-default fill-column 79                    ; Maximum line width
              truncate-lines t                  ; Don't fold lines
              indent-tabs-mode nil              ; Use spaces instead of tabs
              split-width-threshold 160         ; Split verticly by default
              split-height-threshold nil        ; Split verticly by default
              auto-fill-function 'do-auto-fill) ; Auto-fill-mode everywhere

(let ((default-directory (concat user-emacs-directory "site-lisp/")))
  (when (file-exists-p default-directory)
    (setq load-path
          (append
           (let ((load-path (copy-sequence load-path)))
             (normal-top-level-add-subdirs-to-load-path)) load-path))))

(fset 'yes-or-no-p 'y-or-n-p)

(defvar emacs-autosave-directory
  (concat user-emacs-directory "autosaves/")
  "This variable dictates where to put auto saves. It is set to a
  directory called autosaves located wherever your .emacs.d/ is
  located.")

;; Sets all files to be backed up and auto saved in a single directory.
(setq backup-directory-alist
      `((".*" . ,emacs-autosave-directory))
      auto-save-file-name-transforms
      `((".*" ,emacs-autosave-directory t)))

(set-language-environment "UTF-8")

(put 'narrow-to-region 'disabled nil)

(add-hook 'doc-view-mode-hook 'auto-revert-mode)

(dolist (mode
         '(tool-bar-mode                ; No toolbars, more room for text
           scroll-bar-mode              ; No scroll bars either
           blink-cursor-mode))          ; The blinking cursor gets old
  (funcall mode 0))

(dolist (mode
         '(abbrev-mode                  ; E.g. sopl -> System.out.println
           column-number-mode           ; Show column number in mode line
           delete-selection-mode        ; Replace selected text
           dirtrack-mode                ; directory tracking in *shell*
           drag-stuff-global-mode       ; Drag stuff around
           global-company-mode          ; Auto-completion everywhere
           global-git-gutter-mode       ; Show changes latest commit
           global-prettify-symbols-mode ; Greek letters should look greek
           projectile-global-mode       ; Manage and navigate projects
           recentf-mode                 ; Recently opened files
           show-paren-mode              ; Highlight matching parentheses
           ;display-line-numbers-mode     ; mode that show line's number (for version>26)
           which-key-mode))             ; Available keybindings in popup
  (funcall mode 1))

(when (version< emacs-version "24.4")
  (eval-after-load 'auto-compile
    '((auto-compile-on-save-mode 1))))  ; compile .el files on save
(when (version<= "26.0.50" emacs-version )
   (global-display-line-numbers-mode))

(load-theme 'monokai t)

(defun cycle-themes ()
  "Returns a function that lets you cycle your themes."
  (lexical-let ((themes '#1=(leuven material . #1#)))
    (lambda ()
      (interactive)
      ;; Rotates the thme cycle and changes the current theme.
      (load-theme (car (setq themes (cdr themes))) t))))

(cond ((member "Hasklig" (font-family-list))
       (set-face-attribute 'default nil :font "Hasklig-14"))
      ((member "Inconsolata" (font-family-list))
       (set-face-attribute 'default nil :font "Inconsolata-14")))

(defmacro safe-diminish (file mode &optional new-name)
  `(with-eval-after-load ,file
     (diminish ,mode ,new-name)))

(diminish 'auto-fill-function)
(safe-diminish "eldoc" 'eldoc-mode)
(safe-diminish "flyspell" 'flyspell-mode)
(safe-diminish "helm-mode" 'helm-mode)
(safe-diminish "projectile" 'projectile-mode)
(safe-diminish "paredit" 'paredit-mode "()")

(require 'git-gutter-fringe)

(dolist (p '((git-gutter:added    . "#0c0")
             (git-gutter:deleted  . "#c00")
             (git-gutter:modified . "#c0c")))
  (set-face-foreground (car p) (cdr p))
  (set-face-background (car p) (cdr p)))

(setq-default prettify-symbols-alist '(("lambda" . ?λ)
                                       ("delta" . ?Δ)
                                       ("gamma" . ?Γ)
                                       ("phi" . ?φ)
                                       ("psi" . ?ψ)))

(setq company-idle-delay 0
      company-echo-delay 0
      company-dabbrev-downcase nil
      company-minimum-prefix-length 2
      company-selection-wrap-around t
      company-transformers '(company-sort-by-occurrence
                             company-sort-by-backend-importance))

(require 'helm)
(require 'helm-config)

(setq helm-split-window-in-side-p t
      helm-M-x-fuzzy-match t
      helm-buffers-fuzzy-matching t
      helm-recentf-fuzzy-match t
      helm-move-to-line-cycle-in-source t
      projectile-completion-system 'helm)

(when (executable-find "ack")
  (setq helm-grep-default-command
        "ack -Hn --no-group --no-color %e %p %f"
        helm-grep-default-recurse-command
        "ack -H --no-group --no-color %e %p %f"))

(set-face-attribute 'helm-selection nil :background "cyan")

(helm-mode 1)
(helm-projectile-on)
(helm-adaptive-mode 1)

(setq helm-dash-browser-func 'eww)
(add-hook 'emacs-lisp-mode-hook
          (lambda () (setq-local helm-dash-docsets '("Emacs Lisp"))))
(add-hook 'erlang-mode-hook
          (lambda () (setq-local helm-dash-docsets '("Erlang"))))
(add-hook 'java-mode-hook
          (lambda () (setq-local helm-dash-docsets '("Java"))))
(add-hook 'haskell-mode-hook
          (lambda () (setq-local helm-dash-docsets '("Haskell"))))
(add-hook 'clojure-mode-hook
          (lambda () (setq-local helm-dash-docsets '("Clojure"))))

(defun calendar-show-week (arg)
  "Displaying week number in calendar-mode."
  (interactive "P")
  (copy-face font-lock-constant-face 'calendar-iso-week-face)
  (set-face-attribute
   'calendar-iso-week-face nil :height 0.7)
  (setq calendar-intermonth-text
        (and arg
             '(propertize
              (format
               "%2d"
               (car (calendar-iso-from-absolute
                     (calendar-absolute-from-gregorian
                      (list month day year)))))
              'font-lock-face 'calendar-iso-week-face))))

(calendar-show-week t)

(setq calendar-week-start-day 1
      calendar-latitude 60.0
      calendar-longitude 10.7
      calendar-location-name "Oslo, Norway")

(add-hook 'text-mode-hook 'turn-on-flyspell)

(add-hook 'prog-mode-hook 'flyspell-prog-mode)

(defun cycle-languages ()
  "Changes the ispell dictionary to the first element in
ISPELL-LANGUAGES, and returns an interactive function that cycles
the languages in ISPELL-LANGUAGES when invoked."
  (lexical-let ((ispell-languages '#1=("american" "norsk" . #1#)))
    (ispell-change-dictionary (car ispell-languages))
    (lambda ()
      (interactive)
      ;; Rotates the languages cycle and changes the ispell dictionary.
      (ispell-change-dictionary
       (car (setq ispell-languages (cdr ispell-languages)))))))

(defadvice turn-on-flyspell (before check nil activate)
  "Turns on flyspell only if a spell-checking tool is installed."
  (when (executable-find ispell-program-name)
    (local-set-key (kbd "C-c l") (cycle-languages))))

(defadvice flyspell-prog-mode (before check nil activate)
  "Turns on flyspell only if a spell-checking tool is installed."
  (when (executable-find ispell-program-name)
    (local-set-key (kbd "C-c l") (cycle-languages))))

(setq org-directory "~/Dropbox/notebook/")

(setq org-agenda-files '("~/Dropbox/notebook/agenda.org")  ; A list of agenda files
      org-agenda-default-appointment-duration 120 ; 2 hours appointments
      org-capture-templates                       ; Template for adding tasks
      '(("t" "Task" entry (file+headline "~/Dropbox/notebook/agenda.org" "Task")
         "** TODO %?" :prepend t)
        ("m" "Todo" entry (file+olp "~/Dropbox/notebook/agenda.org" "Task" "Todo")
         "*** TODO %?" :prepend t)
        ("a" "Note" entry (file+headline "~/Dropbox/notebook/Note.org" "Note")
         "** %?\n   SCHEDULED: %T" :prepend t)
        ("s" "Snippet" entry (file+headline "~/Dropbox/notebook/Note.org" "Snippet")
         "** %?\n#+BEGIN_SRC %^{language||js|emacs lisp|python|sql|java|go}\n%^C\n#+END_SRC" :prepend t)
       ))

(setq org-src-fontify-natively t
      org-src-tab-acts-natively t
      org-confirm-babel-evaluate nil
      org-edit-src-content-indentation 0)

;;(require 'org)
(eval-after-load "org"
  '(progn
     (setcar (nthcdr 2 org-emphasis-regexp-components) " \t\n,")
     (custom-set-variables `(org-emphasis-alist ',org-emphasis-alist))))

(org-babel-do-load-languages 'org-babel-load-languages
    '(
        (shell . t)
        (emacs-lisp . t)
        (js .t)
    )
)

;; org-mode 設定
(require 'org-crypt)

;; 當被加密的部份要存入硬碟時，自動加密回去
(org-crypt-use-before-save-magic)

;; 設定要加密的 tag 標籤為 secret
(setq org-crypt-tag-matcher "secret")

;; 避免 secret 這個 tag 被子項目繼承 造成重複加密
;; (但是子項目還是會被加密喔)
(setq org-tags-exclude-from-inheritance (quote ("secret")))

;; 用於加密的 GPG 金鑰
;; 可以設定任何 ID 或是設成 nil 來使用對稱式加密 (symmetric encryption)
(setq org-crypt-key nil)

(setq org-brain-path "/wiki")
  ;; For Evil users
  (with-eval-after-load 'evil
    (evil-set-initial-state 'org-brain-visualize-mode 'emacs))
  :config
  (setq org-id-track-globally t)
  (setq org-id-locations-file "~/.emacs.d/.org-id-locations")
  (push '("b" "Brain" plain (function org-brain-goto-end)
          "* %i%?" :empty-lines 1)
        org-capture-templates)
  (setq org-brain-visualize-default-choices 'all)
  (setq org-brain-title-max-length 12)

(defun cycle-spacing-delete-newlines ()
  "Removes whitespace before and after the point."
  (interactive)
  (if (version< emacs-version "24.4")
      (just-one-space -1)
    (cycle-spacing -1)))

(defun jump-to-symbol-internal (&optional backwardp)
  "Jumps to the next symbol near the point if such a symbol
exists. If BACKWARDP is non-nil it jumps backward."
  (let* ((point (point))
         (bounds (find-tag-default-bounds))
         (beg (car bounds)) (end (cdr bounds))
         (str (isearch-symbol-regexp (find-tag-default)))
         (search (if backwardp 'search-backward-regexp
                   'search-forward-regexp)))
    (goto-char (if backwardp beg end))
    (funcall search str nil t)
    (cond ((<= beg (point) end) (goto-char point))
          (backwardp (forward-char (- point beg)))
          (t  (backward-char (- end point))))))

(defun jump-to-previous-like-this ()
  "Jumps to the previous occurrence of the symbol at point."
  (interactive)
  (jump-to-symbol-internal t))

(defun jump-to-next-like-this ()
  "Jumps to the next occurrence of the symbol at point."
  (interactive)
  (jump-to-symbol-internal))

(defun kill-this-buffer-unless-scratch ()
  "Works like `kill-this-buffer' unless the current buffer is the
*scratch* buffer. In witch case the buffer content is deleted and
the buffer is buried."
  (interactive)
  (if (not (string= (buffer-name) "*scratch*"))
      (kill-this-buffer)
    (delete-region (point-min) (point-max))
    (switch-to-buffer (other-buffer))
    (bury-buffer "*scratch*")))

(defun duplicate-thing (comment)
  "Duplicates the current line, or the region if active. If an argument is
given, the duplicated region will be commented out."
  (interactive "P")
  (save-excursion
    (let ((start (if (region-active-p) (region-beginning) (point-at-bol)))
          (end   (if (region-active-p) (region-end) (point-at-eol))))
      (goto-char end)
      (unless (region-active-p)
        (newline))
      (insert (buffer-substring start end))
      (when comment (comment-region start end)))))

(defun tidy ()
  "Ident, untabify and unwhitespacify current buffer, or region if active."
  (interactive)
  (let ((beg (if (region-active-p) (region-beginning) (point-min)))
        (end (if (region-active-p) (region-end) (point-max))))
    (indent-region beg end)
    (whitespace-cleanup)
    (untabify beg (if (< end (point-max)) end (point-max)))))

(defadvice eval-last-sexp (around replace-sexp (arg) activate)
  "Replace sexp when called with a prefix argument."
  (if arg
      (let ((pos (point)))
        ad-do-it
        (goto-char pos)
        (backward-kill-sexp)
        (forward-sexp))
    ad-do-it))

(defadvice load-theme
    (before disable-before-load (theme &optional no-confirm no-enable) activate)
  (mapc 'disable-theme custom-enabled-themes))

(lexical-let* ((default (face-attribute 'default :height))
               (size default))

  (defun global-scale-default ()
    (interactive)
    (setq size default)
    (global-scale-internal size))

  (defun global-scale-up ()
    (interactive)
    (global-scale-internal (incf size 20)))

  (defun global-scale-down ()
    (interactive)
    (global-scale-internal (decf size 20)))

  (defun global-scale-internal (arg)
    (set-face-attribute 'default (selected-frame) :height arg)
    (set-temporary-overlay-map
     (let ((map (make-sparse-keymap)))
       (define-key map (kbd "C-=") 'global-scale-up)
       (define-key map (kbd "C-+") 'global-scale-up)
       (define-key map (kbd "C--") 'global-scale-down)
       (define-key map (kbd "C-0") 'global-scale-default) map))))

(setq initial-major-mode (quote org-mode))
(defun lanyitin-new-empty-buffer()
  "create a new empty buffer with org mode"
  (interactive)
  (with-current-buffer "*scratch*"
    (funcall initial-major-mode)
    (let ((tplPath "~/.emacs.d/init-buffer.tpl.org"))
      (when (file-exists-p tplPath)
       (insert-file-contents tplPath)
      )
    )
  ))

(setq initial-buffer-choice 'lanyitin-new-empty-buffer)

(add-hook 'compilation-filter-hook 'comint-truncate-buffer)

(lexical-let ((last-shell ""))
  (defun toggle-shell ()
    (interactive)
    (cond ((string-match-p "^\\*shell<[1-9][0-9]*>\\*$" (buffer-name))
           (goto-non-shell-buffer))
          ((get-buffer last-shell) (switch-to-buffer last-shell))
          (t (shell (setq last-shell "*shell<1>*")))))

  (defun switch-shell (n)
    (let ((buffer-name (format "*shell<%d>*" n)))
      (setq last-shell buffer-name)
      (cond ((get-buffer buffer-name)
             (switch-to-buffer buffer-name))
            (t (shell buffer-name)
               (rename-buffer buffer-name)))))

  (defun goto-non-shell-buffer ()
    (let* ((r "^\\*shell<[1-9][0-9]*>\\*$")
           (shell-buffer-p (lambda (b) (string-match-p r (buffer-name b))))
           (non-shells (cl-remove-if shell-buffer-p (buffer-list))))
      (when non-shells
        (switch-to-buffer (first non-shells))))))

(defadvice shell (after kill-with-no-query nil activate)
  (set-process-query-on-exit-flag (get-buffer-process ad-return-value) nil))

(defun clear-comint ()
  "Runs `comint-truncate-buffer' with the
`comint-buffer-maximum-size' set to zero."
  (interactive)
  (let ((comint-buffer-maximum-size 0))
    (comint-truncate-buffer)))

(add-hook 'comint-mode-hook (lambda () (local-set-key (kbd "C-l") 'clear-comint)))

(dolist (mode '(cider-repl-mode
                clojure-mode
                ielm-mode
                geiser-repl-mode
                slime-repl-mode
                lisp-mode
                emacs-lisp-mode
                lisp-interaction-mode
                scheme-mode))
  ;; add paredit-mode to all mode-hooks
  (add-hook (intern (concat (symbol-name mode) "-hook")) 'paredit-mode))

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)

(add-hook 'cider-repl-mode-hook (lambda () (local-set-key (kbd "C-l") 'cider-repl-clear-buffer)))

(setq cider-cljs-lein-repl
      "(do (require 'figwheel-sidecar.repl-api)
           (figwheel-sidecar.repl-api/start-figwheel!)
           (figwheel-sidecar.repl-api/cljs-repl))")

(defun activate-slime-helper ()
  (when (file-exists-p "~/.quicklisp/slime-helper.el")
    (load (expand-file-name "~/.quicklisp/slime-helper.el"))
    (define-key slime-repl-mode-map (kbd "C-l")
      'slime-repl-clear-buffer))
  (remove-hook 'lisp-mode-hook #'activate-slime-helper))

(add-hook 'lisp-mode-hook #'activate-slime-helper)

(setq inferior-lisp-program "sbcl")

(setq lisp-loop-forms-indentation   6
      lisp-simple-loop-indentation  2
      lisp-loop-keyword-indentation 6)



(eval-after-load "geiser"
  '(setq geiser-active-implementations '(guile)))

(defun c-setup ()
  (local-set-key (kbd "C-c C-c") 'compile))

(add-hook 'c-mode-common-hook 'c-setup)

(define-abbrev-table 'java-mode-abbrev-table
  '(("psv" "public static void main(String[] args) {" nil 0)
    ("sopl" "System.out.println" nil 0)
    ("sop" "System.out.printf" nil 0)))

(defun java-setup ()
  (abbrev-mode t)
  (setq-local compile-command (concat "javac " (buffer-name))))

(add-hook 'java-mode-hook 'java-setup)

(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(defun insert-markdown-inline-math-block ()
  "Inserts an empty math-block if no region is active, otherwise wrap a
math-block around the region."
  (interactive)
  (let* ((beg (region-beginning))
         (end (region-end))
         (body (if (region-active-p) (buffer-substring beg end) "")))
    (when (region-active-p)
      (delete-region beg end))
    (insert (concat "$math$ " body " $/math$"))
    (search-backward " $/math$")))

(add-hook 'markdown-mode-hook
          (lambda ()
            (auto-fill-mode 0)
            (visual-line-mode 1)
            (ispell-change-dictionary "norsk")
            (local-set-key (kbd "C-c b") 'insert-markdown-inline-math-block)) t)

(defvar custom-bindings-map (make-keymap)
  "A keymap for custom bindings.")

(define-key custom-bindings-map (kbd "C-c D") 'define-word-at-point)

(define-key custom-bindings-map (kbd "C->")  'er/expand-region)
(define-key custom-bindings-map (kbd "C-<")  'er/contract-region)

(define-key custom-bindings-map (kbd "C-c e")  'mc/edit-lines)
(define-key custom-bindings-map (kbd "C-c a")  'mc/mark-all-like-this)
(define-key custom-bindings-map (kbd "C-c n")  'mc/mark-next-like-this)

(define-key custom-bindings-map (kbd "C-c m") 'magit-status)

(define-key company-active-map (kbd "C-d") 'company-show-doc-buffer)
(define-key company-active-map (kbd "C-n") 'company-select-next)
(define-key company-active-map (kbd "C-p") 'company-select-previous)
(define-key company-active-map (kbd "<tab>") 'company-complete)

(define-key company-mode-map (kbd "C-:") 'helm-company)
(define-key company-active-map (kbd "C-:") 'helm-company)

(define-key custom-bindings-map (kbd "C-c h")   'helm-command-prefix)
(define-key custom-bindings-map (kbd "M-x")     'helm-M-x)
(define-key custom-bindings-map (kbd "M-y")     'helm-show-kill-ring)
(define-key custom-bindings-map (kbd "C-x b")   'helm-mini)
(define-key custom-bindings-map (kbd "C-x C-f") 'helm-find-files)
(define-key custom-bindings-map (kbd "C-c h d") 'helm-dash-at-point)
(define-key custom-bindings-map (kbd "C-c h o") 'helm-occur)
(define-key custom-bindings-map (kbd "C-c h g") 'helm-google-suggest)
(define-key custom-bindings-map (kbd "M-i")     'helm-swoop)
(define-key custom-bindings-map (kbd "M-I")     'helm-multi-swoop-all)

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
(define-key helm-map (kbd "C-i")   'helm-execute-persistent-action)
(define-key helm-map (kbd "C-z")   'helm-select-action)

(define-key custom-bindings-map (kbd "M-u")         'upcase-dwim)
(define-key custom-bindings-map (kbd "M-c")         'capitalize-dwim)
(define-key custom-bindings-map (kbd "M-l")         'downcase-dwim)
(define-key custom-bindings-map (kbd "M-]")         'other-frame)
(define-key custom-bindings-map (kbd "C-j")         'newline-and-indent)
(define-key custom-bindings-map (kbd "C-c s")       'ispell-word)
(define-key custom-bindings-map (kbd "C-c c")       'org-capture)
(define-key custom-bindings-map (kbd "C-x m")       'mu4e)
(define-key custom-bindings-map (kbd "C-c <up>")    'windmove-up)
(define-key custom-bindings-map (kbd "C-c <down>")  'windmove-down)
(define-key custom-bindings-map (kbd "C-c <left>")  'windmove-left)
(define-key custom-bindings-map (kbd "C-c <right>") 'windmove-right)
(define-key custom-bindings-map (kbd "C-c t")
  (lambda () (interactive) (org-agenda nil "n")))

(define-key global-map          (kbd "M-p")     'jump-to-previous-like-this)
(define-key global-map          (kbd "M-n")     'jump-to-next-like-this)
(define-key custom-bindings-map (kbd "M-,")     'jump-to-previous-like-this)
(define-key custom-bindings-map (kbd "M-.")     'jump-to-next-like-this)
(define-key custom-bindings-map (kbd "C-c .")   (cycle-themes))
(define-key custom-bindings-map (kbd "C-x k")   'kill-this-buffer-unless-scratch)
(define-key custom-bindings-map (kbd "C-c C-0") 'global-scale-default)
(define-key custom-bindings-map (kbd "C-c C-=") 'global-scale-up)
(define-key custom-bindings-map (kbd "C-c C-+") 'global-scale-up)
(define-key custom-bindings-map (kbd "C-c C--") 'global-scale-down)
(define-key custom-bindings-map (kbd "C-c j")   'cycle-spacing-delete-newlines)
(define-key custom-bindings-map (kbd "C-c d")   'duplicate-thing)
(define-key custom-bindings-map (kbd "<C-tab>") 'tidy)
(define-key custom-bindings-map (kbd "M-§")     'toggle-shell)
(dolist (n (number-sequence 1 9))
  (global-set-key (kbd (concat "M-" (int-to-string n)))
                  (lambda () (interactive) (switch-shell n))))
(define-key custom-bindings-map (kbd "C-c C-q")
  '(lambda ()
     (interactive)
     (focus-mode 1)
     (focus-read-only-mode 1)))
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-'") 'org-sync-pdf))

(define-minor-mode custom-bindings-mode
  "A mode that activates custom-bindings."
  t nil custom-bindings-map)
