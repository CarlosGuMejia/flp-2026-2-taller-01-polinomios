#lang eopl
;Autores: Juan Eduardo Calderon Jaramillo 2611001-3743, Jesus David Lopez Diaz 2611029-3743


;; Taller 1 - Polinomios dispersos.
;; Parte 4: pruebas para las tres representaciones.

(require rackunit)
(require (only-in racket/base exn:fail?))
(require (prefix-in listas: "polinomios-listas.rkt"))
(require (prefix-in procs:  "polinomios-procedimientos.rkt"))
(require (prefix-in dt:     "polinomios-datatypes.rkt"))

;; Representación con listas

;; -- Polinomio cero --
(check-equal?
  (listas:poli? (listas:polinomio-cero 'x))
  #t)

(check-true
  (listas:sin-terminos? (listas:poli->terms (listas:polinomio-cero 'x))))

;; consultar algo que no existe debe dar error
(check-exn
  exn:fail?
  (lambda ()
    (listas:coeficiente-de (listas:polinomio-cero 'x) 0)))

;; eliminar algo que no existe debe dar error
(check-exn
  exn:fail?
  (lambda ()
    (listas:eliminar-termino (listas:polinomio-cero 'x) 0)))

;; agregar un término
(check-equal?
  (listas:coeficiente-de
    (listas:insertar-termino (listas:polinomio-cero 'x) 7 0)
    0)
  7)

;; agregar 0 no debe cambiar el polinomio
(check-equal?
  (listas:insertar-termino (listas:polinomio-cero 'x) 0 3)
  (listas:polinomio-cero 'x))

;; -- Términos que se cancelan --
(define p-cancelado
  (listas:insertar-termino
    (listas:insertar-termino
      (listas:polinomio-cero 'x)
      -3/2 2)
    3/2 2))

(check-true (listas:sin-terminos? (listas:poli->terms p-cancelado)))

;; si se cancelan, consultar ese exponente debe dar error
(check-exn
  exn:fail?
  (lambda ()
    (listas:coeficiente-de p-cancelado 2)))

;; -- Un polinomio con varios términos --
(define p-general
  (listas:insertar-termino
    (listas:insertar-termino
      (listas:insertar-termino (listas:polinomio-cero 'x) 7 0)
      -3/2 2)
    4 5))

(check-equal? (listas:coeficiente-de p-general 5) 4)
(check-equal? (listas:coeficiente-de p-general 2) -3/2)
(check-equal? (listas:coeficiente-de p-general 0) 7)

;; sumar otro término con el mismo exponente
(check-equal?
  (listas:coeficiente-de (listas:insertar-termino p-general 1 2) 2)
  -1/2)

;; -- Eliminar un término --
(check-exn
  exn:fail?
  (lambda ()
    (listas:coeficiente-de (listas:eliminar-termino p-general 2) 2)))

(check-equal?
  (listas:coeficiente-de (listas:eliminar-termino p-general 2) 5)
  4)

;; --- Exponente negativo ---
(check-exn
  exn:fail?
  (lambda ()
    (listas:insertar-termino (listas:polinomio-cero 'x) 5 -1)))

;; --- Exponente que no existe ---
(check-exn
  exn:fail?
  (lambda ()
    (listas:coeficiente-de p-general 3)))

;; --- Eliminar un exponente que no existe ---
(check-exn
  exn:fail?
  (lambda ()
    (listas:eliminar-termino p-general 3)))

;; Representación con procedimientos

;; -- Polinomio cero --
(check-equal?
  (procs:poli? (procs:polinomio-cero 'x))
  #t)

(check-true
  (procs:sin-terminos? (procs:poli->terms (procs:polinomio-cero 'x))))

;; consultar algo que no existe debe dar error
(check-exn
  exn:fail?
  (lambda ()
    (procs:coeficiente-de (procs:polinomio-cero 'x) 0)))

;; eliminar algo que no existe debe dar error
(check-exn
  exn:fail?
  (lambda ()
    (procs:eliminar-termino (procs:polinomio-cero 'x) 0)))

;; agregar un término
(check-equal?
  (procs:coeficiente-de
    (procs:insertar-termino (procs:polinomio-cero 'x) 7 0)
    0)
  7)

;; agregar 0 no debe crear el término
(check-exn
  exn:fail?
  (lambda ()
    (procs:coeficiente-de
      (procs:insertar-termino (procs:polinomio-cero 'x) 0 3)
      3)))

;; -- Términos que se cancelan --
(define p-cancelado-procs
  (procs:insertar-termino
    (procs:insertar-termino
      (procs:polinomio-cero 'x)
      -3/2 2)
    3/2 2))

(check-true (procs:sin-terminos? (procs:poli->terms p-cancelado-procs)))

(check-exn
  exn:fail?
  (lambda ()
    (procs:coeficiente-de p-cancelado-procs 2)))

;; -- Un polinomio con varios términos --
(define p-general-procs
  (procs:insertar-termino
    (procs:insertar-termino
      (procs:insertar-termino (procs:polinomio-cero 'x) 7 0)
      -3/2 2)
    4 5))

(check-equal? (procs:coeficiente-de p-general-procs 5) 4)
(check-equal? (procs:coeficiente-de p-general-procs 2) -3/2)
(check-equal? (procs:coeficiente-de p-general-procs 0) 7)

;; sumar otro término con el mismo exponente
(check-equal?
  (procs:coeficiente-de (procs:insertar-termino p-general-procs 1 2) 2)
  -1/2)

;; -- Eliminar un término --
(check-exn
  exn:fail?
  (lambda ()
    (procs:coeficiente-de (procs:eliminar-termino p-general-procs 2) 2)))

(check-equal?
  (procs:coeficiente-de (procs:eliminar-termino p-general-procs 2) 5)
  4)

;; --- Exponente negativo ---
(check-exn
  exn:fail?
  (lambda ()
    (procs:insertar-termino (procs:polinomio-cero 'x) 5 -1)))

;; --- Exponente que no existe ---
(check-exn
  exn:fail?
  (lambda ()
    (procs:coeficiente-de p-general-procs 3)))

;; --- Eliminar un exponente que no existe ---
(check-exn
  exn:fail?
  (lambda ()
    (procs:eliminar-termino p-general-procs 3)))

#|
;; =================================================================
;; Representación con datatypes
;; Comentado temporalmente: polinomios-datatypes.rkt todavía es
;; la plantilla sin implementar (Carlos). Descomentar cuando esté listo.
;; =================================================================

;; -- Polinomio cero --
(check-equal?
  (dt:poli? (dt:polinomio-cero 'x))
  #t)

(check-true
  (dt:sin-terminos? (dt:poli->terms (dt:polinomio-cero 'x))))

;; consultar algo que no existe debe dar error
(check-exn
  exn:fail?
  (lambda ()
    (dt:coeficiente-de (dt:polinomio-cero 'x) 0)))

;; eliminar algo que no existe debe dar error
(check-exn
  exn:fail?
  (lambda ()
    (dt:eliminar-termino (dt:polinomio-cero 'x) 0)))

;; agregar un término
(check-equal?
  (dt:coeficiente-de
    (dt:insertar-termino (dt:polinomio-cero 'x) 7 0)
    0)
  7)

;; agregar 0 no debe crear el término
(check-exn
  exn:fail?
  (lambda ()
    (dt:coeficiente-de
      (dt:insertar-termino (dt:polinomio-cero 'x) 0 3)
      3)))

;; -- Términos que se cancelan --
(define p-cancelado-dt
  (dt:insertar-termino
    (dt:insertar-termino
      (dt:polinomio-cero 'x)
      -3/2 2)
    3/2 2))

(check-true (dt:sin-terminos? (dt:poli->terms p-cancelado-dt)))

(check-exn
  exn:fail?
  (lambda ()
    (dt:coeficiente-de p-cancelado-dt 2)))

;; -- Un polinomio con varios términos --
(define p-general-dt
  (dt:insertar-termino
    (dt:insertar-termino
      (dt:insertar-termino (dt:polinomio-cero 'x) 7 0)
      -3/2 2)
    4 5))

(check-equal? (dt:coeficiente-de p-general-dt 5) 4)
(check-equal? (dt:coeficiente-de p-general-dt 2) -3/2)
(check-equal? (dt:coeficiente-de p-general-dt 0) 7)

;; --- Exponente negativo ---
(check-exn
  exn:fail?
  (lambda ()
    (dt:insertar-termino (dt:polinomio-cero 'x) 5 -1)))

;; --- Exponente que no existe ---
(check-exn
  exn:fail?
  (lambda ()
    (dt:coeficiente-de p-general-dt 3)))

;; --- Eliminar un exponente que no existe ---
(check-exn
  exn:fail?
  (lambda ()
    (dt:eliminar-termino p-general-dt 3)))

;; --- Sumar polinomios ---
;; p = 4x^5 - (3/2)x^2 + 7
;; q = -4x^5 + (1/2)x^2 + 2x
;; resultado = -x^2 + 2x + 7
(define p-sumar
  (dt:insertar-termino
    (dt:insertar-termino
      (dt:insertar-termino (dt:polinomio-cero 'x) 7 0)
      -3/2 2)
    4 5))

(define q-sumar
  (dt:insertar-termino
    (dt:insertar-termino
      (dt:insertar-termino (dt:polinomio-cero 'x) 2 1)
      1/2 2)
    -4 5))

(define suma-pq (dt:sumar p-sumar q-sumar))

(check-equal? (dt:coeficiente-de suma-pq 2) -1)
(check-equal? (dt:coeficiente-de suma-pq 1) 2)
(check-equal? (dt:coeficiente-de suma-pq 0) 7)

;; el término con x^5 se cancela
(check-exn
  exn:fail?
  (lambda ()
    (dt:coeficiente-de suma-pq 5)))

;; -- Los dos polinomios se cancelan --
(define r-sumar
  (dt:insertar-termino (dt:polinomio-cero 'x) 3 1))

(define s-sumar
  (dt:insertar-termino (dt:polinomio-cero 'x) -3 1))

(check-true
  (dt:sin-terminos? (dt:poli->terms (dt:sumar r-sumar s-sumar))))

;; no se pueden sumar polinomios de variables diferentes
(check-exn
  exn:fail?
  (lambda ()
    (dt:sumar p-sumar (dt:polinomio-cero 'y))))
|#