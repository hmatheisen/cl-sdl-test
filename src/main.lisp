(defpackage sdl-test
  (:use :cl :sdl2))
(in-package :sdl-test)

(defvar *started* nil)
(defvar *window* nil)
(defvar *main-loop-quit* nil)

(defun new-window ()
  (in-main-thread ()
    (setf *window* (create-window :flags '(:shown)))))

(defun close-window ()
  (in-main-thread ()
    (sdl2:destroy-window *window*))
  (setf *window* nil))

(defun handle-event (ev)
  (plus-c:c-let ((event sdl2-ffi:sdl-event :from ev))
    (let ((type (sdl2:get-event-type ev)))
      (cond
        ((eq :lisp-message type)
         (sdl2::get-and-handle-messages))
        ((or (eq :keyup type)
             (eq :keydown type))
         (when *window*
           (print ev)))
        ((eq :windowevent type)
         (let ((window-event-type
                 (autowrap:enum-key 'sdl2-ffi:sdl-window-event-id
                                    (event :window :event))))
           (when *window*
             (case window-event-type
               (:close
                (close-window))))))))))

(defun draw-rect (r x y)
  (sdl2:set-render-draw-color r 255 255 255 255)
  (sdl2:render-draw-rect r (sdl2:make-rect x y 10 10))
  (sdl2:set-render-draw-color r 0 0 0 255))

(defun draw ()
  (sdl2:with-renderer (r *window*)
    (sdl2:render-clear r)
    (draw-rect r 10 10)
    (draw-rect r 100 100)
    (sdl2:render-present r)))

(defun main-loop ()
  (let (*main-loop-quit*)
    (sdl2:with-sdl-event (ev)
      (loop
        as rc = (sdl2:next-event ev :poll)
        do (progn
             (handle-event ev)
             (when *window* (draw))
             (when *main-loop-quit*
               (return-from main-loop)))))))

(defun start ()
  (unless *started*
    (sdl2:init :video)
    (setf *started* t)
    (unwind-protect
         (sdl2:in-main-thread (:background t :no-event t)
           (main-loop))
      (setf *started* nil))))

(defun quit-sdl ()
  (sdl2:in-main-thread ()
    (setf *main-loop-quit* t))
  (sdl2:quit))
