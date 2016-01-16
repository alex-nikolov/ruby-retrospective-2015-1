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

def wall_ahead?(next_head_position, dimensions)
  next_x, next_y = next_head_position

  next_x < 0 or next_x >= dimensions[:width] or
    next_y < 0 or next_y >= dimensions[:height]
end

def obstacle_ahead?(snake, direction, dimensions)
  next_head_position = new_head(snake, direction)

  snake_ahead?(snake, direction) or
    wall_ahead?(next_head_position, dimensions)
end

def danger?(snake, direction, dimensions)
  moved_snake = move(snake, direction)
  obstacle_ahead?(snake, direction, dimensions) or
    obstacle_ahead?(moved_snake, direction, dimensions)
end