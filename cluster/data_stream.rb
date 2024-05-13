class DataStream

  def initialize(filepath)
    @file = File.new(filepath)
    @sets = Hash.new {|h, id| h[id] = Array.new}
  end


  def each(&block)
    read_next_record_set
    while (@id != nil) do
      yield [@id, @current_records]
      read_next_record_set
    end
  end


  private


  def read_next_record_set
    while (!@file.eof? && @sets.size < 2) do
      current_record = @file.readline.strip.split("\t")
      @sets[current_record[0]] << JSON.parse(current_record[1])
    end

    @id              = @sets.keys.sort.first
    @current_records = @sets.delete(@id)
  end

end
