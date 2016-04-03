module Dash
  PERFORM_ERROR = 'Even I have no idea what I mean by that. That error doesn\'t exist'
  BALANCE_REPLY_PRETEXT = 'Your tip jar contains: '
  CURRENCY_ICON = 'Ð'
  WEALTHY_UPPER_BOUND = 2
  WEALTHY_UPPER_BOUND_POSTTEXT = ' your tip jar is filling up. Consider withdraw some Dash to your wallet.'
  WEALTHY_UPPER_BOUND_EMOJI = ':moneybag:'
  BALANCE_REPLY_POSTTEXT = ' to tip'
  DEPOSIT_PRETEXT = 'Make a deposit'
  DEPOSIT_POSTTEXT = 'this is your address'
  TIP_ERROR_TEXT = 'pls say tip @username amount'
  TIP_PRETEXT = 'So generous!'
  TIP_POSTTEXT1 = 'https://chainz.cryptoid.info/dash/tx.dws?'
  TIP_POSTTEXT2 = '| view on blockchain'
  WITHDRAW_TEXT = 'You\'re stingy'
  WITHDRAW_ICON = ':money_with_wings:'
  NETWORKINFO_ICON = ':bar_chart:'
  TOO_POOR_TEXT = 'Too poor, add some Dash to the tipbot.'
  NO_PURPOSE_LOWER_BOUND_TEXT = 'Too small. No purpose'
  NO_PURPOSE_LOWER_BOUND = 0.001
  RANDOMIZED_EMOJI = ':black_joker:'
  NETWORK = 'Dash'
  TITLE_TIPPER = 'generous Dash user'
  TITLE_TIP_RECIEVER = 'lucky Dash user'
  ALLOW_ALL_CMDS_CHANNEL = 'tipbot'
  RESTRICED_CMDS_MESSAGE = "Only 'tip' command is allowed here.\n Go to the  ##{@coin_config_module::ALLOW_ALL_CMDS_CHANNEL} channel to use other tipper commands."
end
