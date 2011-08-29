CUSTOM_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/custom_config.yml")[RAILS_ENV]

#recaptcha keys
ENV['RECAPTCHA_PUBLIC_KEY']  = '6LfRB7oSAAAAAOd1eWofXkoghEPv8h7D49Hw6QIS'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LfRB7oSAAAAALewA_omNEU_4kJm810F1RYnxFyb'

payment_window_logfile = File.open("#{RAILS_ROOT}/log/payment_window.log", 'a')
payment_window_logfile.sync = true
ORDER_PROGRESS_LOG = PaymentWindowLogger.new(payment_window_logfile)