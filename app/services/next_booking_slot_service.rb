class NextBookingSlotService
  def initialize(booking, days_from_now)
    @booking = booking
    @days_from_now = days_from_now
  end

  def call
    occurrences = []

    case @booking.frequency
    when 'once'
      return @booking.start_at >= DateTime.now.utc ? [@booking.start_at] : []
    when 'once_a_week'
      multiplier = 7
    when 'twice_a_week'
      if @booking.offset == 0
        return []
      end
      multiplier = [@booking.offset, 7 - @booking.offset]
    when 'once_every_two_weeks'
      multiplier = 14
    end

    next_date = @booking.start_at
    days_from_now_date = DateTime.now.utc + @days_from_now.days
    count = 0
    while next_date < days_from_now_date
      occurrences << next_date if next_date >= DateTime.now.utc
      next_date += multiplier.days if multiplier.is_a? Integer

      #if even, same week, odd, add
      if multiplier.is_a? Array
        if count %2 == 0
          next_date += multiplier[0].days
        else
          next_date += multiplier[1].days
        end
      end
      count += 1
    end

    occurrences
  end
end