require 'prawn'
require 'prawn/table'

def display_menu
  puts "Select an option:"
  puts "1. Generate equations"
  puts "2. Download PDF"
  puts "3. Exit"
end

def generate_equations(num)
  equations = Array.new
  num.times do
    a = rand(0..10)
    b = rand(0..10)
    equations << "#{a} x #{b} = ..."
  end
  equations
end

def display_equations_table(equations)
  columns = (equations.size / 25.0).ceil
  rows = [25, equations.size].min

  yield "=" * (columns * 20), :puts
  columns.times { |col| yield "| Column #{col + 1} ".ljust(20), :print }
  yield "|", :puts
  yield "=" * (columns * 20), :puts

  rows.times do |row|
    columns.times do |col|
      index = col * 25 + row
      yield "| #{equations[index]} ".ljust(20), :print if equations[index]
    end
    yield "|", :puts
  end
  yield "=" * (columns * 20), :puts
end

def generate_pdf(equations)
  Prawn::Document.generate("equations.pdf") do |pdf|
    pdf.font_size 9
    pdf.move_down 10
    
    total_columns = (equations.size / 25.0).ceil
    columns_per_page = 10
    rows_per_column = 25
    
    equations.each_slice(columns_per_page * rows_per_column).with_index do |chunk, page_index|
      table_data = Array.new(rows_per_column) { Array.new(columns_per_page) }

      chunk.each_with_index do |equation, index|
        row = index % rows_per_column
        col = (index / rows_per_column)
        table_data[row][col] = equation
      end

      headers = (1..columns_per_page).map { |i| "Column #{i + page_index * columns_per_page}" }
      table_data.unshift(headers)

      pdf.table(table_data, header: true, cell_style: { inline_format: true })
      pdf.start_new_page unless chunk.size < columns_per_page * rows_per_column
    end
  end
  puts "PDF file generated successfully!"
end

loop do
  display_menu
  choice = gets.chomp.to_i
  
  case choice
  when 1
    puts "Enter the number of equations to generate:"
    num = gets.chomp.to_i
    @equations = generate_equations(num)
    display_equations_table(@equations) { |line, method| 
      if method == :puts
        puts line
      elsif method == :print
        print line
      end
    }
  when 2
    if @equations.nil? || @equations.empty?
      puts "No equations generated yet. Please generate equations first."
    else
      generate_pdf(@equations)
    end
  when 3
    puts "Goodbye!"
    break
  else
    puts "Invalid choice. Please try again."
  end
end
