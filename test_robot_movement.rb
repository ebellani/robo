require 'test/unit'
require 'robot_movement.rb'
class TestMovement < Test::Unit::TestCase


  # HELPERS

  def parse(expression)
    RobotMovement.parser.parse(expression)
  end

  def new_robot(x, y, direction)
    RobotMovement::Robot.new(x, y, direction)
  end

  def new_board(x, y)
    RobotMovement::Board.new(x, y)
  end

  # END HELPERS

  def test_load_data
    assert_nil parse('hello robot')
    assert_nil parse("10")

    assert parse("1   5").value.instance_of?(RobotMovement::Board)
    assert new_board(9,9).eql?(parse("9 9").value)

    assert parse("1 5 S").value.instance_of?(RobotMovement::Robot)
    assert new_robot(0, 0, "S").eql?(parse("0 0 S").value)
  end

  def test_teleport
    assert new_robot(9, 5, "S").eql?(new_board(9,9).move_robot_to(9, 5, new_robot(0, 0, "S")))
    teleported_robot = parse("T 9 9").value(new_robot(0, 0, "S"), new_board(9,9))
    assert new_robot(9, 9, "S").eql?(teleported_robot)
  end

  def test_turn
    assert new_robot(0, 0, "S").turn_to("L"), new_robot(9, 9, "W")
    assert parse("R").value(new_robot(9, 9, "N")).eql?(new_robot(9, 9, "E"))
  end

  def test_forward
    assert new_board(9,9).move_robot_forward(new_robot(0, 0, "N")).eql?(new_robot(0, 1, "N"))
    assert parse("M").value(new_robot(8, 8, "N"), new_board(9,9)).eql?(new_robot(8, 9, "N"))
  end

  def test_full_movements
    assert new_robot(0, 8, "S").eql?(parse("20 40\n2 0 S\nT 0 8").value)
    assert new_robot(0, 1, "N").eql?(parse("20 40\n2 0 N\nT 0 0\nM").value)
    assert new_robot(5, 5, "N").eql?(parse("20 40\n2 0 N\nT 0 0\nM\nT 5 5").value)
    assert new_robot(0, 2, "N").eql?(parse("20 40\n2 0 N\nT 0 0\nMM").value)
    assert new_robot(0, 0, "E").eql?(parse("20 40\n2 0 N\nT 0 0\nR").value)
    assert new_robot(0, 1, "N").eql?(parse("20 40\n2 0 N\nT 0 0\nRRRRM").value)

    assert new_robot(1, 1, "N").eql?(parse("20 40\n2 0 S\nT 0 2\nMMLMLM").value)
    assert new_robot(0, 0, "S").eql?(parse("3 3\n1 1 N\nRMLMLMMLMM").value)
  end

end
