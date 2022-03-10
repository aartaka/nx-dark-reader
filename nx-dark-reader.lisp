;;;; nx-dark-reader.lisp

(in-package #:nx-dark-reader)

(define-mode dark-reader-mode ()
  "A mode to load Dark Reader script and run it on the page.

For the explanation of `brightness', `contrast', `grayscale', `sepia', `background-color',
`text-color', `selection-color', `use-font', `font-family', `text-stroke', `stylesheet'
see Dark Reader docs and examples. The default values are mostly sensible, though."
  ((glyph "Δ")
   (script nil)
   (brightness
    100
    :type integer)
   (contrast
    100
    :type integer)
   (grayscale
    0
    :type integer)
   (sepia
    0
    :type integer)
   (background-color
    nil
    :type (or null string))
   (text-color
    nil
    :type (or null string))
   (selection-color
    nil
    :type (or null string))
   (use-font
    nil
    :type boolean)
   (font-family
    nil
    :type (or null string))
   (text-stroke
    nil
    :type (or null integer))
   (stylesheet
    nil
    :type (or null string))
   (destructor (lambda (mode)
                 (nyxt::ffi-buffer-remove-user-script (buffer mode) (script mode))))
   (constructor (lambda (mode)
                  (unless (uiop:file-exists-p (nyxt-init-file "darkreader.min.js"))
                    (alexandria:write-string-into-file
                     (dex:get "https://cdn.jsdelivr.net/npm/darkreader/darkreader.min.js")
                     (nyxt-init-file "darkreader.min.js")
                     :if-does-not-exist :create))
                  (with-slots (brightness contrast grayscale sepia
                               background-color text-color selection-color
                               use-font font-family text-stroke
                               stylesheet)
                      mode
                    (setf
                     (script mode)
                     (nyxt::ffi-buffer-add-user-script
                      (buffer mode)
                      (str:concat (uiop:read-file-string
                                   (nyxt-init-file "darkreader.min.js"))
                                  (format nil "
DarkReader.enable({
	brightness: ~d,
	contrast: ~d,
    grayscale: ~d,
	sepia: ~d,
    ~:[~;darkSchemeBackgroundColor: ~s,~]
    ~:[~;darkSchemeTextColor: ~s,~]
    ~:[~;selectionColor: ~s,~]
    ~:[~*~;useFont: true, fontFamily: ~s,~]
    ~:[~;textStroke: ~d,~]
    ~:[~;stylesheet: ~s,~]
});" brightness contrast grayscale sepia
background-color background-color
text-color text-color
selection-color selection-color
use-font font-family
text-stroke text-stroke
stylesheet stylesheet))
                      :all-frames-p nil
                      :at-document-start-p nil
                      :allow-list '("http://*/*" "https://*/*"))))))))
