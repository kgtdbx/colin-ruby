require File.join(File.dirname(__FILE__),'helper')


def get_same_group_index_arr(origin_index)
  base_index = origin_index/3 *3
  [0,1,2].map {|x| x+base_index}
end
def compute_group_index(x_index,y_index)
  x_index/3*3+y_index/3
end
def exist_value?(value)
  value_i = value.to_i
  value_i > 0 and value_i < 10
end
def computer_exlude_x_points(possible_value, x_index, y_index, unshow_values)
  x_index_arr = get_same_group_index_arr(x_index)
  x_index_arr.delete(x_index)
  x_index_arr.delete_if do |index|
    unshow_values[index].include?(possible_value)
  end
  y_index_arr = get_same_group_index_arr(y_index)
  x_index_arr.product(y_index_arr)
end
def computer_exlude_y_points(possible_value, x_index, y_index,  unshow_values)
  y_index_arr = get_same_group_index_arr(y_index)
  y_index_arr.delete(y_index)
  y_index_arr.delete_if do |index|
    unshow_values[index].include?(possible_value)
  end
  x_index_arr = get_same_group_index_arr(x_index)
  x_index_arr.product(y_index_arr)
end

class NineSquare
  @@answer_count=0
  @@answer_iteration_count=0
  def initialize(start_arr)
    @unshow_values_by_x_arr = get_arr_9_9
    @unshow_values_by_y_arr = get_arr_9_9
    @unshow_values_by_group_arr = get_arr_9_9
    @result_map = {}
    @empty_points_arr = []
    @group_null_point_arr = get_arr_9.map {[]}
    start_arr.each_with_index do |sub_arr,y_index|
      sub_arr.each_with_index do |value,x_index|
        group_index = compute_group_index(x_index,y_index)
        if exist_value?(value)
          set_value(value, x_index, y_index, group_index)
        else
          @empty_points_arr << [x_index,y_index,group_index]
          @group_null_point_arr[group_index] << [x_index,y_index]
        end
      end    
    end
  end
  def perform
    @result_map = answer()
    self
  end
  def show_result_map()
    9.times do |row_index|
      9.times do |col_index|
        value = @result_map[[row_index,col_index]]
        value ||= 0
        printf(" #{value},")
      end
      puts ""
    end
    self
  end
  private
  def set_value(value, x_index, y_index, group_index)
    @result_map[[x_index,y_index]]=value
    @unshow_values_by_x_arr[x_index].delete(value)
    @unshow_values_by_y_arr[y_index].delete(value)
    @unshow_values_by_group_arr[group_index].delete(value)
    @group_null_point_arr[group_index].delete([x_index,y_index])
    value
  end
  def answer()
    del_arr = []
    method_name = ""
    @empty_points_arr.each do |x_index,y_index,group_index|
      possible_values = get_possible_values(x_index,y_index,group_index)
      if possible_values.size == 1
        method_name = 'get_possible_values'
      end
      if possible_values.size > 1
        subset_values = exlude_by_other_row_col(possible_values,x_index,y_index,group_index)
        if (subset_values.size > 1)
          puts "logic error"
          exit
        end
        possible_values = subset_values
        if possible_values.size == 1
          method_name = 'exlude_by_other_row_col'
        end
      end
      if possible_values.size == 1
        value = possible_values.first
        set_value(value, x_index, y_index, group_index)
        del_arr << [x_index,y_index,group_index]
        @@answer_count += 1
        puts "NO:#{@@answer_count} value: #{value} has added at (#{x_index},#{y_index}) by #{method_name} in #{@@answer_iteration_count+1} iteration."
      end
    end
    @@answer_iteration_count += 1
    if del_arr.size == 0
      p "I cannot deal with this situation!"
      p "@@answer_iteration_count:", @@answer_iteration_count
      p "@@answer_count:", @@answer_count
      p "@empty_points_arr:", @empty_points_arr
      return @result_map
    end
    @empty_points_arr -= del_arr
    if @empty_points_arr.size > 0
      answer()
    end
    @result_map
  end
  def guess(guess_point_map,result_map, empty_points_arr, 
    unshow_values_by_x_arr, unshow_values_by_y_arr, unshow_values_by_group_arr, 
    group_null_point_arr)
    guessed_result_arr = []
    guess_point_map[:possible_value].each do |possible_value|
      next_result_map, next_empty_points_arr, 
          next_unshow_values_by_x_arr, next_unshow_values_by_y_arr, next_unshow_values_by_group_arr, 
          next_group_null_point_arr = copy_object(result_map, empty_points_arr, 
          unshow_values_by_x_arr, unshow_values_by_y_arr, unshow_values_by_group_arr, 
          group_null_point_arr)
      x_index, y_index, group_index = guess_point_map[:index]
      set_value(result_map,possible_value, x_index, y_index, group_index, 
          next_unshow_values_by_x_arr, next_unshow_values_by_y_arr, next_unshow_values_by_group_arr, 
          next_group_null_point_arr)
      answer_flag, next_guess_point_map, next_result_map = answer(next_result_map, next_empty_points_arr, 
          next_unshow_values_by_x_arr, next_unshow_values_by_y_arr, next_unshow_values_by_group_arr, 
          next_group_null_point_arr)
      if answer_flag == 'logic error'
        puts "logic error"
      elsif answer_flag == 'need guess'
        guessed_result_arr += guess(next_guess_point_map,next_result_map, next_empty_points_arr, 
            next_unshow_values_by_x_arr, next_unshow_values_by_y_arr, next_unshow_values_by_group_arr, 
            next_group_null_point_arr)
      elsif answer_flag=='answered'
        guessed_result_arr << result_map
      end
    end
    guessed_result_arr
  end
  
  def get_possible_values(x_index,y_index,group_index)
    @unshow_values_by_x_arr[x_index] & @unshow_values_by_y_arr[y_index] & 
      @unshow_values_by_group_arr[group_index]
  end
  def exlude_by_other_row_col(possible_values,x_index,y_index,group_index)
    result_values = []
    possible_values.each do |possible_value|
      current_group_null_points = @group_null_point_arr[group_index]
      exlude_row_points = computer_exlude_x_points(possible_value, x_index, y_index, @unshow_values_by_x_arr)
      exlude_col_points = computer_exlude_y_points(possible_value, x_index, y_index, @unshow_values_by_y_arr)
      remain_points = current_group_null_points - 
          exlude_row_points - exlude_col_points
      if remain_points.size == 1
        result_values << possible_value
      end
    end
    result_values
  end
end
start_arr = [
  %w(0 0 0 0 9 8 0 2 0),
  %w(0 0 0 2 0 0 1 0 4),
  %w(0 0 0 0 0 6 5 0 0),
  %w(6 0 0 0 4 0 0 9 0),
  %w(0 0 0 8 0 3 6 0 0),
  %w(4 0 0 0 0 0 0 0 0),
  %w(7 0 9 3 2 0 0 0 5),
  %w(0 0 1 0 0 7 0 0 0),
  %w(0 2 0 0 0 0 7 0 0)
]  

NineSquare.new(start_arr).perform().show_result_map()
p "ok"
