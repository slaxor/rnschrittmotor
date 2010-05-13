# © 2010 Sascha Teske <sascha.teske@microprojects.de>
require 'rubygems'
require 'test/unit'
require 'mocha'
require 'stringio'
require File.join([File.expand_path(File.dirname(__FILE__)), '..', 'rn_schrittmotor'])

class RNSchrittmotorTest <Test::Unit::TestCase

  def setup
    @stepper = RNSchrittmotor.new('/dev/ttyUSB0', 9600)
  end

  def test_crc8
    assert_equal "\x56",  RNSchrittmotor.crc8("\xff\x00\x00\x00\x00\x00")
    assert_equal "\x0e",  RNSchrittmotor.crc8("\xfe\x0f\x00\x00\x00\x00")
  end

  def test_do_it
    @stepper.expects(:write).with("!#\xff\x00\x00\x00\x00\x00\x56")
    @stepper.expects(:read)
    @stepper.do_it("\xff\x00\x00\x00\x00\x00")
  end

  def test_number_to_bytes
    assert_equal "\x04\x0c", RNSchrittmotor.number_to_bytes(3076)
  end

  def test_read_counter
    @stepper.expects(:do_it).with("f\001\000\000\000\000").returns("\xff\xff")
    assert_equal "\xff\xff", @stepper.read_counter(RNSchrittmotor::FIRST)
  end

  def test_read_eeprom
    @stepper.expects(:do_it).with("\3762\000\000\000\000").returns("\xff" * 50)
    assert_equal "\xff" * 50, @stepper.read_eeprom(50)
  end

  def test_read_end_switches
    @stepper.expects(:do_it).with("h\000\000\000\000\000").returns("\x0f")
    assert_equal "\x0f", @stepper.read_end_switches
  end

  def test_read_i2c_response
    @stepper.expects(:do_it).with("g\000\000\000\000\000").returns("*")
    assert_equal "*", @stepper.read_i2c_response
  end

  def test_read_status
    @stepper.expects(:do_it).with("e\001\000\000\000\000").returns("\x00")
    assert_equal "\x00", @stepper.read_status(RNSchrittmotor::FIRST)
  end

  def test_read_version
    @stepper.expects(:do_it).with("\xff\000\000\000\000\000").returns("blah version string")
    assert_equal "blah version string", @stepper.read_version
  end

  def test_reset_counter
    @stepper.expects(:do_it).with("\016\001\000\000\000\000").returns("*")
    assert_equal "*", @stepper.reset_counter(RNSchrittmotor::FIRST)
  end

  def test_reset_eeprom
    @stepper.expects(:do_it).with("\313\313\000\000\000\000").returns("*")
    assert_equal "*", @stepper.reset_eeprom(203)
  end

  def test_run!
    @stepper.expects(:do_it).with("6\001\000\000\000\000").returns("*")
    assert_equal "*", @stepper.run!(RNSchrittmotor::FIRST)
  end

  def test_set_controller_mode
    @stepper.expects(:do_it).with("\310\000\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_controller_mode(RNSchrittmotor::SERIAL)
    @stepper.expects(:do_it).with("\310\000\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_controller_mode(RNSchrittmotor::I2C)
    @stepper.expects(:do_it).with("\310\002\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_controller_mode(RNSchrittmotor::PULSE)
  end

  def test_set_crc_mode
    @stepper.expects(:do_it).with("\311\001\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_crc_mode(RNSchrittmotor::CRCON)
    @stepper.expects(:do_it).with("\311\000\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_crc_mode(RNSchrittmotor::CRCOFF)
  end

  def test_set_direction
    @stepper.expects(:do_it).with("4\001\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_direction(RNSchrittmotor::FIRST, RNSchrittmotor::LEFT)
    @stepper.expects(:do_it).with("4\001\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_direction(RNSchrittmotor::FIRST, RNSchrittmotor::CCW)
    @stepper.expects(:do_it).with("4\001\001\000\000\000").returns("*")
    assert_equal "*", @stepper.set_direction(RNSchrittmotor::FIRST, RNSchrittmotor::RIGHT)
    @stepper.expects(:do_it).with("4\001\001\000\000\000").returns("*")
    assert_equal "*", @stepper.set_direction(RNSchrittmotor::FIRST, RNSchrittmotor::CW)
  end

  def test_set_i2c_slave_id
    @stepper.expects(:do_it).with("\312\026\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_i2c_slave_id(22)
  end

  def test_steps_per_sec
     assert_equal 0, RNSchrittmotor.steps_per_sec(1000)
     assert_equal 1, RNSchrittmotor.steps_per_sec(500)
     assert_equal 250, RNSchrittmotor.steps_per_sec(3)
  end

  def test_set_speed
    @stepper.expects(:do_it).with("5\001\377\377\000\000").returns("*")
    assert_equal "*", @stepper.set_speed(RNSchrittmotor::FIRST, 255, 255)
    @stepper.expects(:do_it).with("5\001\004\005\000\000").returns("*")
    assert_equal "*", @stepper.set_speed(RNSchrittmotor::FIRST, RNSchrittmotor.steps_per_sec(200), 5)
  end

  def test_set_start_current
    @stepper.expects(:do_it).with("\x0a\001\b\a\000\000").returns("*")
    assert_equal "*", @stepper.set_holding_current(RNSchrittmotor::FIRST, 1800, RNSchrittmotor::FORGET)
  end

  def test_set_stepper_current
    @stepper.expects(:do_it).with("\x0b\001\350\003\000\000").returns("*")
    assert_equal "*", @stepper.set_holding_current(RNSchrittmotor::FIRST, 1000, RNSchrittmotor::FORGET)
  end

  def test_set_holding_current
    @stepper.expects(:do_it).with("\x0c\001\334\005\000\000").returns("*")
    assert_equal "*", @stepper.set_holding_current(RNSchrittmotor::FIRST, 100, RNSchrittmotor::FORGET)
    @stepper.expects(:do_it).with("\x0c\001\334\005\001\000").returns("*")
    assert_equal "*", @stepper.set_holding_current(RNSchrittmotor::FIRST, 100, RNSchrittmotor::PERSIST)
  end

  def test_set_stepping_mode
    @stepper.expects(:do_it).with("").returns("*")
    assert_equal "*", @stepper.set_stepping_mode
  end

  def test_step!
    @stepper.expects(:do_it).with("").returns("*")
    assert_equal "*", @stepper.step!
  end

  def test_switch_off!
    @stepper.expects(:do_it).with("").returns("*")
    assert_equal "*", @stepper.switch_off!
  end

  def test_switch_on!
    @stepper.expects(:do_it).with("").returns("*")
    assert_equal "*", @stepper.switch_on!()
  end
end

