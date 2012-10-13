module TableLogic
  DEFAULT_TABLE_SIZE = 6

  def each_in_tables(table_size=DEFAULT_TABLE_SIZE, &block)
    num_tables        = [1, (size.to_f / table_size).ceil].max
    
    e = Enumerator.new do |yielder|
      self.each_with_index
          .group_by { |(p, i)| i % num_tables }
          .each do |table_num, list|
        yielder << list.map(&:first)        
      end
      self
    end

    block_given? ? e.each(&block) : e
  end
end
