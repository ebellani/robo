# -*- coding: utf-8 -*-
=begin
Suppose you have to implement a robot that follows the following
commands:

L - Turn left 90 degrees
R - Turn right 90 degrees
M - Move forward
T - Teleport to X,Y

The robot moves in a Cartesian coordinate system. Here is a sample of
the robot's input.

10 10                # define the size of the board the robot will use
2 5 N                # the robot's initial location
LLRRMMMRLRMMM        # a series of inputs
T 1 3                # teleport to X=1, Y=3
LLRRMMRMMRM          # another series of inputs.

Drive the robot around.
=end

=begin
What are PEGs?

Parsing expression grammars (PEGs) are simple to write and easy to
maintain. They are a simple but powerful generalization of regular
expressions that are easier to work with than the LALR or LR-1
grammars of traditional parser generators. There's no need for a
tokenization phase, and lookahead assertions can be used for a limited
degree of context-sensitivity. Here's an extremely simple Treetop
grammar that matches a subset of arithmetic, respecting operator
precedence:

=end

module RobotMovement
  require 'rubygems'
  require 'treetop'
  require 'robot_grammar'

  #  @grammar = Treetop.load 'robot_grammar'
  @parser  = RobotGrammarParser.new

  def self.parser
    @parser
  end

  class Robot
    @@turn_consequences = {
      "N" => ["W", "E"], 
      "W" => ["S", "N"], 
      "S" => ["E", "W"], 
      "E" => ["N", "S"]}

    attr_accessor :x, :y, :direction

    def initialize(x, y, direction)
      self.x = x
      self.y = y
      self.direction = direction
    end

    def eql?(another_robot)
      (self.x == another_robot.x &&
       self.y == another_robot.y &&
       self.direction == another_robot.direction)
    end

    # turn_to : string -> robot
    def turn_to(turn_direction)
      possible_directions = @@turn_consequences[self.direction]
      self.direction = (turn_direction == "L" ? possible_directions[0] : possible_directions[1])
      self
    end

  end

  class Board

    @@step_consequences = {
      "N" => [lambda{|n| n}, lambda{|n| n+1}], 
      "W" => [lambda{|n| n-1}, lambda{|n| n}], 
      "S" => [lambda{|n| n}, lambda{|n| n-1}], 
      "E" => [lambda{|n| n+1}, lambda{|n| n}]} 

    attr_accessor :x, :y
    
    def initialize(x, y)
      self.x = x
      self.y = y
    end

    def eql?(another_board)
      (self.x == another_board.x &&
       self.y == another_board.y)
    end

    def is_valid_move?(x, y)
      (x <= self.x && y <= self.y)
    end

    # move_to : integer integer robot -> false or robot
    def move_robot_to(x, y, a_robot)
      if is_valid_move?(x, y)
        a_robot.x = x
        a_robot.y = y
        a_robot
      else
        false
      end
    end

    # move_robot_forward : a_robot -> a_robot
    def move_robot_forward(a_robot)
      step_consequences = @@step_consequences[a_robot.direction]
      a_robot.x = step_consequences[0].call(a_robot.x)
      a_robot.y = step_consequences[1].call(a_robot.y)
      a_robot
    end

  end

end
