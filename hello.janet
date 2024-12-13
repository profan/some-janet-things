(use jaylib)

(init-window 600 480 "Testulon")
(set-target-fps 60)
(hide-cursor)

(def balls @[])

(defn v/+
  [[a-x a-y] [b-x b-y]]
  [(+ a-x b-x) (+ a-y b-y)])

(defn v/-
  [[a-x a-y] [b-x b-y]]
  [(- a-x b-x) (- a-y b-y)])

(defn v/div
  [[x y] s]
  [(/ x s) (/ y s)])

(defn v/mul
  [[x y] s]
  [(* x s) (* y s)])

(defn v/length
  [[x y]]
  (math/sqrt (+ (* x x) (* y y))))

(defn v/normalize
  [v]
  (v/div v (v/length v)))

(defmacro v/+= [n v]
  ~(set ,n (v/+ ,n ,v)))

(defmacro v/-= [n v]
  ~(set ,n (v/- ,n ,v)))

(defn get-force-to-apply
  [p m t]
  (def d (v/- p m))
  (def [f-x f-y] (v/normalize d))
  [f-x f-y])

(while (not (window-should-close))
  (begin-drawing)
  (clear-background [0 0 0])
  (def [x y] (get-mouse-position))

  # (draw-text (string "x: " w-x "y: " w-y) x y 32.0 :white)
  (draw-circle x y 4.0 :orange)

  (loop [[x y vx vy] :in balls]
    (draw-circle (math/round x) (math/round y) 4.0 :green))
  
  (for i 0 (- (length balls) 1)
    (def [a-x a-y a-vx a-vy] (i balls))
    (def [b-x b-y b-vx b-vy] ((+ i 1) balls))
    (draw-line (math/round a-x) (math/round a-y) (math/round b-x) (math/round b-y) :white))
  
  (for i 0 (- (length balls) 1)
    (def [x y v-x v-y] (i balls))
    (def f (get-force-to-apply [x y] (get-mouse-position) 1))
    (set (balls i) [;(v/+ [x y] f) v-x v-y]))

  (when (mouse-button-pressed? :left)
    (def [x y] (get-mouse-position))
    (array/push balls [x y 0 0]))

  (end-drawing))