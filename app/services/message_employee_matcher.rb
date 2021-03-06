require "business_time"

class MessageEmployeeMatcher
  def initialize(message)
    @message = message
  end

  def run
    retrieve_matching_employees
  end

  private

  attr_reader :message

  def retrieve_matching_employees
    Employee.where(started_on: day_count.business_days.ago).select do |employee|
      time_to_send_message?(employee.time_zone) && message_not_already_sent?(employee)
    end
  end

  def day_count
    message.days_after_start
  end

  def time_to_send_message?(time_zone)
    employee_current_time = Time.current.in_time_zone(time_zone)

    if employee_current_time.day == Time.current.day
      employee_current_time_value = employee_current_time.strftime("%H%M").to_i
      message_time_value = message.time_of_day.strftime("%H%M").to_i

      employee_current_time_value >= message_time_value
    else
      false
    end
  end

  def message_not_already_sent?(employee)
    SentScheduledMessage.where(employee: employee, scheduled_message: message).count == 0
  end
end
