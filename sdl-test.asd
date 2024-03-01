(defsystem "sdl-test"
  :version "0.0.1"
  :author ""
  :license ""
  :depends-on ("sdl2")
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "sdl-test/tests"))))

(defsystem "sdl-test/tests"
  :author ""
  :license ""
  :depends-on ("sdl-test"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for sdl-test"
  :perform (test-op (op c) (symbol-call :rove :run c)))
