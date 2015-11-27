(defpackage #:trie
  (:use #:common-lisp)
  (:export #:trie
           #:make-trie
           #:subtrie
           #:add-word
           #:trie-word
           #:trie-count
           #:mapc-trie
           #:read-words))

(in-package #:trie)

(defstruct trie (val nil) children)

(defun add-word (string trie)
  (let ((node trie)
        (chars (coerce string 'list)))
    (dolist (c chars)
      (when (null (assoc c (trie-children node)))
        (push (cons c (make-trie)) (trie-children node)))
      (setf node (cdr (assoc c (trie-children node)))))
    (setf (trie-val node) string))
  trie)

(defun subtrie (trie &rest chars)
  (let ((node trie))
    (dolist (c chars)
      (cond ((assoc c (trie-children node)) (setf node (cdr (assoc c (trie-children node)))))
             (t (return-from subtrie nil))))
    node))

(defun trie-word (trie)
  (trie-val trie))

(defun trie-count (trie)
  (let ((count 0))
    (when (trie-val trie) (incf count))
    (mapc #'(lambda (x) (incf count (trie-count (cdr x))))
      (trie-children trie))
    count))

(defun mapc-trie (fn trie)
  (mapc #'(lambda (x) (funcall fn (car x) (cdr x)))
    (trie-children trie)))

(defun read-words(file trie)
  (with-open-file (in file :direction :input)
    (do ((line (read-line in nil :eof) (read-line in nil :eof)))
        ((eql line :eof) trie)
      (add-word line trie))))

