Event_ChannelCreate = lambda { |vars|
  vars[:bot].channel_create { |event|
    unless event.server.nil?
      if event.channel.name.start_with?("ticket-")
        sleep(5)
        ticket_message = event.channel.history(1).first
        userid = ticket_message.embeds[0].description.match(/<@(\d+)>/)[1]
        nickname = ticket_message.embeds[1].description.split("\n")[1].match(/```(\w+)```/)[1].gsub(" ", "")

        vars[:database].add_ticket(event.channel.id, userid.to_i, nickname.to_s)
      end
    end
  }
}
