#lang eopl
;Autores: Juan Eduardo Calderon Jaramillo 2611001-3743
;         Carlos Humberto Gutierrez Mejia 2059817-3743
;         David Apellido Codigo

; Taller 1 — polinomios dispersos.
; Parte 4: bateria de pruebas sobre las tres representaciones.


(require rackunit)
(require (prefix-in listas: "polinomios-listas.rkt"))
(require (prefix-in procs:  "polinomios-procedimientos.rkt"))
(require (prefix-in dt:     "polinomios-datatypes.rkt"))


(define dt-p
  (dt:insertar-termino
   (dt:insertar-termino
    (dt:insertar-termino (dt:polinomio-cero 'x) 7 0)
    -3/2 2)
   4 5))

(define dt-q
  (dt:insertar-termino
   (dt:insertar-termino
    (dt:insertar-termino (dt:polinomio-cero 'x) 2 1)
    1/2 2)
   -4 5))

(define dt-np
  (dt:insertar-termino
   (dt:insertar-termino
    (dt:insertar-termino (dt:polinomio-cero 'x) -7 0)
    3/2 2)
   -4 5))

(define dt-cero (dt:polinomio-cero 'x))

; construccion y observadores 

(test-case "datatypes: constructores y predicados"
  (check-true (dt:poli? dt-cero))
  (check-true (dt:nombre-var? (dt:nombre-var 'x)))
  (check-true (dt:sin-terminos? (dt:sin-terminos)))
  (check-true (dt:mas-terminos?
               (dt:mas-terminos (dt:termino (dt:coef-ent 4) (dt:expo-nat 5))
                                (dt:sin-terminos))))
  (check-true (dt:coef-ent? (dt:coef-ent 4)))
  (check-true (dt:coef-rac? (dt:coef-rac -3 2)))
  (check-false (dt:coef-ent? (dt:coef-rac -3 2)))
  (check-true (dt:expo-nat? (dt:expo-nat 5)))
  (check-false (dt:poli? 'no-es-un-polinomio)))

(test-case "datatypes: polinomio construido a mano igual al insertado"
  (check-equal?
   (dt:polinomio->lista
    (dt:poli (dt:nombre-var 'x)
             (dt:mas-terminos (dt:termino (dt:coef-ent 4) (dt:expo-nat 5))
               (dt:mas-terminos (dt:termino (dt:coef-rac -3 2) (dt:expo-nat 2))
                 (dt:mas-terminos (dt:termino (dt:coef-ent 7) (dt:expo-nat 0))
                                  (dt:sin-terminos))))))
   (dt:polinomio->lista dt-p)))

; polinomio-cero

(test-case "datatypes: polinomio-cero"
  (check-equal? (dt:polinomio->lista dt-cero) '())
  (check-true (dt:poli? (dt:polinomio-cero 'y)))
  (check-exn #rx"simbolo" (lambda () (dt:polinomio-cero 5))))

; Pruebas de insertar-termino

(test-case "datatypes: insertar-termino casos funcionales"
  (check-equal? (dt:polinomio->lista dt-p) '((4 5) (-3/2 2) (7 0)))
  
; Se prueba insertar al inicio, en medio y al final.
  
  (check-equal? (dt:polinomio->lista (dt:insertar-termino dt-p 2 8))
                '((2 8) (4 5) (-3/2 2) (7 0)))
  (check-equal? (dt:polinomio->lista (dt:insertar-termino dt-p 5 3))
                '((4 5) (5 3) (-3/2 2) (7 0)))
  (check-equal? (dt:polinomio->lista (dt:insertar-termino dt-p 6 1))
                '((4 5) (-3/2 2) (6 1) (7 0)))
;  exponente existente: los coeficientes se suman
  (check-equal? (dt:polinomio->lista (dt:insertar-termino dt-p 1 2))
                '((4 5) (-1/2 2) (7 0)))
  
; El resultado debe ser el mismo aunque cambiemos el orden.
  
  (check-equal?
   (dt:polinomio->lista
    (dt:insertar-termino
     (dt:insertar-termino
      (dt:insertar-termino dt-cero 4 5)
      7 0)
     -3/2 2))
   (dt:polinomio->lista dt-p)))

(test-case "datatypes: insertar-termino sobre el polinomio nulo"
  (check-equal? (dt:polinomio->lista (dt:insertar-termino dt-cero 7 0))
                '((7 0)))
  (check-equal? (dt:polinomio->lista (dt:insertar-termino dt-cero -3/2 2))
                '((-3/2 2))))

(test-case "datatypes: insertar-termino que cancela un término"
  (check-equal? (dt:polinomio->lista (dt:insertar-termino dt-p 3/2 2))
                '((4 5) (7 0)))
  (check-equal? (dt:polinomio->lista (dt:insertar-termino dt-p -7 0))
                '((4 5) (-3/2 2)))
;    cancelar el unico término deja el polinomio nulo
  (check-equal?
   (dt:polinomio->lista
    (dt:insertar-termino (dt:insertar-termino dt-cero 7 0) -7 0))
   '()))

(test-case "datatypes: insertar-termino con coeficiente cero no altera"
  (check-equal? (dt:polinomio->lista (dt:insertar-termino dt-p 0 9))
                '((4 5) (-3/2 2) (7 0)))
  (check-equal? (dt:polinomio->lista (dt:insertar-termino dt-p 0 2))
                '((4 5) (-3/2 2) (7 0)))
  (check-equal? (dt:polinomio->lista (dt:insertar-termino dt-cero 0 3))
                '()))

(test-case "datatypes: insertar-termino errores"
  (check-exn #rx"exponente debe ser" (lambda () (dt:insertar-termino dt-p 5 -1)))
  (check-exn #rx"exponente debe ser" (lambda () (dt:insertar-termino dt-p 5 1/2)))
  (check-exn #rx"numero exacto" (lambda () (dt:insertar-termino dt-p 1.5 2))))

; coeficiente-de casos funcionales 

(test-case "datatypes: coeficiente-de casos funcionales"
  (check-equal? (dt:coeficiente-de dt-p 5) 4)
  (check-equal? (dt:coeficiente-de dt-p 2) -3/2)
  (check-equal? (dt:coeficiente-de dt-p 0) 7)
  (check-equal? (dt:coeficiente-de dt-q 1) 2)
  (check-equal? (dt:coeficiente-de dt-q 2) 1/2))

(test-case "datatypes: coeficiente-de errores"
           
; Exponentes que no existen en el polinomio.
           
  (check-exn #rx"no tiene termino" (lambda () (dt:coeficiente-de dt-p 3)))
  
  (check-exn #rx"no tiene termino" (lambda () (dt:coeficiente-de dt-p 9)))
  
  (check-exn #rx"no tiene termino" (lambda () (dt:coeficiente-de dt-q 0)))
  
  (check-exn #rx"no tiene termino" (lambda () (dt:coeficiente-de dt-cero 0))))

; eliminar-termino 

(test-case "datatypes: eliminar-termino casos funcionales"
  (check-equal? (dt:polinomio->lista (dt:eliminar-termino dt-p 2))
                '((4 5) (7 0)))
  (check-equal? (dt:polinomio->lista (dt:eliminar-termino dt-p 5))
                '((-3/2 2) (7 0)))
  (check-equal? (dt:polinomio->lista (dt:eliminar-termino dt-p 0))
                '((4 5) (-3/2 2)))
  ; eliminar el único término deja el polinomio nulo
  (check-equal?
   (dt:polinomio->lista
    (dt:eliminar-termino (dt:insertar-termino dt-cero 7 0) 0))
   '())
  ; el original no cambia
  (check-equal? (dt:polinomio->lista dt-p) '((4 5) (-3/2 2) (7 0))))

(test-case "datatypes: eliminar-termino errores"
  (check-exn #rx"no tiene termino" (lambda () (dt:eliminar-termino dt-p 3)))
  (check-exn #rx"no tiene termino" (lambda () (dt:eliminar-termino dt-p 9)))
  (check-exn #rx"no tiene termino" (lambda () (dt:eliminar-termino dt-cero 0))))

;    sumar 

(test-case "datatypes: sumar casos funcionales"
  (check-equal? (dt:polinomio->lista (dt:sumar dt-p dt-q))
                '((-1 2) (2 1) (7 0)))
  ;  conmutativa
  (check-equal? (dt:polinomio->lista (dt:sumar dt-q dt-p))
                '((-1 2) (2 1) (7 0)))
  (check-equal? (dt:polinomio->lista (dt:sumar dt-p dt-p))
                '((8 5) (-3 2) (14 0)))
  ; el nulo es el neutro
  (check-equal? (dt:polinomio->lista (dt:sumar dt-p dt-cero))
                '((4 5) (-3/2 2) (7 0)))
  (check-equal? (dt:polinomio->lista (dt:sumar dt-cero dt-p))
                '((4 5) (-3/2 2) (7 0))))

(test-case "datatypes: sumar de dos polinomios que se cancelan por completo"
  (check-equal? (dt:polinomio->lista (dt:sumar dt-p dt-np)) '())
  (check-true (dt:poli? (dt:sumar dt-p dt-np))))

(test-case "datatypes: sumar de polinomios en variables distintas"
  (check-exn #rx"misma variable"
             (lambda () (dt:sumar dt-p (dt:polinomio-cero 'y))))
  (check-exn #rx"misma variable"
             (lambda () (dt:sumar (dt:polinomio-cero 'y) dt-p))))
