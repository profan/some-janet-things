(use jaylib)

(init-window 600 480 "Testulon")
(set-target-fps 60)
(hide-cursor)

(def balls @[])

(while (not (window-should-close))
  (begin-drawing)
  (clear-background [0 0 0])
  (def [x y] (get-mouse-position))
  (def [w-x w-y] (get-window-position))
 
  # (draw-text (string "x: " w-x "y: " w-y) x y 32.0 :white)
  (draw-circle x y 4.0 :orange)

  (loop [[x y] :in balls]
    (draw-circle x y 4.0 :green))
  
  (when (mouse-button-pressed? :left)
    (def [x y] (get-mouse-position))
    (array/push balls [x y]))

  (end-drawing))