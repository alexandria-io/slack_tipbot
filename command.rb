require 'bitcoin-client'
Dir['./coin_config/*.rb'].each {|file| require file }
require './bitcoin_client_extensions.rb'

class Command
  attr_accessor :result, :action, :user_name, :icon_emoji
  ACTIONS = %w(balance deposit tip withdraw networkinfo commands checkChannel)
  def initialize(slack_params)
    @coin_config_module = Kernel.const_get ENV['COIN'].capitalize
    text = slack_params['text']
    @params = text.split(/\s+/)
    raise "WACK" unless @params.shift == slack_params['trigger_word']
    @user_name = slack_params['user_name']
    @user_id = slack_params['user_id']
    @channel_name = slack_params['channel_name']
    @action = @params.shift
    @result = {}
  end

  def perform
    if ACTIONS.include?(@action)
      self.send("#{@action}".to_sym)
    else
      raise @coin_config_module::PERFORM_ERROR
    end
  end

  def client
    @client ||= Bitcoin::Client.local
  end

### Commands ###
  def checkChannel
    @result[:text] = "Talking in #{@channel_name} \n"
    if allCommandAllowed 
       @result[:text] += "All tipper commands are allowed."
    else
       @result[:text] += @coin_config_module::RESTRICED_CMDS_MESSAGE
    end
  end

  def balance
    if allCommandAllowed
      balance = client.getbalance(@user_id)
      @result[:text] = "@#{@user_name} #{@coin_config_module::BALANCE_REPLY_PRETEXT} #{balance}#{@coin_config_module::CURRENCY_ICON}"
      if balance >= @coin_config_module::WEALTHY_UPPER_BOUND
        @result[:text] += @coin_config_module::WEALTHY_UPPER_BOUND_POSTTEXT
        @result[:icon_emoji] = @coin_config_module::WEALTHY_UPPER_BOUND_EMOJI
      elsif balance > 0 && balance < @coin_config_module::WEALTHY_UPPER_BOUND
        @result[:text] += @coin_config_module::BALANCE_REPLY_POSTTEXT
      end
    else
       @result[:text] = @coin_config_module::RESTRICED_CMDS_MESSAGE
    end 
  end

  def deposit
    if allCommandAllowed
      @result[:text] = "#{@coin_config_module::DEPOSIT_PRETEXT} #{user_address(@user_id)} #{@coin_config_module::DEPOSIT_POSTTEXT}"
    else
       @result[:text] = @coin_config_module::RESTRICED_CMDS_MESSAGE
    end  
  end

  def tip
    user = @params.shift
    raise @coin_config_module::TIP_ERROR_TEXT unless user =~ /<@(U.+)>/
    target_user = $1
    set_amount

    tx = client.sendfrom @user_id, user_address(target_user), @amount
    @result[:text] = "<@#{@user_id}> sent <@#{target_user}> #{@amount}#{@coin_config_module::CURRENCY_ICON}"
#    @result[:text] = "#{@coin_config_module::TIP_PRETEXT} <@#{@user_id}> => <@#{target_user}> #{@amount}#{@coin_config_module::CURRENCY_ICON}"
#    @result[:attachments] = [{
#      fallback:"<@#{@user_id}> => <@#{target_user}> #{@amount}Ð",
#      color: "good",
#      fields: [
#      {
#        title: "such tipping #{@amount}Ð wow!",
#        value: "#{@coin_config_module::TIP_POSTTEXT1}#{tx}",
#        short: true
#      },
#       {
#        title: "#{@coin_config_module::TITLE_TIPPER}",
#        value: "<@#{@user_id}>",
#        short: true
#      },{
#        title: "#{@coin_config_module::TITLE_TIP_RECIEVER}",
#        value: "<@#{target_user}>",
#        short: true
#      }]
#    }] 

    @result[:text] += " (<#{@coin_config_module::TIP_POSTTEXT1}#{tx}.htm#{@coin_config_module::TIP_POSTTEXT2}>)"
  end

  def withdraw
    if allCommandAllowed
      address = @params.shift
      set_amount
      tx = client.sendfrom @user_id, address, @amount
      @result[:text] = "#{@coin_config_module::WITHDRAW_TEXT} <@#{@user_id}> => #{address} #{@amount}#{@coin_config_module::CURRENCY_ICON} "
      @result[:text] += " (<#{@coin_config_module::TIP_POSTTEXT1}#{tx}#{@coin_config_module::TIP_POSTTEXT2}>)"
      @result[:icon_emoji] = @coin_config_module::WITHDRAW_ICON
    else
       @result[:text] = @coin_config_module::RESTRICED_CMDS_MESSAGE
    end  
end

### no command, internal functions ###
  def networkinfo
    info = client.getinfo
    @result[:text] = info.to_s
    @result[:icon_emoji] = @coin_config_module::NETWORKINFO_ICON
  end

  private

  def allCommandAllowed
    if @channel_name != @coin_config_module::ALLOW_ALL_CMDS_CHANNEL
      return false
    else
      return true
    end
  end

  def set_amount
    amount = @params.shift
    @amount = amount.to_f
    randomize_amount if (@amount == "random")

    raise @coin_config_module::TOO_POOR_TEXT unless available_balance >= @amount + 0.0001  # transaction cost need also be availibe
    raise @coin_config_module::NO_PURPOSE_LOWER_BOUND_TEXT if @amount < @coin_config_module::NO_PURPOSE_LOWER_BOUND
  end

  def randomize_amount
    lower = [1, @params.shift.to_i].min
    upper = [@params.shift.to_i, available_balance].max
    @amount = rand(lower..upper)
    @result[:icon_emoji] = @coin_config_module::RANDOMIZED_EMOJI
  end

  def available_balance
     client.getbalance(@user_id)
  end

  def user_address(user_id)
     existing = client.getaddressesbyaccount(user_id)
    if (existing.size > 0)
      @address = existing.first
    else
      @address = client.getnewaddress(user_id)
    end
  end

  def commands
    
    @result[:text] = "#{ACTIONS.join(', ' )}"
  end

end
