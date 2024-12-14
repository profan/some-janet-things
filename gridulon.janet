(use jaylib)

(defn v/+ [[a-x a-y] [b-x b-y]]
  [(+ a-x b-x) (+ a-y b-y)])

(defn v/- [[a-x a-y] [b-x b-y]]
  [(- a-x b-x) (- a-y b-y)])

(defn v/div [[x y] s]
  [(/ x s) (/ y s)])

(defn v/mul [[x y] s]
  [(* x s) (* y s)])

(defn v/% [[x y] s]
  [(% x s) (% y s)])

(defn v/length [[x y]]
  (math/sqrt (+ (* x x) (* y y))))

(defn v/normalize [v]
  (v/div v (v/length v)))

(defn v/round [[x y]]
  [(math/round x) (math/round y)])

(defmacro v/+= [n v]
  ~(set ,n (v/+ ,n ,v)))

(defmacro v/-= [n v]
  ~(set ,n (v/- ,n ,v)))

(defmacro v/mul= [n s]
  ~(set ,n (v/mul ,n ,s)))

(defmacro v/div= [n s]
  ~(set ,n (v/div ,n ,s)))

(defn lerp [a b t]
 (+ (* a (- 1.0 t)) (* b t)))

(defn lerp-colour [a b t]
  [(min 1.0 (lerp (0 a) (0 b) t))
    (min 1.0 (lerp (1 a) (1 b) t))
    (min 1.0 (lerp (2 a) (2 b) t))
    (min 1.0 (lerp (3 a) (3 b) t))])

(def *window-size-w* 640)
(def *window-size-h* 640)

(defn make-grid-entry [x y colour grid-size]
  (def target-random-r (+ (/ x grid-size) (/ (math/random) 32.0)))
  (def target-random-g (+ (/ y grid-size) (/ (math/random) 32.0)))
  (def target-random-b (+ (/ x grid-size) (/ (math/random) 32.0)))
  (def target-colour [target-random-r target-random-g target-random-b 1.0])
  (def final-target-colour (lerp-colour target-colour [1.0 1.0 1.0 1.0] 0.5))
  @{:start-colour colour
    :end-colour final-target-colour
    :time 0.0})

(defn initialize-grid [grid size]
  (for x 0 size
    (for y 0 size
      (put grid [x y] (make-grid-entry x y [1.0 1.0 1.0 1.0] size)))))

(init-window *window-size-w* *window-size-h* "gridulon")
(set-target-fps 60)
(hide-cursor)

(def *grid-tile-count* 32)
(def *grid-tile-size* (/ *window-size-w* *grid-tile-count*))
(def *grid-tile-chunk-size* 8)

(var current-tile-timer 0.0)
(var current-tile-min-time 0.25)
(var current-tile-max-time 0.75)

(var secondary-tile-timer 0.0)

(var current-brush-size (* *grid-tile-size* 4))
(def grid @{})

(initialize-grid grid *grid-tile-count*)

(while (not (window-should-close))
  (begin-drawing)
  (clear-background [0 0 0])
  (set-window-size *window-size-w* *window-size-h*)

  (def dt (get-frame-time))
  (def [m-x m-y] (get-mouse-position))

  (loop [[grid-pos entry] :in (pairs grid)]

    (def [x y] (v/mul grid-pos *grid-tile-size*))

    (def current-t (entry :time))
    (def current-colour (lerp-colour (entry :start-colour) (entry :end-colour) current-t))
    (draw-rectangle x y *grid-tile-size* *grid-tile-size* current-colour)

    (-= (entry :time) (* dt 0.25))
    (set (entry :time) (max (entry :time) 1.0)))

  (defn find-minimum-tile []

    (var has-found-min? false)
    (var smallest-time ((first grid) :time))
    (var smallest-entry (first grid))
    (var smallest-pos [0 0])

    (loop [[grid-pos entry] :in (pairs grid)]
      (def time (entry :time))
      (when (< time smallest-time)
        (set smallest-time time)
        (set smallest-pos grid-pos)
        (set smallest-entry entry)))

   [smallest-pos smallest-entry])

  (defn paint-tile [c-x c-y current-paint-speed is-painting?]
    (def [g-x g-y] (v/div [c-x c-y] *grid-tile-size*))
    (def [t-x t-y] (v/mul (v/round (v/div [g-x g-y] *grid-tile-chunk-size*)) *grid-tile-chunk-size*))

    (def start-x (math/round t-x))
    (def start-y (math/round t-y))
    (def target-x (math/round (+ t-x *grid-tile-chunk-size*)))
    (def target-y (math/round (+ t-y *grid-tile-chunk-size*)))

    (for cur-x start-x target-x
      (for cur-y start-y target-y
        (def entry (grid [cur-x cur-y]))
        (when (and is-painting? (not (nil? entry)))
          (+= (entry :time) (* dt current-paint-speed))))))

  (def is-painting? (mouse-button-down? :left))
  (def is-painting-fast? (and is-painting? (key-down? :left-shift)))
  (def current-paint-speed (if is-painting-fast? 16.0 2.0))
  (paint-tile m-x m-y current-paint-speed is-painting?)

  (when (<= current-tile-timer 0.0)
    (def new-random-min (* (math/random) current-tile-min-time))
    (def new-random-max (* (math/random) current-tile-max-time))
    (def new-random-time (lerp new-random-min new-random-max 0.5))
    (def new-random-x (math/round (* (math/random) (- *window-size-w* 1))))
    (def new-random-y (math/round (* (math/random) (- *window-size-h* 1))))
    (def new-random-tile [new-random-x new-random-y])
    (paint-tile new-random-x new-random-y 64.0 true)
    (set secondary-tile-timer (* new-random-time 2.0))
    (set current-tile-timer new-random-time))

  (when (<= secondary-tile-timer 0.0)
    (def (entry-pos entry) (find-minimum-tile))
    (def [x y] (v/mul entry-pos *grid-tile-size*))
    (paint-tile x y 64.0 true)
    (set secondary-tile-timer 0.0))

  (-= current-tile-timer dt)

  (draw-circle-lines m-x m-y 4.0 0x428bcaff)

  (end-drawing))