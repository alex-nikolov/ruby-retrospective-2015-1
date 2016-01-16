def new_head(snake, direction)
  [snake.last[0] + direction[0], snake.last[1] + direction[1]]
end

def move(snake, direction)
  grow(snake, direction).drop(1)
end

def grow(snake, direction)
  snake + [new_head(snake, direction)]
end

def new_food(food, snake, dimensions)
  play_field = [*0...dimensions[:width]].product [*0...dimensions[:height]]
  (play_field - food - snake).sample
end

def snake_ahead?(snake, direction)
  snake.include? new_head(snake, direction)
end

def wall_ahead?(snake, direction, dimensions)
  small_width = new_head(snake, direction)[0] < 0
  big_width = new_head(snake, direction)[0] >= dimensions[:width]
  small_height = new_head(snake, direction)[1] < 0
  big_height = new_head(snake, direction)[1] >= dimensions[:height]

  small_width or small_height or big_width or big_height
end

def obstacle_ahead?(snake, direction, dimensions)
  snake_ahead?(snake, direction) or
    wall_ahead?(snake, direction, dimensions)
end

def danger?(snake, direction, dimensions)
  moved_snake = move(snake, direction)
  close_to_death = obstacle_ahead?(snake, direction, dimensions) or
                     obstacle_ahead?(moved_snake, direction, dimensions)
end