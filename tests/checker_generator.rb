# frozen_string_literal: true

def red(msg)
  "\e[31m#{msg}\e[0m"
end

def green(msg)
  "\e[32m#{msg}\e[0m"
end

class VeredictChecker # rubocop:disable Style/Documentation
  def initialize
    @veredict = true
    @err_msgs = []
  end

  def good_veredict?
    print "\n"
    @veredict
  end

  def err_msg
    @err_msgs.to_s
  end

  def append(veredict, err_msg)
    if veredict
      print(green('.'))
    else
      print(red('.'))
    end
    @err_msgs.append(err_msg) unless veredict
    @veredict &&= veredict
  end
end

def check_error(err, veredict_checker)
  return unless err

  puts "err: #{err}"
  veredict_checker.append(false, err)
end

def check_val(val, check_fn, veredict_checker)
  return unless val

  is_good_val = check_fn.call(val)
  puts "bad value: #{val}" unless is_good_val
  veredict_checker.append(is_good_val, val)
end

def check_list(val_list, check_fn, veredict_checker)
  val_list.each { |val| check_val(val, check_fn, veredict_checker) }
end

def check_hash(hash, check_fn, veredict_checker)
  hash.each_value { |val| check_val(val, check_fn, veredict_checker) }
end

def check_hash_list(hash, check_fn, veredict_checker)
  hash.each_value { |val_list| check_list(val_list, check_fn, veredict_checker) }
end

def gen_result_callback(veredict_checker)
  ->(err, _result) { check_error(err, veredict_checker) }
end

def gen_check_result_callback(check_fn, veredict_checker)
  lambda { |err, result|
    check_error(err, veredict_checker)
    check_val(result, check_fn, veredict_checker)
  }
end

def gen_check_result_list_callback(check_fn, veredict_checker)
  lambda { |err, result|
    check_error(err, veredict_checker)
    check_list(result, check_fn, veredict_checker)
  }
end

def gen_check_notification_w_n_type_callback(check_fn, veredict_checker)
  ->(notification, _notification_type) { check_val(notification, check_fn, veredict_checker) }
end

def gen_check_notification_list_callback(check_fn, veredict_checker)
  ->(notification) { check_list(notification, check_fn, veredict_checker) }
end

def |(check_fn, veredict_checker)
  ->(notification, _notification_type) { check_list(notification, check_fn, veredict_checker) }
end

def gen_check_notification_hash_list_callback(check_fn, veredict_checker)
  ->(notification, _notification_type) { check_hash_list(notification, check_fn, veredict_checker) }
end

def gen_check_notification_hash_callback(check_fn, veredict_checker)
  ->(notification, _notification_type) { check_hash(notification, check_fn, veredict_checker) }
end

def gen_check_notification_list_w_n_type_callback(check_fn, veredict_checker)
  ->(notification, _notification_type) { check_list(notification, check_fn, veredict_checker) }
end
