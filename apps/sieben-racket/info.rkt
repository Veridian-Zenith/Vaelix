#lang info

(define name "sieben-racket")
(define version "0.0.2")
(define description "Vaelix plugin and scripting environment - Theme engine, plugin API, and Racket DSL")
(define homepage "https://github.com/veridian-zenith/vaelix")
(define repository
  (list "github" "veridian-zenith/vaelix"))

(define deps '(
    ("base" #:version "8.18")
    ("json" #:version "1.1")
    ("threading" #:version "0.2")
    ("file-progress" #:version "0.4")
    ("web-server" #:version "3.4")
    ("net-url" #:version "0.4")
    ("net-http-connection" #:version "2.2")
    ("db" #:version "6.1")
    ("syntax-color" #:version "0.2")
    ("parser-tools" #:version "0.9")
))

(define build-deps '(
    ("rackunit-lib" #:version "1.0")
    ("cover" #:version "0.0")
    ("cover-html" #:version "0.0")
))

(define pkg-supply '(
    "src/"
    "plugins/"
    "LICENSE"
    "README.md"
))

;; Plugin API Definitions
(define (define-plugin-foreign-interface)
  (list
   (make-foreign-interface 'plugin_init! "Initialize plugin environment")
   (make-foreign-interface 'plugin_cleanup! "Cleanup plugin environment")
   (make-foreign-interface 'register_event_hook! "Register event hook")
   (make-foreign-interface 'unregister_event_hook! "Unregister event hook")
   (make-foreign-interface 'modify_tab! "Modify tab properties")
   (make-foreign-interface 'create_widget! "Create UI widget")
   (make-foreign-interface 'get_config "Get configuration value")
   (make-foreign-interface 'set_config! "Set configuration value")
   (make-foreign-interface 'make_request "Make network request")
   (make-foreign-interface 'eval_racket_code "Evaluate Racket code in sandbox")))

;; Module Paths for Plugin Components
(define module-paths '(plugin-api theme-engine config-dsl plugin-sandbox))

;; Plugin Load Path Configuration
(define compile-omit-paths '(test tests ".git" "coverage" "benchmarks"))

;; Distribution Configuration
(define release-archives #t)
(define create-info-files #t)
(define make-zip-files #t)

;; Documentation Generation
(define generate-doc #t)
(define doc-paths '("src/plugin-api.rkt" "src/theme-engine.rkt" "plugins/"))

;; Installation Configuration
(define compile-subdirs '("src" "plugins"))
(define install-collection "sieben-racket")
