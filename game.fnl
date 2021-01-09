(local cellWidth 25)
(local cellNum {:x 20
                :y 14})
(local timerLimit 0.1)
(var snake {})
(var food {})
(var timer 0)
(var nextDir {:x 1 :y 0})

(fn cellCollide? [a b]
  (and (= a.x b.x) (= a.y b.y)))

(fn cellInSnake? [s c]
  (lume.any s (fn [v] (cellCollide? v c))))

(fn nextCell [s]
  (let [head (lume.first s)]
    {:x (+ head.x s.dir.x) :y (+ head.y s.dir.y)}))

(fn move! [s]
  (table.insert s 1 (nextCell s))
  (table.remove s))

(fn grow! [s] (table.insert s 1 (nextCell s)))

(fn spawnFood! []
  (let [x (math.random cellNum.x)
        y (math.random cellNum.y)
        trial {: x : y}]
    (if (cellInSnake? snake trial)
        (spawnFood!)
        (set food trial))))

(fn randomDir []
  (let [ds [{:x  1 :y  0}
            {:x -1 :y  0}
            {:x  0 :y  1}
            {:x  0 :y -1}]]
    (. ds (math.random 4))))

(fn newgame! []
  (set nextDir (randomDir))
  (set snake {:dir nextDir})
  (table.insert snake 1 {:x (math.random 6 (- cellNum.x 6))
                         :y (math.random 6 (- cellNum.y 6))})
  (grow! snake)
  (grow! snake)
  (spawnFood!)
  (set timer 0))

(fn endgame! []
  (newgame!))

(fn love.load [] (newgame!))


(fn love.update [dt]
  (set timer (+ timer dt))
  (when (>= timer timerLimit)
    (set timer (- timer timerLimit))
    (when (and (~= snake.dir.x nextDir.x)
               (~= snake.dir.y nextDir.y))
      (set snake.dir.x nextDir.x)
      (set snake.dir.y nextDir.y))
    (local trial (nextCell snake))
    ; Test collision with border
    (when (or (< trial.x 1)
              (> trial.x cellNum.x)
              (< trial.y 1)
              (> trial.y cellNum.y))
          (endgame!))
    ; Test collision with snake
    (when (cellInSnake? snake trial)
          (endgame!))
    ; Test collision with food
    (when (cellCollide? trial food)
          (grow! snake)
          (spawnFood!))
    ; Move snake
    (move! snake)))

(fn love.keypressed [key]
  (if (lume.find ["h" "a" "left"] key)
      (when (= snake.dir.x 0)
        (set nextDir {:x -1 :y 0}))
      (lume.find ["j" "s" "down"] key)
      (when (= snake.dir.y 0)
        (set nextDir {:x  0 :y 1}))
      (lume.find ["k" "w" "up"] key)
      (when (= snake.dir.y 0)
        (set nextDir {:x  0 :y -1}))
      (lume.find ["l" "d" "right"] key)
      (when (= snake.dir.x 0)
        (set nextDir {:x  1 :y 0}))))

(fn drawCell [t params]
  (love.graphics.setColor params.color)
  (love.graphics.rectangle "fill"
                           (* (- t.x 1) cellWidth)
                           (* (- t.y 1) cellWidth)
                           (- cellWidth 1)
                           (- cellWidth 1)))

(fn love.draw []
  (love.graphics.setBackgroundColor 0.28 0.28 0.28)
  (lume.each snake (fn [v] (drawCell v {:color [0.3 0.82 0.287]})))
  (drawCell food {:color [0.942 0.71 0.135]}))
