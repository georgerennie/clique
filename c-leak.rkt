#lang racket/base

(require racket/cmdline)
(require "src/c-frontend-cpp.rkt")
(require "src/c-frontend-lexer.rkt")
(require "src/c-frontend-parser.brag")
(require "src/c-frontend-lower.rkt")
(require "src/ast.rkt")

(define lowered-path (make-parameter #f))
(define lowered-prefix (make-parameter ""))

(define input-file
  (command-line
   #:program "c-leak"
   #:once-each ["--lowered-path" path "Write lowered c file to this path" (lowered-path path)]
   ["--lowered-prefix" prefix "Add this prefix to all lowered functions" (lowered-prefix prefix)]
   #:args (input-file)
   input-file))

(displayln "Preprocessing sources...")
(define pre-processed (c-pre-process input-file))
(displayln "Tokenizing sources...")
(define tokens (tokenize (open-input-string pre-processed)))
(displayln "Parsing sources...")
(define parse-tree (parse input-file tokens))
(displayln "Lowering sources...")
(define functions (lower-parse-tree parse-tree))

(when (lowered-path)
  (printf "Writing lowered c to \"~a\"~n" (lowered-path))
  (define out (open-output-file (lowered-path) #:exists 'replace))
  (functions-to-c-file functions out (lowered-prefix))
  (close-output-port out))