Dir["./src/events/*.rb"].each { |file| require file }

module EventHandler
  Events = [
    Event_ChannelCreate,
    Event_ChannelDelete,
  ]

  def self.init_events(vars)
    Events.each { |event|
      event.call(vars)
    }
    vars[:logger].info "События загружены"
  end
end
