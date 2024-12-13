(use jaylib)

(init-window 600 480 "Testulon")
(set-target-fps 60)
(hide-cursor)

(def balls @[])

(while (not (window-should-close))
  (begin-drawing)
  (clear-background [0 0 0])
  (def [x y] (get-mouse-position))

  # (draw-text (string "x: " w-x "y: " w-y) x y 32.0 :white)
  (draw-circle x y 4.0 :orange)

  (loop [[x y] :in balls]
    (draw-circle x y 4.0 :green))
  
  (for i 0 (- (length balls) 1)
    (def [a-x a-y] (i balls))
    (def [b-x b-y] ((+ i 1) balls))
    (draw-line a-x a-y b-x b-y :white))

  (when (mouse-button-pressed? :left)
    (def [x y] (get-mouse-position))
    (array/push balls [x y]))

  (end-drawing))