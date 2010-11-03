require 'test/unit'
require 'robot_movement.rb'
class TestMovement < Test::Unit::TestCase

  def setup
    @a_10_by_10_board = RobotMovement::Board.new(9, 9)
    @initial_robot = RobotMovement::Robot.new(0, 0, "S")
  end

  def test_basic_functions
    assert @a_10_by_10_board.eql? RobotMovement::Board.new(9, 9)
    assert @initial_robot.eql? RobotMovement::Robot.new(0, 0, "S")
  end

  def test_load_data
    assert_nil RobotMovement.parser.parse('hello robot')
    assert_nil RobotMovement.parser.parse("10")

    assert RobotMovement.parser.parse("1   5").value.instance_of?(RobotMovement::Board)
    assert @a_10_by_10_board.eql?(RobotMovement.parser.parse("9 9").value)

    assert RobotMovement.parser.parse("1 5 S").value.instance_of?(RobotMovement::Robot)
    assert @initial_robot.eql?(RobotMovement.parser.parse("0 0 S").value)
    #     (check-equal? (process-mech (open-input-string "20 40\n2 0 S\nT 0 2\nMMLMLM"))
    #               (make-mech 1 1 #\N))
    #  
    #     (check-equal? (process-mech (open-input-string "3 3\n1 1 N\nRMLMLMMLMM"))
    #               (make-mech 0 0 #\S))body
  end

  def test_movements
    assert RobotMovement::Robot.new(9, 5, "S").eql?(@a_10_by_10_board.move_robot_to(9, 5, @initial_robot))
    teleported_robot = RobotMovement.parser.parse("T 9 9").value(@a_10_by_10_board,
                                                                 @initial_robot)
    assert RobotMovement::Robot.new(9, 9, "S").eql?(teleported_robot)
  end

end
